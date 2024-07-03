# Firefox Browser Setup

- [Installation](#installation)
- [Appearance](#appearance)
- [Setting](#setting)
  - [General](#general)
  - [Home](#home)
  - [Privacy \& Security](#privacy--security)
- [Developer Tools](#developer-tools)
- [Extensions \& Themes](#extensions--themes)
  - [Extensions](#extensions)
- [Bookmark](#bookmark)

## Installation

- [Firefox](https://www.mozilla.org/en-US/firefox/new/)

## Appearance

- Customize : 빵모양 -> Customize

## Setting

### General

Tabs

- [ ] Ctrl+Tab cycles through tabs in recently used order
- [X] Open links in tabs instead of new windows
- [ ] When you open a link in a new tab, switch to it immediately

Zoom

- Default zoom : 110~120%
- [X] Zoom text only

### Home

Firefox Home Content

- [X] Web Search

### Privacy & Security

Logins and Passwords

- [ ] Ask to save logins and passwords for websites
  - ...

History

- Firefox will 'Never remember history'

## Developer Tools

- setting : "..." -> Settings
  - Theme
    - [X] Dark
  - Advanced Setttings
    - Enabling the Browser Toolbox
      - [X] Enable browser chrome and add-on debugging toolboxes
        - [X] Enable remote debugging

## Extensions & Themes

### Extensions

- AdBlocker Ultimate
- Dark Reader
- LastPass
- Perfect Home
- Octotree - GitHub code tree

## Bookmark

Import bookmark from chrome

https://support.mozilla.org/ko/kb/import-bookmarks-google-chrome

Import from file

http://kb.mozillazine.org/Import_bookmarks#Import_from_file

Exporting bookmark

기본적으로 firefox 3이상에서는 sqlite에 북마크를 저장. but `about:config` 에 들어가서 `browser.bookmarks.autoExportHTML` 를 true로 하면 `bookmarks.html` file이 생성됨

http://kb.mozillazine.org/Export_bookmarks

http://kb.mozillazine.org/Browser.bookmarks.autoExportHTML