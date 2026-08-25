class CalendarGrid
  Cell = Data.define(:date, :in_month, :today, :selected, :events, :birthdays, :holidays, :tag_countries) do
    def marks
      list = []
      holidays.each { |holiday| list << [ :holiday, holiday_label(holiday) ] }
      birthdays.each { |birthday| list << [ :birthday, birthday.name ] }
      events.each { |event| list << [ :event, event.title ] }
      extra = [ list.size - 3, 0 ].max
      [ list.first(3), extra ]
    end

    def holiday_label(holiday)
      name = I18n.t("holidays.#{holiday.country.downcase}.#{holiday.key}")
      tag_countries ? "#{name} · #{holiday.country}" : name
    end

    def empty?
      events.empty? && birthdays.empty? && holidays.empty?
    end
  end

  def initialize(user:, month:, selected:)
    @user = user
    @month = month.beginning_of_month
    @selected = selected
    @today = Date.current
  end

  attr_reader :month, :selected, :today

  def start_date
    @month.beginning_of_week(:monday)
  end

  def end_date
    @month.end_of_month.end_of_week(:monday)
  end

  def prev_month
    @month.prev_month
  end

  def next_month
    @month.next_month
  end

  def weekday_indexes
    [ 1, 2, 3, 4, 5, 6, 0 ]
  end

  def cells
    @cells ||= build_cells
  end

  def selected_cell
    cells.find { |cell| cell.selected } || cells.find { |cell| cell.date == @selected }
  end

  private
    def build_cells
      events_by_date = Hash.new { |hash, date| hash[date] = [] }
      @user.events.in_range(start_date, end_date).each do |event|
        (event.starts_on..event.ends_on).each do |date|
          events_by_date[date] << event if date.between?(start_date, end_date)
        end
      end

      birthdays = @user.birthdays.to_a
      birthdays_by_date = Hash.new { |hash, date| hash[date] = [] }
      (start_date..end_date).each do |date|
        birthdays.each { |birthday| birthdays_by_date[date] << birthday if birthday.observed_on?(date) }
      end

      holidays_by_date = Hash.new { |hash, date| hash[date] = [] }
      codes = @user.holiday_country_codes
      Holidays.in_range(codes, start_date, end_date).each do |holiday|
        holidays_by_date[holiday.date] << holiday
      end
      tag_countries = codes.size > 1

      (start_date..end_date).map do |date|
        Cell.new(
          date: date,
          in_month: date.month == @month.month && date.year == @month.year,
          today: date == @today,
          selected: date == @selected,
          events: events_by_date[date],
          birthdays: birthdays_by_date[date],
          holidays: holidays_by_date[date],
          tag_countries: tag_countries
        )
      end
    end
end
