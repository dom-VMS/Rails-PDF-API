require 'barby'
require 'barby/barcode/code_39'
require 'barby/outputter/prawn_outputter'

class SO < VarlandPdf

  DEFAULT_MARGIN = 0
  DEFAULT_LAYOUT = :portrait

  def initialize(data = nil, color = nil)
    super()
    @data = data
    @color = color
    print_text
    print_header
    first_page_header
  end

  def first_page_header

    # Move to first page.
    go_to_page  1

    # Draw revision dates.
    bounding_box [_i(0.25), _i(3.45)], width: _i(8), height: _i(0.8) do
      page_header_data_box 'REV DATES:', -0.05, 0.8, 1.5, 0.2, :left
      headings = ['SPEC INST', 'STD PROC', 'LOADINGS', 'PART SPEC']
      dates = ['12/11/15', '04/06/18', '12/23/15', '04/06/18']
      times = ['16:22', '13:06', '12:07', '13:06']
      initials = ['JP', 'MMJ', 'BM', 'MMJ']
      y = 0.8
      0.upto(3) do |i|
        page_header_data_box headings[i], 1, y, 1.5, 0.2, :left
        page_header_data_box dates[i], 1.8, y, 1.5, 0.2, :left
        page_header_data_box "#{initials[i]}:#{initials[i]}", 2.4, y, 1.5, 0.2, :left
        page_header_data_box times[i], 3.1, y, 1.5, 0.2, :left
        y -= 0.2
      end
      headings = ['LAST ORDER', 'PREV ORDER', 'QUOTE ART']
      dates = ['04/03/18', '06/26/17', '01/29/18']
      numbers = ['284439', '277270', '69419']
      y = 0.8
      0.upto(2) do |i|
        page_header_data_box headings[i], 4, y, 1.5, 0.2, :left
        page_header_data_box dates[i], 4.9, y, 1.5, 0.2, :left
        page_header_data_box numbers[i], 5.5, y, 1.5, 0.2, :left
        y -= 0.2
      end
    end

    # Draw shop order note box.
    bounding_box [_i(0.25), _i(2.5)], width: _i(8), height: _i(0.25) do
      fill_color 'cccccc'
      fill_rectangle([_i(0), _i(0.25)], _i(8), _i(0.25))
      stroke_bounds
      font_size 11.96
      fill_color '000000'
      font 'Arial Narrow', style: :bold
      text_box  'Shop Order Notes'.upcase,
                at: [_i(0.05), _i(0.25)],
                width: _i(7.9),
                height: _i(0.25),
                align: :center,
                valign: :center
    end
    bounding_box [_i(0.25), _i(2.25)], width: _i(8), height: _i(2) do
      stroke_bounds
      font_size 11.96
      fill_color '000000'
      font 'Source Code Pro', style: :bold
      y = 2
      5.times do
        text_box  'SEE JP BEFORE RUNNING FIRST LOAD. LAST COUPLE ORDERS WE HAVE HAD TO ADD 500CC',
                  at: [_i(0.05), _i(y)],
                  width: _i(7.9),
                  height: _i(0.2),
                  align: :left,
                  valign: :center
        y -= 0.2
        text_box  'OF BRIGHTENER BEFORE RUNNING. DO WE NEED TO DO THIS AGAIN? -MMJ',
                  at: [_i(0.05), _i(y)],
                  width: _i(7.9),
                  height: _i(0.2),
                  align: :left,
                  valign: :center
        y -= 0.2
      end
    end
      
    # Draw page header box.
    bounding_box [_i(0.25), _i(8.45)], width: _i(8), height: _i(5) do

      # Draw shaded background if necessary.
      fill_color 'ffffff'
      case @color
      when 'yellow'
        fill_color 'f9d423'
      when 'green'
        fill_color '93dfb8'
      when 'blue'
        fill_color 'b4f3fd'
      when 'purple'
        fill_color 'e3aad6'
      when 'red'
        fill_color 'ff4e50'
      end
      fill_rectangle([0, _i(5)], _i(8), _i(5))
      fill_color 'ffffff'
      fill_rectangle([_i(3.2), _i(3.3)], _i(8), _i(2.5))

      # Draw shaded header boxes.
      fill_color 'cccccc'
      fill_rectangle([_i(3.2), _i(4)], _i(4.8), _i(0.7))

      # Draw border around entire box.
      stroke_color '000000'
      stroke_bounds

      # Draw horizontal lines.
      [4, 3.7, 3.3, 3.05, 2.8, 2.55, 2.3, 2.05, 1.8, 1.55, 1.3, 1.05].each do |y|
        stroke_line [_i(3.2), _i(y)], [_i(8), _i(y)]
      end
      stroke_line [_i(0), _i(0.8)], [_i(8), _i(0.8)]

      # Draw vertical lines.
      x = 3.2
      [0.5, 0.5, 0.8, 0.45, 0.75, 0.45, 0.45, 0.9].each do |w|
        stroke_line [_i(x), _i(3.7)], [_i(x), _i(0.8)]
        x += w
      end
      stroke_line [_i(3.2), _i(5)], [_i(3.2), _i(0)]
      stroke_line [_i(6.5), _i(5)], [_i(6.5), _i(4)]

      # Draw header text.
      page_header_text_box 'Production Report', 3.2, 4, 4.8, 0.3, true
      page_header_text_box 'Date', 3.2, 3.7, 0.5, 0.4
      page_header_text_box 'Shift', 3.7, 3.7, 0.5, 0.4
      page_header_text_box 'Operation', 4.2, 3.7, 0.8, 0.2, false, :center, :bottom
      page_header_text_box 'Letter', 4.2, 3.5, 0.8, 0.2, false, :center, :top
      page_header_text_box 'Dept', 5, 3.7, 0.45, 0.4
      page_header_text_box 'Quantity', 5.45, 3.7, 0.75, 0.4
      page_header_text_box 'By', 6.2, 3.7, 0.45, 0.4
      page_header_text_box '#', 6.65, 3.7, 0.45, 0.4
      page_header_text_box 'Thickness', 7.1, 3.7, 0.9, 0.4
      page_header_text_box 'Ship To:', 3.25, 5, 3.2, 0.2, false, :left
      page_header_text_box 'Final Inspection By:', 6.5, 5, 1.5, 0.2, false, :center
      page_header_text_box 'Part & Material Description:', 0.05, 0.8, 3.9, 0.2, false, :left

      # Draw header data.
      y = 5
      ['WE CERTIFY THAT THIS LOT OF PARTS',
       'WAS PROCESSED TO THE FOLLOWING',
       'PARAMETERS:',
       '',
       'MATTE ACID TIN (.0002" MINIMUM)',
       'GM 4253M, CODE 20',
       '',
       '',
       '',
       'QUALITY CONTROL DEPARTMENT',
       'VARLAND METAL SERVICE, INC.'].each do |text|
        page_header_data_box text, 0, y, 4, 0.2, :left
        y -= 0.2
      end
      page_header_data_box 'COPPER X 14.77MM OD X 6.4MM ID X', 0, 0.6, 4, 0.2, :left
      page_header_data_box '13MM LONG', 0, 0.4, 4, 0.2, :left
      page_header_data_box '28.830 PCS/LB', 3.2, 0.8, 2.4, 0.2, :left
      page_header_data_box '0.35 FT<sup>2</sup>/LB', 3.2, 0.6, 2.4, 0.2, :left
      page_header_data_box '290.00 LBS/FT<sup>3</sup>', 3.2, 0.4, 2.4, 0.2, :left
      page_header_data_box '15.733292 GRAMS/PC', 3.2, 0.2, 2.4, 0.2, :left
      page_header_data_box '34.69 LBS/M', 5.6, 0.8, 2.4, 0.2, :left
      page_header_data_box "12.24 FT<sup>2</sup>/M", 5.6, 0.6, 2.4, 0.2, :left
      page_header_data_box '0.03468 PC WT', 5.6, 0.4, 2.4, 0.2, :left
      page_header_data_box '11.368545 CM<sup>2</sup>/PC', 5.6, 0.2, 2.4, 0.2, :left
      font 'Arial', style: :bold
      font_size 40
      fill_color 'ff0000'
      stroke_color '000000'
      case @color
      when 'red'
        fill_color 'ffffff'
      end
      text_box  'NEW JOB',
                at: [_i(0), _i(1.4)],
                width: _i(3.2),
                height: _i(0.6),
                align: :center,
                valign: :center,
                mode: :fill_stroke

    end

  end

  def print_header

    # Print page numbers.
    font_size 8
    font 'Arial Narrow', style: :bold
    bounding_box [_i(0.25), _i(10.75)], width: _i(8), height: _i(0.75) do
      number_pages 'PAGE <page>', align: :center
    end

    # Configure shop order barcode.
    barcode = Barby::Code39.new 987654.to_s.rjust(10)

    # Print header on every page.
    repeat :all do

      # Draw oversized shop order numbers.
      font_size 40
      font 'Arial Narrow', style: :bold
      text_box '123456', at: [_i(1), _i(10.75)], width: _i(2.5), height: _i(0.6)
      text_box '123456', at: [_i(8.25), _i(10.25)], width: _i(1.8), height: _i(0.6), rotate: 270, align: :center

      # Draw shop order barcode.
      bounding_box [_i(5.58), _i(10.75)], width: _i(2.5), height: _i(0.3) do
        barcode.annotate_pdf self, height: _i(0.3)
      end

      bounding_box [_i(0.25), _i(10.45)], width: _i(7.5), height: _i(0.2) do
        page_header_data_box '04/06/18 22:48', 0, 0.2, 7.55, 0.2, :right
      end
      
      # Draw page header box.
      bounding_box [_i(0.25), _i(10.25)], width: _i(7.5), height: _i(1.8) do

        # Draw shaded background if necessary.
        fill_color 'ffffff'
        case @color
        when 'yellow'
          fill_color 'f9d423'
        when 'green'
          fill_color '93dfb8'
        when 'blue'
          fill_color 'b4f3fd'
        when 'purple'
          fill_color 'e3aad6'
        when 'red'
          fill_color 'ff4e50'
        end
        fill_rectangle([0, _i(1.8)], _i(7.5), _i(1.8))

        # Draw shaded header boxes.
        fill_color 'cccccc'
        [1.8, 0.5].each do |y|
          fill_rectangle([0, _i(y)], _i(7.5), _i(0.2))
        end
        fill_rectangle([_i(3.5), _i(1.3)], _i(4), _i(0.2))

        # Draw border around entire box.
        stroke_color '000000'
        stroke_bounds

        # Draw horizontal lines.
        [1.6, 1.1, 0.5, 0.3].each do |y|
          stroke_line [0, _i(y)], [_i(7.5), _i(y)]
        end
        stroke_line [_i(3.5), _i(1.3)], [_i(7.5), _i(1.3)]

        # Draw vertical lines.
        [4.5, 5.2, 7.2].each do |x|
          stroke_line [_i(x), _i(1.8)], [_i(x), _i(1.3)]
        end
        stroke_line [_i(3.5), _i(1.8)], [_i(3.5), _i(0.5)]
        stroke_line [_i(6), _i(1.3)], [_i(6), _i(0.5)]
        [1.5, 2.75, 4, 6].each do |x|
          stroke_line [_i(x), _i(0.5)], [_i(x), _i(0)]
        end

        # Draw header text.
        page_header_text_box 'Customer Name', 0, 1.8, 3.5
        page_header_text_box 'Cust Code', 3.5, 1.8, 1
        page_header_text_box 'Proc Code', 4.5, 1.8, 0.7
        page_header_text_box 'Part ID', 5.2, 1.8, 2
        page_header_text_box 'Sub', 7.2, 1.8, 0.3
        page_header_text_box 'Part Name & Information', 3.5, 1.3, 2.5
        page_header_text_box 'Customer PO #', 6, 1.3, 1.5
        page_header_text_box 'Shop Order Date', 0, 0.5, 1.5
        page_header_text_box 'Pounds', 1.5, 0.5, 1.25
        page_header_text_box 'Pieces', 2.75, 0.5, 1.25
        page_header_text_box 'Containers', 4, 0.5, 2
        page_header_text_box 'Shipping #', 6, 0.5, 1.5

        # Draw header data.
        page_header_data_box 'HINES PRECISION INC.', 0, 1.6, 3.5, 0.5, :left, true
        page_header_data_box 'HINES', 3.5, 1.6, 1, 0.3, :center, true
        page_header_data_box 'AT', 4.5, 1.6, 0.7, 0.3, :center, true
        page_header_data_box '4222', 5.2, 1.6, 2, 0.3, :left, true
        page_header_data_box '', 7.2, 1.6, 0.3, 0.3, :center, true
        page_header_data_box 'BRIGHT ACID TIN', 0, 1.1, 3.5, 0.2, :left, false
        page_header_data_box '(EQUIPMENT #2 IF NECESSARY)', 0, 0.9, 3.5, 0.2, :left, false
        page_header_data_box 'LINE TERMINAL A PHASE', 3.5, 1.1, 2.5, 0.2, :left, false
        page_header_data_box 'OLD SIEMENS # 806439A', 3.5, 0.9, 2.5, 0.2, :left, false
        page_header_data_box 'NEW SIEMENS # 812465A', 3.5, 0.7, 2.5, 0.2, :left, false
        page_header_data_box 'PO-61411', 6, 1.1, 1.5, 0.2, :left, false
        page_header_data_box 'PAGE-12', 6, 0.9, 1.5, 0.2, :left, false
        page_header_data_box 'LOT-L00059', 6, 0.7, 1.5, 0.2, :left, false
        page_header_data_box '04/05/18', 0, 0.3, 1.5, 0.3, :center, true
        page_header_data_box '258.00', 1.5, 0.3, 1.25, 0.3, :center, true
        page_header_data_box '8,850', 2.75, 0.3, 1.25, 0.3, :center, true
        page_header_data_box '10 TOTES', 4, 0.3, 2, 0.3, :center, true
        page_header_data_box '$/M', 6, 0.3, 1.5, 0.3, :right, false, :bottom

      end

    end

  end

  def page_header_text_box(text, x, y, width, height = 0.2, large = false, align = :center, valign = :center)
    font 'Arial Narrow', style: :bold
    font_size large ? 14 : 9
    fill_color '000000'
    text_box  text.upcase,
              at: [_i(x), _i(y)],
              width: _i(width),
              height: _i(height),
              align: align,
              valign: valign,
              overflow: :shrink_to_fit
  end

  def page_header_data_box(text, x, y, width, height = 0.3, align = :left, large = false, valign = :center)
    return if text.blank?
    font 'Arial Narrow', style: :bold
    font_size large ? 16 : 11
    fill_color '000000'
    case @color
    when 'red'
      fill_color 'ffffff'
    end
    x += 0.05
    width -= 0.1
    text_box  text,
              at: [_i(x), _i(y)],
              width: _i(width),
              height: _i(height),
              align: align,
              valign: valign,
              inline_format: true
  end

  def print_text

    start_new_page
    font_size 11.96
    fill_color '000000'
    font 'Source Code Pro', style: :normal
    bounding_box [_i(0.25), _i(8)], width: _i(8), height: _i(7.75) do
      2.times do
        text ('=' * 31) + ' SHOP ORDER NOTES ' + ('=' * 31)
        text 'SEE JP BEFORE RUNNING FIRST LOAD. LAST COUPLE ORDERS WE HAVE HAD TO ADD 500CC'
        text 'OF BRIGHTENER BEFORE RUNNING. DO WE NEED TO DO THIS AGAIN? -MMJ'
        text ('=' * 80)
        text ' '
      end
    end

  end

end