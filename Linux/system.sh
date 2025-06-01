#!/bin/bash
set -e

USER_NAME=$(logname)
USER_HOME=$(eval echo "~$USER_NAME")
USER_SHELL=$(getent passwd "$USER_NAME" | cut -d: -f7)
SHELL_EXEC_PATH=$(which "$USER_SHELL")

# Identify OS version and name
OS_NAME=$(uname -s)
if [ -f /etc/os-release ]; then
    OS_VERSION=$(grep "PRETTY_NAME" /etc/os-release | cut -d= -f2 | tr -d '"')
else
    OS_VERSION="Unknown"
fi

# Save information to UserInfo.txt
cat <<EOF > UserInfo.txt
User Name: $USER_NAME
Shell Name: $USER_SHELL
Shell Executable Path: $SHELL_EXEC_PATH
OS Version: $OS_VERSION
OS Name: $OS_NAME
EOF

# List files in the user's home directory
ls -a "$USER_HOME" > UserHomeFileList.txt

# List all directories and files in /var/log
ls -alR /var/log > log.txt

# Create directory in /opt
EXAMPLE_DIR="/opt/example_dir"
mkdir -p "$EXAMPLE_DIR"

# Create symbolic links in /opt/example_dir
ln -sf "$(pwd)/UserInfo.txt" "$EXAMPLE_DIR/UserInfo.txt"
ln -sf "$(pwd)/UserHomeFileList.txt" "$EXAMPLE_DIR/UserHomeFileList.txt"
ln -sf "$(pwd)/log.txt" "$EXAMPLE_DIR/log.txt"

# Install nginx if not already installed
if ! command -v nginx &> /dev/null; then
    apt-get update
    apt-get install -y nginx
fi

# Get the private IP address
PRIVATE_IP=$(hostname -I | awk '{print $1}')

# Update server_name in nginx config
NGINX_DEFAULT_CONF="/etc/nginx/sites-available/default"
if grep -q "server_name" "$NGINX_DEFAULT_CONF"; then
    sed -i "s/server_name .*/server_name $PRIVATE_IP;/" "$NGINX_DEFAULT_CONF"
else
    # Add server_name if not present
    sed -i "/listen 80 default_server;/a\\\tserver_name $PRIVATE_IP;" "$NGINX_DEFAULT_CONF"
fi

# Replace NGINX default page with UserInfo.txt content
cp UserInfo.txt /var/www/html/index.nginx-debian.html

# Enable and restart nginx
systemctl enable nginx
systemctl restart nginx

echo "Script executed successfully."
echo "You can view the UserInfo.txt content at: http://$PRIVATE_IP"

