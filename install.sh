#!/bin/sh

if ! command -v curl >/dev/null; then
  echo "installing curl"
  apt-get install curl -y
fi

if ! command -v zip >/dev/null; then
  echo "installing zip"
  apt-get install zip -y
fi

echo "downlading script to /usr/local/bin/bashpunchman.sh"
curl -s https://raw.githubusercontent.com/ecspresso/BashPunchMan/refs/heads/main/bashpunchman.sh -o /usr/local/bin/bashpunchman.sh
echo "downlading timer to /etc/systemd/system/bashpunchman.timer"
curl -s https://raw.githubusercontent.com/ecspresso/BashPunchMan/refs/heads/main/bashpunchman.timer -o /etc/systemd/system/bashpunchman.timer
echo "downlading service to /etc/systemd/system/bashpunchman.service"
curl -s https://raw.githubusercontent.com/ecspresso/BashPunchMan/refs/heads/main/bashpunchman.service -o /etc/systemd/system/bashpunchman.service

chmod +x /usr/local/bin/bashpunchman.sh

echo "reloading systemd daemon"
systemctl daemon-reload

echo "enabling"
sudo systemctl enable bashpunchman.service
sudo systemctl enable bashpunchman.timer
sudo systemctl start bashpunchman.timer

echo "timer and service status:"
systemctl status bashpunchman.timer
systemctl status bashpunchman.service