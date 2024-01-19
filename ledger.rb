require 'json'
require 'date'
require 'pry'

class LedgerEntry
  attr_accessor :activity_id, :date, :type, :method, :amount, :balance, :requester, :source, :destination

  def initialize(entry_data)
    @activity_id = entry_data["activity_id"]
    @date = DateTime.parse(entry_data["date"])
    @type = entry_data["type"]
    @method = entry_data["method"]
    @amount = entry_data["amount"]
    @balance = entry_data["balance"]
    @requester = entry_data["requester"]
    @source = entry_data["source"]
    @destination = entry_data["destination"]
  end

  def description
    case type
    when 'DEPOSIT'
      "Deposit from #{source['description']} for your investment in #{destination['description']}"
    when 'INVESTMENT'
      "#{type.capitalize} of $#{amount} in #{destination['description']}"
    when 'REFUND'
      "Refund of $#{amount} from #{source['description']} for your investment in #{destination['description']}"
    when 'WITHDRAWAL'
      "#{type.capitalize} of $#{amount} to #{destination['description']} from #{source['description']}"
    when 'TRANSFER'
      "#{type.capitalize} of $#{amount} from #{source['description']} to #{destination['description']}"
    else
      "#{type.capitalize} of $#{amount} #{destination['description']}"
    end
  end
end

class LedgerProcessor
  def initialize(ledger_data)
    @ledger_entries = process_ledger_data(ledger_data)
  end

  def process_ledger_data(ledger_data)
    ledger_data.map { |entry_data| LedgerEntry.new(entry_data) }
  end

  def remove_duplicate_entries
    @ledger_entries.uniq { |entry| entry.activity_id }
  end

  def sort_ledger
    @ledger_entries.sort_by { |entry| [-entry.date.to_time.to_i, entry.activity_id] }
  end

  def display_ledger
    sorted_ledger = sort_ledger
    puts "Your investing account ($#{sorted_ledger.last&.balance || 0} available)"
    # date_range=sorted_ledger.last&.date&.strftime('%m/%d/%Y') - sorted_ledger.first&.date&.strftime('%m/%d/%Y')
    puts "#{sorted_ledger.last&.date&.strftime('%m/%d/%Y')} - #{sorted_ledger.first&.date&.strftime('%m/%d/%Y').ljust(40)}" if sorted_ledger.any?
  
    puts "| Date        | Type        |        Amount   |        Balance   |    Description    "
    puts "-------------------------------------------------------------------------------------------------------------------------------------------------------------------"
  
    sorted_ledger.each do |entry|
      source_description = entry.source&.dig('description').to_s
      destination_description = entry.destination&.dig('description').to_s
  
      puts "#{entry.date.strftime('%Y-%m-%d')} | #{entry.type.ljust(11)} | #{entry.amount.to_s.ljust(10)} | #{entry.balance.to_s.ljust(10)} |  #{entry.description.ljust(30)}"
    end
  end
  
  
end
# Example usage with three ledgers
ledger_files = ['data/simple_ledger.json', 'data/duplicate_ledger.json', 'data/complicated_ledger.json']
combined_ledger_data = []

ledger_files.each do |file_path|
  ledger_data = JSON.parse(File.read(file_path))
  combined_ledger_data += ledger_data
end

ledger_processor = LedgerProcessor.new(combined_ledger_data.uniq)

# Remove duplicates and display the sorted ledger
puts "Filtered and Combined Ledger (without duplicates):"
ledger_processor.remove_duplicate_entries.each { |entry| puts entry.inspect }

# Display the sorted ledger
puts "\nSorted and Combined Ledger:"
ledger_processor.display_ledger
