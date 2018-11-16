module MentionableModel
  extend ActiveSupport::Concern

  included do
    has_many :mentions, as: :mentionable, dependent: :destroy

    after_save :extract_mentions

    def extract_mentions
      matches = self.body.present? ? self&.body&.scan(/@\[[А-Яа-яA-Za-zёЁ ]+\]\((\d+)\)/i).flatten.uniq.map(&:to_i) : []
      mentions.each do |m|
        m.destroy unless matches.include?(m.account_id)
      end
      matches.each do |m|
        mentions.find_or_create_by(account_id: m, post_id: id)
      end
    end

    def mentioned?(account_id)
      mentions.exists?(account_id: account_id)
    end
  end
end
