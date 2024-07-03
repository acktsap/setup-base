# Eclipse Setup

- [Installation](#installation)
- [Setting](#setting)
- [Formatter](#formatter)
  - [Code template](#code-template)
  - [Static import](#static-import)
  - [Highlight Current Variable](#highlight-current-variable)
  - [Font size](#font-size)
  - [Import order](#import-order)
  - [Checkstyle warning color](#checkstyle-warning-color)
- [Plugins](#plugins)

## Installation

todo

## Setting

## Formatter

- Preference -> Java -> Code style -> Formatter [google style guide github](https://github.com/google/styleguide)
- Usage : command + shift + f (osx) or alt + shift + f (windows)
- Customizing
    - Line Wrapping -> Never join already wrapped lines

### Code template

- Copyright comment new file : Preference -> Java -> Code Templates -> Comments -> Files & Check automatically add comments

```java
/*
 * @copyright defined in LICENSE.txt
 */

```

### Static import

Java -> Editor -> Content Assist -> Favorites

```java
java.util.UUID.*                // randomUUID()
java.util.Objects.*         // requireNonNull
org.slf4j.LoggerFactory.* // logback
```

### Highlight Current Variable

Java -> Editor -> Mark occurrences

### Font size

General -> Appearance -> Colors and Fonts -> Java

### Import order

Java -> Code Style -> Organized Imports

### Checkstyle warning color

General -> Editors -> Text Editors -> Annotations -> Checkstyle warning

## Plugins

- Vim
- Relative Line Number Ruler
- CheckStyle
- [Lombok](https://projectlombok.org/download)
- Infinitest
- editorconfig
