module ChangeAasmState
  extend ActiveSupport::Concern

  included do
    def apply_state(state)
      if try("may_to_#{state}?")
        send("to_#{state}")
        state == 'draft' ? save(validate: false) : save
      else
        errors.add(:not_allowed_state, 'Not allowed state')
        false
      end
    end
  end
end
