class BirthdaysController < ApplicationController
  rate_limit to: 60, within: 1.minute, only: :create,
    by: -> { current_user.id },
    with: -> { redirect_back fallback_location: root_path, alert: I18n.t("auth.too_many") }

  def create
    birthday = current_user.birthdays.new(birthday_params)
    save_birthday(birthday)
  end

  def update
    birthday = current_user.birthdays.find(params[:id])
    birthday.assign_attributes(birthday_params)
    save_birthday(birthday)
  end

  def destroy
    birthday = current_user.birthdays.find(params[:id])
    date = landing_date(birthday)
    birthday.destroy
    Birthday.reclaim_space
    redirect_to cal_path(date)
  end

  private
    def birthday_params
      params.require(:birthday).permit(:name, :month, :day, :year, :body)
    end

    def save_birthday(birthday)
      if birthday.save
        redirect_to cal_path(landing_date(birthday))
      else
        redirect_to cal_path(landing_date(birthday)), alert: birthday.errors.full_messages.to_sentence
      end
    end

    def landing_date(birthday)
      year = params[:return_year].presence&.to_i || Date.current.year
      year = Date.current.year unless year.between?(1900, 2100)
      month = birthday.month.presence || Date.current.month
      day = birthday.day.presence || 1
      if month == 2 && day == 29 && !Date.gregorian_leap?(year)
        Date.new(year, 2, 28)
      else
        Date.new(year, month, [ day, Time.days_in_month(month, year) ].min)
      end
    rescue Date::Error, TypeError, ArgumentError
      Date.current
    end
end
