# Brave Browser Setup

- [Installation](#installation)
- [Settings](#settings)
  - [Get started](#get-started)
  - [Privacy and security](#privacy-and-security)
  - [Search engine](#search-engine)
- [Additional Settings](#additional-settings)
  - [Autofill](#autofill)
- [Extensions](#extensions)
- [Bookmark](#bookmark)

## Installation

https://brave.com

## Settings

### Get started

- On startup : check Open the New Tab page

### Privacy and security

- [ ] Allow privacy-preserving product analytics (P3A)
- [ ] Automatically send daily usage ping to Brave
- Clear browsing data -> On exit
    - Check except
        - Cached images and files
        - Hosted app data

### Search engine

- Normal Windows : Google
- Private Windows : Brave
- Manage search engines and site search
    - Search engines
        - DuckDuckGo (Default), default can be set in site search
            - :d, :ㅇ
            - https://duckduckgo.com/?q=%s
    - Site search
        - Google
            - :g, :ㅎ
            - https://www.google.com/search?q=%s
        - Brave
            - :b, :ㅠ
            - https://search.brave.com/search?q=%s
        - Naver
            - :n, :ㅜ
            - https://search.naver.com/search.naver?sm=top_hty&fbm=1&ie=utf8&query=%s
        - YouTube
            - :y, :ㅛ
            - https://www.youtube.com/results?search_query=%s
        - Dict
            - :c, :ㅊ
            - https://en.dict.naver.com/#/search?query=%s
        - Investopedia
            - :i, :ㅑ
            - https://www.investopedia.com/search?q=%s
        - wikipedia
            - :w, :ㅈ
            - https://en.wikipedia.org/w/index.php?title=Special:Search&search=%s

## Additional Settings

### Autofill

- [ ] Offer to save passwords
 
## Extensions

- [Dark Reader](https://chromewebstore.google.com/detail/dark-reader/eimadpbcbfnmbkopoojfekhnkhdbieeh)
    - Drak
        - Brightness : off
        - Contrast : -10
        - Sepia : +35
        - Grayscale : off
- [LastPass](https://chromewebstore.google.com/detail/lastpass-free-password-ma/hdokiejnpimakedhajhdlcegeplioahd)
- [Google Translate](https://chromewebstore.google.com/detail/google-translate/aapbdbdomjkkjkaonfhkkikfgjllcleb)
    - Extension Options
        - My primary language: Korean
- [Octotree : GitHub code tree](https://chromewebstore.google.com/detail/octotree-github-code-tree/bkhaagjahfmjljalopjnoealnfndnagc)
- [Looper for YouTube](https://chromewebstore.google.com/detail/looper-for-youtube/iggpfpnahkgpnindfkdncknoldgnccdg)

## Bookmark

Backup

```sh
cp "/Users/${USER}/Library/Application Support/BraveSoftware/Brave-Browser/Default/Bookmarks" ${path_to_backup}
```
Restore

```sh
cp ${path_to_backup} "/Users/${USER}/Library/Application Support/BraveSoftware/Brave-Browser/Default/Bookmarks"
```
