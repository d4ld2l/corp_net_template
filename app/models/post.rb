class Post < ApplicationRecord
  include LikableModel
  include MentionableModel
  include Posts::Search
  include Indexable

  belongs_to :author, class_name: 'Account', foreign_key: :author_id
  belongs_to :community
  belongs_to :deleted_by, class_name: 'Account', foreign_key: :deleted_by_id
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :favorite_posts, dependent: :destroy
  has_many :accounts, through: :favorite_posts
  has_many :documents, as: :document_attachable, dependent: :destroy
  has_many :photos, as: :photo_attachable, dependent: :destroy

  scope :only_my, ->(account_id) { where(author_id: account_id) }
  scope :favorites, ->(account_id) { includes(:favorite_posts).where(favorite_posts: { account_id: account_id }) }
  scope :by_communities, -> { where.not(community_id: nil) }

  accepts_nested_attributes_for :photos, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :documents, reject_if: :all_blank, allow_destroy: true

  validates_length_of :name, minimum: 1, maximum: 50, allow_blank: true
  validates :allow_commenting, inclusion: { in: [true, false] }
  validates_presence_of :body, message: 'body должен присутствовать'

  acts_as_taggable_on :tags
  acts_as_tenant :company

  before_save :extract_tags

  def can_edit?(account_id)
    author_id == account_id
  end

  def can_delete?(account_id)
    author_id == account_id
  end

  def last_comments
    comments.last(3)
  end

  def comments_list(current_account_id = nil)
    comments.includes(:account, :children).order(created_at: :asc).only_top_level.as_json(except: %i[commentable_id commentable_type user_id], include: { account: { methods: [:full_name] }, children: { include: { account: { methods: [:full_name] } }, current_account_id: current_account_id } },
                                                                                          current_account_id: current_account_id)
  end

  def in_favorites?(current_account_id = nil)
    favorite_posts.where(account_id: current_account_id).any?
  end

  def as_json(options = {})
    h = super(options)
    if options[:current_account_id]
      h['can_edit'] = can_edit?(options[:current_account_id])
      h['can_delete'] = can_delete?(options[:current_account_id])
      h['comments_list'] = comments_list(options[:current_account_id])
      h['in_favorites'] = in_favorites?(options[:current_account_id])
      h['already_liked'] = already_liked?(options[:current_account_id])
    end
    h
  end

  private

  def extract_tags
    matches = body.present? ? self&.body&.scan(/#[\w\-\.а-яА-ЯёЁ]*/i) : []
    tags = []
    matches.each do |m|
      tag = m.delete('#')
      tags << tag if tag.present?
    end
    self.tag_list = tags
  end
end
