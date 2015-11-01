# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
 #AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password')

n = Project.create! :title => "NinjaHR"
i = Project.create! :title => "Interakt"
a = Project.create! :title => "Addressed"

t=Task.create! :  :project_id => 1,:admin_user_id=>1,:title=>"Implement Active admin",:is_done =>0,:due_date => "2015-11-12"