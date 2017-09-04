ROM::Rails::Railtie.configure do |config|
  db_name = Rails.application.secrets.db_name
  hostname = Rails.application.secrets.db_hostname

  config.gateways[:default] = [
    :sql,
    ENV["DATABASE_URL"] || "postgres://#{hostname}/#{db_name}",
    extensions: [:pg_hstore],
    not_inferrable_relations: [:schema_migrations]
  ]
end
