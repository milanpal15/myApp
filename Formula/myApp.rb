# myapp.rb
class Myapp < Formula
  desc "MyApp Installer"
  homepage "https://github.com/milanpal15"
  url "https://github.com/myapp/myapp-1.0.tar.gz"
  sha256 "your_sha256_checksum_here"
  version "1.0"

  depends_on "node"
  depends_on "mongodb-community"

  def install
    # Create directories
    prefix.install "frontend", "backend", "nssm.exe"

    # Install frontend dependencies
    system "npm", "config", "set", "cache", "/tmp/npm-cache"
    system "npm", "install", "--legacy-peer-deps", prefix/"frontend"

    # Install backend dependencies
    system "npm", "install", prefix/"backend"

    # Create start scripts
    (prefix/"start-backend.sh").write <<~EOS
      #!/bin/bash
      cd #{prefix}/backend
      echo "Starting Backend Server..."
      npm start
    EOS

    (prefix/"start-frontend.sh").write <<~EOS
      #!/bin/bash
      cd #{prefix}/frontend
      echo "Starting Frontend Server..."
      npm start
    EOS

    (prefix/"control.sh").write <<~EOS
      #!/bin/bash
      echo "MyApp Control Script"
      echo "1. Start Servers"
      echo "2. Stop Servers"
      echo "3. Restart Servers"
      echo "4. Exit"
      read -p "Enter your choice: " choice

      case $choice in
        1)
          #{prefix}/start-backend.sh &
          sleep 5
          #{prefix}/start-frontend.sh &
          ;;
        2)
          pkill -f "node"
          ;;
        3)
          pkill -f "node"
          #{prefix}/start-backend.sh &
          sleep 5
          #{prefix}/start-frontend.sh &
          ;;
        4)
          exit 0
          ;;
        *)
          echo "Invalid choice"
          ;;
      esac
    EOS

    chmod 0755, prefix/"start-backend.sh"
    chmod 0755, prefix/"start-frontend.sh"
    chmod 0755, prefix/"control.sh"
  end

  def caveats
    <<~EOS
      To start, stop, and restart the servers, use:
        #{prefix}/control.sh
    EOS
  end
end
