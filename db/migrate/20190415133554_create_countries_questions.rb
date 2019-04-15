class CreateCountriesQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :questions do |t|
      t.integer :user_id
      t.integer :country_id
      t.string :question
    end

    create_table :countries do |t|
      t.string :name
      t.integer :level
      t.string :code
    end

  end
end
