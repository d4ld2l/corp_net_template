class NewsItem < ApplicationRecord
  include AASM
  include ChangeAasmState
  include LikableModel
  include Elasticsearch::Model
  include Indexable

  belongs_to :author, class_name: 'Account', foreign_key: :account_id
  belongs_to :news_category

  has_many :comments, -> { order(created_at: :asc) }, as: :commentable, dependent: :destroy
  has_many :photos, as: :photo_attachable, dependent: :destroy
  has_many :documents, as: :document_attachable, dependent: :destroy

  belongs_to :community, optional: true

  accepts_nested_attributes_for :photos, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :documents, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :comments, reject_if: :all_blank, allow_destroy: true

  validates_presence_of :title, :news_category_id, :body

  # before_save do
  #   self.tag_list = tag_list.map { |tag| tag.starts_with?('#') ? tag : "##{tag}" }
  # end

  scope :state_count, ->(state) { where(state: state.to_sym).count }
  scope :state_order, ->(state, order) { where(state: state).order(created_at: order) }
  scope :only_published, -> { where(state: :published) }
  scope :only_unpublished, -> { where(state: :unpublished) }
  scope :only_archived, -> { where(state: :archived) }
  scope :only_draft, -> { where(state: :draft) }
  scope :only_by_community, -> { joins(:community) }
  scope :only_not_by_community, -> { where(community_id: nil) }
  scope :created_after, ->(date) { where('created_at >= ?', date) }
  scope :created_before, ->(date) { where('? >= created_at', date) }
  scope :published_after, ->(date) { where('published_at >= ?', date) }
  scope :published_before, ->(date) { where('? >= published_at', date) }
  scope :on_top, ->(top) { where on_top: top }

  scope :sort_by_published_at_asc, -> { order('(CASE published_at WHEN NULL THEN (CASE WHEN created_at > updated_at THEN created_at ELSE updated_at END) ELSE published_at END ASC)') }
  scope :sort_by_published_at_desc, -> { order('(CASE published_at WHEN NULL THEN (CASE WHEN created_at > updated_at THEN created_at ELSE updated_at END) ELSE published_at END DESC)') }

  acts_as_taggable_on :tags
  acts_as_tenant :company

  aasm column: :state do
    state :draft, initial: true
    state :published, :unpublished, :archived

    event :to_published do
      after do
        set_published_at
        if Setting.find_by(code: 'notify_all_on_news_published')&.value == '1'
          NewsMailer.notification_about_publishing(self.title, self.id, Account.not_blocked.pluck(:email)).deliver_later
        end
      end

      transitions from: %i[draft unpublished], to: :published
    end

    event :to_unpublished do
      transitions from: :published, to: :unpublished
    end

    event :to_archived do
      transitions from: %i[published unpublished], to: :archived
    end

    event :to_draft do
      transitions from: :archived, to: :draft
    end
  end

  def comments_list(current_account_id = nil)
    comments.select { |x| x.parent_comment_id.nil? }.as_json(except: %i[commentable_id commentable_type user_id], include: { account: { methods: [:full_name] }, children: { include: { account: { methods: [:full_name] } }, current_account_id: current_account_id } },
                                                             current_account_id: current_account_id)
  end

  def as_json(options = {})
    h = super(options)
    if options[:current_account_id]
      h['already_liked'] = already_liked?(options[:current_account_id])
      h['comments_list'] = comments_list(options[:current_account_id])
    end
    h
  end

  def as_indexed_json(options={})
    self.as_json(
        only: %i[news_category_id state account_id published_at title preview body on_top],
    )
  end

  def self.search(query, params={})
    reserved_symbols = %w(+ - = && || > < ! ( ) { } [ ] ^ " ~ * ? : \\ /)
    search_query = query || ''
    # escaping reserved symbols
    reserved_symbols.each do |s|
      search_query.gsub!(s, "\\#{s}")
    end
    es_query = {
        query: {
            bool: {
                must: filter_array(search_query, params)
            },
        },
        sort: [{ _score: { order: :desc } },
               { published_at: { order: :desc } }]
    }
    __elasticsearch__.search( es_query )
  end

  private

  def self.filter_array(query, params={})
    search_params_array = []
    search_params_array += date_params(params)
    search_params_array +=
        params.map do |k, v|
          unless v.blank?
            case
              when k == 'q' && query.present?
                {
                    bool: {
                        should: {
                            multi_match: {
                                query: query,
                                type: 'phrase_prefix',
                                fields: %w[title body preview]
                            }
                        },
                    }
                }
              when k == 'on_top' && v == "1"
                {
                    bool: {
                        should: {match: { 'on_top' => v}}
                    }
                }
              when k == 'news_category_id'
                {
                    bool: {
                        should: v.map {|x| {match: { 'news_category_id' => x.to_i}}}
                    }
                }
              when k == 'account_id'
                {
                    bool: {
                        should: v.map {|x| {match: { 'account_id' => x}}}
                    }
                }
              when k == 'state'
                {
                    bool: {
                        should: v.map {|x| {match: { 'state' => x}}}
                    }
                }
            end
          end
        end
    search_params_array.compact
  end

  def self.date_params(params)
    date_params = []
    unless params.slice("published_at_from", "published_at_to").values.all?(&:blank?)
      date_params <<
          {
              range: {
                  published_at: {
                      gte: params["published_at_from"]&.to_date,
                      lte: params["published_at_to"]&.to_date
                  }.delete_if {|_, v| v.blank?}
              }
          }
    end
    date_params
  end

  private

  def set_published_at
    self.published_at = Time.current
  end
end
