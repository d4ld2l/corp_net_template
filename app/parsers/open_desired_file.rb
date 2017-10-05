Dir.glob("#{Rails.root}/lib/parsers/hh/*.rb").each { |parser| require parser }

module Parsers::OpenDesiredFile
  def self.open(options = {})
    case options[:format]
    when 'docx'
      Parsers::HH::ResumeDocx.new(path: options[:path], format: options[:format]).parse
    when 'doc'
      Parsers::HH::ResumeDoc.new(path: options[:path], format: options[:format]).parse
    when 'pdf'
      Parsers::HH::ResumePdf.new(path: options[:path], format: options[:format]).parse
    else
      raise ArgumentError, "Extension .#{options[:format]} of this file is unsupported, sorry bro"
    end
  end
end