# HexTeX

A simple discord slash-command LaTeX renderer written in bash (with a hint of php)

[Invite my instance](https://hexf.me/cgi/hextex/invite)


## Dependencies

* CGI Server (e.g. NGINX)
* PHP 7.2+ (used for libsodium)
* PDFLaTeX
* ImageMagick
* jq
* Bash

## Installation

1. Copy git repository into folder with CGI access
2. `cp credentials.json.sample credentials.json`
3. Fill credentials in for Discord bot
4. Run `bash publish.sh` to register commands with Discord
5. Invite the bot at `https://hexf.me/cgi/hextex/invite` or whatever your URL is

