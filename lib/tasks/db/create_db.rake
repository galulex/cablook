namespace :db do
  task :create_db do
    if Rails.env.test?
      db_name = Rails.application.secrets.db_name
      conn = PG.connect(dbname: 'postgres')
      begin
        conn.exec_params("CREATE DATABASE #{db_name}")
        puts "Database #{db_name} created."
      rescue PG::DuplicateDatabase
        puts "Database #{db_name} already exists."
      end
    end
    puts 'Database successfuly set up.'
  end
end
