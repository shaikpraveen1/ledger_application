task :test do
  system('ruby self_signed_certificate_generator.rb')
  system('ruby server.rb &')
  sleep(2)
  system('ruby test_connection.rb')
  system('pkill -f -TERM server.rb')
end
