namespace :db do
  task :seeds do
    unless Rails.env.production?
      load 'db/seeds.rb'
    end
  end
end
