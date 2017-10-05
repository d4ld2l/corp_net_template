class NewsItem < ApplicationRecord
  include AASM
  include ChangeAasmState

  belongs_to :user
  belongs_to :news_category
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :photos, as: :photo_attachable
  has_many :documents, as: :document_attachable
  belongs_to :community
  # has_many :communities_news_items, dependent: :destroy
  # has_many :communities, through: :communities_news_items

  accepts_nested_attributes_for :photos, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :comments, reject_if: :all_blank, allow_destroy: true

  validates_presence_of :title, :news_category_id, :body

  # before_save do
  #   self.tag_list = tag_list.map { |tag| tag.starts_with?('#') ? tag : "##{tag}" }
  # end

  scope :state_count, ->(state) { where(state: state.to_sym).count }
  scope :state_order, ->(state, order) { where(state: state).order(created_at: order)}
  scope :only_published, ->{where(state: :published)}
  scope :only_unpublished, ->{where(state: :unpublished)}
  scope :only_archived, ->{where(state: :archived)}
  scope :only_draft, ->{where(state: :draft)}
  scope :only_by_community, ->{joins(:community)}
  scope :only_not_by_community, ->{where(community_id: nil)}
  scope :created_after, ->(date) { where('created_at >= ?', date) }
  scope :created_before, ->(date) { where('? >= created_at', date) }
  scope :published_after, ->(date) { where('published_at >= ?', date) }
  scope :published_before, ->(date) { where('? >= published_at', date) }

  acts_as_taggable_on :tags

  aasm column: :state do
    state :draft, initial: true
    state :published, :unpublished, :archived

    event :to_published do
      after do
        set_published_at
      end

      transitions from: [:draft, :unpublished], to: :published
    end

    event :to_unpublished do
      transitions from: :published, to: :unpublished
    end

    event :to_archived do
      transitions from: [:published, :unpublished], to: :archived
    end

    event :to_draft do
      transitions from: :archived, to: :draft
    end
  end

  def comments_count
    comments&.count
  end

  def author
    user&.profile
  end

  private

  def set_published_at
    self.published_at = Time.current
  end
end
