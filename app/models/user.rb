class User < ApplicationRecord
  HOLIDAY_PACKS = Holidays::CODES

  has_secure_password
  has_many :events, dependent: :destroy
  has_many :birthdays, dependent: :destroy

  normalizes :email, with: -> { it.strip.downcase }

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, allow_nil: true

  def holiday_country_codes
    holiday_countries.to_s.split(/[,\s]+/).map(&:upcase).select { |code| HOLIDAY_PACKS.include?(code) }.uniq
  end

  def holiday_country_codes=(codes)
    self.holiday_countries = Array(codes).flatten.map { |code| code.to_s.upcase }
      .select { |code| HOLIDAY_PACKS.include?(code) }.uniq.join(",")
  end
end
