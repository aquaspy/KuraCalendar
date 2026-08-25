require "test_helper"

class HolidaysPacksTest < ActiveSupport::TestCase
  test "united states movable holidays in 2026" do
    by_key = Holidays::UnitedStates.for_year(2026).index_by(&:key)
    assert_equal Date.new(2026, 1, 19), by_key[:mlk].date
    assert_equal Date.new(2026, 2, 16), by_key[:presidents].date
    assert_equal Date.new(2026, 5, 25), by_key[:memorial].date
    assert_equal Date.new(2026, 7, 4), by_key[:independence].date
    assert_equal Date.new(2026, 9, 7), by_key[:labor].date
    assert_equal Date.new(2026, 11, 26), by_key[:thanksgiving].date
  end

  test "slovenia work-free days in 2026" do
    by_key = Holidays::Slovenia.for_year(2026).index_by(&:key)
    assert_equal Date.new(2026, 1, 2), by_key[:new_year_2].date
    assert_equal Date.new(2026, 4, 6), by_key[:easter_monday].date
    assert_equal Date.new(2026, 5, 24), by_key[:pentecost].date
    assert_equal Date.new(2026, 6, 25), by_key[:statehood].date
  end

  test "czechia bank holidays in 2026" do
    by_key = Holidays::Czechia.for_year(2026).index_by(&:key)
    assert_equal Date.new(2026, 4, 3), by_key[:good_friday].date
    assert_equal Date.new(2026, 4, 6), by_key[:easter_monday].date
    assert_equal Date.new(2026, 7, 6), by_key[:jan_hus].date
    assert_equal Date.new(2026, 12, 24), by_key[:christmas_eve].date
  end

  test "in_range merges selected countries" do
    found = Holidays.in_range(%w[BR US], Date.new(2026, 9, 7), Date.new(2026, 9, 7))
    keys = found.map { |holiday| [ holiday.country, holiday.key ] }
    assert_includes keys, [ "BR", :independence ]
    assert_includes keys, [ "US", :labor ]
  end
end
