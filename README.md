# SSL Server with Self-Signed Certificate Example

This is a simple Ruby script demonstrating how to create an SSL server with a self-signed certificate using the WEBrick and OpenSSL libraries. Additionally, a script to generate a self-signed Certificate Authority (CA) and server certificate is provided.

## Contents

- [Prerequisites](#prerequisites)
- [Dependencies](#dependencies)
- [Usage](#usage)
  - [Generate CA and Server Certificates](#1-generate-ca-and-server-certificates)
  - [Run SSL Server](#2-run-ssl-server)
  - [Test Connection](#3-test-connection)
  - [Clean Up](#4-clean-up)
  - [Rake task](#5-rake-task)
- [File Descriptions](#file-descriptions)
- [Troubleshooting](#troubleshooting)

## Prerequisites

- Ruby installed on your machine.

## Dependencies

Ensure you have the following gems installed:

- `webrick`
- `openssl`
- `net-http`

## Usage

1. **Generate CA and Server Certificates:**

    Run the following command to generate the Certificate Authority (CA) and server certificates:

    ```bash
    bundle install # Install required gems
    ruby self_signed_certificate_generator.rb
    ```

    This will generate CA and server certificates (`ca_key.pem`, `ca_cert.pem`, `server_key.pem`, `server_cert.pem`).

2. **Run SSL Server:**

    Run the following command to start the SSL server:

    ```bash
    ruby server.rb
    ```

    The server will be available at `https://localhost:443/`.

3. **Test Connection:**

    Run the following command to test the SSL connection to the server:

    ```bash
    ruby test_connection.rb
    ```

    This script sends a simple HTTP GET request to the server and prints the response.

4. **Clean Up:**

    If needed, terminate the server by running:

    ```bash
    pkill -f -TERM server.rb
    ```
5. **Rake Task:**

Run the rake task to check if everything is working, terminate the server before running rake tast

```bash
rake task
```

## File Descriptions

- `server.rb`: The main script to start the SSL server.

- `self_signed_certificate_generator.rb`: A script to generate a self-signed Certificate Authority (CA) and server certificate.

- `test_connection.rb`: A script to test the SSL connection to the server.

- `ca_key.pem`, `ca_cert.pem`: Generated CA key and certificate.

- `server_key.pem`, `server_cert.pem`: Generated server key and certificate.

## Troubleshooting

If you encounter any issues, ensure that you have the required dependencies and that the certificate files are generated successfully or try running as root user. Also ensure all the files are present in the same directory.
