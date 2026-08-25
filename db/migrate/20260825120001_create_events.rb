class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :body, null: false, default: ""
      t.boolean :all_day, null: false, default: true
      t.date :starts_on, null: false
      t.date :ends_on, null: false
      t.time :starts_at
      t.time :ends_at
      t.timestamps
    end
    add_index :events, [ :user_id, :starts_on ]
    add_index :events, [ :user_id, :ends_on ]
  end
end
