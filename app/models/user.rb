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

  has_and_belongs_to_many :teams, join_table: :user_teams

  validates :email,         presence: true,
                            format: /\A[^@]+@([^@\.]+\.)+[^@\.]+\z/

end
