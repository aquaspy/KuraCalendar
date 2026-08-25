module Holidays
  class Czechia
    extend Pack
    CODE = "CZ"

    def self.for_year(year)
      paschal = Holidays.easter(year)
      [
        item(Date.new(year, 1, 1), :new_year),
        item(paschal - 2, :good_friday),
        item(paschal + 1, :easter_monday),
        item(Date.new(year, 5, 1), :labor),
        item(Date.new(year, 5, 8), :liberation),
        item(Date.new(year, 7, 5), :cyril_methodius),
        item(Date.new(year, 7, 6), :jan_hus),
        item(Date.new(year, 9, 28), :statehood),
        item(Date.new(year, 10, 28), :czechoslovak),
        item(Date.new(year, 11, 17), :freedom),
        item(Date.new(year, 12, 24), :christmas_eve),
        item(Date.new(year, 12, 25), :christmas),
        item(Date.new(year, 12, 26), :st_stephen)
      ]
    end
  end
end
