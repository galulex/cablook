ROM::Rails::Railtie.configure do |config|
  config.gateways[:default] = [
    :sql,
    ENV['DATABASE_URL'],
    extensions: %i[pg_array pg_json connection_validator],
    not_inferrable_relations: [:schema_migrations]
  ]
end
