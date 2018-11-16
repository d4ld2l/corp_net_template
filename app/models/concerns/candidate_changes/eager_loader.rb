module CandidateChanges
  module EagerLoader
    def self.preload(candidate_changes)
      preloader = ActiveRecord::Associations::Preloader.new
      preloader.preload(candidate_changes, { account:{} })
      preloader.preload(candidate_changes.select { |cc| cc.change_for_type.eql?(VacancyStage.name) }, { change_for: {} })
      preloader.preload(candidate_changes.select { |cc| cc.change_for_type.eql?(Comment.name) }, { change_for: {} })
      preloader.preload(candidate_changes.select { |cc| cc.change_for_type.eql?(CandidateRating.name) }, { change_for: {} })
    end
  end
end