Rails.application.routes.draw do

  match "/inert_identification_bakesheet" => "pdf#inert_identification_bakesheet",
        via: [:get, :post]

  match "/inert_final_bakesheet" => "pdf#inert_final_bakesheet",
        via: [:get, :post]

end