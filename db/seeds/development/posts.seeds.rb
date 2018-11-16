print '  creating posts '
ActiveRecord::Base.transaction do
  posts = [
      {name: 'Тостовый пост от человека без комментариев', body: 'Тело поста', author: Profile.last, allow_commenting: false},
      {name: 'Тостовый пост от человека с комментами', body: 'Тело поста', author: Profile.last},
      {name: 'Тостовый пост от группы', body: 'Тело поста', community: Community.last},
      {name: 'Тостовый пост от группы и человека', body: 'Тело поста', community: Community.last, author: Profile.last},
  ]
  posts.each do |p|
    Post.find_or_create_by(p)
  end
end