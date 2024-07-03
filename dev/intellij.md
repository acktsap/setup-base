# Intellij Setup

- [Installation](#installation)
- [Left Panel Setting](#left-panel-setting)
  - [Project](#project)
- [Setting](#setting)
  - [Appearance \& Behavior](#appearance--behavior)
    - [Apperance](#apperance)
    - [System Settings](#system-settings)
  - [Keymap](#keymap)
  - [Editor](#editor)
    - [General](#general)
    - [Code Editing](#code-editing)
    - [Code Style](#code-style)
    - [File and Code Templates](#file-and-code-templates)
  - [Plugins](#plugins)
  - [Build, Execution, Deployment](#build-execution-deployment)
    - [Build Tools](#build-tools)
- [Etc](#etc)
  - [JDK Version](#jdk-version)
  - [VM options](#vm-options)
- [JVM Flags](#jvm-flags)
  - [JVM Option](#jvm-option)
  - [Java Compiler Option](#java-compiler-option)

## Installation

- https://www.jetbrains.com/ko-kr/idea/download

## Left Panel Setting

### Project

- Open File With Single Click
- Always Select Opened File

## Setting

### Appearance & Behavior

#### Apperance

- Theme
    - DRacula

#### System Settings

- AutoSave
    - [ ] Save files if the IDE is idle for 15 seconds
    - [X] Save files when switching to a different application
    - [ ] Backup files before saving
    - Sync external changes
        - [x] When switching to the IDE window or opening an editor tab
        - [x] Periodically when the IDE is inactive

### Keymap

Use Eclipse (macOS)

- Tool Windows
    - Project : Command + 8
        - see also: [Shortcut to toggle focus between project sidebar and editor?](https://intellij-support.jetbrains.com/hc/en-us/community/posts/206887115-Shortcut-to-toggle-focus-between-project-sidebar-and-editor-)
- By search
    - Go to Implementations : Ctrl + i
    - Go to Test : Ctrl + t
    - Rename (Refactor) : Command + option + r

### Editor

#### General

- Auto Import
    - java
        - [X] Add unambiguous import on the fly.
        - [X] Optimize imports on the fly
    - kotlin
        - [X] Add unambiguous import on the fly.
        - [X] Optimize imports on the fly
- Appearance
    - [x] Show whitespace
        - [x] Leading
        - [x] Inner
        - [x] Trailing
        - [x] Selection

#### Code Editing

- Quick Documentation
    - [ ] Show quick documentation on hover
    
#### Code Style

- Java
    - Scheme : ${project_specific_setting}
    - Wrapping and Braces
        - Keep when reformatting
            - [ ] Comment at first column
    - Imports
        - General
            - Class count to use import with `*` : 99
            - Names count to use static import with `*` : 99
        - Packages to Use import with `*`: Remove all
    - Code Generation
        - Comment Code
            - [ ] Line comment at first column
            - [X] Add a space at line comment start
                - [ ] Enforce on reformat
- Kotlin
    - Wrapping and Braces
        - Keep when reformatting
            - [ ] Comment at first column
    - Code Generation
        - Comment Code
            - [ ] Line comment at first column
            - [X] Add a space at line comment start
                - [ ] Enforce on reformat
                
#### File and Code Templates

- Class : ${your_setting}
- eg.
```java
/*
* @copyright defined in LICENSE.txt
*/
```

### Plugins

- [IdeaVim](https://plugins.jetbrains.com/plugin/164-ideavim)
    - [MacOS](MacOS.md) 에서 vim key 반복이 안될 때 이렇게 terminal에다가 하면 됨.
        - `defaults write -g ApplePressAndHoldEnabled -bool false`
- [Sequence Diagram](https://plugins.jetbrains.com/plugin/8286-sequence-diagram)
- [Ktlint](https://plugins.jetbrains.com/plugin/15057-ktlint-unofficial-)
- [CheckStyle-IDEA](https://plugins.jetbrains.com/plugin/1065-checkstyle-idea)
    - Check Reformat code
    - Check Optimize imports
- [Lombok](https://plugins.jetbrains.com/plugin/6317-lombok)
- [Infinitest](https://plugins.jetbrains.com/plugin/3146-infinitest)

Deprecated

- ~~Relative Line Numbers~~ -> `:set rnu` via IdeaVim plugin
- ~~[Save actions](https://plugins.jetbrains.com/plugin/7642-save-actions/versions)~~ -> Use default config

### Build, Execution, Deployment

#### Build Tools

- Gradle
    - Gradle projects
        - Build and running : Intellij IDEA
        - Run test using : Intellij IDEA

## Etc

### JDK Version

File > Project Structure > Project > Project SDK, Project language level

### VM options

Help -> Edit Custom VM Options (or shift + shift -> enter custom vm options)

```sh
-Xms4G
-Xmx4G
```

## JVM Flags

### JVM Option

- Help -> Edit custom VM Options에서 설정 가능.
```text
-Xms4G
-Xmx4G
```

### Java Compiler Option

- Build, Execution, Development -> Compiler -> Java Compiler 에서 설정 가능.
- e.g.
```text
-parameters
```