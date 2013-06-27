# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class User < ActiveRecord::Base
  attr_accessible :email, :name

  has_many :user_teams, class_name: 'UserTeams', dependent: :destroy
  has_many :teams, through: :user_teams

  has_many :pairings, dependent: :destroy, foreign_key: 'user1_id'

  validates :email,         presence: true,
                            format: /\A[^@]+@([^@\.]+\.)+[^@\.]+\z/,
                            uniqueness: true

end
