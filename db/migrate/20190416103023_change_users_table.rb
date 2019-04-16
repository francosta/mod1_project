class ChangeUsersTable < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :available_questions, :text
    remove_column :users, :points
  end
end
