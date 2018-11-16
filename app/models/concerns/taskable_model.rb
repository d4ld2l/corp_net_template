module TaskableModel
  extend ActiveSupport::Concern

  included do
    has_many :tasks, as: :taskable, dependent: :destroy
  end

end
