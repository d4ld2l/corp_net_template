Rails.application.routes.draw do
  def draw_from_file(routes_file_name)
    instance_eval(File.read(Rails.root.join("config/routing/#{routes_file_name}")))
  end

  scope path: ENV['RAILS_RELATIVE_URL_ROOT'] || '' do

    devise_for :accounts, path: 'auth',
               defaults: { format: :json },
               controllers: {sessions: 'auth/sessions', registrations: 'auth/registrations'}

    devise_scope :accounts do
      get 'create_from_email_message', to: 'auth/sessions#create_from_email_message', as: 'cfem'
    end

    draw_from_file('api/v0/routes.rb')
    draw_from_file('admin/routes.rb')

    #misc
    mount Ckeditor::Engine => '/ckeditor'
  end
end
