![stability-wip](https://img.shields.io/badge/stability-work_in_progress-lightgrey.svg)

# telegram-bot-motion-rasp

A helper to install motion detection into your raspberry PI and send detected motions via telegram bot.

## Good for?

- monitoring houses
- monitoring babies
- watching birds
- monitoring pets
- monitoring harmful insects
- employees
- (...)

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
## Crontab -e

a good think to do is adding the script to a crontab job to run the verification any time you desire

```sh
crontab -e
```

add the following line (ex.: run it every 12 minutes)

```sh
*/12 * * * * /home/pi/telegram-bot-motion-rasp/motion.sh
```

## Note
- run it as default (pi) user
- this version works better in Debian based distribution
