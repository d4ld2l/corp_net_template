module Profile::Achievements
  extend ActiveSupport::Concern

  included do
    after_save :check_achievements

    def check_achievements(options={})
      f_values = get_fullness_json.select{|x, y| y == true}
      achs = Achievement.where(enabled: true, code: f_values.keys)
      achs.each{|x| x.grant(id)}
    end

    private

    def only_balance_was_updated
      changed.all?{|x| x.to_s == 'balance' || x.to_s == 'updated_at'}
    end

  end
end
