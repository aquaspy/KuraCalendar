class CalendarImporter
  CAP = 500

  def self.call(user, io)
    payload = JSON.parse(read(io))
    raise ArgumentError, "not an object" unless payload.is_a?(Hash)

    events = Array(payload["events"])
    birthdays = Array(payload["birthdays"])
    raise ArgumentError, "not a KuraCalendar export" if events.empty? && birthdays.empty? && payload["app"] != "KuraCalendar"

    count = 0
    events.first(CAP).each do |row|
      next unless row.is_a?(Hash)
      event = user.events.new(
        title: row["title"],
        body: row["body"].to_s,
        all_day: truthy?(row.fetch("all_day", true)),
        starts_on: row["starts_on"],
        ends_on: row["ends_on"].presence || row["starts_on"],
        starts_at: row["starts_at"],
        ends_at: row["ends_at"]
      )
      count += 1 if event.save
    end
    birthdays.first(CAP).each do |row|
      next unless row.is_a?(Hash)
      birthday = user.birthdays.new(
        name: row["name"],
        month: row["month"],
        day: row["day"],
        year: row["year"],
        body: row["body"].to_s
      )
      count += 1 if birthday.save
    end
    count
  end

  def self.read(io)
    return io if io.is_a?(String)
    io.rewind if io.respond_to?(:rewind)
    io.read
  end
  private_class_method :read

  def self.truthy?(value)
    !%w[0 false no off].include?(value.to_s.strip.downcase) && value != false
  end
  private_class_method :truthy?
end
