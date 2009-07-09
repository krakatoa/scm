namespace :db do
  desc 'Resetea la base y la carga con los datos iniciales.'
  task(:restart => :environment) do
    Rake::Task["db:drop"].invoke
    Rake::Task["db:create"].invoke
    
    Rake::Task["db:migrate"].invoke
    Rake::Task["db:fixtures:load"].invoke
    Rake::Task["db:vigiladores:preparar_csv"].invoke
    Rake::Task["db:vigiladores:cargar_csv"].invoke

    User.load_yml(EMPRESA)
    AdminUser.create!(:apellido => "alonso", :nombre => "fernando", :password => "33021803")
  end
end