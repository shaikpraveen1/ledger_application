require 'openssl'
def generate_certificate(key, cert, issuer_certificate = nil, serial = 1, validity_years = 1)
  cert.version = 2
  cert.serial = serial
  cert.issuer = issuer_certificate ? issuer_certificate.subject : cert.subject
  cert.public_key = key.public_key
  cert.not_before = Time.now
  cert.not_after = cert.not_before + validity_years * 365 * 24 * 60 * 60
rescue OpenSSL::X509::CertificateError, OpenSSL::PKey::RSAError => e
  puts "Error generating certificate: #{e.message}"
  raise e 
end

def generate_ca
  key = OpenSSL::PKey::RSA.new(2048)
  cert = OpenSSL::X509::Certificate.new
  cert.subject = OpenSSL::X509::Name.parse("/C=IND/O=MyCA/CN=MyCA Root Certificate")
  generate_certificate(key, cert)  
  ef = OpenSSL::X509::ExtensionFactory.new(cert, cert)
  cert.add_extension ef.create_extension("basicConstraints", "CA:TRUE", true)
  cert.add_extension ef.create_extension("subjectKeyIdentifier", "hash")
  cert.add_extension ef.create_extension("authorityKeyIdentifier",
                                         "keyid:always,issuer:always")

  cert.sign(key, OpenSSL::Digest::SHA256.new)

  [key, cert]
end

def generate_server_certificate(ca_key, ca_cert)
  key = OpenSSL::PKey::RSA.new(2048)
  cert = OpenSSL::X509::Certificate.new
  cert.subject = OpenSSL::X509::Name.parse("/C=IND/O=MyCA/CN=localhost")
  generate_certificate(key, cert, ca_cert, 2)
  ef = OpenSSL::X509::ExtensionFactory.new(ca_cert, cert)
  
  cert.extensions = [
    ef.create_extension("basicConstraints", "CA:FALSE", true),
    ef.create_extension("subjectKeyIdentifier", "hash"),
    ef.create_extension("authorityKeyIdentifier", "keyid:always,issuer:always"),
    ef.create_extension("keyUsage", "keyEncipherment,digitalSignature", true),
    ef.create_extension("extendedKeyUsage", "serverAuth", true),
    ef.create_extension("subjectAltName", "DNS:localhost", true)
  ]

  cert.sign(ca_key, OpenSSL::Digest::SHA256.new)

  [key, cert]
end
begin
  ca_key, ca_cert = generate_ca
  File.write('ca_key.pem', ca_key.to_pem)
  File.write('ca_cert.pem', ca_cert.to_pem)
  unless File.exist?('ca_key.pem') && File.exist?('ca_cert.pem')
    raise "CA key or certificate file not found."
  end
  server_key, server_cert = generate_server_certificate(ca_key, ca_cert)

  File.write('server_key.pem', server_key.to_pem)
  File.write('server_cert.pem', server_cert.to_pem)
  puts "Files generated successfully"
  rescue StandardError => e
  puts "Unexpected error: #{e.message}"
end