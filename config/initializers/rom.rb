ROM::Rails::Railtie.configure do |config|
  db_name = Rails.application.secrets.db_name
  hostname = Rails.application.secrets.hostname

  config.gateways[:default] = [
    :sql,
    "postgres://#{hostname}/#{db_name}",
    extensions: [:pg_hstore],
    not_inferrable_relations: [:schema_migrations]
  ]
end
