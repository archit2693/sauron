json.containers @containers do |container|
  json.name container.container_hostname
  json.ipaddress container.ipaddress
  json.status container.status
  json.created_at container.created_at
end

