class DchTaskNotificationsWorker
  include Sidekiq::Worker

  def perform(task, users, event, id = nil, author = nil)
    @author = author
    @task = task
    users.each { |uid| ExternalIntegrations::DchApi.new(body(uid, event)).send_notification }
  end

  private

  def body(uid, event)
    { uid: uid, message: send(event) }
  end

  def task_created
    "На вас назначена задача #{@task['title']}. Подробнее: #{ENV['FRONT_HOST']}/tasks"
  end

  def task_updated
    "Задача #{@task['title']} изменена. Подробнее: #{ENV['FRONT_HOST']}/tasks"
  end

  def task_expired
    "Истек срок задачи #{@task['title']}. Подробнее: #{ENV['FRONT_HOST']}/tasks"
  end
end
