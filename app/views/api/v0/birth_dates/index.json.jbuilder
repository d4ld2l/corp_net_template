@collection.each do |birthday, profiles|
  json.set! birthday, profiles do |profile|
    json.id profile.id
    json.email profile.email
    json.full_name profile.full_name
    json.photo profile.photo
    json.birthday profile.birthday
  end
end