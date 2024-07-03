# Terminal

- [Bootstrap](#bootstrap)
- [Setup](#setup)
- [Color](#color)
  - [Iterm](#iterm)
  - [Window terminal](#window-terminal)
- [See also](#see-also)

## Bootstrap

Make a keypair in `~/.ssh`.

```shell
# make parent directory
mkdir -p $HOME/.ssh
cd $HOME/.ssh

# generate ecdsa key
ssh-keygen -t ecdsa
```

Register public key in [github](https://github.com/settings/keys).

Write following contents to `~/.ssh/config`

```shell
# make sure IdentityFile is in 400 mode
    
Host github.com
  IdentityFile ~/.ssh/blablabla
  StrictHostKeyChecking no
    
Host bitbucket.org
  IdentityFile ~/.ssh/blablabla
  StrictHostKeyChecking no
    
Host *
  IdentityFile ~/.ssh/blablabla
  StrictHostKeyChecking no
```

Fetch setup-base.

```shell
git clone git@github.com:acktsap/setup-base.git
```

## Setup

- Setup : `setup-all.sh`
- Setup vim : `vi .` and :PluginInstall

## Color

https://github.com/sindresorhus/hyper-snazzy

### Iterm

General

- Profile
  - Colors
    - Color Presents
      - Import
        - import Snazzy.itermcolors
  - Text
    - Size as 13
- Selection
  - [x] Application in terminal may access clipboard

### Window terminal

![wsl-color-1](./wsl-color-1.jpg)
![wsl-color-2](./wsl-color-2.jpg)

Set as ubuntu theme.

- 슬롯#1 : Red: 48, Green: 10, Blue: 36
- 슬롯#2 : Red: 52, Green: 101, Blue: 164
- 슬롯#3 : Red: 78, Green: 154, Blue: 6
- 슬롯#4 : Red: 6, Green: 152, Blue: 154
- 슬롯#5 : Red: 204, Green: 0, Blue: 0
- 슬롯#6 : Red: 117, Green: 80, Blue: 123
- 슬롯#7 : Red: 196, Green: 160, Blue: 0
- 슬롯#8 : Red: 211, Green: 215, Blue: 207
- 슬롯#9 : Red: 85, Green: 87, Blue: 83
- 슬롯#10 : Red: 114, Green: 159, Blue: 207
- 슬롯#11 : Red: 138, Green: 226, Blue: 52
- 슬롯#12 : Red: 52, Green: 226, Blue: 226
- 슬롯#13 : Red: 239, Green: 41, Blue: 41
- 슬롯#14 : Red: 173, Green: 127, Blue: 168
- 슬롯#15 : Red: 252, Green: 233, Blue: 79
- 슬롯#16 : Red: 238, Green: 238, Blue: 238

- 화면 텍스트 : 슬록#8
- 화면 배경 : 슬록#1
- 팝업 텍스트 : 슬록#1
- 팝업 배경  : 슬록#16

## See also

- [wsl ubuntu theme](https://webdir.tistory.com/546)
- [github dotfile search](https://github.com/search?q=zsh+dotfiles&ref=commandbar)
- [What should/shouldn't go in .zshenv, .zshrc, .zlogin, .zprofile, .zlogout? (stackexchange)](https://unix.stackexchange.com/questions/71253/what-should-shouldnt-go-in-zshenv-zshrc-zlogin-zprofile-zlogout)
- [4.3 Git 서버 - SSH 공개키 만들기](https://git-scm.com/book/ko/v2/Git-%EC%84%9C%EB%B2%84-SSH-%EA%B3%B5%EA%B0%9C%ED%82%A4-%EB%A7%8C%EB%93%A4%EA%B8%B0)