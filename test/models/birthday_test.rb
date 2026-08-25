require "test_helper"

class BirthdayTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(email: "ada@example.com", password: "secret-password")
  end

  test "observes feb 29 on feb 28 in common years" do
    birthday = @user.birthdays.create!(name: "Ada", month: 2, day: 29, year: 2000)
    assert birthday.observed_on?(Date.new(2025, 2, 28))
    refute birthday.observed_on?(Date.new(2025, 3, 1))
    assert birthday.observed_on?(Date.new(2024, 2, 29))
    refute birthday.observed_on?(Date.new(2024, 2, 28))
  end

  test "age on the birthday year" do
    birthday = @user.birthdays.create!(name: "Lin", month: 8, day: 11, year: 2000)
    assert_equal 26, birthday.age_in(2026)
    assert_equal "Lin (26)", birthday.label_on(Date.new(2026, 8, 11))
  end

  test "rejects 31 april" do
    birthday = @user.birthdays.new(name: "No", month: 4, day: 31)
    refute birthday.valid?
    assert birthday.errors[:day].any?
  end
end
