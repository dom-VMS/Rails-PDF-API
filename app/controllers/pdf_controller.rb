class PdfController < ApplicationController

  def index
  end

  def inert_id_bakestand_bakesheets
    data = params[:data]
    id = InertIdentificationBakesheet.new data
    bakestand = InertBakestandBakesheet.new data
    id_path = Tempfile.new(['id','.pdf']).path
    bakestand_path = Tempfile.new(['bakestand','.pdf']).path
    id.render_file id_path
    bakestand.render_file bakestand_path
    spooler = VMS::PrintSpooler.new printer: :ph, color: true
    spooler.print_files id_path, landscape: true
    spooler.print_files bakestand_path
    File.delete id_path
    File.delete bakestand_path
    render plain: "OK"
  end

  def inert_identification_bakesheet
    data = nil
    if params[:sample]
      printer = :ox
      data = File.read(Rails.root.join('lib', 'assets', 'sample_iao_id.txt'))
    else
      printer = :ph
      data = params[:data]
    end
    pdf = InertIdentificationBakesheet.new data
    if params[:print]
      path = Tempfile.new(['id','.pdf']).path
      pdf.render_file path
      spooler = VMS::PrintSpooler.new printer: printer, color: true
      spooler.print_files path, landscape: true
      File.delete(path)
      render plain: "PDF sent to printer."
    else
      send_data pdf.render,
                filename: "Identification Bakesheet.pdf",
                type: "application/pdf",
                disposition: "inline"
    end
  end
  
  def inert_bakestand_bakesheet
    data = nil
    if params[:sample]
      printer = :ox
      data = File.read(Rails.root.join('lib', 'assets', 'sample_iao_id.txt'))
    else
      printer = :ph
      data = params[:data]
    end
    pdf = InertBakestandBakesheet.new data
    if params[:print]
      path = Tempfile.new(['bakestand','.pdf']).path
      pdf.render_file path
      spooler = VMS::PrintSpooler.new printer: printer, color: true
      spooler.print_files path
      File.delete(path)
      render plain: "PDF sent to printer."
    else
      send_data pdf.render,
                filename: "Bakestand Bakesheet.pdf",
                type: "application/pdf",
                disposition: "inline"
    end
  end

  def inert_final_bakesheet
    data = nil
    if params[:sample]
      printer = :ox
      data = File.read(Rails.root.join('lib', 'assets', 'sample_iao_final.txt'))
    else
      printer = :ph
      data = params[:data]
    end
    pdf = InertFinalBakesheet.new data
    if params[:print]
      path = Tempfile.new(['final','.pdf']).path
      pdf.render_file path
      spooler = VMS::PrintSpooler.new printer: printer, color: true
      spooler.print_files path
      File.delete(path)
      render plain: "PDF sent to printer."
    else
      send_data pdf.render,
                filename: "Final Bakesheet.pdf",
                type: "application/pdf",
                disposition: "inline"
    end
  end

end