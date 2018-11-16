class CustomerContact < ApplicationRecord
  include Elasticsearch::Model
  include Indexable

  belongs_to :customer

  has_many :contact_emails, as: :contactable
  has_many :contact_phones, as: :contactable
  has_many :contact_messengers, as: :contactable
  has_many :comments, as: :commentable, class_name: 'Comment', dependent: :destroy, validate: false

  has_one :preferred_phone, -> {where(preferable: true)}, class_name: 'ContactPhone', as: :contactable, dependent: :destroy
  has_one :preferred_email, -> {where(preferable: true)}, class_name: 'ContactEmail', as: :contactable, dependent: :destroy

  accepts_nested_attributes_for :contact_emails, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :contact_phones, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :contact_messengers, reject_if: :all_blank, allow_destroy: true

  attr_accessor :social_urls_string

  before_save :remove_blank_social_urls

  validates_presence_of :name

  def as_indexed_json(options = {})
    as_json(include: {contact_emails:{only: [:email]}, contact_phones:{ only: [:number]}, contact_messengers:{only: [:phones]}})
  end

  def social_urls_string
    social_urls&.join(', ')
  end

  def social_urls_string=(arr)
    self.social_urls = arr&.split(', ')
  end

  private

  def remove_blank_social_urls
    social_urls.reject!(&:blank?)
  end
end
