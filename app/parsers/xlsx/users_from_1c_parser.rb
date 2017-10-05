module Parsers
  module XLSX
    class UsersFrom1CParser < XLSX::BaseXlsxParser
      DEFAULT_DOMAIN = 'example.com'.freeze
      DEFAULT_PASSWORD = 'qwerty$4'.freeze

      def self.parse(file, options={})
        doc = super(file)
        rows = doc.sheets[0].rows[2..-1]
        users = []
        rows.each do |row|
          if row[0]
            users << parse_user_row(row, options)
          end
        end
        users
      end

      private

      def self.parse_user_row(row, options={})
        user_hash = {}
        full_name = row[0].split(' ')
        user_hash[:email] = format_email(full_name[1], full_name[0], options[:company_domain] || DEFAULT_DOMAIN)
        user_hash[:profile_attributes] = {
            city: row[13],
            last_name: full_name[0],
            first_name: full_name[1],
            middle_name: full_name[2],
            position_name: row[12],
            department_name: row[11],
            position_code: Position.find_by(name_ru: row[12])&.code,
            department_code: Department.find_by(name_ru: row[11])&.code,
            default_legal_unit_employee_attributes:{
                legal_unit_id: options[:legal_unit_id],
                legal_unit_employee_position_attributes:{
                    position_code: Position.find_by(name_ru: row[12])&.code,
                    department_code: Department.find_by(name_ru: row[11])&.code,
                },
                employee_number:row[1],
                employee_uid:row[2],
                individual_employee_uid:row[3]
            }
        }
        if row[10]
          user_hash[:profile_attributes][:default_legal_unit_employee_attributes][:hired_at] = (row[10].class == Date) ? row[10] : Date.parse(row[10])
        end
        user_hash[:profile_attributes][:birthdate] = Date.parse(row[6]) if row[6]
        user_hash[:password] = DEFAULT_PASSWORD
        user_hash[:duplicates] = find_user_duplicates({
            surname: full_name[0],
            name: full_name[1],
            middlename: full_name[2],
            email: user_hash[:email],
            birthdate: user_hash[:profile_attributes][:birthdate]})
        user_hash
      end

      def self.find_user_duplicates(options = {})
        duplicate_ids = []
        duplicate_ids << User.find_by_email(options[:email])&.id
        duplicate_ids += User.includes(:profile).where(
            profiles:
                {
                    name: options[:name],
                    surname: options[:surname],
                    middlename: options[:middlename],
                    birthday: options[:birthdate]
                }
        ).pluck(:id)
        duplicate_ids.compact.uniq
      end

      def self.format_email(first_name, last_name, domain)
        first_char_t = Russian::transliterate(first_name[0])
        last_name_t = Russian::transliterate(last_name)
        "#{first_char_t}#{last_name_t}@#{domain}".downcase
      end
    end
  end
end