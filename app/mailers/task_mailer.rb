class TaskMailer < ApplicationMailer
  def notify_about_create(t, emails, copies)
    if t[:parent_name] != nil # это подзадача
      subject = 'Создана подзадача'
      parent_name = t[:parent_name]
      subtask_name = t[:task_name]
      @body = "На вас назначена задача #{parent_name}/#{subtask_name} "
      @link = "<a href=\"#{ENV['FRONT_HOST']}/tasks\">Посмотреть задачи</a>".html_safe
      mail(to: emails, cc: copies, subject:subject, from: ENV['FROM_MAIL'])
    else # это задача
      subject = 'Создана задача'
      task_name = t[:task_name]
      @body = "На вас назначена задача #{task_name} "
      @link = "<a href=\"#{ENV['FRONT_HOST']}/tasks\">Посмотреть задачи</a>".html_safe
      mail(to: emails, cc: copies, subject:subject, from: ENV['FROM_MAIL'])
    end
  end

  def notify_about_update(t, emails, copies)
    if t[:parent_name] != nil # это подзадача
      subject = 'Изменена подзадача'
      parent_name = t[:parent_name]
      subtask_name = t[:task_name]
      @body = "Задача #{parent_name}/#{subtask_name} изменена. "
      @link = "<a href=\"#{ENV['FRONT_HOST']}/tasks\">Посмотреть задачи</a>".html_safe
      mail(to: emails, cc: copies, subject:subject, from: ENV['FROM_MAIL'])
    else # это задача
      subject = 'Изменена задача'
      task_name = t[:task_name]
      @body = "Задача #{task_name} изменена. "
      @link = "<a href=\"#{ENV['FRONT_HOST']}/tasks\">Посмотреть задачи</a>".html_safe
      mail(to: emails, cc: copies, subject:subject, from: ENV['FROM_MAIL'])
    end
  end

end