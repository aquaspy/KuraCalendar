require "test_helper"

class ApiV1Test < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email: "ada@example.com", password: "secret-password")
    @token = ApiToken.generate_for(@user, name: "hermes")
    @token.save!
    @auth = { "Authorization" => "Bearer #{@token.raw_token}" }
  end

  test "requests without a token are rejected" do
    get api_v1_events_path
    assert_response :unauthorized
    assert_equal "unauthorized", JSON.parse(response.body)["error"]
  end

  test "requests with a bogus token are rejected" do
    get api_v1_events_path, headers: { "Authorization" => "Bearer kura_bogus" }
    assert_response :unauthorized
  end

  test "lists events within a date range" do
    @user.events.create!(title: "Dentist", starts_on: "2026-09-25", ends_on: "2026-09-25")
    @user.events.create!(title: "Far away", starts_on: "2026-11-01", ends_on: "2026-11-01")

    get api_v1_events_path(from: "2026-09-01", to: "2026-09-30"), headers: @auth
    assert_response :success
    titles = JSON.parse(response.body)["events"].map { |event| event["title"] }
    assert_equal [ "Dentist" ], titles
  end

  test "an agent can create, read, update and delete an event" do
    post api_v1_events_path, headers: @auth, as: :json, params: {
      event: { title: "Call", starts_on: "2026-09-26", all_day: false, starts_at: "14:30", ends_at: "15:00" }
    }
    assert_response :created
    created = JSON.parse(response.body)["event"]
    assert_equal "Call", created["title"]
    assert_equal "14:30", created["starts_at"]
    id = created["id"]

    get api_v1_event_path(id), headers: @auth
    assert_response :success
    assert_equal "Call", JSON.parse(response.body)["event"]["title"]

    patch api_v1_event_path(id), headers: @auth, as: :json, params: {
      event: { title: "Call rescheduled" }
    }
    assert_response :success
    assert_equal "Call rescheduled", JSON.parse(response.body)["event"]["title"]

    delete api_v1_event_path(id), headers: @auth
    assert_response :no_content
    assert_nil @user.events.find_by(id: id)
  end

  test "event endpoints accept flat params for simpler agents" do
    post api_v1_events_path, headers: @auth, as: :json, params: {
      title: "Flat", starts_on: "2026-09-26"
    }
    assert_response :created
    assert_equal "Flat", JSON.parse(response.body)["event"]["title"]
  end

  test "invalid events return errors" do
    post api_v1_events_path, headers: @auth, as: :json, params: {
      event: { title: "" }
    }
    assert_response :unprocessable_entity
    assert JSON.parse(response.body)["errors"].any?
  end

  test "invalid date filters return errors" do
    get api_v1_events_path(from: "not-a-date"), headers: @auth
    assert_response :unprocessable_entity
    assert JSON.parse(response.body)["errors"].any?
  end

  test "an agent can manage birthdays" do
    post api_v1_birthdays_path, headers: @auth, as: :json, params: {
      birthday: { name: "Eben", month: 8, day: 11, year: 1990 }
    }
    assert_response :created
    id = JSON.parse(response.body)["birthday"]["id"]

    get api_v1_birthdays_path, headers: @auth
    assert_response :success
    assert_equal "Eben", JSON.parse(response.body)["birthdays"].first["name"]

    patch api_v1_birthday_path(id), headers: @auth, as: :json, params: {
      birthday: { year: 1991 }
    }
    assert_response :success
    assert_equal 1991, JSON.parse(response.body)["birthday"]["year"]

    delete api_v1_birthday_path(id), headers: @auth
    assert_response :no_content
    assert_nil @user.birthdays.find_by(id: id)
  end

  test "one user cannot touch another user's records" do
    event = @user.events.create!(title: "Secret", starts_on: "2026-09-25", ends_on: "2026-09-25")
    other = User.create!(email: "other@example.com", password: "secret-password")
    other_token = ApiToken.generate_for(other, name: "other")
    other_token.save!

    get api_v1_event_path(event), headers: { "Authorization" => "Bearer #{other_token.raw_token}" }
    assert_response :not_found
    assert_equal "Secret", event.reload.title
  end

  test "revoked tokens stop working" do
    @token.destroy
    get api_v1_events_path, headers: @auth
    assert_response :unauthorized
  end

  test "tokens keep working while the app is locked" do
    post login_path, params: { email: @user.email, password: "secret-password" }
    post lock_path
    assert_redirected_to unlock_path

    get api_v1_events_path, headers: @auth
    assert_response :success
  end

  test "using a token records its last use" do
    assert_nil @token.last_used_at
    get api_v1_events_path, headers: @auth
    assert_response :success
    assert_not_nil @token.reload.last_used_at
  end
end
