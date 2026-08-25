module ApplicationHelper
  def signup_enabled?
    Kura.signup_enabled?
  end

  def cal_path(date)
    month_path(year: date.year, month: date.month, day: date.day)
  end

  def month_nav_path(month, keep_day)
    day = [ keep_day, Time.days_in_month(month.month, month.year) ].min
    month_path(year: month.year, month: month.month, day: day)
  end

  def holiday_name(holiday)
    name = t("holidays.#{holiday.country.downcase}.#{holiday.key}")
    current_user.holiday_country_codes.size > 1 ? "#{name} · #{holiday.country}" : name
  end

  def clock_value(value)
    value&.strftime("%H:%M")
  end
end
