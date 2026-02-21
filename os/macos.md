# MacOS Setup

- [System preference](#system-preference)
  - [Keyboard](#keyboard)
  - [Mouse](#mouse)
  - [Trackpad](#trackpad)
  - [Sound](#sound)
  - [Appearance](#appearance)
  - [Desktop \& Dock](#desktop--dock)
  - [Displays](#displays)
  - [Battery](#battery)
  - [Control Center](#control-center)
  - [Date \& Time](#date--time)
- [Finder](#finder)
- [Utils](#utils)
  - [DisplayLink](#displaylink)
  - [Scroll Reverser](#scroll-reverser)
  - [Karabiner](#karabiner)
  - [Rectangle](#rectangle)
  - [RunCat](#runcat)
  - [Hammerspoon](#hammerspoon)
  - [Itsycal](#itsycal)
- [Optional Utils](#optional-utils)
  - [Alfred](#alfred)
  - [IINA](#iina)
  - [Gif Brewery 3 by gfycat](#gif-brewery-3-by-gfycat)
- [See also](#see-also)

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
    - ~~Select the previous input source : Option + Space (⌥ + Space)~~ -> Karabiner Virtual Keyboard로 대체
  - Function Keys
    - [X] Use F1, F2, etc. Keys as standard function keys
    - Else, ${customizing}
  - Modifier Keys
    - Caps Lock -> Control
    - ~~(External keyboard) only~~ -> Karabiner Virtual Keyboard로 대체
      - Control -> Control
      - Option -> Command
      - Command -> Optional

### Mouse

- Tracking speed : almost max
- [ ] Natural Scrolling

### Trackpad

Point & Click

- [X] Tap to click
- Tracking speed : 6
  
Scroll & Zoom

- [X] Natural Scrolling

### Sound

- Sound Effects -> Alert volume to 0
  - [ ] Play sound on startup
  - [ ] Play user interface sound effects
  - [ ] Play feedback when volue is changed

### Appearance

- Dark

### Desktop & Dock

- Size : 33%
- Magnification : 50%
- Position on screen : Right
- [X] Automatically hide and show the dock
- [ ] Show recent application on Dock

### Displays

- Set proper setting per monitor.

### Battery

- Turn display off after 5 minutes

Options

- [ ] Slightly dim the display while on battery power
- [ ] Prevent automatic sleeping on power adapter when the display is off

### Control Center

- Menu Bar Only
  - Clock Options
    - [x] Display the time with seconds

### Date & Time

- [ ] Set time and date automatically
- [x] 24-hour time

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
    - Scroll Direction (Before this, set mouse scroll direction to natural)
      - [ ] Reverse Trackpad
      - [X] Reverse Mouse
     - App
    - [X] Start at login
    - [X] Show in menu bar
    - Check for update
      - [ ] Automatically
      - [ ] Include beta versions

### Karabiner

- Virtual keyboard
- [Download](https://karabiner-elements.pqrs.org/)
- Setting
  - Simple modifications
    - Apple Internal Keyboard
      - right_command -> **F18**
    - External keyboard (e.g. Realforce)
      - caps_lick -> left_control
      - left_command -> left_option
      - left_option -> left_command
      - right_command -> right_option
      - right_option -> **F18**
  - Function keys
    - For all devices
      - [X] Use all F1, F2, etc as standard function keys
  - Devices
    - [X] Apple Internal Keyboard
      - [ ] Manipulate caps lock LED
    - [X] External keyboard (eg. Realforce)
      - [ ] Manipulate caps lock LED
  - System Preference (Keyboard)
    - Keyboard Shortcuts -> Input Sources
      - Select the previous input source to **F18** (오른쪽 command key 누르기)
  - See also
    - https://ssossoblog.tistory.com/54

### Rectangle

- A Window Manager
- [Download](https://rectangleapp.com)

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
      - [X] Launch Runcat at login
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
- [Download](https://www.mowglii.com/itsycal/)
- [GitHub](https://github.com/sfsam/Itsycal)

## Optional Utils

### Alfred

- 알프레드
- [Download](https://www.alfredapp.com)
- Setting
  - System Preference
    - Keyboard Shortcuts
      - Spotlight
        - [ ] Show Spotlight search
  - Alfred Hotkey: `command + Space`

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
