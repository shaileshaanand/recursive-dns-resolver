def get_command_line_argument
  # ARGV is an array that Ruby defines for us,
  # which contains all the arguments we passed to it
  # when invoking the script from the command line.
  # https://docs.ruby-lang.org/en/2.4.0/ARGF.html
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

# `domain` contains the domain name we have to look up.
domain = get_command_line_argument

# File.readlines reads a file and returns an
# array of string, where each element is a line
# https://www.rubydoc.info/stdlib/core/IO:readlines
dns_raw = File.readlines("zone")

# ..
# ..
# FILL YOUR CODE HERE
def parse_dns(dns_raw)
  # parse dns_raw data to a hash where domain points to a list consisting
  # destination and record_type
  dns_records = {}
  dns_raw.each { |dns_entry|
    if dns_entry.strip != "" and dns_entry.strip[0] != "#"
      # first condition checks empty line and the second checks for comment
      dns_row = dns_entry.strip.gsub(" ", "").split(",")
      # removing extra spaces and then splitting by ','
      dns_records[dns_row[1]] = [dns_row[2], dns_row[0]]
    end
  }
  return dns_records
end

def resolve(dns_records, lookup_chain, domain)
  # resolves address to ip
  if dns_records.key?(domain)
    record_type = dns_records[domain][1]
    destination = dns_records[domain][0]
    if record_type == "A"
      lookup_chain.push(destination)
      return lookup_chain
    elsif record_type == "CNAME"
      lookup_chain.push(destination)
      resolve(dns_records, lookup_chain, destination)
    else
      lookup_chain.push("Error: invalid record type '#{record_type}'")
    end
  else
    lookup_chain.push("Error: record not found for #{domain}")
  end
  return lookup_chain
end

# ..
# ..

# To complete the assignment, implement `parse_dns` and `resolve`.
# Remember to implement them above this line since in Ruby
# you can invoke a function only after it is defined.
dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
