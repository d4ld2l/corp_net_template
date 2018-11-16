class Ahoy::Store < Ahoy::DatabaseStore
end

# set to true for JavaScript tracking
Ahoy.api = false
# Ahoy.visit_duration = 1.minute
Ahoy.geocode = false
Ahoy.user_method = :current_account