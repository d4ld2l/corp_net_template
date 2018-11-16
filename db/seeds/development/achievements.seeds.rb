ActiveRecord::Base.transaction do
  print 'creating achievement groups'
  ags = [
      {name: 'Заполнение профиля'}
  ].map{|x| AchievementGroup.find_or_create_by(x)}
  ag = ags.first

  print '  creating profile_fill achievements'
  [
      {name:'Заполнение контактов', code: 'contacts_filled', achievement_group_id: ag.id, enabled: true, can_achieve_again: false, pay: 10},
      {name:'Заполнение навыков', code: 'skills_filled', achievement_group_id: ag.id, enabled: true, can_achieve_again: false, pay: 10},
      {name:'Заполнение резюме', code: 'resumes_filled', achievement_group_id: ag.id, enabled: true, can_achieve_again: false, pay: 10},
      {name:'Заполнение проектов', code: 'projects_filled', achievement_group_id: ag.id, enabled: true, can_achieve_again: false, pay: 10},
  ].each{|x| Achievement.find_or_create_by(x)}
end