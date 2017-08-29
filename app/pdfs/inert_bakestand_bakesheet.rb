class InertBakestandBakesheet < VarlandPdf

  BACKGROUND_COLORS = InertIdentificationBakesheet::BACKGROUND_COLORS
  VALIDATION_REGEX = InertIdentificationBakesheet::VALIDATION_REGEX
  TOP_ROW_COLORS = InertIdentificationBakesheet::SHELF_NUMBER_COLORS

  def initialize(data)
    super()
    @data = data
    single_line_controlled_form_header "Bakestand Identification Bakesheet",
                                       "08/22/17",
                                       "JP"
    font "Whitney"
    if is_valid?
      parse_data
      draw_orders_table
      draw_bakestand
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

    base = nil
    case column
      when 0
        base = 0
      when 1
        base = 6
      when 2
        base = 12
      else
        return nil
    end

    index = nil
    case row
      when 1..3
        index = base + row - 1
      when 5..7
        index = base + row - 2
      else
        return nil
    end

    return index

  end

  def draw_bakestand

    # Draw bounding box.
    bounding_box([0, bounds.height - 396], :width => bounds.width, :height => 320) do
      # stroke_bounds
      
      # Draw heading.
      text_box "Arrangement of Parts on Bakestand",
                :height    =>  15,
                :width     =>  450,
                :overflow  =>  :shrink_to_fit,
                :valign    =>  :top,
                :size      =>  12,
                :style     =>  :bold,
                :align     =>  :left

      move_down 15

      shop_orders = []
      loads = []
      loadings = []
      5.downto(0).each do |i|
        if @trays[i * 3][:so].zero? && @trays[i * 3 + 1][:so].zero? && @trays[i * 3 + 2][:so].zero?
          @trays.delete_at i * 3 + 2
          @trays.delete_at i * 3 + 1
          @trays.delete_at i * 3
          3.times do
            @trays << { :so => 0,
                        :load => 0,
                        :customer => "",
                        :process => "",
                        :part => "",
                        :sub => "",
                        :set => 0,
                        :min => 0,
                        :max => 0,
                        :length => 0,
                        :profile => "" }
          end
        end
      end
      (0..17).each do |i|
        shop_orders << @trays[i][:so]
        loads << @trays[i][:load]
        if @trays[i][:so].zero?
          loadings << " "
        else
          loadings << "#{@trays[i][:so]} » #{@trays[i][:load]}"
        end
      end

      rows = []
      rows << ["« EMPTY »", "« EMPTY »", "« EMPTY »", "« EMPTY »"]
      rows << ["#{loadings[0]}", "#{loadings[6]}", "#{loadings[12]}", " "]
      rows << ["#{loadings[1]}", "#{loadings[7]}", "#{loadings[13]}", " "]
      rows << ["#{loadings[2]}", "#{loadings[8]}", "#{loadings[14]}", " "]
      rows << [" ", " ", " ", " "]
      rows << ["#{loadings[3]}", "#{loadings[9]}", "#{loadings[15]}", " "]
      rows << ["#{loadings[4]}", "#{loadings[10]}", "#{loadings[16]}", " "]
      rows << ["#{loadings[5]}", "#{loadings[11]}", "#{loadings[17]}", " "]
      (1..3).each do
        rows << [" ", " ", " ", " "]
      end

      table(rows) do |t|
        t.cells.padding = 8
        t.position = :left
        t.column_widths = [135, 135, 135, 135]
        t.cells.style do |c|
          c.size = 10
          c.inline_format = true
          c.overflow = :shrink_to_fit
          c.align = :center
          c.valign = :top
          tray_index = find_index(c.column, c.row)
          unless tray_index.nil?
            so_index = nil
            @shop_orders.each_with_index do |so, index|
              if so == shop_orders[tray_index]
                so_index = index
                break
              end
            end
            unless so_index.nil?
              c.background_color = BACKGROUND_COLORS[so_index]
            end
          end
          if c.row.zero?
            c.text_color = TOP_ROW_COLORS[1]
            c.background_color = TOP_ROW_COLORS[0]
            c.size = 8
            c.padding = 9
          end
        end
      end

    end

  end

  def draw_orders_table

    # Draw bounding box.
    bounding_box([0, bounds.height - 54], :width => bounds.width, :height => 324) do

      # Draw heading.
      text_box "Parts Loaded on this Bakestand",
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
      rows << ["Shop Order", "Part Information", "QC Approval to Dump"]
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
                 {content: part_info.join("\n")},
                 {content: ""}]
      end

      # Draw table.
      table(rows) do |t|
        t.cells.padding = 3
        t.position = :left
        t.column_widths = [90, 216, 144]
        t.cells.style do |c|
          c.size = 10
          c.inline_format = true
          c.border_bottom_width = 0
          c.border_top_width = 1
          c.overflow = :shrink_to_fit
          c.align = :center
          c.valign = :top
          if c.column == 1
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
            page.row(index + 1).column(-1).background_color = 'ffffff'
          end
        end
      end

    end

  end

end