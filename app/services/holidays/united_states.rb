module Holidays
  class UnitedStates
    extend Pack
    CODE = "US"

    def self.for_year(year)
      [
        item(Date.new(year, 1, 1), :new_year),
        item(Holidays.nth_wday(year, 1, 1, 3), :mlk),
        item(Holidays.nth_wday(year, 2, 1, 3), :presidents),
        item(Holidays.last_wday(year, 5, 1), :memorial),
        item(Date.new(year, 6, 19), :juneteenth),
        item(Date.new(year, 7, 4), :independence),
        item(Holidays.nth_wday(year, 9, 1, 1), :labor),
        item(Holidays.nth_wday(year, 10, 1, 2), :columbus),
        item(Date.new(year, 11, 11), :veterans),
        item(Holidays.nth_wday(year, 11, 4, 4), :thanksgiving),
        item(Date.new(year, 12, 25), :christmas)
      ]
    end
  end
end
