require 'custom_exceptions'

module Parsers
  class XLSX::AccountsXlsxParser < XLSX::BaseXlsxParser

    DEFAULT_PASSWORD = 'qwerty1337'.freeze
    DEFAULT_DOMAIN = 'socialhr.ru'.freeze
    ACCOUNT_CREATION_TRIES = 10.freeze
    PROPER_COLUMNS = ["№", "Сотрудник", "Табельный номер", "Дата рождения", "Вид занятости", "Должность",
                      "Количество ставок", "Дата приема", "Блок", "Практика", "Подразделение", "Офис", "Состояние",
                      "Дата окончания стд", "Заработная плата"].freeze


    def self.check_table_format(header)
      header.each_with_index {|h, i| return false if h.strip.downcase != PROPER_COLUMNS[i].strip.downcase}
      true
    end

    def self.from_xlsx(file, legal_unit_id)
      # конвертируем из xls в xlsx по необходимости
      unless file.path.include?('xlsx')
        Converters::XlsToXlsx.convert(file.path) do |converted|
          file = File.open(converted)
        end
      end

      imported_ids = []

      doc = SimpleXlsxReader.open(file)

      unless check_table_format(doc.sheets[0].rows[0])
        raise ProfileImportException.new("Ошибка: неправильный формат импортируемой таблицы! Правильный формат столбцов: #{PROPER_COLUMNS}")
        return
      end

      rows = doc.sheets[0].rows[1..-1]
      rows.each_with_index do |row, row_index|
        if row.any?
          raise ProfileImportException.new("Отсутствует ФИО пользователя в строке #{row_index+1}") if row[1] == '' || row[1].nil?
          fio = row[1].split(' ')
          raise ProfileImportException.new("Отсутствует фамилия или имя: #{row[1]} (строка #{row_index})") if fio.size < 2
          fio << '' if fio[2].nil?

          if fio[2] == ''
            possibly_updating_accounts = Account.where("middlename='' OR middlename='.'").where(surname: fio[0], name: fio[1])
          else
            possibly_updating_accounts = Account.where(surname: fio[0], name: fio[1], middlename: fio[2])
          end

          account = possibly_updating_accounts.find_by(birthday: row[3]) || possibly_updating_accounts.find_by(birthday: nil) || Account.new

          if account.persisted?
            lue = LegalUnitEmployee.find_by(account_id: account.id, legal_unit_id: legal_unit_id) || LegalUnitEmployee.new
          else
            lue = LegalUnitEmployee.new
          end
          lue.legal_unit_id = legal_unit_id unless lue.persisted?

          # проверяем уникальность табельного номера до всех сохранений
          unless row[2].blank? || lue.employee_number.to_s == row[2].to_s || LegalUnitEmployee.find_by(legal_unit_id: legal_unit_id, employee_number: row[2]).nil?
            raise ProfileImportException.new("Табельный номер #{row[2]} уже существует и
                          принадлежит пользователю #{LegalUnitEmployee.find_by(legal_unit_id: legal_unit_id, employee_number: row[2]).account.full_name} (строка #{row_index})")
          end

          if lue.persisted?
            lue_p = LegalUnitEmployeePosition.find_by(legal_unit_employee_id: lue.id) || LegalUnitEmployeePosition.new
          else
            lue_p = LegalUnitEmployeePosition.new
          end

          # запись ФИО перемещена в конец, потому что там проверка на уникальность через сохранение

          # таб номер
          lue.employee_number = row[2] # .to_i.to_s

          # дата рождения
          account.birthday = row[3]

          # вид занятости
          lue.default = row[4].downcase.include? "основн" if row[4].present? and row[4] != 'Не указано'
          # проверка на существование другого основного вида занятости
          existing_default_lue = account.default_legal_unit_employee
          unless !(lue.default) || (existing_default_lue.nil? || existing_default_lue.id == lue.id)
            existing_default_lue.default = false
            existing_default_lue.save!
          end

          # должность
          position = Position.where("LOWER(name_ru)='#{row[5].downcase}'").find_by(legal_unit_id: legal_unit_id) # TODO: создание позиций при их отсутствии
          if position.nil?
            position = Position.new
            position.name_ru = row[5].capitalize
            position.legal_unit_id = legal_unit_id
            position.code = position.name_ru # <- Временно (Хехе... Временно...)
            position.save!
          end
          lue_p.position_code = position.code
          # сохранение происходит позже


          # кол-во ставок
          lue.wage_rate = row[6].to_s.split('/').map(&:to_f).inject(&:/)

          # Дата приема
          lue.hired_at = row[7]

          # Блок
          if row[8].present?
            parent_dep = Department.where("LOWER(name_ru)='#{row[8].strip.downcase}'").find_by(legal_unit_id: legal_unit_id)
            # binding.pry
            if parent_dep.nil?
              parent_dep = Department.new
              parent_dep.legal_unit_id = legal_unit_id
              parent_dep.name_ru = row[8].strip.capitalize
              parent_dep.code = LegalUnit.find(legal_unit_id).code + '__' + row[8].strip.capitalize
              parent_dep.save!
            end
            parent_dep_id = parent_dep.id
          else
            parent_dep_id = nil
          end

          # Практика
          if row[9].present?
            dep = Department.where("LOWER(name_ru)='#{row[9].strip.downcase}'").where(legal_unit_id: legal_unit_id).find_by(parent_id: parent_dep_id)
            # binding.pry
            if dep.nil?
              dep = Department.new
              dep.legal_unit_id = legal_unit_id
              dep.name_ru = row[9].strip.capitalize
              dep.code = LegalUnit.find(legal_unit_id).code + '__' + row[9].strip.capitalize
              dep.parent_id = parent_dep_id

              addition_index = 1
              while Department.where(code: dep.code).count > 0
                addition_index += 1
                dep.code = LegalUnit.find(legal_unit_id).code + '__' + row[9].strip.capitalize + "_#{addition_index}"
                # existing_dep = Department.find_by(code: dep.code)
                # raise ProfileImportException.new("Практика с кодом \"#{row[9]}\" уже существует, но принадлежит другому
                #                                  блоку #{existing_dep.parent&.name_ru}. В файле указана принадлежность к блоку
                #                                  #{row[8]} (строка #{row_index+1})")
              end

              begin
                dep.save!
                pp dep
              rescue
                raise ProfileImportException.new("Практика \"#{row[9]}\" уже существует, но принадлежит другому блоку (строка #{row_index+1})")
              end
            end
            lue_p.department_code = dep.code
          end

          # Подразделение
          lue.structure_unit = row[10]

          # Офис
          if row[11].present?
            office = Office.find_by("LOWER(name)='#{row[11].downcase}'")
            if office.nil?
              office = Office.new
              office.name = row[11].capitalize
              office.save!
            end
            lue.office_id = office.id
          end

          #	Состояние
          state = LegalUnitEmployeeState.new
          state.state = row[12]
          state.save!
          lue.legal_unit_employee_state_id = state.id

          # Дата окончания стд
          lue.contract_end_at = row[13]
          if lue.contract_end_at.nil?
            lue.contract_type_id = ContractType.find_by(name: "Бессрочный договор").id
          else
            lue.contract_type_id = ContractType.find_by(name: "Срочный договор").id
          end

          # Заработная плата
          lue.wage = row[14]

          # записываем ФИО
          account.middlename = fio[2] if fio[2] == ''

          unless account.persisted?
            account.surname = fio[0]
            account.name = fio[1]
            account.middlename = fio[2] || ''
            number = Account.where(surname: fio[0], name: fio[1]).count
            ACCOUNT_CREATION_TRIES.times do
              begin
                account.email = format_email(fio[0], fio[1], number, DEFAULT_DOMAIN)
                account.password = DEFAULT_PASSWORD
                account.login = account.email.split('@').first
                account.save!
                break
              rescue
                number += 1
              end
            end
            if number >= ACCOUNT_CREATION_TRIES
              raise ProfileImportException.new("Ошибка при создании учётной записи пользователя #{row[1]}")
              return
            end
          end

          lue.account_id = account.id
          lue.save!
          lue_p.legal_unit_employee_id = lue.id
          lue_p.save!
          `rm #{file.path}`
          imported_ids << account.id
        end
      end
      imported_ids
    end

    def self.to_xlsx(collection, selected_legal_unit_id)
      file = Tempfile.new(["Accounts" + Date.today.to_s, ".xlsx"])
      @workbook = RubyXL::Workbook.new
      @worksheet = @workbook[0]
      @curr_row = 1

      column_names = ['№', 'Сотрудник', 'Табельный номер', 'Дата рождения', 'Вид занятости', 'Должность',
                      'Количество ставок', 'Дата приема', 'Блок', 'Практика', 'Подразделение', 'Офис', 'Состояние',
                      'Дата окончания стд', 'Заработная плата']

      column_names.each_with_index do |element, i|
        @worksheet.add_cell(0, i, element)
        @worksheet.change_column_width(i, element.length + 5)
      end

      collection.each do |a|
        legal_unit_employee = LegalUnitEmployee.find_by(account_id: a.id, legal_unit_id:selected_legal_unit_id) #.first

        row = [@curr_row, a.full_name]# , legal_unit_employee.employee_number, p.birthday.present? ? I18n.l(p.birthday) : '',
        #  legal_unit_employee.default, legal_unit_employee.position, legal_unit_employee.wage_rate
        # ]
        # таб номер
        row << (legal_unit_employee.employee_number) #|| 'Не указан')
        # Дата рождения
        row << (a.birthday.present? ? I18n.l(a.birthday) : '')
        # вид занятости
        row << (legal_unit_employee.default.nil? ? 'Не указано' :
                    (legal_unit_employee.default? ? 'Основное место работы' : 'Внешнее совместительство'))
        # должность
        row << legal_unit_employee.position&.position&.name_ru
        # кол-во ставок
        row << legal_unit_employee.wage_rate
        # Дата приема
        row << (legal_unit_employee.hired_at.present? ? I18n.l(legal_unit_employee.hired_at) : '')
        # Блок
        row << legal_unit_employee.position&.department&.parent&.name_ru
        # Практика
        row << legal_unit_employee.position&.department&.name_ru
        # Подразделение
        row << legal_unit_employee&.structure_unit
        # Офис
        row << legal_unit_employee.office&.name
        #	Состояние
        row << legal_unit_employee.state&.state
        # Дата окончания стд
        row << (legal_unit_employee.contract_end_at.present? ? I18n.l(legal_unit_employee.contract_end_at) : '')
        # Заработная плата
        row << legal_unit_employee.wage

        self.insert_row(row)
      end

      @workbook.write(file)
      file.path
    end

    # это другой экспорт, в апи он по другому шаблону
    def self.to_xlsx_in_api_format(collection)
      file = Tempfile.new(["Accounts_hr" + Date.today.to_s, ".xlsx"])
      @workbook = RubyXL::Workbook.new
      @worksheet = @workbook[0]
      @curr_row = 1

      column_names = ['Юр. лицо', '№', 'Сотрудник', 'Табельный номер', 'Дата рождения', 'Вид занятости', 'Должность',
                      'Количество ставок', 'Дата приема', 'Блок', 'Практика', 'Подразделение', 'Офис', 'Состояние',
                      'Дата окончания стд', 'Заработная плата']

      column_names.each_with_index do |element, i|
        @worksheet.add_cell(0, i, element)
        @worksheet.change_column_width(i, element.length + 5)
      end

      collection.each_with_index do |a, i|
        legal_unit_employees = LegalUnitEmployee.where(account_id: a.id)

        legal_unit_employees.each_with_index do |lue, lue_i|
          row = [lue.legal_unit.name, i+1, a.full_name]
          # таб номер
          row << (lue.employee_number) #|| 'Не указан')
          # Дата рождения
          row << (a.birthday.present? ? I18n.l(a.birthday) : '')
          # вид занятости
          row << (lue.default.nil? ? 'Не указано' :
                      (lue.default? ? 'Основное место работы' : 'Внешнее совместительство'))
          # должность
          row << lue.position&.position&.name_ru
          # кол-во ставок
          row << lue.wage_rate
          # Дата приема
          row << (lue.hired_at.present? ? I18n.l(lue.hired_at) : '')
          # Блок
          row << lue.position&.department&.parent&.name_ru
          # Практика
          row << lue.position&.department&.name_ru
          # Подразделение
          row << lue&.structure_unit
          # Офис
          row << lue.office&.name
          #	Состояние
          row << lue.state&.state
          # Дата окончания стд
          row << (lue.contract_end_at.present? ? I18n.l(lue.contract_end_at) : '')
          # Заработная плата
          row << lue.wage

          self.insert_row(row)
        end

        # если legal unit employёв больше чем 1, то слияем (сливаем? слияеяем? слияниеяем?) нужные по шаблону ячейки таблицы.
        if legal_unit_employees.size > 1
          curr_cell_index = @curr_row - 1
          offset = legal_unit_employees.size - 1
          # номер
          @worksheet.merge_cells(curr_cell_index - offset, 1, curr_cell_index, 1)
          # имя
          @worksheet.merge_cells(curr_cell_index - offset, 2, curr_cell_index, 2)
          # дата рождения
          @worksheet.merge_cells(curr_cell_index - offset, 4, curr_cell_index, 4)
        end
      end

      @workbook.write(file)
      file.path
    end

    private
    def self.insert_row(row)
      row.each_with_index do |element, i|
        @worksheet.add_cell(@curr_row, i, element)
      end
      @curr_row += 1
    end

    def self.format_email(first_name, last_name, number, domain)
      first_char_t = Russian::transliterate(last_name[0])
      last_name_t = Russian::transliterate(first_name)
      number = nil unless number > 1
      "#{first_char_t}#{last_name_t}#{number || ''}@#{domain}".downcase
    end

  end
end
