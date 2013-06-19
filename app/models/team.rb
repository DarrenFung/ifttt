class Team < ActiveRecord::Base

  has_and_belongs_to_many :users, join_table: :user_teams

  attr_accessible :name
end
