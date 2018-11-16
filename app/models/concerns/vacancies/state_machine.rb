module Vacancies
  module StateMachine
    extend ActiveSupport::Concern

    included do
      include AASM
      include ChangeAasmState

      aasm column: :status do
        state :draft, initial: true
        state :new, :worked, :paused, :archived

        event :to_new do
          transitions from: [:draft], to: :new
        end

        event :to_worked do
          transitions from: [:new, :paused], to: :worked
        end

        event :to_paused do
          transitions from: :worked, to: :paused

        end

        event :to_archived do
          transitions from: [:new, :worked, :paused], to: :archived
        end
      end
    end
  end
end
