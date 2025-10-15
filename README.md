# Description

Inspired by [OPM-Scraper](https://github.com/Mowerick/opm-chapter-bot).

BashPunchMan is a Bash script automation tool for downloading One-Punch Man manga chapters from the r/OnePunchMan subreddit and packaging them into CBZ (Comic Book Archive) format files.
It downloads any chapter not found in the target folder and creates a `.cbz` (`.zip`) named the same as the chapter.

I created this with the intention to use it with [Kavita](https://www.kavitareader.com/) but any reader that can handle `.cbz` should do.

Special thanks to [@funkyhippo](https://gist.github.com/funkyhippo) for maintaining the public JSON feed that powers this script:  
[`https://gist.githubusercontent.com/funkyhippo/1d40bd5dae11e03a6af20e5a9a030d81/raw`](https://gist.githubusercontent.com/funkyhippo/1d40bd5dae11e03a6af20e5a9a030d81/raw)


# Usage

### Manually
```bash
./bashpunchman.sh
```

Assuming the provided installation is used:
```bash
/usr/local/bin/bashpunchman.sh
```

### Systemd
Assuming the provided installation is used, to manually run the systemd service:

```bash
systemctl start bashpunchman.service
```

Then follow the logs with 
```bash
journalctl -u bashpunchman.service -f
```

# Installation

Some command may required root access.

## Via script

Downloads the script and enables downloading with a monthly timer via systemd.

```
wget https://raw.githubusercontent.com/ecspresso/BashPunchMan/refs/heads/main/install.sh -O install.sh &&  chmod +x install.sh && ./install.sh && rm install.sh
```

## Manuelly
### Save the script
```bash
git clone git@github.com:ecspresso/BashPunchMan.git
cd BashPunchMan
cp $bashpunchman.sh /usr/local/bin/bashpunchman.sh
chmod +x /usr/local/bin/bashpunchman.sh
```

### Add script to systemd (optional)
#### Copy timer and service
```bash
cp bashpunchman.service /etc/systemd/system/
cp bashpunchman.timer /etc/systemd/system/
```

#### Reload systemd and enable
```bash
systemctl daemon-reload
sudo systemctl enable bashpunchman.service
sudo systemctl enable bashpunchman.timer
```

#### Start timer
```bash
sudo systemctl start bashpunchman.timer
```

### Clean-up (optional)
Delete git folder
```bash
cd ..
rm -r ./BashPunchMan
```

## NixOS
`bashpunchman.nix` adds the script, service and timer. Download it and include it in your configuration to enable.

# Logging

Logging is done to `journal` if run by `systemd`, `stdout` if run manually.

### View all logs
`journalctl -u bashpunchman.service`

### Follow logs in real-time
`journalctl -u bashpunchman.service -f`
