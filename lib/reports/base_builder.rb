# Creating a report (base class)
class Reports::BaseBuilder < DocxReplace::Doc
  class BuildError < StandardError; end
  class TemplateError < Zip::Error; end

  attr_accessor :path, :temp_dir, :resource, :template_name

  def initialize(options = {})
    @template_name = options[:template_name] || 'template.docx'
    @path = options[:path] || "#{Rails.root}/public/#{@template_name.to_s}"
    @temp_dir = options[:temp_dir] || "#{Rails.root}/tmp"
    @resource = options[:resource]

    super @path, @temp_dir
  rescue => e
    raise TemplateError, "Exception with template file: #{e.inspect}"
  end

  def build_report
    document = replace_attributes
    tmp_file = Tempfile.new('word_temlpate', @temp_dir)
    document.commit(tmp_file.path)
    tmp_file
  rescue => e
    raise BuildError, "Something went wrong #{e.inspect}"
  end

  private

  def replace_attributes
    attributes.each { |key, value| replace(key, value, true) }
    self
  end

  # redefine this method in specific builder
  def attributes
    # example:
    # {
    #   '$attr_name$' => @resource.name
    # }
  end
end
