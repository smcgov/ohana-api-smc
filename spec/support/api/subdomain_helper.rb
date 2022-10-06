def api_subdomain
  ENV.fetch('API_SUBDOMAIN', nil)
end
