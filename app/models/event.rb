class Event < ApplicationRecord
  TITLE_MAX = 200
  BODY_MAX = 8_000
  PER_USER_CAP = 2_000
  RANGE_MAX = 366

  belongs_to :user

  before_validation :normalize

  validates :title, presence: true, length: { maximum: TITLE_MAX }
  validates :body, length: { maximum: BODY_MAX }
  validates :starts_on, :ends_on, presence: true
  validate :ends_not_before_start
  validate :range_not_absurd
  validate :times_make_sense
  validate :within_cap, on: :create

  scope :in_range, ->(from, to) {
    where("starts_on <= ? AND ends_on >= ?", to, from).order(:starts_on, :id)
  }

  def self.reclaim_space
    connection.execute("VACUUM")
  end

  def time_label
    return if all_day?

    start = format_clock(starts_at)
    finish = format_clock(ends_at)
    return start if finish.blank? || finish == start

    "#{start}–#{finish}"
  end

  def as_export
    {
      "title" => title,
      "body" => body,
      "all_day" => all_day,
      "starts_on" => starts_on&.iso8601,
      "ends_on" => ends_on&.iso8601,
      "starts_at" => format_clock(starts_at),
      "ends_at" => format_clock(ends_at)
    }
  end

  def as_api
    as_export.merge(
      "id" => id,
      "created_at" => created_at&.iso8601,
      "updated_at" => updated_at&.iso8601
    )
  end

  private
    def normalize
      self.title = title.to_s.strip
      self.body = body.to_s
      self.ends_on = starts_on if ends_on.blank? && starts_on.present?
      if all_day
        self.starts_at = nil
        self.ends_at = nil
      end
    end

    def ends_not_before_start
      return if starts_on.blank? || ends_on.blank?
      errors.add(:ends_on, :before_start) if ends_on < starts_on
    end

    def range_not_absurd
      return if starts_on.blank? || ends_on.blank?
      errors.add(:ends_on, :too_long) if (ends_on - starts_on) > RANGE_MAX
    end

    def times_make_sense
      return if all_day?
      errors.add(:starts_at, :blank) if starts_at.blank?
      return if starts_at.blank? || ends_at.blank? || starts_on.blank? || ends_on.blank?
      return if ends_on > starts_on
      errors.add(:ends_at, :before_start) if ends_at < starts_at
    end

    def within_cap
      return unless user
      errors.add(:base, :too_many) if user.events.count >= PER_USER_CAP
    end

    def format_clock(value)
      value&.strftime("%H:%M")
    end
end
