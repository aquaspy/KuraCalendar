require "test_helper"

class EventTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(email: "ada@example.com", password: "secret-password")
  end

  test "in_range includes spanning events" do
    event = @user.events.create!(title: "Trip", starts_on: "2026-08-30", ends_on: "2026-09-02")
    found = @user.events.in_range(Date.new(2026, 9, 1), Date.new(2026, 9, 7))
    assert_includes found, event
    refute_includes @user.events.in_range(Date.new(2026, 8, 1), Date.new(2026, 8, 29)), event
  end

  test "all-day events drop times" do
    event = @user.events.create!(
      title: "Park",
      all_day: true,
      starts_on: "2026-08-25",
      starts_at: "14:00"
    )
    assert event.all_day?
    assert_nil event.starts_at
  end

  test "timed events need a start time" do
    event = @user.events.new(title: "Call", all_day: false, starts_on: "2026-08-25")
    refute event.valid?
    assert event.errors[:starts_at].any?
  end

  test "rejects an inverted range" do
    event = @user.events.new(title: "Nope", starts_on: "2026-08-25", ends_on: "2026-08-20")
    refute event.valid?
    assert event.errors[:ends_on].any?
  end

  test "reclaim_space never breaks the request" do
    Event.reclaim_space
    Event.transaction do
      assert_nil Event.reclaim_space
    end
  end
end
