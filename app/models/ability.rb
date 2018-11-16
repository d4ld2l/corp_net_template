class Ability
  include CanCan::Ability

  def initialize(account)
    # rules for everyone
    if account
      can :create, Event
      can :manage, Event, {created_by_id: account&.id}
      can :manage, EventParticipant
      can :create, Comment
      can :manage, Comment, {account_id: account&.id}
      can :create, Post
      can :manage, Post, {author_id: account&.id}
    end

    if account&.role? :user
      can :read, :all
      can :manage, Profile, {account_id: account&.id}
      can :manage, LegalUnitEmployee
      cannot :see_about_tab, Profile
      can [:create, :edit, :update], [Resume, ResumeWorkExperience, ResumeCertificate, ResumeRecommendation]
      can :manage, Resume, {account_id: account&.id}
      can :see_menu, [Community, NewsItem, Survey]
      can :manage, [Account, AccountCommunity, Community, Topic, Message]
      cannot :read, [Achievement, AchievementGroup, ProfileAchievement, Transaction]
    end

    if account&.role? :admin
      can :manage, :all
      can :see_menu, :all
      cannot :manage, Company
      cannot :see_menu, :superadmin
    end 

    if account.supervisor?
      can :manage, :all
      can :see_menu, :all
      cannot :delete, account.company
    end

    if account&.role? :recruiter
      can :read, Profile
      can :see_resume_tab, [Profile]
      can :manage, [Candidate]
      can :manage, Resume, {account_id: account&.id}
      can :manage, Vacancy, {owner_id: account&.id}
      can :manage, CandidateVacancy do |c_vacancy|
        (c_vacancy.vacancy.owner_id == account&.id) || (c_vacancy.vacancy.creator_id == account&.id)
      end
      can :manage, VacancyStage do |v_stage|
        (v_stage.vacancy.owner_id == account&.id) || (v_stage.vacancy.creator_id == account&.id)
      end
    end

    if account&.role? :general_recruiter
      can :manage, [Vacancy, VacancyStage, Candidate, CandidateVacancy]
      can :manage, Resume, {account_id: account&.id}
      can :see_resume_tab, [Profile]
      can :read, [Account, Project, LegalUnit, LegalUnitEmployee,
                  LegalUnitEmployeeState, LegalUnitEmployeePosition, Resume]
      can :manage, [AccountCommunity, Community, Topic, Message]

    end

    if account&.role? :manager
      can :see_menu, :all
      can [:create, :read], Vacancy
      can :manage, Profile, {account_id: account&.id}
      can [:edit, :update], Profile do |p|
        p.is_managed_by?(account)
      end
      can :manage, [AccountCommunity, Community, Topic, Message]
      can [:see_resumes_tab, :see_about_tab], [Profile]
      can :read, [Account, Project, Department, Resume, LegalUnit, LegalUnitEmployee,
                  LegalUnitEmployeeState, LegalUnitEmployeePosition]
    end

    if account&.role? :hr
      can :see_menu, :all
      can :manage, Resume, {account_id: account&.id}
      can :manage, [Account, Resume, LegalUnitEmployee, Department, LegalUnit,
                    LegalUnitEmployeePosition, LegalUnitEmployeeState,
                    AccountCommunity, Community, Topic, Message]
      can :read, [Project]
      can [:see_about_tab, :see_resume_tab], Profile
      can :edit_private_info, Profile
    end

    if account&.role? :project_manager
      can :read, :all
      can :manage, Resume, {account_id: account&.id}
      can :manage, [Project, ProfileProject]
      can :see_menu, [Community, NewsItem]
      can :see_resume_tab, [Profile]
      can :manage, [CommunitiesUser, Community, Topic, Message]
      can :read, [User, Profile, LegalUnitEmployee, Department, LegalUnit,
                  LegalUnitEmployeePosition, LegalUnitEmployeeState]
    end

    if account&.has_permission?(:game_master)
      can :manage, [Achievement, AchievementGroup, ProfileAchievement, Transaction]
      can :see_menu, :gamification
      can :access_submodule, :gamification
      can :see_transactions_tab, Profile
    end
  end
end
