require 'chronic'
require 'httparty'
require 'icalendar'

class PickupService
  BANK_HOLIDAYS_CALANDER_URI = "https://www.gov.uk/bank-holidays/england-and-wales.ics"

  def self.perform(cut_off_time, days_required = 2)
    date = Chronic.parse(cut_off_time)
    available_dates = []

    while available_dates.size < days_required
      date = next_available_date(date)
      available_dates << available_date_hash(date)
      date = next_day(date)
    end

    available_dates
  end

  private

  def self.available_date_hash(date)
    {date:        date.strftime("%a, %d %b %Y"),
     description: parse_day(date)}
  end

  def self.next_day(date)
    date + (3600 * 24)
  end

  def self.next_available_date(date)
    date = next_day(date) if cut_off_date_passed?(date)
    skip_weekends_and_holidays(date)
  end

  def self.skip_weekends_and_holidays(date)
    while is_weekend?(date) || is_bank_holiday?(date)
      date = next_day(date)
      next_available_date(date)
    end

    date
  end

  def self.is_weekend?(date)
    date.sunday? || date.saturday?
  end

  def self.cut_off_date_passed?(date)
    date <= Time.now
  end

  def self.parse_day(date)
    return "Today" if date.to_date == Date.today
    return "Tomorrow" if date.to_date == Date.today.to_date + 1
    date.strftime("%A")
  end

  def self.is_bank_holiday?(date)
    @bank_holidays ||= fetch_bank_holidays
    @bank_holidays.any? {|bank_holiday| bank_holiday.to_date == date.to_date}
  end

  def self.fetch_bank_holidays
    bank_holidays = []
    response = HTTParty.get BANK_HOLIDAYS_CALANDER_URI
    if response.code == 200
      calanders = Icalendar.parse(response)
      cal = calanders.first
      cal.events.each do |e|
        bank_holidays << e.dtstart
      end
    end

    bank_holidays
  end
end
