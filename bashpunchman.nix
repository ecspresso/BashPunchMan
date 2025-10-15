{ lib, pkgs, ... }:

{
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "bashpunchman" ''
      #!/bin/sh

      LOG_TAG="bashpunchman"

      log() {
          local priority="$1"
          shift
          local message="$*"
          if [ $STARTED_BY_SYSTEMD ]; then
            logger -t "$LOG_TAG" -p "user.$priority" "$message"
          else
            echo "[$priority] $message"
          fi
      }

      ERROR_COUNTER=0

      if ! command -v curl >/dev/null; then
        log error 'curl is missing, please install before continuing.'
        ERROR_COUNTER=1
      fi

      if ! command -v zip >/dev/null; then
        log error 'zip is missing, please install before continuing.'
        ERROR_COUNTER=1
      fi

      if [ $ERROR_COUNTER = 1 ]; then
        exit 1;
      fi

      TMP_FOLDER="/tmp"
      MANGA_FOLDER="/kavita/manga/One-Punch Man"
      URL="https://gist.githubusercontent.com/funkyhippo/1d40bd5dae11e03a6af20e5a9a030d81/raw"

      if [ ! -d "$MANGA_FOLDER" ]; then
        log info "Creating $MANGA_FOLDER"
        mkdir -p "$MANGA_FOLDER"
      fi

      log info "Downloading and parsing chapters"
      CHAPTERS=$(curl -s "$URL" | jq '.chapters')
      CHAPTER_KEYS=$(echo "$CHAPTERS" | jq 'keys | .[]')

      for ch in $CHAPTER_KEYS; do
        TITLE=$(echo "$CHAPTERS" | jq ".$ch.title" | tr -d '"')
        FILE_NAME="$TITLE.cbz"

        if [ ! -e "$MANGA_FOLDER/$FILE_NAME" ]; then
          log info "$TITLE missing, downloading"

          COUNTER=$((echo "$CHAPTERS" | jq ".$ch.groups.\"/r/OnePunchMan\" | .[]" | wc -l) - 1)
          mkdir -p "$TMP_FOLDER/$TITLE"

          for i in $(seq 0 $COUNTER); do
            link=$(echo "$CHAPTERS" | jq ".$ch.groups.\"/r/OnePunchMan\" | .[$i]" | tr -d '"')
            curl -sL "$link" -o "$TMP_FOLDER/$TITLE/$i.png"
            log debug "Downloaded $i.png of $COUNTER for $TITLE"
          done

          zip -q -r "$MANGA_FOLDER/$FILE_NAME" "$TMP_FOLDER/$TITLE"
          log info "Created $FILE_NAME"

          rm -r "$TMP_FOLDER/$TITLE"
          log debug "Removed temporary folder $TMP_FOLDER/$TITLE"
        else
          log debug "$MANGA_FOLDER/$FILE_NAME already exists"
        fi
      done

      '')
  ];

  systemd.timers.bashpunchman = {
    description = "Run BashPunchMan Monthly";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "monthly";
      Persistent = true;
      Unit = "bashpunchman.service";
    };
  };

  systemd.services.bashpunchman = {
    description = "One-Punch Man Manga Downloader";
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${lib.getExe pkgs bashpunchman}";
      User = "root";
      StandardOutput = "journal";
      StandardError = "journal";
      SyslogIdentifier = "BashPunchMan";
      Restart = "on-failure";
      RestartSec = "5m";
    };
  };
}