# MacOS Setup

- [Launch Agent](#launch-agent)
- [System preference](#system-preference)
    - [Keyboard](#keyboard)
    - [Pointer Control](#pointer-control)
    - [Trackpad](#trackpad)
    - [Sound](#sound)
    - [Appearance](#appearance)
    - [Desktop \& Dock](#desktop--dock)
    - [Displays](#displays)
    - [Battery](#battery)
    - [Menu Bar](#menu-bar)
    - [Date \& Time](#date--time)
- [Finder](#finder)
- [Utils](#utils)
    - [DisplayLink](#displaylink)
    - [Scroll Reverser](#scroll-reverser)
    - [Rectangle](#rectangle)
    - [RunCat](#runcat)
    - [Hammerspoon](#hammerspoon)
    - [Itsycal](#itsycal)
- [Optional Utils](#optional-utils)
    - [IINA](#iina)
    - [Gif Brewery 3 by gfycat](#gif-brewery-3-by-gfycat)
- [See also](#see-also)

## Launch Agent

- Add this scripts to `~/Library/LaunchAgents/com.user.hidutil.f18.plist`.
- script
```shell
mkdir -p ~/Library/LaunchAgents/
vi ~/Library/LaunchAgents/com.user.hidutil.f18.plist
```
- xml
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
 "http://www.apple.com/DTDs/PropertyList-1.0.dtd">

<!--
  macOS LaunchAgent for hidutil key remapping

  Purpose:
  - Remap Right Command key (⌘) -> F18 at login

  HID codes:
  - 0x7000000E7 = Right Command
  - 0x70000006D = F18
-->
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.hidutil.f18</string>

    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/hidutil</string>
        <string>property</string>
        <string>--set</string>
        <string>
        {
            "UserKeyMapping":[
                {
                    "HIDKeyboardModifierMappingSrc":0x7000000E7,
                    "HIDKeyboardModifierMappingDst":0x70000006D
                }
            ]
        }
        </string>
    </array>

    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
```
- Load
```shell
launchctl load ~/Library/LaunchAgents/com.user.hidutil.f18.plist
```
- Check
```shell
hidutil property --get "UserKeyMapping"
```
- Unload
```shell
launchctl unload ~/Library/LaunchAgents/com.user.hidutil.f18.plist
```

## System preference

### Keyboard

- [ ] Adjust keyboard brightness in low light
- Keyboard brightness to 30%
- Turn keyboard backlight off after inactivity to **Never**
- Keyboard Shortcuts
    - Launchpad & Dock
        - [ ] Turn Dock hiding on/off
    - Mission Control
        - [ ] Show Desktop
    - Input Sources
        - [ ] Select the previous input source
        - [X] Select next source in Input menu : F18 (right command, changed by [Launch Agent](#launch-agent))
    - Function Keys
        - [X] Use F1, F2, etc. Keys as standard function keys
        - Else, ${customizing}
    - Modifier Keys
        - Caps Lock -> Control
        - (External keyboard) only
            - Control -> Control
            - Option -> Command
            - Command -> Optional

### Pointer Control

- Trackpad Options
    - Scroll speed : 5
- Mouse Options
    - Scroll speed : 5

### Trackpad

- Point & Click
    - Tracking speed : 6
    - [X] Tap to click
- Scroll & Zoom
    - [ ] Natural scrolling

Scroll & Zoom

- [X] Natural Scrolling

### Sound

- Sound Effects
    - Alert volume : 0
    - [ ] Play sound on startup
    - [ ] Play user interface sound effects
    - [ ] Play feedback when volue is changed

### Appearance

- Dark

### Desktop & Dock

- Dock
    - Size : 33%
    - Magnification : 70%
    - Dock position on screen : Right
    - Window title bar double-click action : No Action
- [X] Automatically hide and show the dock
- [ ] Show suggested and recent apps in Dock
- Desktop & Stage Manager
    - Show items
        - [X] On Desktop
        - [ ] In Stage Manager
    - [X] Stage Manager
    - [X] Show recent apps in Stage Manager
    - Show windows from an application : Once at a Time

### Displays

- Set proper setting per monitor.

### Battery

- Turn display off after 5 minutes -> ???
- Options
    - [ ] Slightly dim the display while on battery power
    - [ ] Prevent automatic sleeping on power adapter when the display is off

### Menu Bar

- Menu Bar Controls
    - Clock
        - Date
            - [ ] Show date
            - [ ] Show the day of the week
        - Time
            - [ ] Show AM/PM
            - [ ] Flash the time separators
            - [x] Display the time with seconds
    - Check those only
        - [X] Wi-Fi
        - [X] Battery
        - [X] Text Input
- Allow in the Menu Bar
    - Check those only
        - [X] DisplayLink Manager
        - [X] Itsycal
        - [X] KakaoTalk
        - [X] Rectangle
        - [X] RunCat
        - [X] Scroll Reverser

### Date & Time

- [ ] Set time and date automatically
- [X] 24-hour time
- [ ] Set time zone automatically using your current location

## Finder

- Make workspace dir & pin it to the Favorites

## Utils

### DisplayLink

Must be done before connecting to DisplayLink

- [DisplayLink](https://www.synaptics.com/products/displaylink-graphics/downloads/macos)

### Scroll Reverser

- Separate mouse and trackpad settings.
- [Download](https://pilotmoon.com/scrollreverser/)
    - Scrolling
        - Scrolling Axes
            - [X] Reverse Vertical
            - [X] Reverse Horizontal
        - ScrolX Direction (Before this, set mouse scroll direction to natural)
            - [X] Reverse Trackpad
            - [ ] Reverse Mouse
    - App
        - [X] Start at login
        - [X] Show in menu bar
        - Check for update
            - [ ] Automatically
            - [ ] Include beta versions

### Rectangle

- A Window Manager
- [Download](https://rectangleapp.com)
- Setting
    - Snap Areas
        - [X] Snap windows by dragging
    - General
        - [X] Launch on login
        - [ ] check for updates automaticallly
        - [X] Double-click window title bar to maximize/restore
        - Stage manager recent app area : 90 px

Usage

- ctrl + option +
    - < : left half
    - > : right half
    - up : up half
    - down : bottom half
    - enter : maximun

Settting

- 3rd column
    - [X] Launch Spectacle at login

### RunCat

- Monotoring tool
- [Download](https://apps.apple.com/kr/app/runcat/id1429033973?mt=12)
- Setting
    - General
        - Runner
            - Uncheck All
        - Launch
            - [X] Launch Runcat automatically at login
    - System Info
        - [x] Memory Performance
        - [x] Storage Capacity
        - [x] Battery State
        - [x] Network Connection

### Hammerspoon

- Macro tool for mac.
- [Download](http://www.hammerspoon.org/)
- Setting
    - Behavior
        - [X] Launch Hammerspoon at login
        - [ ] Check for updates
        - [ ] Show dock icon
        - [X] Show menu icon
        - [ ] Keep Console window on top
        - [ ] Send crash data (require restart)
    - vim hangul setting
        - Open Config -> Put code to Config -> Reload Config
```lua
-- key mapping for vim
-- key bindding reference --> https://www.hammerspoon.org/docs/hs.hotkey.html

local convertToEngWithEscHotKey
convertToEngWithEscHotKey = hs.hotkey.bind({}, 'escape', function()
  local inputEnglish = "com.apple.keylayout.ABC"
  local inputSource = hs.keycodes.currentSourceID()

  if not (inputSource == inputEnglish) then
    -- 한글로 작성 중 한영전환했을 때 작성 중이던 글자가 소실되는 현상을 막기 위해
    hs.eventtap.keyStroke({}, 'right')
    hs.keycodes.currentSourceID(inputEnglish)
  end

  -- esc mapping으로 인한 재귀호출을 방지하기 위해
  convertToEngWithEscHotKey:disable()
  hs.eventtap.keyStroke({}, 'escape', 100) -- 100 ns
  convertToEngWithEscHotKey:enable()
end)

local convertToEngWithCtrlAndSquareBrackets
convertToEngWithCtrlAndSquareBrackets = hs.hotkey.bind({'ctrl'}, '[', function()
  local inputEnglish = "com.apple.keylayout.ABC"
  local inputSource = hs.keycodes.currentSourceID()

  if not (inputSource == inputEnglish) then
    -- 한글로 작성 중 한영전환했을 때 작성 중이던 글자가 소실되는 현상을 막기 위해
    hs.eventtap.keyStroke({}, 'right')
    hs.keycodes.currentSourceID(inputEnglish)
  end

  -- esc mapping으로 인한 재귀호출을 방지하기 위해
  convertToEngWithCtrlAndSquareBrackets:disable()
  hs.eventtap.keyStroke({'ctrl'}, '[', 100) -- 100 ns
  convertToEngWithCtrlAndSquareBrackets:enable()
end)
```
- See also
    - [Hammerspoon official](http://www.hammerspoon.org/go/)
    - [esc 키로 편하게 한영 변환하기 for vim](https://humblego.tistory.com/10)
    - [vim - normal mode에서 자동으로 한영전환하기](https://frhyme.github.io/vim/vim09_type_kor_on_command_mode/)

### Itsycal

- Calendar on menu bar.
- Setting
    - General
        - [X] Launch at login
        - [ ] Automatically check for updates
        - [ ] Beep beep on the hour
    - Appearance
        - Menu Bar
            - Choose 2nd one
            - [X] Show month in icon
            - [X] Show day of week in icon
            - Datetime pattern : '' (empty)
        - Calandar
            - Text size : middle one
            - Highlight
                - [X] Sun
                - [X] Sat
            - [X] Show event dots
                - [X] Use colored dots
            - [X] Show calander weeks
- [Download](https://www.mowglii.com/itsycal/)
- [GitHub](https://github.com/sfsam/Itsycal)

## Optional Utils

### IINA

- Open source music player written in native Swift language.
- [Download](https://iina.io/)

### Gif Brewery 3 by gfycat

- gif generator.
- [Download](https://apps.apple.com/kr/app/gif-brewery-3-by-gfycat/id1081413713?mt=12)
- Setting
    - Video location : `~/Movies/GIF Brewery 3`

## See also

- [10 Must-Have macOS Tools for Power Users and Developers](https://link.medium.com/1qxMH7jnMab)
