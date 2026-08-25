require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "normalizes email and requires a long enough password" do
    user = User.create!(email: "  Ada@Example.com ", password: "secret-password")
    assert_equal "ada@example.com", user.email
    assert_raises(ActiveRecord::RecordInvalid) do
      User.create!(email: "other@example.com", password: "short")
    end
  end

  test "holiday packs default to Brazil" do
    user = User.create!(email: "lin@example.com", password: "secret-password")
    assert_equal [ "BR" ], user.holiday_country_codes
    user.holiday_country_codes = [ "US", "BR", "XX" ]
    user.save!
    assert_equal [ "US", "BR" ], user.reload.holiday_country_codes
    user.holiday_country_codes = []
    user.save!
    assert_equal [], user.reload.holiday_country_codes
  end
end
