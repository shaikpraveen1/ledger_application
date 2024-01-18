# # server.rb
require 'openssl'
require 'webrick'
require 'webrick/https'

server = WEBrick::HTTPServer.new(
  Port: 443,
  SSLEnable: true,
  SSLCertName: [['CN', WEBrick::Utils::getservername]],
  SSLPrivateKey: OpenSSL::PKey::RSA.new(File.read('server_key.pem')),
  SSLCertificate: OpenSSL::X509::Certificate.new(File.read('server_cert.pem'))
)
trap('TERM') { server.shutdown }

server.mount_proc '/' do |req, res|
  begin
   res.body= "Certificate Expiration Date: #{server.config[:SSLCertificate].not_after}"
  rescue Errno::ENOENT
    "Certificate file not found"
  rescue OpenSSL::X509::CertificateError => e
    "Error reading certificate: #{e.message}"
  rescue OpenSSL::PKey::RSAError => e
    "Error reading private key: #{e.message}"
  rescue OpenSSL::SSL::SSLError => e
    "SSL/TLS error: #{e.message}"
  rescue => e
    "Unexpected error: #{e.message}"
  end
end
server.start





