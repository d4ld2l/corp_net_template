# Сервисы
class Service < ApplicationRecord
  include AASM
  include ChangeAasmState
  include Elasticsearch::Model
  include Indexable
  # optional: true for service_group - is temporary
  belongs_to :service_group
  has_many :bids, dependent: :destroy
  has_many :documents, as: :document_attachable, class_name: 'Document'
  belongs_to :bid_stages_group, optional: true
  has_many :bid_stages, through: :bid_stages_group
  has_many :contacts_services, dependent: :destroy
  has_many :contacts, through: :contacts_services
  has_many :notifications, as: :notice

  accepts_nested_attributes_for :contacts_services, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :documents, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :notifications, reject_if: :all_blank, allow_destroy: true

  validates :contacts_services, length: { minimum: 1, message: 'Должен быть минимум один контакт' }
  validates :name, :service_group_id, presence: true

  acts_as_tenant :company

  aasm column: :state do
    state :draft, initial: true
    state :published, :unpublished

    event :to_published do
      after do
        set_published_at
      end
      transitions from: %i[draft unpublished], to: :published
    end

    event :to_unpublished do
      after do
        reset_published_at
      end
      transitions from: :published, to: :unpublished
    end
  end

  def as_indexed_json(options={})
    self.as_json(
            only: %i[service_group_id state created_at published_at]
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
               { created_at: { order: :desc } }]
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
              when k == 'service_group_id'
                {
                    bool: {
                        should: v.map {|x| {match: { 'service_group_id' => x}}}
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
    unless params.slice("created_at_from", "created_at_to").values.all?(&:blank?)
      date_params <<
          {
              range: {
                  created_at: {
                      gte: params["created_at_from"]&.to_date,
                      lte: params["created_at_to"]&.to_date
                  }.delete_if {|_, v| v.blank?}
              }
          }
    end
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
    self.published_at = DateTime.now
  end

  def reset_published_at
    self.published_at = nil
  end
end
