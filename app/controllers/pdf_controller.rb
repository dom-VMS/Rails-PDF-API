class PdfController < ApplicationController

  def inert_identification_bakesheet
    data = nil
    case request.request_method
      when 'GET'
        @sample_data = File.read(Rails.root.join('lib', 'assets', 'sample_inert_identification_bakesheet.txt'))
      when 'POST'
        data = params[:data]
        pdf = InertIdentificationBakesheet.new data
        send_data pdf.render,
                  filename: "Identification Bakesheet",
                  type: "application/pdf",
                  disposition: "inline"
    end
  end

  def inert_final_bakesheet
    data = nil
    case request.request_method
      when 'GET'
        @sample_data = File.read(Rails.root.join('lib', 'assets', 'sample_inert_final_bakesheet.txt'))
      when 'POST'
        data = params[:data]
        pdf = InertFinalBakesheet.new data
        send_data pdf.render,
                  filename: "Final Bakesheet",
                  type: "application/pdf",
                  disposition: "inline"
    end
  end

end