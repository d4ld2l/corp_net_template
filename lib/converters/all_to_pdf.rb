# requirements: sudo apt-get install cups-pdf
class Converters::AllToPdf
  def self.convert(file, remove=true, &block)
    file_converted = `cd tmp && lowriter --convert-to pdf #{file}`
    file_converted_path = file.gsub(/\.[A-Za-z]{2,4}/, '.pdf')[1..-1]
    yield(file_converted_path)
    file_removed = `rm #{file_converted_path}` if remove
  end
end
