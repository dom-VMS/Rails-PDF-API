class InertFinalBakesheet < VarlandPdf

  BACKGROUND_COLORS = ['7be042',
                       'ff657f',
                       '9cb5f2',
                       'ffc72d',
                       'b677ff',
                       '73fdff']
  LIGHT_GRAY = 'dddddd'
  SOAK_BACKGROUND = 'eeeeee'
  DEFAULT_LAYOUT = :portrait
  VALIDATION_REGEX = '^\{"trays":\[(\{"so":[\d]+,"load":[\d]+,"customer":' +
                     '"[\w]*","process":"[\w]*","part":"[\w]*","sub":"[\w]*"' +
                     ',"set":[\d]+,"min":[\d]+,"max":[\d]+,"length":[\d]+,' +
                     '"profile":"[\w]*"\},?){18}\],"timestamps":\{("(' +
                     'cycle_started|purge_ended|soak_started|soak_ended|' +
                     'gas_off)":"[\d\-T:]+",?){5}\},"status_readings":\[(\{' +
                     '"air":\d+,"parts":\d+,"pressure":[\d\.]+,"timestamp":' +
                     '"[\d\-T:]+"\},?)+\]\}$'
		PARTS_COLOR = '3a8eed'
		AIR_COLOR = 'f26077'
		PRESSURE_COLOR = '68bc36'
		GAS_COLOR = '9662d0'
		PURGE_COLOR = 'ff914d'
		COOLING_COLOR = '00bfc0'
		LEGEND_COLORS = [[PARTS_COLOR, AIR_COLOR, PRESSURE_COLOR],
		                 [GAS_COLOR, PURGE_COLOR, COOLING_COLOR]]

  def initialize(data)
    super()
    @data = data
    single_line_controlled_form_header "Inert Atmosphere Oven Final Bakesheet",
                                       "08/22/17",
                                       "JP"
    font "Whitney"
    if is_valid?
      parse_data
      # print_title
      draw_graph
      print_timestamps
      draw_orders_table
      draw_tray_loadings
    else
      move_down 18
      print_error "Cannot generate bakesheet – invalid data given"
    end
  end

  def is_valid?
    regex = Regexp.new(VALIDATION_REGEX)
    return !regex.match(@data).nil?
  end

  def parse_data
    pieces = JSON.parse(@data).symbolize_keys
    @trays = pieces[:trays]
    @trays.each do |t|
      t.symbolize_keys!
    end
    @shop_orders = @trays.collect{|t| t[:so]}.uniq.sort - [0]
    @tstamps = pieces[:timestamps].symbolize_keys
    [:cycle_started,
     :purge_ended,
     :soak_started,
     :soak_ended,
     :gas_off].each do |symbol|
      @tstamps[symbol] = DateTime.parse(@tstamps[symbol])
    end
    @status_readings = pieces[:status_readings]
    @status_readings.each do |s|
      s.symbolize_keys!
      s[:timestamp] = DateTime.parse(s[:timestamp])
    end
  end

  def round_datetime_to(timestamp, granularity=30.minutes)
    Time.at((timestamp.to_time.to_i/granularity).round * granularity).to_datetime
  end

  def round_datetime_down(timestamp, granularity=30.minutes)
    rounded = round_datetime_to timestamp
    if rounded > timestamp
      return Time.at(rounded.to_time - granularity).to_datetime
    else
      return rounded
    end
  end

  def round_datetime_up(timestamp, granularity=30.minutes)
    rounded = round_datetime_to timestamp
    if rounded > timestamp
      return rounded
    else
      return Time.at(rounded.to_time + granularity).to_datetime
    end
  end

  def calculate_time_percentage(timestamp)
    return 0 if timestamp < @chart_start
    return 0 if timestamp > @chart_end
    total_range = @chart_end.to_i - @chart_start.to_i
    seconds_from_start = timestamp.to_i - @chart_start.to_i
    percentage = seconds_from_start.to_f / total_range
    return percentage
  end

  def draw_graph

    # Find chart time ranges.
    @chart_start = round_datetime_down @status_readings[0][:timestamp]
    @chart_end = round_datetime_up @status_readings[-1][:timestamp]

    # Find percentages.
    cycle_started_pctg = calculate_time_percentage @tstamps[:cycle_started]
    purge_ended_pctg = calculate_time_percentage @tstamps[:purge_ended]
    soak_started_pctg = calculate_time_percentage @tstamps[:soak_started]
    soak_ended_pctg = calculate_time_percentage @tstamps[:soak_ended]
    gas_off_pctg = calculate_time_percentage @tstamps[:gas_off]

    # Chart properties.
    chart_width = 5.25
    chart_height = 0.375 * 10

    # Draw bounding box for legend.
    bounding_box([_i(0.5), bounds.height - _i(0.75)],
                 :width => _i(chart_width),
                 :height => _i(0.25)) do

      rows = []
      rows << ["● PARTS TEMPERATURE",
               "● AIR TEMPERATURE",
               "● CHAMBER PRESSURE"]
      rows << ["● GAS",
               "● PURGE",
               "● COOLING"]

      table(rows) do |t|
        t.cells.padding = 0
        t.position = :left
        t.cells.style do |c|
          c.text_color = LEGEND_COLORS[c.row][c.column]
          c.size = 7
          c.inline_format = true
          c.border_width = 0
          c.overflow = :shrink_to_fit
          c.align = :left
          c.valign = :top
          c.font_style = :bold
        end
      end

    end

    # Draw bounding box for left y axis.
    bounding_box([0, bounds.height - _i(1) + _i(0.125)],
                 :width => _i(0.5),
                 :height => _i(chart_height) + _i(0.25)) do

      # Draw bottom value.
      text_box "0° F",
               :overflow  =>  :shrink_to_fit,
               :valign    =>  :top,
               :size      =>  7,
               :style     =>  :bold,
               :align     =>  :right,
               :at        =>  [0, 12],
               :width     =>  _i(0.455)

      # Draw other labels.
      y = 12
      y_increment = chart_height / 10
      value_increment = 100
      value = 0
      1.upto(10) do
        value += value_increment
        y += _i(y_increment)
        text_box "#{value}° F",
                 :overflow  =>  :shrink_to_fit,
                 :valign    =>  :top,
                 :size      =>  7,
                 :style     =>  :bold,
                 :align     =>  :right,
                 :inline_format =>  true,
                 :at        =>  [0, y],
                 :width     =>  _i(0.455)
      end

    end

    # Draw bounding box for right y axis.
    bounding_box([_i(5.75), bounds.height - _i(1) + _i(0.125)],
                 :width => _i(0.5),
                 :height => _i(chart_height) + _i(0.25)) do

      # Draw bottom value.
      text_box "0″ H<sub>2</sub>O",
               :overflow  =>  :shrink_to_fit,
               :valign    =>  :top,
               :size      =>  7,
               :style     =>  :bold,
               :align     =>  :left,
               :inline_format =>  true,
               :at        =>  [_i(0.045), 12],
               :width     =>  _i(0.455)

      # Draw other labels.
      y = 12
      y_increment = chart_height / 10
      value_increment = 0.5
      value = 0
      1.upto(10) do
        value += value_increment
        y += _i(y_increment)
        text_box "#{value}″ H<sub>2</sub>O",
                 :overflow  =>  :shrink_to_fit,
                 :valign    =>  :top,
                 :size      =>  7,
                 :style     =>  :bold,
                 :align     =>  :left,
                 :inline_format =>  true,
                 :at        =>  [_i(0.045), y],
                 :width     =>  _i(0.455)
      end

    end

    # Draw bounding box for chart.
    bounding_box([_i(0.5), bounds.height - _i(1)],
                 :width => _i(chart_width),
                 :height => _i(chart_height)) do

      # Draw soak background.
      width = chart_width * (soak_ended_pctg - soak_started_pctg)
      x = soak_started_pctg * chart_width
      fill_color SOAK_BACKGROUND
      fill_rectangle [_i(x), _i(chart_height)], _i(width), _i(chart_height)
      fill_color '000000'

      # Draw horizontal gridlines.
      y = 0
      1.upto(10).each do |i|
        y += _i(chart_height / 10)
        stroke_color LIGHT_GRAY
        stroke_line [0, y], [_i(chart_width), y]
        stroke_color '000000'
      end

      # Draw vertical gridlines.
      total_range = @chart_end.to_i - @chart_start.to_i
      x_increment = 1800
      count_increments = total_range / x_increment
      while count_increments > 15 do
        x_increment *= 2
        count_increments = total_range / x_increment
      end
      x = 0
      1.upto(count_increments).each do |i|
        x += _i(chart_width / count_increments)
        stroke_color LIGHT_GRAY
        stroke_line [x, 0], [x, _i(chart_height)]
        stroke_color '000000'
      end

      # Plot values.
      @status_readings.each do |s|
        percentage_x = calculate_time_percentage s[:timestamp]
        air_percentage_y = s[:air] / 1000.0
        parts_percentage_y = s[:parts] / 1000.0
        pressure_percentage_y = s[:pressure] / 5.0
        fill_color AIR_COLOR
        fill_circle [_i(percentage_x * chart_width),
                     _i(air_percentage_y * chart_height)], 2.5
        fill_color PARTS_COLOR
        fill_circle [_i(percentage_x * chart_width),
                     _i(parts_percentage_y * chart_height)], 3
        fill_color PRESSURE_COLOR
        fill_circle [_i(percentage_x * chart_width),
                     _i(pressure_percentage_y * chart_height)], 1
      end
      fill_color '000000'

      # Draw chart border.
      stroke_bounds

    end

    # Draw bar charts.
    bar_chart_height = 0.125
    bar_chart_width = chart_width
    bar_chart_x = 0.5
    y = bounds.height - _i(4.75)
    bounding_box([_i(bar_chart_x), y],
                 :width => _i(bar_chart_width),
                 :height => _i(bar_chart_height)) do

      # Draw gas chart.
      width = bar_chart_width * (gas_off_pctg - cycle_started_pctg)
      x = cycle_started_pctg * bar_chart_width
      fill_color GAS_COLOR
      fill_rectangle [_i(x), _i(bar_chart_height)], _i(width), _i(bar_chart_height)
      fill_color '000000'
      stroke_bounds

    end
    y -= _i(bar_chart_height)
    bounding_box([_i(bar_chart_x), y],
                 :width => _i(bar_chart_width),
                 :height => _i(bar_chart_height)) do

      # Draw purge chart.
      width = bar_chart_width * (purge_ended_pctg - cycle_started_pctg)
      x = cycle_started_pctg * bar_chart_width
      fill_color PURGE_COLOR
      fill_rectangle [_i(x), _i(bar_chart_height)], _i(width), _i(bar_chart_height)
      fill_color '000000'
      stroke_bounds

    end
    y -= _i(bar_chart_height)
    bounding_box([_i(bar_chart_x), y],
                 :width => _i(bar_chart_width),
                 :height => _i(bar_chart_height)) do

      # Draw cooling chart.
      width = bar_chart_width * (gas_off_pctg - soak_ended_pctg)
      x = soak_ended_pctg * bar_chart_width
      fill_color COOLING_COLOR
      fill_rectangle [_i(x), _i(bar_chart_height)], _i(width), _i(bar_chart_height)
      fill_color '000000'
      stroke_bounds

    end
    y -= _i(bar_chart_height)

    # Draw bounding box for x axis.
    bounding_box([_i(0.5), y],
                 :width => _i(chart_width),
                 :height => _i(1)) do

      # Draw first value.
      vertical_text_box @chart_start.strftime('%m/%d/%y %l:%M %P'),
                        :overflow  =>  :shrink_to_fit,
                        :valign    =>  :middle,
                        :size      =>  7,
                        :style     =>  :bold,
                        :align     =>  :right,
                        :inline_format =>  true,
                        :at        =>  [0, 7],
                        :width     =>  _i(0.95),
                        :height    =>  7

      # Draw other values.
      total_range = @chart_end.to_i - @chart_start.to_i
      value_increment = 1800
      count_increments = total_range / value_increment
      while count_increments > 15 do
        value_increment *= 2
        count_increments = total_range / value_increment
      end
      x = 0
      x_increment = chart_width / count_increments
      value = @chart_start
      1.upto(count_increments) do
        value += value_increment.seconds
        x += _i(x_increment)
        vertical_text_box value.strftime('%m/%d/%y %l:%M %P'),
                          :overflow  =>  :shrink_to_fit,
                          :valign    =>  :middle,
                          :size      =>  7,
                          :style     =>  :bold,
                          :align     =>  :right,
                          :inline_format =>  true,
                          :at        =>  [x, 7],
                          :width     =>  _i(0.95),
                          :height    =>  7
      end

    end

  end

  def print_title
    text_box "INERT ATMOSPHERE OVEN FINAL BAKESHEET",
             :overflow  =>  :shrink_to_fit,
             :valign    =>  :top,
             :size      =>  18,
             :style     =>  :bold,
             :align     =>  :left
  end

  def print_timestamps

    # Draw bounding box.
    bounding_box([0, bounds.height - _i(6.35)],
                 :width => _i(6.75),
                 :height => _i(1.5)) do

      # Draw heading.
      text_box "BAKE CYCLE DETAILS",
               :height    =>  18,
               :width     =>  _i(6.75),
               :overflow  =>  :shrink_to_fit,
               :valign    =>  :top,
               :size      =>  12,
               :style     =>  :bold,
               :align     =>  :left

      move_down 18

      # Build table rows.
      time_format = "%m/%d/%Y %I:%M:%S %P";
      rows = []
      rows << ["Cycle Started:",
               @tstamps[:cycle_started].strftime(time_format)]
      rows << ["Purge Ended:",
               @tstamps[:purge_ended].strftime(time_format)]
      rows << ["Soak Started:",
               @tstamps[:soak_started].strftime(time_format)]
      rows << ["Soak Ended:",
               @tstamps[:soak_ended].strftime(time_format)]
      rows << ["Gas Off:",
               @tstamps[:gas_off].strftime(time_format)]

      # Draw table.
      table(rows) do |t|
        t.cells.padding = 3
        t.cells.padding_left = 0
        t.position = :left
        t.column_widths = [_i(0.875), _i(5.875)]
        t.cells.style do |c|
          c.size = 9
          c.inline_format = true
          c.border_width = 0
          c.overflow = :shrink_to_fit
          c.align = :left
          c.valign = :top
          if c.column > 0
            c.font_style = :bold
          end
        end
      end

    end

  end

  def draw_orders_table

    # Draw bounding box.
    bounding_box([0, bounds.height - _i(7.85)],
                 :width => _i(8),
                 :height => _i(3.25)) do

      # Draw heading.
      text_box "SHOP ORDER DETAILS",
               :height    =>  18,
               :width     =>  _i(8),
               :overflow  =>  :shrink_to_fit,
               :valign    =>  :top,
               :size      =>  12,
               :style     =>  :bold,
               :align     =>  :left

      move_down 18

      # Build table rows.
      rows = []
      rows << ["S.O. #",
               "CUSTOMER",
               "PROC",
               "PART ID",
               "BAKE CYCLE DETAILS"]
      @shop_orders.each do |so|
        customer = ""
        process = ""
        part = ""
        bake_cycle = ""
        @trays.each do |t|
          if t[:so] == so
            customer = t[:customer]
            process = t[:process]
            part = t[:part]
            unless t[:sub].blank?
              part += " (Sub: #{t[:sub]})"
            end
            bake_cycle = "#{t[:set]}° F (#{t[:min]}° F/#{t[:max]}° F)," +
                         " #{t[:length] / 60.0} HR"
            break
          end
        end
        rows << [so.to_s, customer, process, part, bake_cycle]
      end

      # Draw table.
      table(rows) do |t|
        t.cells.padding = 5
        t.position = :left
        t.column_widths = [_i(1),
                           _i(1),
                           _i(0.5),
                           _i(2),
                           _i(2.5)]
        t.cells.style do |c|
          c.size = 9
          c.inline_format = true
          c.border_width = 1
          c.overflow = :shrink_to_fit
          c.align = :center
          c.valign = :top
          if c.column >= 3
            c.align = :left
          end
          if c.row.zero?
            c.font_style = :bold
            c.background_color = LIGHT_GRAY
          end
        end
        t.before_rendering_page do |page|
          @shop_orders.each_with_index do |so, index|
            page.row(index + 1).background_color = BACKGROUND_COLORS[index]
          end
        end
      end

    end

  end

  def draw_tray_loadings

    shelf_width = 0.25
    tray_width = 0.75
    tray_height = 0.375
    shelf_height = tray_width + tray_height
    label_height = 0.25

    # Draw bounding box.
    bounding_box([bounds.width - _i(shelf_width + tray_width),
                  bounds.height - _i(0.75)],
                 :width => _i(shelf_width + tray_width),
                 :height => _i(label_height + 6 * shelf_height)) do

      # Draw heading.
      text_box "TRAY\nARRANGEMENT",
               :height    =>  _i(label_height),
               :width     =>  _i(shelf_width + tray_width),
               :overflow  =>  :shrink_to_fit,
               :valign    =>  :top,
               :size      =>  9,
               :style     =>  :bold,
               :align     =>  :center

      y = bounds.height - _i(label_height)
      6.times do |i|
        base = i * 3
        bounding_box([0, y],
                     :width => _i(shelf_width),
                     :height => _i(shelf_height)) do
          fill_color LIGHT_GRAY
          fill_rectangle [0, 0 + _i(shelf_height)],
                         _i(shelf_width),
                         _i(shelf_height)
          fill_color '000000'
          stroke_bounds
        end
        bounding_box([_i(shelf_width), y],
                     :width => _i(tray_height),
                     :height => _i(tray_width)) do
          unless @trays[base + 1][:so].zero?
            so_index = @shop_orders.index(@trays[base + 1][:so])
            fill_color BACKGROUND_COLORS[so_index]
            fill_rectangle [0, 0 + _i(tray_width)],
                            _i(tray_height),
                            _i(tray_width)
            fill_color '000000'
          end
          stroke_bounds
        end
        bounding_box([_i(tray_height + shelf_width), y],
                     :width => _i(tray_height),
                     :height => _i(tray_width)) do
          unless @trays[base + 2][:so].zero?
            so_index = @shop_orders.index(@trays[base + 2][:so])
            fill_color BACKGROUND_COLORS[so_index]
            fill_rectangle [0, 0 + _i(tray_width)],
                            _i(tray_height),
                            _i(tray_width)
            fill_color '000000'
          end
          stroke_bounds
        end
        bounding_box([_i(shelf_width), y - _i(0.75)],
                     :width => _i(tray_width),
                     :height => _i(tray_height)) do
          unless @trays[base][:so].zero?
            so_index = @shop_orders.index(@trays[base][:so])
            fill_color BACKGROUND_COLORS[so_index]
            fill_rectangle [0, 0 + _i(tray_height)],
                            _i(tray_width),
                            _i(tray_height)
            fill_color '000000'
          end
          stroke_bounds
        end
        unless @trays[base + 1][:so].zero?
          vertical_text_box label_with_bold_value(['SO', 'LOAD'],
                                                  [@trays[base + 1][:so],
                                                   @trays[base + 1][:load]],
                                                  :use_colon => false,
                                                  :label_size => 6),
                            :at             =>  [_i(shelf_width),
                                                 y - _i(tray_height)],
                            :height         =>  _i(tray_height),
                            :width          =>  _i(tray_width),
                            :overflow       =>  :shrink_to_fit,
                            :size           =>  9,
                            :align          =>  :center,
                            :valign         =>  :center,
                            :inline_format  =>  true
        end
        unless @trays[base + 2][:so].zero?
          vertical_text_box label_with_bold_value(['SO', 'LOAD'],
                                                  [@trays[base + 2][:so],
                                                   @trays[base + 2][:load]],
                                                  :use_colon => false,
                                                  :label_size => 6),
                            :at             =>  [_i(shelf_width) +
                                                 _i(tray_height),
                                                 y - _i(tray_height)],
                            :height         =>  _i(tray_height),
                            :width          =>  _i(tray_width),
                            :overflow       =>  :shrink_to_fit,
                            :size           =>  9,
                            :align          =>  :center,
                            :valign         =>  :center,
                            :inline_format  =>  true
        end
        unless @trays[base][:so].zero?
          text_box label_with_bold_value(['SO', 'LOAD'],
                                         [@trays[base][:so],
                                          @trays[base][:load]],
                                         :use_colon => false,
                                         :label_size => 6),
                   :at            =>  [_i(shelf_width),
                                       y - _i(tray_width)],
                   :height        =>  _i(tray_height),
                   :width         =>  _i(tray_width),
                   :overflow      =>  :shrink_to_fit,
                   :size          =>  9,
                   :align         =>  :center,
                   :valign        =>  :center,
                   :inline_format =>  true
        end
        vertical_text_box "SHELF ##{i + 1}",
                          :at             =>  [0,
                                               y - _i(shelf_height) +
                                               _i(shelf_width)],
                          :height         =>  _i(shelf_width),
                          :width          =>  _i(shelf_height),
                          :overflow       =>  :shrink_to_fit,
                          :size           =>  9,
                          :style          =>  :bold,
                          :align          =>  :center,
                          :valign         =>  :center,
                          :inline_format  =>  true
        y -= _i(shelf_height)
      end

    end

  end

end