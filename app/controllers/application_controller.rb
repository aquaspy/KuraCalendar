class ApplicationController < ActionController::Base
  include Authentication
  include Locale
  include Locking
  helper_method :cal_path

  allow_browser versions: :modern unless Rails.env.test?
  stale_when_importmap_changes

  private
    def cal_path(date)
      month_path(year: date.year, month: date.month, day: date.day)
    end
end
