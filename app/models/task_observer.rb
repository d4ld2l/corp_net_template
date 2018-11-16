class TaskObserver < ApplicationRecord
  belongs_to :task, touch: true
  belongs_to :account
end
