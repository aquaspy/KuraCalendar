class Birthday < ApplicationRecord
  NAME_MAX = 200
  BODY_MAX = 8_000
  PER_USER_CAP = 500
  DAYS_IN_MONTH = [ nil, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ].freeze

  belongs_to :user

  before_validation :normalize

  validates :name, presence: true, length: { maximum: NAME_MAX }
  validates :body, length: { maximum: BODY_MAX }
  validates :month, numericality: { only_integer: true, in: 1..12 }
  validates :day, numericality: { only_integer: true, in: 1..31 }
  validates :year, numericality: { only_integer: true, in: 1900..2100 }, allow_nil: true
  validate :day_exists
  validate :within_cap, on: :create

  def self.reclaim_space
    connection.execute("VACUUM")
  end

  def observed_on?(date)
    return false if date.blank?
    if month == 2 && day == 29
      return date.month == 2 && date.day == 29 if Date.gregorian_leap?(date.year)
      return date.month == 2 && date.day == 28
    end
    date.month == month && date.day == day
  end

  def age_in(year)
    return if self.year.blank?
    year - self.year
  end

  def label_on(date)
    age = age_in(date.year)
    age && age >= 0 ? "#{name} (#{age})" : name
  end

  def as_export
    {
      "name" => name,
      "month" => month,
      "day" => day,
      "year" => year,
      "body" => body
    }
  end

  private
    def normalize
      self.name = name.to_s.strip
      self.body = body.to_s
      self.year = nil if year.blank?
    end

    def day_exists
      return if month.blank? || day.blank?
      max = DAYS_IN_MONTH[month]
      errors.add(:day, :invalid) if max.nil? || day < 1 || day > max
    end

    def within_cap
      return unless user
      errors.add(:base, :too_many) if user.birthdays.count >= PER_USER_CAP
    end
end
