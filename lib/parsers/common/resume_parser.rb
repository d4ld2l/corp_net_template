class Parsers::Common::ResumeParser < Parsers::BaseParser

  def self.parse(file)
    f = open_file(file)
    text = f.respond_to?(:text) ? f&.text || '' : f.pages.map(&:text).join('\n')
    fio = exception_handler { extract_name(text).split(' ') } || [nil, nil, nil]
    phone = extract_phone(text)
    email = extract_email(text)
    contacts = []
    contacts << ResumeContact.new(contact_type: :phone, value: phone) if phone
    contacts << ResumeContact.new(contact_type: :email, value: email) if email
    result = HashWithIndifferentAccess.new(
        parsed: false,
        first_name:  fio[1],
        middle_name: fio[2],
        last_name: fio[0],
        birthdate: nil,

        resume_text: text,
        manual: false,
        resume_contacts: contacts,

        raw_resume_doc_id: create_pdf_resume_doc(file)&.id
    )
    result
  end

  def self.open_file(file)
    case File.extname(file)
      when '.docx'
        Docx::Document.open(file.path)
      when '.doc'
        res = nil
        Converters::DocToDocx.convert(file.path) do |converted|
          res = Docx::Document.open(converted)
        end
        res
      when '.pdf'
        PDF::Reader.new(file.path)
      when '.rtf'
        nil
      else
        raise ArgumentError, "Extension #{File.extname(file)} of this file is unsupported, sorry bro"
    end
  end

  def self.extract_name(text)
    fio_regex = /[А-ЯЁ][а-яё]+(-[А-ЯЁ][а-яё]+)? [А-ЯЁ][а-яё]+( [А-ЯЁ][а-яё]+)?/
    text.match(fio_regex)[0] if text.match(fio_regex)
  end

  def self.extract_email(text)
    email_regex = /[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}/
    text.match(email_regex)[0] if text.match(email_regex)
  end

  def self.extract_phone(text)
    phone_regex = /(\+)?([-\s\S _():=+]?\d[-\s\S _():=+]?){10,14}/
    text.match(phone_regex)[0].strip if text.match(phone_regex)
  end

  def self.create_pdf_resume_doc(file)
    res = nil
    if File.extname(file) == '.pdf'
      res = Document.create(name: 'Резюме', file: file)
    else
      Converters::AllToPdf.convert(file.path, remove: false) do |converted|
        res = Document.create(name: 'Резюме', file: File.open(converted))
      end
    end
    res
  end

end