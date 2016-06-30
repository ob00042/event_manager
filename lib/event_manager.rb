require "csv"
require "sunlight/congress"
require "erb"

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, "0")[0..4]
end

def legislators_by_zipcode(zipcode)
  legislators = Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def save_thank_you_letters(id, form_letter)
  Dir.mkdir("output") unless Dir.exists? "output"

  filename = "output/thanks_#{id}.html"

  File.open(filename, "w") do |file|
	file.puts form_letter
  end
end

def clean_phone_number(phone)

	phone = phone.to_s.scan(/[\d*]/).join

	unless phone.length == 10
	  if phone.length == 11 && phone[0] == "1"
		phone = phone[1..-1]
	  else
		phone = "0000000000"
	  end
	end

	phone

end

def check_hour(date)

  full_time = DateTime.strptime(date, "%m/%d/%y %H:%M")
  hour = full_time.hour
  @visited_day << full_time.wday

  @visited_hour += hour
  @count += 1

end

def common_day
  avg_day = @visited_day.group_by(&:itself).values.max_by(&:size).first
  case avg_day.to_s
  when "0"
  	puts "Sunday"
  when "1"
  	puts "Monday"
  when "2"
  	puts "Tuesday"
  when "3"
  	puts "Wednesday"
  when "4"
  	puts "Thursday"
  when "5"
  	puts "Friday"
  when "6"
  	puts "Saturday"
  else
  	puts "Oh fuck off"
  end
end

puts "EventManager Initialized!"

contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol

template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter

@visited_hour = 0
@visited_day = []
@count = 0

contents.each do |row|
	id = row[0]
	name = row[:first_name]
	
	zipcode = clean_zipcode(row[:zipcode])

	legislators = legislators_by_zipcode(zipcode)

	form_letter = erb_template.result(binding)

	#save_thank_you_letters(id, form_letter)

	phone_number = clean_phone_number(row[:homephone])

	hour = check_hour(row[:regdate])

end

avegare_hour = @visited_hour/@count

puts "Most people registered at #{avegare_hour}"

print "Most common day is "
common_day
