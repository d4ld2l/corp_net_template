class CreateAndEnableComponentsCompanySeed
  def initialize(company)
    @company = company
  end

  def seed
    shr = Component.find_or_create_by(name: 'shr_core', enabled: true, company: @company)
    rec = Component.find_or_create_by(name: 'recruitment_core', enabled: true, company: @company)

    [
        {name: 'shr_news', enabled: true, company: @company, core_component_id:shr.id},
        {name: 'shr_services', enabled: true, company: @company, core_component_id:shr.id},
        {name: 'shr_bids', enabled: true, company: @company, core_component_id:shr.id},
        {name: 'shr_surveys', enabled: true, company: @company, core_component_id:shr.id},
        {name: 'shr_org', enabled: true, company: @company, core_component_id:shr.id},
        {name: 'shr_teams', enabled: true, company: @company, core_component_id:shr.id},
        {name: 'shr_projects', enabled: true, company: @company, core_component_id:shr.id},
        {name: 'shr_calendar', enabled: true, company: @company, core_component_id:shr.id},
        {name: 'shr_tasks', enabled: true, company: @company, core_component_id:shr.id},
        {name: 'shr_feed', enabled: true, company: @company, core_component_id:shr.id},
        {name: 'shr_discussions', enabled: true, company: @company, core_component_id:shr.id},
        {name: 'shr_data_storage', enabled: true, company: @company, core_component_id:shr.id},
        {name: 'shr_game', enabled: true, company: @company, core_component_id:shr.id},
        {name: 'shr_skills', enabled: true, company: @company, core_component_id:shr.id},
        {name: 'shr_resume', enabled: true, company: @company, core_component_id:shr.id},
        {name: 'shr_personnel', enabled: true, company: @company, core_component_id:shr.id},
        {name: 'shr_communities', enabled: true, company: @company, core_component_id:shr.id},
        {name: 'shr_assessment', enabled: true, company: @company, core_component_id:shr.id}
    ].each{|x| Component.find_or_create_by(x)}

    [
        {name: 'recruitment_tasks', enabled: true, company: @company, core_component_id:rec.id}
    ].each{|x| Component.find_or_create_by(x)}
  end
end
