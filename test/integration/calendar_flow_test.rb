require "test_helper"
require "tempfile"

class CalendarFlowTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email: "ada@example.com", password: "secret-password")
  end

  test "signup can be turned off" do
    ENV["SIGNUP_ENABLED"] = "false"
    get signup_path
    assert_redirected_to login_path
    follow_redirect!
    refute_includes response.body, I18n.t("auth.create_one")

    assert_no_difference -> { User.count } do
      post signup_path, params: { email: "intruder@example.com", password: "secret-password", password_confirmation: "secret-password" }
    end
    assert_redirected_to login_path
  ensure
    ENV.delete("SIGNUP_ENABLED")
  end

  test "signup creates a user with a real password" do
    post signup_path, params: { email: "lin@example.com", password: "secret-password", password_confirmation: "secret-password" }
    assert_redirected_to root_path
    user = User.find_by(email: "lin@example.com")
    assert user
    assert user.authenticate("secret-password")
    refute user.authenticate("wrong")
  end

  test "login opens the calendar" do
    post login_path, params: { email: @user.email, password: "secret-password" }
    assert_redirected_to root_path
    follow_redirect!
    assert_response :success
    assert_includes response.body, "KuraCalendar"
    assert_select ".cal-grid"
    assert_select ".cal-cell.is-today"
    assert_select ".cal-cell.is-today[aria-current=date]"
  end

  test "strangers cannot read the calendar" do
    get root_path
    assert_redirected_to login_path
  end

  test "a user can add an event on a day" do
    login
    assert_difference -> { @user.events.count }, 1 do
      post events_path, params: { event: { title: "Dentist", starts_on: "2026-08-25", ends_on: "2026-08-25", all_day: "1" } }
    end
    assert_redirected_to month_path(year: 2026, month: 8, day: 25)
    follow_redirect!
    assert_includes response.body, "Dentist"
  end

  test "a timed event and a birthday show on the month" do
    login
    post events_path, params: { event: { title: "Call", starts_on: "2026-08-26", all_day: "0", starts_at: "14:30", ends_at: "15:00" } }
    post birthdays_path, params: { birthday: { name: "Eben", month: 8, day: 11, year: 1990 }, return_year: 2026 }
    get month_path(year: 2026, month: 8, day: 26)
    assert_response :success
    assert_includes response.body, "Call"
    assert_includes response.body, "14:30"
    get month_path(year: 2026, month: 8, day: 11)
    assert_includes response.body, "Eben (36)"
  end

  test "another user cannot touch an event" do
    event = @user.events.create!(title: "Secret", starts_on: Date.new(2026, 8, 25), ends_on: Date.new(2026, 8, 25))
    User.create!(email: "other@example.com", password: "secret-password")
    post login_path, params: { email: "other@example.com", password: "secret-password" }
    patch event_path(event), params: { event: { title: "Stolen" } }
    assert_response :not_found
    assert_equal "Secret", event.reload.title
  end

  test "independence day shows and clearing countries hides it" do
    login
    get month_path(year: 2026, month: 9, day: 7)
    assert_response :success
    assert_includes response.body, I18n.t("holidays.br.independence")

    post holidays_path, params: { year: 2026, month: 9, day: 7 }
    follow_redirect!
    refute_includes response.body, I18n.t("holidays.br.independence")
    assert_equal [], @user.reload.holiday_country_codes
  end

  test "brazil and the united states can share a day" do
    login
    post holidays_path, params: { countries: [ "BR", "US" ], year: 2026, month: 9, day: 7 }
    follow_redirect!
    assert_includes response.body, I18n.t("holidays.br.independence")
    assert_includes response.body, I18n.t("holidays.us.labor")
    assert_includes response.body, "BR"
    assert_includes response.body, "US"
  end

  test "a spanning event appears on both days" do
    login
    post events_path, params: { event: { title: "Trip", starts_on: "2026-08-31", ends_on: "2026-09-01", all_day: "1" } }
    get month_path(year: 2026, month: 8, day: 31)
    assert_includes response.body, "Trip"
    get month_path(year: 2026, month: 9, day: 1)
    assert_includes response.body, "Trip"
  end

  test "export and import round-trip events and birthdays" do
    login
    @user.events.create!(title: "Park", starts_on: Date.new(2026, 8, 25), ends_on: Date.new(2026, 8, 25))
    @user.birthdays.create!(name: "Ada", month: 8, day: 11, year: 2000)

    get export_path
    assert_response :success
    payload = response.body
    json = JSON.parse(payload)
    assert_equal "KuraCalendar", json["app"]
    assert_equal 1, json["events"].size
    assert_equal 1, json["birthdays"].size

    other = User.create!(email: "lin@example.com", password: "secret-password")
    post login_path, params: { email: other.email, password: "secret-password" }
    file = Tempfile.new([ "kura", ".json" ])
    file.write(payload)
    file.rewind
    post import_path, params: { file: Rack::Test::UploadedFile.new(file.path, "application/json") }
    file.close!
    assert_redirected_to root_path
    assert_equal 1, other.events.count
    assert_equal "Park", other.events.first.title
    assert_equal 1, other.birthdays.count
  end

  test "lock hides the calendar until unlocked" do
    login
    @user.events.create!(title: "Hidden after lock", starts_on: Date.current, ends_on: Date.current)
    post lock_path
    assert_redirected_to unlock_path
    follow_redirect!
    assert_response :success
    refute_includes response.body, "Hidden after lock"

    get root_path
    assert_redirected_to unlock_path
  end

  test "service worker uses the kuracalendar cache" do
    get pwa_service_worker_path(format: :js)
    assert_response :success
    assert_includes response.body, 'const CACHE = "kuracalendar-v1"'
  end

  private
    def login
      post login_path, params: { email: @user.email, password: "secret-password" }
    end
end
