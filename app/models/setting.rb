class SettingValidator < ActiveModel::Validator
  def validate(record)
    case record.kind.to_sym
    when :color
      record.errors[:value] << "Value '#{record.value}' invalid for kind '#{record.kind}'" unless record.value =~ /#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})/
    end
  end
end

# Настройки, специфичные для тенанта
class Setting < ApplicationRecord
  enum kind:[:text, :color, :int, :float, :url, :boolean]

  belongs_to :company
  belongs_to :settings_group

  acts_as_tenant :company

  validates_presence_of :code, :label, :value
  validates_uniqueness_of :code, scope: :company_id
  validates_with SettingValidator

  before_save :trigger_the_settings

  def enabled?
    self.value == '1'
  end

  private

  def trigger_the_settings
    case code
    when 'auto_birthday'
      if value == '1'
        Sidekiq::Cron::Job.create(name: 'BirthdayWorker - every day at 7am', cron: '0 7 */1 * *', class: 'BirthdayWorker')
      else
        Sidekiq::Cron::Job.destroy 'BirthdayWorker - every day at 7am'
      end
    when 'auto_employee'
      if value == '1'
        Sidekiq::Cron::Job.create(name: 'NewEmployeeWorker - every day at 7am', cron: '0 7 */1 * *', class: 'NewEmployeeWorker')
      else
        Sidekiq::Cron::Job.destroy 'NewEmployeeWorker - every day at 7am'
      end
    when 'auto_news_destroy'
      if value == '1'
        Sidekiq::Cron::Job.create(name: 'NewsDestroyWorker - every day at 7am', cron: '0 7 */1 * *', class: 'NewsDestroyWorker')
      else
        Sidekiq::Cron::Job.destroy 'NewsDestroyWorker - every day at 7am'
      end
    else 'nothing'
    end
  end
end
