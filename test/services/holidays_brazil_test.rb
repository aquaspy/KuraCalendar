require "test_helper"

class HolidaysBrazilTest < ActiveSupport::TestCase
  test "easter 2026 is 5 april" do
    assert_equal Date.new(2026, 4, 5), Holidays::Brazil.easter(2026)
  end

  test "carnival 2026 is 17 february" do
    carnival = Holidays::Brazil.for_year(2026).find { |holiday| holiday.key == :carnival }
    assert_equal Date.new(2026, 2, 17), carnival.date
  end

  test "good friday and corpus christi follow easter 2026" do
    by_key = Holidays::Brazil.for_year(2026).index_by(&:key)
    assert_equal Date.new(2026, 4, 3), by_key[:good_friday].date
    assert_equal Date.new(2026, 6, 4), by_key[:corpus_christi].date
  end

  test "independence day is 7 september" do
    found = Holidays::Brazil.in_range(Date.new(2026, 9, 1), Date.new(2026, 9, 30))
    assert found.any? { |holiday| holiday.key == :independence && holiday.date == Date.new(2026, 9, 7) }
  end

  test "known easter years" do
    assert_equal Date.new(2025, 4, 20), Holidays::Brazil.easter(2025)
    assert_equal Date.new(2024, 3, 31), Holidays::Brazil.easter(2024)
    assert_equal Date.new(2000, 4, 23), Holidays::Brazil.easter(2000)
  end
end
