class Task < ApplicationRecord
  include DiscussableModel
  belongs_to :executor, class_name: 'Account', foreign_key: :executor_id
  belongs_to :author, class_name: 'Account', foreign_key: :author_id
  belongs_to :parent, class_name: 'Task', foreign_key: :parent_id

  belongs_to :taskable, polymorphic: true, optional: true

  has_many :subtasks, class_name: 'Task', foreign_key: :parent_id, dependent: :destroy
  has_many :executed_subtasks, -> { finished }, class_name: 'Task', foreign_key: :parent_id, dependent: :destroy
  has_many :subtasks_available_to_account, -> { account_id = RequestStore.store[:current_account].id; executed_by_me(account_id).or(created_by_me(account_id)).or(observed_by_me(account_id)).or(available_for_task_accounts(account_id)).ordered }, class_name: 'Task', foreign_key: :parent_id
  has_many :task_observers, dependent: :destroy

  accepts_nested_attributes_for :task_observers, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :subtasks, reject_if: :all_blank, allow_destroy: true

  #counter_culture :parent, column_name: 'total_subtasks_count'
  counter_culture :parent,
                  column_name: 'total_subtasks_count',
                  column_names: {
                    ["tasks_tasks.done in (?)", [true, false]] => 'total_subtasks_count'
                  }
  counter_culture :parent,
                  column_name: Proc.new { |s| s.done? ? 'executed_subtasks_count' : nil },
                  column_names: {
                    ["tasks_tasks.done = ?", true] => 'executed_subtasks_count'
                  }

  # validates_numericality_of :priority, greater_than_or_equal_to: 1, less_than_or_equal_to: 3

  scope :roots, -> { where(parent_id: nil) }
  scope :executed_by_me, ->(x) { assigned_to_me(x).or(where_account_is_executor_on_subtask(x)) }
  scope :assigned_to_me, ->(x) { where executor_id: x }
  scope :created_by_me, ->(x) { authored_by_me(x).or(where_account_is_creator_on_subtask(x)) }
  scope :authored_by_me, ->(x) { where author_id: x }
  scope :observed_by_me, ->(x) { where("id IN (SELECT task_id FROM task_observers WHERE account_id = #{x})") }
  scope :where_account_is_on_subtask, ->(x) { where("id in (SELECT t.parent_id FROM tasks t WHERE t.executor_id = #{x} OR t.author_id = #{x} OR t.id IN (SELECT task_id FROM task_observers WHERE account_id = #{x}))") }
  scope :available_for_task_accounts, ->(x) { where("parent_id in (SELECT t.id FROM tasks t WHERE t.executor_id = #{x} OR t.author_id = #{x} OR t.id IN (SELECT task_id FROM task_observers WHERE account_id = #{x}))") }
  scope :where_account_is_observer_on_subtask, ->(x) { where("id in (SELECT t.parent_id FROM tasks t WHERE t.id IN (SELECT task_id FROM task_observers WHERE account_id = #{x}))") }
  scope :where_account_is_executor_on_subtask, ->(x) { where("id in (SELECT t.parent_id FROM tasks t WHERE t.executor_id = #{x})") }
  scope :where_account_is_creator_on_subtask, ->(x) { where("id in (SELECT t.parent_id FROM tasks t WHERE t.author_id = #{x})") }
  scope :available_to_me, ->(x) { executed_by_me(x).or(created_by_me(x)).or(observed_by_me(x)).or(where_account_is_on_subtask(x)) }
  scope :without_executor, -> { where(executor_id: nil) }
  scope :in_progress, -> { where(done: false) }
  scope :finished, -> { where(done: true) }
  scope :ordered, -> { order(executed_at: :asc, priority: :asc, title: :asc) }

  before_create { self.author = RequestStore.store[:current_account] }
  before_create :notify_about_create
  before_save :notify_about_update, if: -> {self.persisted?}
  after_save :set_expiration_notification

  def notify_about_create
    email = ""
    copies = []
    if executor_id != author_id && executor_id.present?
      email = executor&.email
    end

    task_observers.each do |t_o|
      copies << t_o.account&.email
    end

    if parent.present?
      if parent.executor_id != author_id
        copies << parent.executor&.email
      end
    end

    if email.present? || copies.present?
        TaskMailer.notify_about_create(self_json_for_mailer, email, copies).deliver_later
    end
    DchTaskNotificationsWorker.perform_async({ title: title }, task_observers.joins(:account).pluck('accounts.uid') + (executor_id == author_id ? [] : [executor&.uid]), persisted? ? :task_updated : :task_created)
  end

  def notify_about_update
    email = ""
    copies = []
    if executor_id != author_id && executor_id.present?
      email = executor&.email
    end

    task_observers.each do |t_o|
      copies << t_o.account&.email
    end

    if parent.present?
      if parent.executor_id != author_id
        copies << parent.executor&.email
      end
    end

    if email.present? || copies.present?
        TaskMailer.notify_about_update(self_json_for_mailer, email, copies).deliver_later
    end
    DchTaskNotificationsWorker.perform_async({ title: title }, task_observers.joins(:account).pluck('accounts.uid') + (executor_id == author_id ? [] : [executor&.uid]), persisted? ? :task_updated : :task_created)
  end

  def self_json_for_mailer
    {
        parent_name: self.parent&.title,
        task_name: self.title
    }
  end

  def self.counters(account_id)
    all = roots.available_to_me(account_id).group(:done).count
    my = roots.created_by_me(account_id).group(:done).count
    for_me = roots.executed_by_me(account_id).group(:done).count
    {
      in_progress: {
        available_to_me: all[false] || 0,
        created_by_me: my[false] || 0,
        executed_by_me: for_me[false] || 0
      },
      finished: {
        available_to_me: all[true] || 0,
        created_by_me: my[true] || 0,
        executed_by_me: for_me[true] || 0
      }
    }
  end

  private

  def set_expiration_notification
    sch = Sidekiq::ScheduledSet.new.select
    sch.each do |job|
      job.delete if job.klass == 'DchTaskNotificationsWorker' && job.args[3] == id
    end
    DchTaskNotificationsWorker.perform_at(executed_at, { title: title }, [executor_id], :task_expired, id) unless done?
  end
end
