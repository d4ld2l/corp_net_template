class Ability
  include CanCan::Ability

  def initialize(user)
    # rules for everyone
    can :create, Event
    can :manage, Event, {created_by_id: user.id}
    can :manage, EventParticipant

    if user.role? :admin
      can :manage, :all
      can :see_menu, :all
    end

    if user.role? :user
      can :read, :all
      can :manage, Profile, {user_id: user.id}
      cannot :see_about_tab, Profile
      can :see_menu, [User, Community, NewsItem]
      can :manage, [CommunitiesUser, Community, Topic, Message]
    end

    if user.role? :manager
      can :see_menu, :all
      can :manage, Profile, {user_id: user.id}
      can [:edit, :update], Profile do |p|
        p.is_managed_by?(user&.profile)
      end
      can :manage, [CommunitiesUser, Community, Topic, Message]
      can [:see_about_tab], [Profile]
      can :read, [User, Profile, Project, ProjectRole, Department, LegalUnit, LegalUnitEmployee,
                  LegalUnitEmployeeState, LegalUnitEmployeePosition]
    end

    if user.role? :project_manager
      can :read, :all
      can :manage, [Project, UserProject]
      can :see_menu, [User, Community, NewsItem]
      can :manage, [CommunitiesUser, Community, Topic, Message]
      can :read, [User, Profile, LegalUnitEmployee, Department, LegalUnit,
                  LegalUnitEmployeePosition, LegalUnitEmployeeState]
    end
  end
end
