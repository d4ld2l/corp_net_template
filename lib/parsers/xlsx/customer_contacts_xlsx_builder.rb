module Parsers
  module XLSX
    class CustomerContactsXlsxBuilder
      def self.build(customer)
        file = Tempfile.new(["Контакты заказчика #{customer.name}", '.xlsx'])
        @workbook = RubyXL::Parser.parse("lib/templates/xlsx/customer_contacts_template.xlsx")
        @worksheet = @workbook[0]
        build_contacts(customer.customer_contacts)
        @workbook.write(file)
        file
      end

      private

      def self.build_contacts(contacts)
        #insert_header
        insert_body(contacts)
      end

      def self.insert_header
        @worksheet.insert_cell(0, 0, 'ФИО')
        @worksheet.insert_cell(0, 1, 'Должность')
        @worksheet.insert_cell(0, 2, 'Город')
        @worksheet.insert_cell(0, 3, 'Описание')
        @worksheet.insert_cell(0, 4, 'Предпочитаемый телефон')
        @worksheet.insert_cell(0, 5, 'Другие телефоны')
        @worksheet.insert_cell(0, 6, 'Предпочитаемый email')
        @worksheet.insert_cell(0, 7, 'Другие email\'ы')
        @worksheet.insert_cell(0, 8, 'Skype')
        @worksheet.insert_cell(0, 9, 'Telegram')
        @worksheet.insert_cell(0, 10, 'Соц.сети')
      end

      def self.insert_body(contacts, new_line_index=1)
        cur_index = new_line_index
        contacts.each do |c|
          phones = c.contact_phones
          emails = c.contact_emails
          messengers = c.contact_messengers
          merge_count = [phones.size, emails.size, messengers.size, c.social_urls&.size].max
          merge_count = 1 if merge_count == 0

          ((0..10).to_a - [5, 7, 9, 10, 11]).each do |i|
            @worksheet.merge_cells(cur_index, i, cur_index + merge_count - 1, i)
          end

          @worksheet.insert_cell(cur_index, 0, c.name)
          @worksheet.insert_cell(cur_index, 1, c.position)
          @worksheet.insert_cell(cur_index, 2, c.city)
          @worksheet.insert_cell(cur_index, 3, c.description)
          @worksheet.insert_cell(cur_index, 4, c.preferred_phone&.number || phones&.first&.number)
          @worksheet.insert_cell(cur_index, 6, c.preferred_email&.email  || emails&.first&.email)
          @worksheet.insert_cell(cur_index, 8, c.skype)

          phones.each_with_index do |p, i|
            @worksheet.insert_cell(cur_index + i, 5, p.number)
          end

          emails.each_with_index do |e, i|
            @worksheet.insert_cell(cur_index + i, 7, e.email)
          end

          messengers.each_with_index do |m, i|
            @worksheet.insert_cell(cur_index + i, 9, m.name)
            @worksheet.insert_cell(cur_index + i, 10, m.phones.join(", "))
          end

          c.social_urls.each_with_index do |s, i|
            @worksheet.insert_cell(cur_index + i, 11, s)
          end

          cur_index += merge_count
        end
      end
    end
  end
end
