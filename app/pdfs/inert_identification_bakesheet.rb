class InertIdentificationBakesheet < VarlandPdf

  BACKGROUND_COLORS = ['7be042',
                       'ff657f',
                       '9cb5f2',
                       'ffc72d',
                       'b677ff',
                       '73fdff']
  SHELF_NUMBER_COLORS = ['dddddd', '999999']
  DEFAULT_LAYOUT = :landscape
  VALIDATION_REGEX = '^\[(\{"so":[\d]+,"load":[\d]+,"customer":"[\w]*",' +
                     '"process":"[\w]*","part":"[\w]*","sub":"[\w]*",' +
                     '"set":[\d]+,"min":[\d]+,"max":[\d]+,"length":[\d]+,' +
                     '"profile":"[\w]*"\},?){18}\]$'

  def initialize(data)
    super()
    @data = data
    single_line_controlled_form_header "Inert Atmosphere Oven Identification Bakesheet",
                                       "08/22/17",
                                       "JP"
    font "Whitney"
    if is_valid?
      parse_data
      draw_tray_loadings
      draw_cycle_summary
      draw_orders_table
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
    @trays = JSON.parse(@data)
    @trays.each do |t|
      t.symbolize_keys!
    end
    @shop_orders = @trays.collect{|t| t[:so]}.uniq.sort - [0]
  end

  # Find array index based on column and row of data.
  def find_index(column, row)

    # Column 0 is for shelf numbers, so no index.
    return nil if column == 0

    # Find shelf number.
    shelf = ((row + 1) / 2.0).ceil

    # Return index number.
    if (row % 2 != 0)
      return 3 * (shelf - 1) + 2
    else
      return 3 * (shelf - 1) + (column - 1)
    end

  end

  def draw_cycle_summary

    # Draw bounding box.
    bounding_box([0, bounds.height - 54], :width => 450, :height => 82) do

      # Draw heading.
      text_box "Bake Cycle Information",
               :height    =>  15,
               :width     =>  450,
               :overflow  =>  :shrink_to_fit,
               :valign    =>  :top,
               :size      =>  12,
               :style     =>  :bold,
               :align     =>  :left

      move_down 15

      # Build table rows.
      rows = []
      rows << ["Profile Name", "Setpoint", "Minimum", "Maximum", "Soak Length"]
      @trays.each do |t|
        unless t[:so].zero?
          rows << [t[:profile],
                   "#{t[:set]}° F",
                   "#{t[:min]}° F",
                   "#{t[:max]}° F",
                   "#{t[:length]} min"]
          break
        end
      end

      # Draw table.
      table(rows) do |t|
        t.cells.padding = 10
        t.position = :center
        t.column_widths = [162, 72, 72, 72, 72]
        t.cells.style do |c|
          c.size = 16
          c.font_style = :bold
          c.inline_format = true
          c.border_bottom_width = 0
          c.border_top_width = 1
          c.overflow = :shrink_to_fit
          c.align = :center
          c.valign = :top
          if c.column.zero?
            c.align = :left
          end
          if c.row.zero?
            c.size = 10
            c.padding_top = 10
            c.padding_bottom = 10
            c.text_color = "ffffff"
            c.background_color = "000000"
          end
        end
        t.before_rendering_page do |page|
          page.row(0).border_top_width = 2
          page.row(0).border_bottom_width = 2
          page.row(-1).border_bottom_width = 2
          page.column(0).border_left_width = 2
          page.column(-1).border_right_width = 2
        end
      end

    end

  end

  def draw_orders_table

    # Draw bounding box.
    bounding_box([0, bounds.height - 151], :width => 450, :height => 353) do

      # Draw heading.
      text_box "Parts Loaded in the Inert Atmosphere Oven",
               :height    =>  15,
               :width     =>  450,
               :overflow  =>  :shrink_to_fit,
               :valign    =>  :top,
               :size      =>  12,
               :style     =>  :bold,
               :align     =>  :left

      move_down 15

      # Build table rows.
      rows = []
      rows << ["Shop Order", "Part Information"]
      @shop_orders.each do |so|
        part_info = []
        @trays.each do |t|
          if t[:so] == so
            part_info << label_with_bold_value("Customer", t[:customer])
            part_info << label_with_bold_value("Process Code", t[:process])
            part_info << label_with_bold_value("Part ID", t[:part])
            unless t[:sub].blank?
              part_info << label_with_bold_value("Sub ID", t[:sub])
            end
            break
          end
        end
        rows << [{content: "<strong>#{so.to_s}</strong>"},
                 {content: part_info.join("\n")}]
      end

      # Draw table.
      table(rows) do |t|
        t.cells.padding = 3
        t.position = :left
        t.column_widths = [90, 216]
        t.cells.style do |c|
          c.size = 10
          c.inline_format = true
          c.border_bottom_width = 0
          c.border_top_width = 1
          c.overflow = :shrink_to_fit
          c.align = :center
          c.valign = :top
          unless c.column.zero?
            c.align = :left
          end
          if c.row.zero?
            c.padding_top = 10
            c.padding_bottom = 10
            c.font_style = :bold
            c.text_color = "ffffff"
            c.background_color = "000000"
          end
        end
        t.before_rendering_page do |page|
          page.row(0).border_top_width = 2
          page.row(0).border_bottom_width = 2
          page.row(-1).border_bottom_width = 2
          page.column(0).border_left_width = 2
          page.column(-1).border_right_width = 2
          @shop_orders.each_with_index do |so, index|
            page.row(index + 1).background_color = BACKGROUND_COLORS[index]
          end
        end
      end

    end

  end

  def draw_tray_loadings

    # Draw bounding box.
    bounding_box([468, bounds.height - 54], :width => 252, :height => 450) do

      # Draw heading.
      text_box "Tray Arrangement",
               :height    =>  15,
               :width     =>  252,
               :overflow  =>  :shrink_to_fit,
               :valign    =>  :top,
               :size      =>  12,
               :style     =>  :bold,
               :align     =>  :left

      move_down 15

      # Determine text to be printed in each cell.
      cell_data = @trays.collect{|t| t[:so] == 0 ? "" :
                                                   "#{t[:so]} » #{t[:load]}"}

      # Build table rows.
      rows = []
      (1..6).each do |shelf|
        base = 3 * (shelf - 1)
        rows << [{:content => shelf.to_s,
                  :rowspan => 2},
                 {:content => cell_data[base]},
                 {:content => cell_data[base + 1]}]
        rows << [{:content => cell_data[base + 2],
                  :colspan => 2}]
      end

      # Draw table.
      table(rows) do |t|
        t.position = :center
        t.column_widths = [36, 108, 108]
        t.cells.style do |c|
          c.padding = 0
          c.size = 10
          c.height = 36
          c.border_top_width = (c.row % 2).zero? ? 2 : 1
          c.overflow = :shrink_to_fit
          c.align = :center
          c.valign = :center
          c.font_style = :bold
          if c.column == 0
            c.size = 20
            c.font_style = :normal
            c.background_color = SHELF_NUMBER_COLORS[0]
            c.text_color = SHELF_NUMBER_COLORS[1]
          else
            tray_index = find_index(c.column, c.row)
            unless tray_index.nil? || @trays[tray_index].empty?
              so_index = @shop_orders.index(@trays[tray_index][:so])
              unless so_index.nil?
                c.background_color = BACKGROUND_COLORS[so_index]
              end
            end
          end
        end
        t.before_rendering_page do |page|
          page.row(-1).border_bottom_width = 2
          page.column(0).border_left_width = 2
          page.column(0).border_right_width = 2
          page.column(-1).border_right_width = 2
        end
      end

    end

  end

end