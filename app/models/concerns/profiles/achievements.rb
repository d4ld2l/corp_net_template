module Profiles
  module Achievements
    extend ActiveSupport::Concern

    included do
      after_save :check_achievements, unless: :only_balance_was_updated

      def check_achievements
        f_values = get_fullness_json.select { |x, y| y == true }
        achs = Achievement.where(enabled: true, code: f_values.keys)
        achs.each { |x| x.grant(id) }
      end

      private

      def only_balance_was_updated
        changed.all? { |x| x.to_s == 'balance' || x.to_s == 'updated_at' }
      end

    end
  end
end
