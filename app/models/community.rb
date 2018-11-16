class Community < ApplicationRecord

  include Elasticsearch::Model
  include Indexable

  enum c_type: %i[opened closed]

  belongs_to :account, inverse_of: :managed_communities, optional: true

  has_many :account_communities, dependent: :destroy
  has_many :accounts, through: :account_communities
  # has_many :communities_news_items, dependent: :destroy
  has_many :news_items, dependent: :destroy
  has_many :notifications, as: :notice
  has_many :topics, dependent: :destroy

  # scope :search_import, -> { includes() }
  validates :name, :c_type, :photo, :description, presence: true

  acts_as_taggable_on :tags

  mount_uploader :photo, PhotoUploader
  mount_uploaders :documents, DocumentUploader


  # def self.create_new_user_by_invite_email(email)
  #   password = Devise.friendly_token.first(8)
  #   account = Account.create(email: email.email, password: password)
  #   tokens = account.create_new_auth_token
  #   account.assign_attributes(name: email.name, surname: email.surname, middlename: email.middle_name).save(validate: false)
  #   { account: account, token: tokens }
  # end

  def users_count
    accounts.count
  end

  def as_indexed_json(options={})
    as_json only: %i[name created_at]
  end

  def self.search(query, options={})
    __elasticsearch__.search(
        query: {
            bool: {
                must: {
                    multi_match: {
                        query: query,
                        type: 'phrase_prefix',
                        fields: %w[name]
                    }
                }
            }
        },
        sort: [{ _score: { order: :desc } },
               { created_at: { order: :desc } }]
    )
  end

  def show_accounts_for_block
    accounts.where(account_communities: { status: :accepted })
            .order('RANDOM()').take(8)
            .in_groups_of(4, false)
  end
end
