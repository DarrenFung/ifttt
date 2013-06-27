# == Schema Information
#
# Table name: teams
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Team < ActiveRecord::Base

  has_many :user_teams, class_name: 'UserTeams'
  has_many :users, through: :user_teams

  attr_accessible :name

end
