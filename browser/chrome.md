# Chrome Browser Setup

- [Installation](#installation)
- [Setting](#setting)
  - [Manage what you sync](#manage-what-you-sync)
- [Run in incognito mode](#run-in-incognito-mode)
- [Bookmark](#bookmark)

## Installation

https://www.google.com/chrome/

## Setting

### Manage what you sync

- Apps
- Bookmarks
- Extensions
- Setttings

## Run in incognito mode

https://www.techwalla.com/articles/how-to-always-launch-chrome-in-incognito-on-a-mac

Save as Application

```sh
do shell script "open -a Google\\ Chrome --new --args -incognito"
```

## Bookmark

Backup

```sh
# backup
cp "/Users/${USER}/Library/Application Support/Google/Chrome/Default/Bookmarks" ${path_to_backup}

# restore
cp ${path_to_backup} "/Users/${USER}/Library/Application Support/Google/Chrome/Default/Bookmarks"
```
