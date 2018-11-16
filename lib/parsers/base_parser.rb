require 'docx'
require 'pdf-reader'
require 'msworddoc-extractor'
require 'nokogiri'

module Parsers
  class BaseParser
    # self.abstract_class = true

    attr_accessor :path, :url, :format

    def initialize(options = {})
      @path = options[:path]
      @url = options[:url]
      @format = options[:format]
    end
    
    protected

    def exception_handler(default_result=nil)
      begin
        yield
      rescue
        return default_result
      end
    end

    def self.exception_handler(default_result=nil)
      begin
        yield
      rescue
        return default_result
      end
    end
  end
end
