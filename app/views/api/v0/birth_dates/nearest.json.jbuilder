if @result.keys.any?
  json.set! @result.keys.first, @result.values.first do |profile|
    json.id profile.id
    json.email profile.email
    json.full_name profile.full_name
    json.photo profile.photo
    json.birthday profile.birthday
  end
end