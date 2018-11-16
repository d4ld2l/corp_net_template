class TeamBuildingInformationAccount < ApplicationRecord

  include Elasticsearch::Model
  include Indexable

  validates_uniqueness_of :account_id, scope: :team_building_information_id


  belongs_to :team_building_information
  belongs_to :account

  delegate :full_name, to: :account

  settings index: {
    number_of_shards: 1,
    analysis: {
      analyzer: {
        trigram: {
          tokenizer: 'trigram',
          filter: [:lowercase]
        }
      },
      tokenizer: {
        trigram: {
          type: 'edge_ngram',
          min_gram: 2,
          max_gram: 20,
          token_chars: %w[letter digit]
        }
      }
    }
  } do
    mapping do
      indexes 'account.surname', type: 'text', analyzer: 'russian' do
        indexes :trigram, analyzer: 'trigram'
      end
      indexes 'account.middlename', type: 'text', analyzer: 'russian' do
        indexes :trigram, analyzer: 'trigram'
      end
      indexes 'account.name', type: 'text', analyzer: 'russian' do
        indexes :trigram, analyzer: 'trigram'
      end
    end
  end

  def bid_id
    team_building_information.bid_id
  end

  def as_indexed_json(options = {})
    as_json(
      only: %i[team_building_information_id],
      include: {
        account: {
          only: %i[surname middlename name]
        }
      },
      methods: :bid_id
    )
  end


  def self.search(query, options = {})
    __elasticsearch__.search(
      query: {
        bool: {
          must: [
            {
              multi_match: {
                query: query,
                type: 'cross_fields',
                analyzer: "trigram",
                fields: %w[account.surname^30 account.name^20 account.middlename^10]
              }
            },
            {
              term: {
                bid_id: options[:bid_id]
              }
            }
          ]
        }
      }
    )
  end

end
