module Holidays
  class Brazil
    extend Pack
    CODE = "BR"

    def self.easter(year)
      Holidays.easter(year)
    end

    def self.for_year(year)
      paschal = Holidays.easter(year)
      [
        item(Date.new(year, 1, 1), :new_year),
        item(paschal - 47, :carnival),
        item(paschal - 2, :good_friday),
        item(paschal, :easter),
        item(Date.new(year, 4, 21), :tiradentes),
        item(Date.new(year, 5, 1), :labor),
        item(paschal + 60, :corpus_christi),
        item(Date.new(year, 9, 7), :independence),
        item(Date.new(year, 10, 12), :aparecida),
        item(Date.new(year, 11, 2), :finados),
        item(Date.new(year, 11, 15), :republic),
        item(Date.new(year, 11, 20), :black_awareness),
        item(Date.new(year, 12, 25), :christmas)
      ]
    end
  end
end
