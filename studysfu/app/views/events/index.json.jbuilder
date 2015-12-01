json.array!(@events) do |event|
  json.extract! event, :id, :title, :description
  json.start event.starts_at
  json.end event.ends_at
  json.url event_url(event, format: :html)
end
