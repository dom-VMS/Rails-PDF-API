class ShopOrder < VarlandPdf

  DEFAULT_MARGIN = 0
  DEFAULT_LAYOUT = :portrait

  def initialize(data = nil)
    super()
    @data = data
    page_header
  end

  def page_header(first_page = false)

    # Draw shaded boxes.
    stroke do

      # Set colors.
      fill_color 'eeeeee'

      # Shop order shaded box.
      fill_rectangle [_i(0.05), _i(10.90)], _i(0.65), _i(0.3)
      
      # Customer name shaded box.
      fill_rectangle [_i(0.05), _i(10.40)], _i(7.55), _i(0.15)

      # Part name shaded box.
      fill_rectangle [_i(3.2), _i(10)], _i(4.4), _i(0.15)
      fill_rectangle [_i(0.05), _i(9.3)], _i(7.55), _i(0.15)
      
    end

    # Draw lines.
    stroke do

      # Set colors.
      stroke_color '000000'

      # Outside box.
      move_to [_i(0.05), _i(10.4)]
      line_to [_i(7.6), _i(10.4)]
      line_to [_i(7.6), _i(8.85)]
      line_to [_i(0.05), _i(8.85)]
      line_to [_i(0.05), _i(10.4)]

      # Shop order box.
      move_to [_i(0.05), _i(10.9)]
      line_to [_i(0.7), _i(10.9)]
      line_to [_i(0.7), _i(10.6)]
      line_to [_i(0.05), _i(10.6)]
      line_to [_i(0.05), _i(10.9)]

      # Part name box.
      move_to [_i(3.2), _i(10)]
      line_to [_i(7.6), _i(10)]
      line_to [_i(7.6), _i(9.85)]
      line_to [_i(3.2), _i(9.85)]
      line_to [_i(3.2), _i(10)]
      move_to [_i(0.05), _i(9.85)]
      line_to [_i(3.2), _i(9.85)]

      # Horizontal lines.
      move_to [_i(0.05), _i(10.25)]
      line_to [_i(7.6), _i(10.25)]
      move_to [_i(0.05), _i(9.3)]
      line_to [_i(7.6), _i(9.3)]
      move_to [_i(0.05), _i(9.15)]
      line_to [_i(7.6), _i(9.15)]

      # Vertical lines.
      move_to [_i(3.2), _i(10.4)]
      line_to [_i(3.2), _i(9.3)]
      move_to [_i(4), _i(10.4)]
      line_to [_i(4), _i(10)]
      move_to [_i(4.63), _i(10.4)]
      line_to [_i(4.63), _i(10)]
      move_to [_i(7.3), _i(10.4)]
      line_to [_i(7.3), _i(10)]
      move_to [_i(5.9), _i(10)]
      line_to [_i(5.9), _i(9.3)]
      [1.1, 2.8, 4, 6.05].each do |x|
        move_to [_i(x), _i(9.3)]
        line_to [_i(x), _i(8.85)]
      end

    end

    # Box labels.
    fill_color '000000'
    font_size = 7
    text_box "S.O. #",
             :overflow  =>  :shrink_to_fit,
             :size      =>  font_size,
             :style     =>  :bold,
             :align     =>  :center,
             :valign    =>  :center,
             :at        =>  [_i(0.05), _i(10.83)],
             :width     =>  _i(0.65),
             :height    =>  _i(0.15)
    x = 0.05
    y = 9.3
    h = 0.15
    t = ['S.O. Date', 'Pounds', 'Pieces', 'Number & Type of Containers', 'Shipping #']
    w = [1.05, 1.7, 1.2, 2.05, 1.55]
    0.upto(4).each do |i|
      text_box t[i].upcase,
               :overflow  =>  :shrink_to_fit,
               :size      =>  font_size,
               :style     =>  :bold,
               :align     =>  :center,
               :valign    =>  :center,
               :at        =>  [_i(x), _i(y)],
               :width     =>  _i(w[i]),
               :height    =>  _i(h)
      x += w[i]
    end
    x = 0.05
    y = 10.402
    h = 0.15
    t = ['Customer Name', 'Cust Code', 'Proc Code', 'Part ID', 'Sub']
    w = [3.15, 0.8, 0.63, 2.67, 0.3]
    0.upto(4).each do |i|
      text_box t[i].upcase,
               :overflow  =>  :shrink_to_fit,
               :size      =>  font_size,
               :style     =>  :bold,
               :align     =>  :center,
               :valign    =>  :center,
               :at        =>  [_i(x), _i(y)],
               :width     =>  _i(w[i]),
               :height    =>  _i(h)
      x += w[i]
    end
    x = 3.2
    y = 10
    h = 0.15
    t = ['Part Name & Information', 'Customer P.O. #']
    w = [2.7, 1.7]
    0.upto(1).each do |i|
      text_box t[i].upcase,
               :overflow  =>  :shrink_to_fit,
               :size      =>  font_size,
               :style     =>  :bold,
               :align     =>  :center,
               :valign    =>  :center,
               :at        =>  [_i(x), _i(y)],
               :width     =>  _i(w[i]),
               :height    =>  _i(h)
      x += w[i]
    end

  end

end