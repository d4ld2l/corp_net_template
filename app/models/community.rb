class Community < ApplicationRecord
  enum c_type: [:opened, :closed]

  belongs_to :user
  has_many :communities_users, dependent: :destroy
  has_many :users, through: :communities_users
  # has_many :communities_news_items, dependent: :destroy
  has_many :news_items
  has_many :notifications, as: :notice
  has_many :topics, dependent: :destroy

  # scope :search_import, -> { includes() }
  validates :name, :c_type, :photo, :description, presence: true

  acts_as_taggable_on :tags

  mount_uploader :photo, PhotoUploader
  mount_uploaders :documents, DocumentUploader

  searchkick callbacks: :async, word_start: [:email, :name, :surname, :middlename]#, merge_mappings: true#, language: [:english, :russian]

  def self.create_new_user_by_invite_email(email)
    password = Devise.friendly_token.first(8)
    user = User.create(email: email.email, password: password)
    tokens = user.create_new_auth_token
    user.build_profile(name: email.name, surname: email.surname, middlename: email.middle_name).save(validate: false)
    { user: user, token: tokens }
  end

  def search_data
    {
      tags: tags,
      name: name
    }
  end

  def users_count
    users.count
  end

  def show_users_for_block
    users.where(communities_users: { status: :accepted })
         .order('RANDOM()').take(8)
         .in_groups_of(4, false)
  end
end
