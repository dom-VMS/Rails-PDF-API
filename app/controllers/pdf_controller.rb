class PdfController < ApplicationController

  def index
  end

  def inert_identification_bakesheet
    data = nil
    if params[:sample]
      data = File.read(Rails.root.join('lib', 'assets', 'sample_iao_id.txt'))
    else
      data = params[:data]
    end
    pdf = InertIdentificationBakesheet.new data
    send_data pdf.render,
              filename: "Identification Bakesheet.pdf",
              type: "application/pdf",
              disposition: "inline"
  end

  def inert_final_bakesheet
    data = nil
    if params[:sample]
      data = File.read(Rails.root.join('lib', 'assets', 'sample_iao_final.txt'))
    else
      data = params[:data]
    end
    pdf = InertFinalBakesheet.new data
    send_data pdf.render,
              filename: "Final Bakesheet.pdf",
              type: "application/pdf",
              disposition: "inline"
  end

end