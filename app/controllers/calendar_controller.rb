class CalendarController < ApplicationController
  def show
    @grid = CalendarGrid.new(user: current_user, month: month_date, selected: selected_date)
  end

  def export
    payload = {
      "app" => "KuraCalendar",
      "exported_at" => Time.current.iso8601,
      "events" => current_user.events.order(:starts_on, :id).map(&:as_export),
      "birthdays" => current_user.birthdays.order(:month, :day, :id).map(&:as_export)
    }
    send_data JSON.pretty_generate(payload),
      filename: "kuracalendar-#{Date.current}.json",
      type: "application/json"
  end

  def import
    file = params[:file]
    raise ArgumentError, "missing file" unless file.respond_to?(:read)
    count = CalendarImporter.call(current_user, file)
    redirect_to root_path, notice: t("app.import_done", count: count)
  rescue ArgumentError, JSON::ParserError, TypeError, NoMethodError => e
    Rails.logger.warn("[import] #{e.class}: #{e.message}")
    redirect_to root_path, alert: t("app.import_invalid")
  end

  def update_holidays
    current_user.holiday_country_codes = params[:countries]
    current_user.save!
    redirect_to cal_path(selected_date)
  end

  private
    def month_date
      year = params[:year].presence&.to_i
      month = params[:month].presence&.to_i
      Date.new(year, month, 1)
    rescue Date::Error, TypeError, ArgumentError
      Date.current.beginning_of_month
    end

    def selected_date
      month = month_date
      if params[:day].present?
        Date.new(month.year, month.month, params[:day].to_i)
      elsif Date.current.year == month.year && Date.current.month == month.month
        Date.current
      else
        month
      end
    rescue Date::Error, TypeError, ArgumentError
      month_date
    end
end
