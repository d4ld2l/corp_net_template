class SendInvite
  include ActiveModel::Model

  attr_accessor :name, :surname, :middle_name, :email

  def initialize(attributes = {})
    @email = attributes[:email]
    @name = attributes[:name]
    @surname = attributes[:surname]
    @middle_name = attributes[:middle_name]
  end

  validates :email, :name, :surname, presence: true
end