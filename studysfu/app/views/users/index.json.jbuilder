json.array!(@users) do |user|
  json.extract! user, :id, :Email, :FirstName, :LastName, :Password
  json.url user_url(user, format: :json)
end
