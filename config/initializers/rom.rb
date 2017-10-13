ROM::Rails::Railtie.configure do |config|
  db_name = Rails.application.secrets.db_name
  db_hostname = Rails.application.secrets.db_hostname
  db_user = Rails.application.secrets.db_user
  db_password = Rails.application.secrets.db_password

  config.gateways[:default] = [
    :sql,
    ENV['DATABASE_URL'] || "postgres://#{db_user}:#{db_password}@#{db_hostname}/#{db_name}",
    extensions: %i[pg_hstore pg_array pg_json],
    not_inferrable_relations: [:schema_migrations]
  ]
end
