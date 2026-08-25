module Holidays
  class Slovenia
    extend Pack
    CODE = "SI"

    def self.for_year(year)
      paschal = Holidays.easter(year)
      [
        item(Date.new(year, 1, 1), :new_year),
        item(Date.new(year, 1, 2), :new_year_2),
        item(Date.new(year, 2, 8), :preseren),
        item(paschal, :easter),
        item(paschal + 1, :easter_monday),
        item(Date.new(year, 4, 27), :uprising),
        item(Date.new(year, 5, 1), :labor),
        item(Date.new(year, 5, 2), :labor_2),
        item(paschal + 49, :pentecost),
        item(Date.new(year, 6, 25), :statehood),
        item(Date.new(year, 8, 15), :assumption),
        item(Date.new(year, 10, 31), :reformation),
        item(Date.new(year, 11, 1), :all_saints),
        item(Date.new(year, 12, 25), :christmas),
        item(Date.new(year, 12, 26), :independence)
      ]
    end
  end
end
