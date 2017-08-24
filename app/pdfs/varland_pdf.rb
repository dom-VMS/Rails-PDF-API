class VarlandPdf < Prawn::Document

  # Default page properties may be overridden by child classes.
  DEFAULT_MARGIN = 36
  DEFAULT_LAYOUT = :portrait

  ROTATION_FUDGE_FACTOR = -4

  def initialize
    super(top_margin: self.class::DEFAULT_MARGIN,
          bottom_margin: self.class::DEFAULT_MARGIN,
          left_margin: self.class::DEFAULT_MARGIN,
          right_margin: self.class::DEFAULT_MARGIN,
          page_layout: self.class::DEFAULT_LAYOUT)
    define_fonts
  end

  def define_fonts
    font_families.update(
      "Whitney" => {
        :normal       => Rails.root.join('lib', 'assets', 'Whitney-Book.ttf'),
        :italic       => Rails.root.join('lib', 'assets', 'Whitney-BookItalic.ttf'),
        :bold         => Rails.root.join('lib', 'assets', 'Whitney-Semibold.ttf'),
        :bold_italic  => Rails.root.join('lib', 'assets', 'Whitney-SemiboldItalic.ttf')
      }
    )
  end

  def inches_to_points(inches)
    return inches * 72.0
  end
  def _i(inches)
    return inches_to_points(inches)
  end

  def print_error(msg)
    text msg,
         :color => 'ff0000',
         :style => :bold
  end

  def label_with_bold_value(label, value, options = {})
    case label.class.to_s
      when "String"
        label = [label]
        value = [value]
    end
    if options[:use_colon].nil?
      options[:use_colon] = true
    end
    lines = []
    label.each_with_index do |label, index|
      if options[:label_size]
        label_html = "<font size='#{options[:label_size]}'>#{label}"
      else
        label_html = label
      end
      label_html += options[:use_colon] ? ":" : ""
      lines << label_html + "</font> <strong>#{value[index]}</strong>"
    end
    return lines.join("\n")
  end

  def vertical_text_box(text, options = {})

    # ROTATION_FUDGE_FACTOR

    # Set rotation parameters in options hash.
    options[:rotate] = 90
    options[:rotate_around] = :lower_left
    options[:at][0] += options[:height] + ROTATION_FUDGE_FACTOR
    options[:at][1] += ROTATION_FUDGE_FACTOR

    # Draw text box.
    text_box text, options

  end

  def controlled_form_header(name, revision_date, location, approved_by)

    # Store properties of header.
    widths = [72, bounds.width - 216, 72, 72]
    box_height = 36
    padding = 3
    labels = ["Document Name",
              "Revision Date",
              "Location",
              "Approved By",
              "Page #"]
    font_sizes = [7, 18, 12]

    # Set font for header.
    font("Whitney") do

      # Draw boxes (document name, revision date, location, approval, page #)
      x = 0
      y = bounds.height
      bounding_box([x, y], :width => bounds.width, :height => box_height) do
       stroke_bounds
      end
      y -= box_height
      bounding_box([x, y], :width => widths[0], :height => box_height) do
       stroke_bounds
      end
      x += widths[0]
      bounding_box([x, y], :width => widths[1], :height => box_height) do
       stroke_bounds
      end
      x += widths[1]
      bounding_box([x, y], :width => widths[2], :height => box_height) do
       stroke_bounds
      end
      x += widths[2]
      bounding_box([x, y], :width => widths[3], :height => box_height) do
       stroke_bounds
      end

      # Draw headings.
      x = 0
      y = bounds.height
      text_box "#{labels[0]}:",
               :at        =>  [x + padding, y - padding],
               :height    =>  box_height - (2 * padding),
               :width     =>  bounds.width - (2 * padding),
               :overflow  =>  :shrink_to_fit,
               :valign    =>  :top,
               :size      =>  font_sizes[0]
      y -= box_height
      text_box "#{labels[1]}:",
               :at        =>  [x + padding, y - padding],
               :height    =>  box_height - (2 * padding),
               :width     =>  widths[0] - (2 * padding),
               :overflow  =>  :shrink_to_fit,
               :valign    =>  :top,
               :size      =>  font_sizes[0]
      x += widths[0]
      text_box "#{labels[2]}:",
               :at        =>  [x + padding, y - padding],
               :height    =>  box_height - (2 * padding),
               :width     =>  widths[1] - (2 * padding),
               :overflow  =>  :shrink_to_fit,
               :valign    =>  :top,
               :size      =>  font_sizes[0]
      x += widths[1]
      text_box "#{labels[3]}:",
               :at        =>  [x + padding, y - padding],
               :height    =>  box_height - (2 * padding),
               :width     =>  widths[2] - (2 * padding),
               :overflow  =>  :shrink_to_fit,
               :valign    =>  :top,
               :size      =>  font_sizes[0]
      x += widths[2]
      text_box "#{labels[4]}:",
               :at        =>  [x + padding, y - padding],
               :height    =>  box_height - (2 * padding),
               :width     =>  widths[3] - (2 * padding),
               :overflow  =>  :shrink_to_fit,
               :valign    =>  :top,
               :size      =>  font_sizes[0]

      # Draw data.
      x = 0
      y = bounds.height
      text_box name,
               :at        =>  [x + padding, y - padding],
               :height    =>  box_height - (2 * padding),
               :width     =>  bounds.width - (2 * padding),
               :overflow  =>  :shrink_to_fit,
               :valign    =>  :center,
               :size      =>  font_sizes[1],
               :style     =>  :bold,
               :align     =>  :center
      y -= box_height
      text_box revision_date,
               :at        =>  [x + padding, y - padding],
               :height    =>  box_height - (2 * padding),
               :width     =>  widths[0] - (2 * padding),
               :overflow  =>  :shrink_to_fit,
               :valign    =>  :center,
               :size      =>  font_sizes[2],
               :style     =>  :bold,
               :align     =>  :center
      x += widths[0]
      text_box location,
               :at        =>  [x + padding, y - padding],
               :height    =>  box_height - (2 * padding),
               :width     =>  widths[1] - (2 * padding),
               :overflow  =>  :shrink_to_fit,
               :valign    =>  :center,
               :size      =>  font_sizes[2],
               :style     =>  :bold,
               :align     =>  :left
      x += widths[1]
      text_box approved_by,
               :at        =>  [x + padding, y - padding],
               :height    =>  box_height - (2 * padding),
               :width     =>  widths[2] - (2 * padding),
               :overflow  =>  :shrink_to_fit,
               :valign    =>  :center,
               :size      =>  font_sizes[2],
               :style     =>  :bold,
               :align     =>  :center
      x += widths[2]
      text_box "#{page_number} of #{page_count}",
               :at        =>  [x + padding, y - padding],
               :height    =>  box_height - (2 * padding),
               :width     =>  widths[3] - (2 * padding),
               :overflow  =>  :shrink_to_fit,
               :valign    =>  :center,
               :size      =>  font_sizes[2],
               :style     =>  :bold,
               :align     =>  :center

    end

  end

  def single_line_controlled_form_header(name, revision_date, approved_by)

    location = 'test'

    # Store properties of header.
    widths = [bounds.width - 216, 72, 72, 72]
    box_height = 36
    padding = 3
    labels = ["Document Name",
              "Revision Date",
              "Approved By",
              "Page #"]
    font_sizes = [7, 18, 12]

    # Set font for header.
    font("Whitney") do

      # Draw boxes (document name, revision date, location, approval, page #)
      x = 0
      y = bounds.height
      bounding_box([x, y], :width => widths[0], :height => box_height) do
       stroke_bounds
      end
      x += widths[0]
      bounding_box([x, y], :width => widths[1], :height => box_height) do
       stroke_bounds
      end
      x += widths[1]
      bounding_box([x, y], :width => widths[2], :height => box_height) do
       stroke_bounds
      end
      x += widths[2]
      bounding_box([x, y], :width => widths[3], :height => box_height) do
       stroke_bounds
      end

      # Draw headings.
      x = 0
      y = bounds.height
      text_box "#{labels[0]}:",
               :at        =>  [x + padding, y - padding],
               :height    =>  box_height - (2 * padding),
               :width     =>  bounds.width - (2 * padding),
               :overflow  =>  :shrink_to_fit,
               :valign    =>  :top,
               :size      =>  font_sizes[0]
      x += widths[0]
      text_box "#{labels[1]}:",
               :at        =>  [x + padding, y - padding],
               :height    =>  box_height - (2 * padding),
               :width     =>  widths[0] - (2 * padding),
               :overflow  =>  :shrink_to_fit,
               :valign    =>  :top,
               :size      =>  font_sizes[0]
      x += widths[1]
      text_box "#{labels[2]}:",
               :at        =>  [x + padding, y - padding],
               :height    =>  box_height - (2 * padding),
               :width     =>  widths[1] - (2 * padding),
               :overflow  =>  :shrink_to_fit,
               :valign    =>  :top,
               :size      =>  font_sizes[0]
      x += widths[2]
      text_box "#{labels[3]}:",
               :at        =>  [x + padding, y - padding],
               :height    =>  box_height - (2 * padding),
               :width     =>  widths[2] - (2 * padding),
               :overflow  =>  :shrink_to_fit,
               :valign    =>  :top,
               :size      =>  font_sizes[0]

      # Draw data.
      x = 0
      y = bounds.height
      text_box name,
               :at        =>  [x + padding, y - padding],
               :height    =>  box_height - (2 * padding),
               :width     =>  widths[0] - (2 * padding),
               :overflow  =>  :shrink_to_fit,
               :valign    =>  :center,
               :size      =>  font_sizes[1],
               :style     =>  :bold,
               :align     =>  :center
      x += widths[0]
      text_box revision_date,
               :at        =>  [x + padding, y - padding],
               :height    =>  box_height - (2 * padding),
               :width     =>  widths[1] - (2 * padding),
               :overflow  =>  :shrink_to_fit,
               :valign    =>  :center,
               :size      =>  font_sizes[2],
               :style     =>  :bold,
               :align     =>  :center
      x += widths[1]
      text_box approved_by,
               :at        =>  [x + padding, y - padding],
               :height    =>  box_height - (2 * padding),
               :width     =>  widths[1] - (2 * padding),
               :overflow  =>  :shrink_to_fit,
               :valign    =>  :center,
               :size      =>  font_sizes[2],
               :style     =>  :bold,
               :align     =>  :center
      x += widths[2]
      text_box "#{page_number} of #{page_count}",
               :at        =>  [x + padding, y - padding],
               :height    =>  box_height - (2 * padding),
               :width     =>  widths[3] - (2 * padding),
               :overflow  =>  :shrink_to_fit,
               :valign    =>  :center,
               :size      =>  font_sizes[2],
               :style     =>  :bold,
               :align     =>  :center

    end

  end

end