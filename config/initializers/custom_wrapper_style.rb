SimpleForm.setup do |config|
  config.wrappers :layouts_input_file, tag: 'div', class: 'fileinput-button', error_class: 'has-error' do |b|
    b.use :html5
    b.optional :readonly
    b.wrapper tag: 'span', class: 'btn btn-primary btn-sm' do |ba|
      ba.use :label_text
    end
    b.use :input, type: :file, class: 'hidden'
  end
end
