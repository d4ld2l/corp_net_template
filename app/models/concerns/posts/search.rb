module Posts
  module Search
    extend ActiveSupport::Concern

    included do
      include Elasticsearch::Model

      settings index: {
        analysis: {
          filter: {
            russian_stemmer: {
              type: 'stemmer',
              language: 'russian'
            }
          },
          analyzer: {
            russian: {
              tokenizer: 'standard',
              filter: [
                'russian_stemmer'
              ]
            }
          }
        }
      } do
        mapping do
          indexes :body, type: 'text', analyzer: 'russian'
        end
      end

      def as_indexed_json(options = {})
        as_json(
          methods: [:likes_count, :comments_count, :comments_list, :tag_list],
          include: { author: { methods: [:full_name] }, community: {}, deleted_by: { methods: [:full_name] }, likes: { except: [:likable_id, :likable_type] }, documents: {}, photos: {} }
        )
      end

      def self.search(query)
        if query.include?('#')
          tag_search(query.gsub('#', ' ')).all
        else
          string_search(query).all
        end
      end

      private

      def self.string_search(query)
        __elasticsearch__.search(
          {
            query: {
              multi_match: {
                query: query,
                fields: %w(body^3 documents.name),
                fuzziness: 1,
                analyzer: 'russian'
              }
            }
          }
        ).records
      end

      def self.tag_search(query)
        __elasticsearch__.search(
          {
            query: {
              multi_match: {
                query: query,
                fields: %w(tag_list)
              }
            }
          }
        ).records
        #tagged_with(tags, wild: true, any: true)
      end

    end
  end
end