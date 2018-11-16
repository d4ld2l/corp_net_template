class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def to_issuer_json
    {type: self.class, id: self.id}
  end
end
