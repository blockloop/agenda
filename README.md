## About

I have a terrible memory and I hate fragmentation. I like to wake up and know what I have to do for the day. Agenda gathers tasks and events from [many sources](#sources) and sends them to you via email or [pushover](https://pushover.net)

## Usage

```shell
cd /opt/ # or wherever you want
git clone git@github.com:brettof86/agenda.git
cd agenda
cp config.example.yaml config.yaml
vim config.yaml #put your info in this file
bundle install
chmod +x agenda
sudo ln -s /opt/agenda/agenda /usr/local/bin/agenda
agenda help
```

## Sources

Right now these are the sources where Agenda pulls from

- Google Calendar
- MS Exchange
- ICloud Reminders
