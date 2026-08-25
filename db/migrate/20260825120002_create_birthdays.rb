class CreateBirthdays < ActiveRecord::Migration[8.1]
  def change
    create_table :birthdays do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :month, null: false
      t.integer :day, null: false
      t.integer :year
      t.text :body, null: false, default: ""
      t.timestamps
    end
    add_index :birthdays, [ :user_id, :month, :day ]
  end
end
