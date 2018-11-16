require 'csv'
module Departments
  module CsvExportable
    extend ActiveSupport::Concern

    included do
      def parent_code
        parent&.code
      end

      def parent_code=(code)
        self.parent = Department.find_by(code: code)
      end

      def self.to_csv(options = {})
        columns = options.delete(:columns) || column_names
        CSV.generate(options) do |csv|
          csv << columns
          all.each do |d|
            csv << columns.map { |x| d.send(x) }
          end
        end
      end

      def self.from_csv(file, options = {})
        legal_unit_id = options.delete(:legal_unit_id)
        data = CSV.read(file)
        header = data.delete_at(0)
        departments = []
        parent_codes = []
        data.each do |f|
          d = Department.find_or_initialize_by(code: f[header.index('code')])
          d.name_ru = f[header.index('name_ru')]
          d.region = f[header.index('region')]
          d.legal_unit_id = legal_unit_id
          d.save
          departments << d
          parent_codes << f[header.index('parent_code')]
        end
        parent_codes.each_with_index do |pc, index|
          departments[index].parent_code = pc
          departments[index].save
        end

      end
    end

  end
end