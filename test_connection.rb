require 'net/http'
require 'uri'

begin
  url = 'https://localhost:443/'
  ca_file = 'ca_cert.pem'

  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_PEER
  http.ca_file = ca_file

  request = Net::HTTP::Get.new(uri.path)
  response = http.request(request)
  puts response.body
 
rescue Errno::ENOENT
  puts "Certificate file not found"
rescue => e
  puts "Error: #{e.message}"
end


