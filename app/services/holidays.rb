module Holidays
  CODES = %w[BR US SI CZ].freeze

  Holiday = Data.define(:date, :key, :country)

  module Pack
    def in_range(start_date, end_date)
      (start_date.year..end_date.year).flat_map { |year| for_year(year) }
        .select { |holiday| holiday.date.between?(start_date, end_date) }
    end

    def item(date, key)
      Holiday.new(date, key, self::CODE)
    end
  end

  class << self
    def packs
      @packs ||= {
        "BR" => Brazil,
        "US" => UnitedStates,
        "SI" => Slovenia,
        "CZ" => Czechia
      }
    end

    def in_range(countries, start_date, end_date)
      Array(countries).uniq.filter_map { |code| packs[code] }.flat_map { |pack|
        pack.in_range(start_date, end_date)
      }.sort_by { |holiday| [ holiday.date, holiday.country, holiday.key.to_s ] }
    end

    # Anonymous Gregorian (Meeus/Jones/Butcher).
    def easter(year)
      a = year % 19
      b, c = year.divmod(100)
      d, e = b.divmod(4)
      f = (b + 8) / 25
      g = (b - f + 1) / 3
      h = (19 * a + b - d - g + 15) % 30
      i, k = c.divmod(4)
      l = (32 + 2 * e + 2 * i - h - k) % 7
      m = (a + 11 * h + 22 * l) / 451
      month, day = (h + l - 7 * m + 114).divmod(31)
      Date.new(year, month, day + 1)
    end

    def nth_wday(year, month, wday, nth)
      date = Date.new(year, month, 1)
      date += (wday - date.wday) % 7
      date + ((nth - 1) * 7)
    end

    def last_wday(year, month, wday)
      date = Date.new(year, month, -1)
      date -= (date.wday - wday) % 7
    end
  end
end
