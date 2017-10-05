module Parsers
  class XLSX::BaseXlsxParser
    require 'simple_xlsx_reader'

    def self.parse(file, options = {})
      SimpleXlsxReader.open(file)
    end
  end
end