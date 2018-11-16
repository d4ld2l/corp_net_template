module Assessment::A360::Result
  class Presenter
    def initialize(session)
      @session = session
    end

    def as_json
      result = {}
      result[:evaluations_count] = @session.session_evaluations.size
      ss = SkillsScorer.new(@session)
      result[:skills] = @session.skills.map do |s|
        s.as_json(only:[:id, :name, :description]).merge(
            {
                avg_score_common: ss.score(s.id),
                avg_score_self: ss.score(s.id, :self),
                avg_score_not_self: ss.score(s.id, :not_self),
                avg_score_manager: ss.score(s.id, :manager),
                avg_score_associate: ss.score(s.id, :associate),
                avg_score_subordinate: ss.score(s.id, :subordinate),
                comments: ss.comments(s.id),
                indicators: ss.indicators_score(s.id, [:common, :self, :not_self, :manager, :associate, :subordinate])
            }
        )
      end
      result
    end
  end

  class SkillsScorer
    def initialize(session)
      @session = session
      session_evaluations = session.session_evaluations
      @skills = []
      session_evaluations.each do |s|
        @skills += s.skill_evaluations.map do |sk_e|
          indicators = sk_e.indicator_evaluations.map do |i|
            {
                id: i.assessment_indicator.id,
                name: i.assessment_indicator.name,
                score: i.rating
            }
          end
          {
              id: sk_e.skill_id,
              kind: session_kind(session, s.account_id),
              comment: sk_e.comment,
              indicators: indicators
          }
        end
      end
    end

    def score(skill_id, filter = nil)
      sk_e = filter_skill_evaluations(skill_id, filter)
      result = 0
      sk_e.each do |s|
        ind = s[:indicators].map{|i| i[:score]}.reject{|i| (i == 0) || (i == nil)}
        result += ind.sum.to_f / ind.size
      end
      if (sk_e.size == 0) || (result == 0)
        return nil
      else
        return (result.to_f / sk_e.size).round(1)
      end
    end

    def comments(skill_id)
      @skills.select{|s| s[:id] == skill_id}.map{|x| x[:comment]}.reject{|x| x.blank?}.compact
    end

    def indicators_score(skill_id, filters)
      result = {}
      filters.each do |filter|
        sk_e = filter_skill_evaluations(skill_id, filter)
        indicators = []
        sk_e.each do |sk|
          sk[:indicators].each do |i|
            index = indicators.index{|x| x[:id] == i[:id]}
            if index
              if (i[:score] != 0) && (i[:score] != nil)
                indicators[index][:avg_score] += i[:score]
                indicators[index][:evaluations] += 1
              end
            else
              ev_count = (i[:score] != 0) && (i[:score] != nil) ? 1 : 0
              indicators.push i.merge({avg_score: i[:score], evaluations: ev_count})
            end
          end
        end
        indicators.each do |i|
          ev_count = i[:evaluations] == 0 ? 1 : i[:evaluations]
          i[:avg_score] = (i[:avg_score].to_f / ev_count).round(1)
          i.delete(:score)
        end
        result[filter] = indicators
      end
      result
    end

    private

    def filter_skill_evaluations(skill_id, filter)
      sk_e = @skills.select{|s| s[:id] == skill_id}.reject{|s| s[:indicators].map{|i| i[:score]}.reject{|i| (i == 0) || (i == nil)}.size == 0}
      if filter != nil && filter != :common
        if filter == :not_self
          sk_e = sk_e.select{|s| s[:kind] != :self}
        else
          sk_e = sk_e.select{|s| s[:kind] == filter}
        end
      end
      sk_e
    end

    def session_kind(session, account_id)
      if session.account_id == account_id
        :self
      elsif p = session.participants.to_a.select{|p| p.account_id == account_id}&.first
        p&.kind&.to_sym
      else
        :undefined
      end
    end
  end
end