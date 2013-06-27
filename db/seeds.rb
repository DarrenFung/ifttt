# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

team1 = Fabricate :team,  name: 'Team 1'
team2 = Fabricate :team,  name: 'Team 2'

elizabeth = Fabricate :user, name: 'Elizabeth'
sophia = Fabricate :user, name: 'Sophia'
ludwig = Fabricate :user, name: 'Ludwig'
vinny = Fabricate :user, name: 'Vinny'
stacey = Fabricate :user, name: 'Stacey'

team1.users.push elizabeth, sophia, ludwig, vinny, stacey

angela = Fabricate :user, name: 'Angela'
casey = Fabricate :user, name: 'Casey'
will = Fabricate :user, name: 'William'

team2.users.push angela, casey, will, ludwig
