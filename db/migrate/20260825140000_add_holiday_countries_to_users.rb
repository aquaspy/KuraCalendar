class AddHolidayCountriesToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :holiday_countries, :string, null: false, default: "BR"
    reversible do |dir|
      dir.up do
        execute "UPDATE users SET holiday_countries = '' WHERE show_holidays = 0"
      end
    end
    remove_column :users, :show_holidays, :boolean, default: true, null: false
  end
end
