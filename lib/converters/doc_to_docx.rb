# requirements: sudo apt-get install cups-pdf
class Converters::DocToDocx
  def self.convert(file_path, remove=false, &block)
    file_converted = `cd tmp && lowriter --convert-to docx #{file_path}`
    file_converted_path = file_path.gsub(/\.[A-Za-z]{2,4}/, '.docx')[1..-1]
    yield(file_converted_path)
    file_removed = `rm #{file_converted_path}` if remove
  end
end
