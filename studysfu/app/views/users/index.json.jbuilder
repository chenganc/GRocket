json.array!(@users) do |user|
  json.extract! user, :id, :email, :firstName, :lastName, :password
  json.url user_url(user, format: :json)
end
