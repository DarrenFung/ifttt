class CreatePairings < ActiveRecord::Migration
  def change
    create_table :pairings do |t|
      t.belongs_to :user1
      t.belongs_to :user2

      t.timestamps
    end
    add_index :pairings, :user1_id
    add_index :pairings, :user2_id
  end
end
