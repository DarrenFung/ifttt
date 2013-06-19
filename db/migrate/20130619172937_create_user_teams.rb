class CreateUserTeams < ActiveRecord::Migration
  def up
    create_table :user_teams do |t|
      t.belongs_to :user
      t.belongs_to :team
    end
  end

  def down
    drop_table :user_teams
  end
end
