![stability-wip](https://img.shields.io/badge/stability-work_in_progress-lightgrey.svg)

# telegram-bot-motion-rasp

A helper to install motion detection into your raspberry PI and send detected motions via telegram bot.  

## Dependencies
- internet connection
- git
- curl
- motion
- usb webcam connected to your rasp
- personal telegram bot (api token)
- your telegram id (id destination that the messages will be sent)

## How to run (run it on your raspberry)

```sh
git clone https://github.com/dodopontocom/telegram-bot-motion-rasp.git && cd telegram-bot-motion-rasp
```
```sh
echo "export TELEGRAM_TOKEN=<YOUR TELEGRAM BOT TOKEN>" >> .definitions.sh
echo "export NOTIFICATION_ID=<YOUR UNIQ TELEGRAM ID>" >> .definitions.sh
```
```sh
bash ./motion.sh
```

## Note
- run it as default (pi) user
- this version works better in Debian based distribution
