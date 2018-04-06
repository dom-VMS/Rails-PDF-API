class ShopOrder < VarlandPdf

  DEFAULT_LAYOUT = :portrait

  def initialize(data = nil)
    super()
    @data = data
    single_line_controlled_form_header "Shop Order",
                                       "04/06/18",
                                       "TV"
  end

end