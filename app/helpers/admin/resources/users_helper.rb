module Admin::Resources::UsersHelper
  def user_duplicate_tooltip_title(user)
    res = ''
    if user.profile
      res = "ФИО: #{user.profile.full_name}, дата рождения: #{user.profile.birthday || 'не указана'}"
    else
      res = 'Профиль не создан'
    end
    res
  end
end
