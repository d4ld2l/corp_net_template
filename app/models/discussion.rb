class Discussion < ApplicationRecord
  include LikableModel
  include MentionableModel
  include Elasticsearch::Model
  include Indexable
  include Discussions::Joinable
  include Discussions::Readable
  include Discussions::Ws
  include Discussions::ServiceMessages

  settings index: { number_of_shards: 1 } do
    mappings do
      indexes 'discussable_type', index: 'not_analyzed', type: 'string'
    end
  end

  belongs_to :discussable, polymorphic: true, optional: true
  belongs_to :author, class_name: 'Account', foreign_key: :author_id

  has_many :comments, -> { order(created_at: :asc) }, as: :commentable, dependent: :destroy
  has_many :documents, as: :document_attachable, dependent: :destroy
  has_many :photos, as: :photo_attachable, dependent: :destroy

  mount_uploader :logo, PhotoUploader
  mount_base64_uploader :logo, PhotoUploader

  accepts_nested_attributes_for :photos, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :documents, reject_if: :all_blank, allow_destroy: true

  enum state: %i[opened closed]

  def as_indexed_json(_options = {})
    as_json(
      only: %i[name body author_id discussable_type created_at state available_to_all],
      include:
        {
          comments: {
            only: [:body]
          }
        }
    )
  end

  def serializable_hash(options = nil)
    h = super(options)
    if options[:current_account_id]
      h['in_favorites'] = faved?(options[:current_account_id])
      h['already_liked'] = already_liked?(options[:current_account_id])
      h['messages_count'] = count_total_messages
      h['is_read'] = read?(options[:current_account_id])
      h['unread_count'] = count_unread(options[:current_account_id])
      h['mentioned'] = mentioned?(options[:current_account_id])
      h['likes_count'] = likes.count
      h['discussers_count'] = discussers.count
      h['status'] = member?(options[:current_account_id]) ? 'active' : 'available'
    end
    h
  end

  def count_total_messages
    1 + comments_count.to_i
  end

  def self.search(query, params = {})
    reserved_symbols = %w(+ - = && || > < ! ( ) { } [ ] ^ " ~ * ? : \\ /)
    search_query = query || ''
    # escaping reserved symbols
    reserved_symbols.each do |s|
      search_query.gsub!(s, "\\#{s}")
    end
    search_array = []
    unless search_query.blank?
      search_array.push(multi_match: {
        query: search_query.strip,
        fields: %w[name body comments.body],
        type: 'phrase'
      })
    end
    search_array += filter_params(params) unless params.blank?
    return where('1=0') if search_array.blank?
    __elasticsearch__.search(
      {
        query: {
          bool: {
            must: search_array
          }
        }
      }.compact
    )
  end

  def self.authors
    Account.where(id: joins(:accounts).pluck('accounts.id'))
  end

  def close!
    raise ClosingClosedDiscussion, 'Обсуждение уже закрыто' if closed?
    update(state: 'closed')
  end

  def closed?
    state == 'closed'
  end

  def opened?
    state == 'opened'
  end

  def open!
    raise OpeningOpenedDiscussion, 'Обсуждение уже открыто' if opened?
    update(state: 'opened')
  end

  def self.categories
    pluck(:discussable_type).uniq.map { |x| x.nil? ? 'Discussion' : x }
  end

  alias_method :messages_count, :count_total_messages

  def self.filter_params(params = {})
    params.map do |k, v|
      case k.to_s
      when 'author_id'
        {
          bool: {
            should: v.split(',')&.map { |x| { 'term' => { k.to_s => x } } }
          }
        }
      when 'discussable_type'
        {
          bool: {
            should: v.split(',')&.map { |x| x == 'Discussion' ? { bool: { must_not: { exists: { field: :discussable_type } } } } : { 'term' => { k.to_s => x } } }
          }
        }
      when 'created_at'
        {
          bool: {
            should: {
              range: {
                k => {
                  gte: v.split(',')[0],
                  lte: v.split(',')[1] || DateTime.current
                }
              }
            }
          }
        }
      when 'state'
        {
          bool: {
            should: v.split(',')&.map { |x| { 'term' => { k.to_s => x } } }
          }
        }
      when 'visibilty'
        {
          bool: {
            should: { term: { available_to_all: v == 'public' } }
          }
        }
      end
    end.compact
  end
end
