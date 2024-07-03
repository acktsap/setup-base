# Programming Language Setup

- [Jdk](#jdk)
  - [osx](#osx)
  - [Graalvm](#graalvm)
- [JavaScript Runtime](#javascript-runtime)
  - [Nvm](#nvm)
- [Golang](#golang)
- [Ruby](#ruby)

## Jdk

- [common](https://blog.benelog.net/installing-jdk.html)

### osx

https://github.com/AdoptOpenJDK/homebrew-openjdk

```sh
# brew tap
brew tap homebrew/cask-versions

# latest version
brew install --cask temurin 

# jdk 11
brew install --cask temurin@11 

# jdk 17
brew install --cask temurin@17

# jdk 21
brew install --cask temurin@21
```

### Graalvm

https://www.graalvm.org/downloads/

## JavaScript Runtime

- [Nvm](Nvm.md) 참고.

### Nvm

Node.js virtual machine

- Install : `curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash`
- Install node version 8 : `nvm install 8`
- Install node version 8.1.5 : `nvm install 8.1.5`
- List installed : `nvm ls`
- Use 8.x.x version : `nvm use 8`
- Use 8.1.5 version : `nvm use 8.1.5`

## Golang

Installation

[official link](https://go.dev/doc/install)

Version check

```sh
go version
```

## Ruby

https://www.ruby-lang.org/ko/documentation/installation/
