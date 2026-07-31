#!/bin/sh

set -eu

DEFAULT_JDK=jdk21
DEFAULT_LAUNCHER=/usr/local/bin/idea
JETBRAINS_CONFIG_ROOT="${HOME}/Library/Application Support/JetBrains"
PRODUCT_INFO="/Applications/IntelliJ IDEA.app/Contents/Resources/product-info.json"

SDK_RECORDS=
SDK_TABLES=
SDK_TABLES_UNIQUE=
XML_TEMP=

cleanup() {
  [ -z "$SDK_RECORDS" ] || rm -f "$SDK_RECORDS"
  [ -z "$SDK_TABLES" ] || rm -f "$SDK_TABLES"
  [ -z "$SDK_TABLES_UNIQUE" ] || rm -f "$SDK_TABLES_UNIQUE"
  [ -z "$XML_TEMP" ] || rm -f "$XML_TEMP"
}

trap cleanup 0 HUP INT TERM

die() {
  printf '%s\n' "$*" >&2
  exit 1
}

usage() {
  cat <<'EOF'
usage: idea-open [-n|--no-open] [--launcher PATH] [target_path] [jdk_name]

Open a directory in IntelliJ IDEA, applying project-local Gradle runner, JDK,
and annotation processing settings first.

positional arguments:
  target_path       Directory to open. Default: current directory.
  jdk_name          IntelliJ SDK name or Java version. Default: jdk21.

options:
  -n, --no-open     Apply settings without launching IntelliJ.
  --launcher PATH   IntelliJ launcher. Default: /usr/local/bin/idea, then PATH.
  -h, --help        Show this help.

Whether IntelliJ reuses the current window is a global IDE setting:
confirmOpenNewProject2 in ide.general.xml (0 = new, 1 = current, -1 = ask).
EOF
}

expand_tilde() {
  tilde='~'
  case $1 in
    "$tilde")
      printf '%s\n' "$HOME"
      ;;
    "$tilde"/*)
      printf '%s/%s\n' "$HOME" "${1#\~/}"
      ;;
    *)
      printf '%s\n' "$1"
      ;;
  esac
}

absolute_directory() {
  directory=$(expand_tilde "$1")
  case $directory in
    -*)
      directory=./$directory
      ;;
  esac
  (CDPATH='' cd -P "$directory" 2>/dev/null && pwd -P) ||
    die "$directory is not a directory"
}

resolve_launcher() {
  requested_launcher=$1
  if [ -n "$requested_launcher" ]; then
    launcher=$(expand_tilde "$requested_launcher")
  elif [ -x "$DEFAULT_LAUNCHER" ]; then
    launcher=$DEFAULT_LAUNCHER
  else
    launcher=$(command -v idea 2>/dev/null || :)
    [ -n "$launcher" ] ||
      die "No IntelliJ launcher found. Create one from Toolbox (Settings > Tools > Shell scripts), or pass --launcher."
  fi

  [ -x "$launcher" ] || die "$launcher is not executable"
  printf '%s\n' "$launcher"
}

create_sdk_table_list() {
  temp_root=${TMPDIR:-/tmp}
  SDK_TABLES=$temp_root/idea-open-sdk-tables.$$
  SDK_TABLES_UNIQUE=$temp_root/idea-open-sdk-tables-unique.$$
  SDK_RECORDS=$temp_root/idea-open-sdk-records.$$
  previous_umask=$(umask)
  umask 077
  : >"$SDK_TABLES"
  : >"$SDK_RECORDS"
  umask "$previous_umask"

  if [ -f "$PRODUCT_INFO" ]; then
    data_directory=$(
      sed -n 's/.*"dataDirectoryName"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$PRODUCT_INFO" |
        sed -n '1p'
    )
    if [ -n "$data_directory" ]; then
      current_table=$JETBRAINS_CONFIG_ROOT/$data_directory/options/jdk.table.xml
      [ ! -f "$current_table" ] || printf '%s\n' "$current_table" >>"$SDK_TABLES"
    fi
  fi

  for table in \
    "$JETBRAINS_CONFIG_ROOT"/IntelliJIdea*/options/jdk.table.xml \
    "$JETBRAINS_CONFIG_ROOT"/IdeaIC*/options/jdk.table.xml; do
    [ ! -f "$table" ] || printf '%s\n' "$table"
  done |
    LC_ALL=C sort -r >>"$SDK_TABLES"

  awk '!seen[$0]++' "$SDK_TABLES" >"$SDK_TABLES_UNIQUE"
}

append_java_sdks() {
  table=$1
  table_rank=$2
  awk -v table_rank="$table_rank" '
    function xml_decode(value) {
      gsub(/&quot;/, "\"", value)
      gsub(/&apos;/, "\047", value)
      gsub(/&lt;/, "<", value)
      gsub(/&gt;/, ">", value)
      gsub(/&amp;/, "\\&", value)
      return value
    }

    function option_value(line, value) {
      value = line
      sub(/^.*value="/, "", value)
      sub(/".*$/, "", value)
      return xml_decode(value)
    }

    /<jdk([[:space:]>])/ {
      in_jdk = 1
      name = ""
      type = ""
      version = ""
      home = ""
      next
    }

    in_jdk && /<name[[:space:]][^>]*value="/ {
      name = option_value($0)
      next
    }

    in_jdk && /<type[[:space:]][^>]*value="/ {
      type = option_value($0)
      next
    }

    in_jdk && /<version[[:space:]][^>]*value="/ {
      version = option_value($0)
      next
    }

    in_jdk && /<homePath[[:space:]][^>]*value="/ {
      home = option_value($0)
      next
    }

    in_jdk && /<\/jdk>/ {
      if (type == "JavaSDK" && name != "") {
        printf "%d\t%d\t%s\t%s\t%s\n", table_rank, order, name, version, home
      }
      order++
      in_jdk = 0
    }
  ' "$table" >>"$SDK_RECORDS"
}

requested_java_major() {
  printf '%s\n' "$1" |
    awk '
      {
        value = tolower($0)
        if (value == "#java_home" || value == "java_home") {
          exit
        }

        alias = value
        sub(/^(jdk|java)-?/, "", alias)
        if (alias ~ /^[0-9]+(\.[0-9]+)?$/) {
          split(alias, parts, ".")
          if (parts[1] == "1" && parts[2] == "8") {
            print "8"
          } else {
            print parts[1]
          }
          exit
        }

        if (match(value, /(^|[^0-9])1\.8([^0-9]|$)/)) {
          print "8"
          exit
        }

        for (i = 1; i <= length(value); i++) {
          if (substr(value, i, 1) ~ /[0-9]/) {
            number = ""
            while (i <= length(value) && substr(value, i, 1) ~ /[0-9]/) {
              number = number substr(value, i, 1)
              i++
            }
            if (length(number) <= 2) {
              print number
              exit
            }
          }
        }
      }
    '
}

available_java_sdks() {
  available=$(
    awk -F '\t' '
      !seen[$3]++ {
        if (count++) {
          printf ", "
        }
        printf "%s", $3
      }
      END {
        if (count) {
          print ""
        }
      }
    ' "$SDK_RECORDS"
  )
  [ -n "$available" ] || available=none
  printf '%s\n' "$available"
}

resolve_jdk_name() {
  requested=$1
  create_sdk_table_list

  table_rank=0
  while IFS= read -r table; do
    append_java_sdks "$table" "$table_rank"
    table_rank=$((table_rank + 1))
  done <"$SDK_TABLES_UNIQUE"

  JDK_NAME=$(
    awk -F '\t' -v requested="$requested" '
      $3 == requested {
        print $3
        exit
      }
    ' "$SDK_RECORDS"
  )
  if [ -n "$JDK_NAME" ]; then
    return 0
  fi

  major=$(requested_java_major "$requested")
  available=$(available_java_sdks)
  [ -n "$major" ] ||
    die "No registered IntelliJ Java SDK is named '$requested'. Available Java SDKs: $available"

  JDK_NAME=$(
    awk -F '\t' -v major="$major" '
      function contains_major(value, wanted, start, before, after) {
        value = tolower(value)
        for (start = 1; start <= length(value) - length(wanted) + 1; start++) {
          if (substr(value, start, length(wanted)) != wanted) {
            continue
          }
          before = start == 1 ? "" : substr(value, start - 1, 1)
          after = substr(value, start + length(wanted), 1)
          if (before !~ /[0-9]/ && after !~ /[0-9]/) {
            return 1
          }
        }
        return 0
      }

      function preferred_rank(name) {
        name = tolower(name)
        if (name == "temurin-" major) return 0
        if (name == major) return 1
        if (name == "jdk-" major) return 2
        if (name == "jdk" major) return 3
        return 4
      }

      {
        if (!contains_major($3, major) &&
            !contains_major($4, major) &&
            !contains_major($5, major)) {
          next
        }

        preferred = preferred_rank($3)
        temurin = index(tolower($3 " " $5), "temurin") ? 0 : 1
        if (!found ||
            $1 < best_table ||
            ($1 == best_table && preferred < best_preferred) ||
            ($1 == best_table && preferred == best_preferred && temurin < best_temurin) ||
            ($1 == best_table && preferred == best_preferred && temurin == best_temurin && $2 < best_order)) {
          found = 1
          best_table = $1
          best_preferred = preferred
          best_temurin = temurin
          best_order = $2
          best_name = $3
        }
      }

      END {
        if (found) {
          print best_name
        }
      }
    ' "$SDK_RECORDS"
  )

  [ -n "$JDK_NAME" ] ||
    die "No registered IntelliJ Java SDK matches '$requested'. Available Java SDKs: $available"
}

xml_escape() {
  printf '%s\n' "$1" |
    awk '
      {
        gsub(/&/, "\\&amp;")
        gsub(/"/, "\\&quot;")
        gsub(/</, "\\&lt;")
        gsub(/>/, "\\&gt;")
        print
      }
    '
}

validate_project_xml() {
  path=$1
  validation_status=0
  awk '
    /<project([[:space:]>])/ {
      opened = 1
    }
    /<\/project>/ {
      closed = 1
    }
    /<(component|option|GradleProjectSettings|annotationProcessing|profile)([[:space:]\/>]|$)/ && !/>/ {
      unsupported_layout = 1
    }
    /<component([[:space:]\/>]|$)/ && /<\/component>/ {
      unsupported_layout = 1
    }
    /<option([[:space:]\/>]|$)/ && /<\/option>/ {
      unsupported_layout = 1
    }
    /<GradleProjectSettings([[:space:]\/>]|$)/ && /<\/GradleProjectSettings>/ {
      unsupported_layout = 1
    }
    /<annotationProcessing([[:space:]\/>]|$)/ && /<\/annotationProcessing>/ {
      unsupported_layout = 1
    }
    /<profile([[:space:]\/>]|$)/ && /<\/profile>/ {
      unsupported_layout = 1
    }
    END {
      if (!(opened && closed)) {
        exit 1
      }
      if (unsupported_layout) {
        exit 2
      }
    }
  ' "$path" || validation_status=$?

  case $validation_status in
    0)
      ;;
    1)
      die "$path is not valid IntelliJ project XML"
      ;;
    *)
      die "$path uses an unsupported compact or multiline IntelliJ XML layout"
      ;;
  esac
}

write_misc_xml() {
  path=$1
  jdk_name=$2
  created=false
  if [ ! -f "$path" ]; then
    created=true
    cat >"$path" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<project version="4">
  <component name="ProjectRootManager" version="2" default="true" project-jdk-name="$jdk_name" project-jdk-type="JavaSDK" />
</project>
EOF
  else
    validate_project_xml "$path"
    XML_TEMP=$path.idea-open.$$
    cp -p "$path" "$XML_TEMP"
    awk -v jdk_name="$jdk_name" '
      function update_component(line, self_closing) {
        gsub(/[[:space:]]+(version|default|project-jdk-name|project-jdk-type|languageLevel)="[^"]*"/, "", line)
        self_closing = line ~ /\/>[[:space:]]*$/
        sub(/[[:space:]]*\/?>[[:space:]]*$/, "", line)
        line = line " version=\"2\" default=\"true\" project-jdk-name=\"" jdk_name "\" project-jdk-type=\"JavaSDK\""
        return line (self_closing ? " />" : ">")
      }

      /<component[[:space:]][^>]*name="ProjectRootManager"/ {
        print update_component($0)
        found = 1
        next
      }

      /<\/project>/ && !found {
        print "  <component name=\"ProjectRootManager\" version=\"2\" default=\"true\" project-jdk-name=\"" jdk_name "\" project-jdk-type=\"JavaSDK\" />"
        found = 1
      }

      {
        print
      }
    ' "$path" >"$XML_TEMP"
    mv "$XML_TEMP" "$path"
    XML_TEMP=
  fi

  if [ "$created" = true ]; then
    printf 'created'
  else
    printf 'updated'
  fi
}

write_compiler_xml() {
  path=$1
  created=false
  if [ ! -f "$path" ]; then
    created=true
    cat >"$path" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project version="4">
  <component name="CompilerConfiguration">
    <annotationProcessing>
      <profile default="true" name="Default" enabled="true" />
    </annotationProcessing>
  </component>
</project>
EOF
  else
    validate_project_xml "$path"
    XML_TEMP=$path.idea-open.$$
    cp -p "$path" "$XML_TEMP"
    awk '
      function indent_of(line, indent) {
        indent = line
        sub(/[^[:space:]].*$/, "", indent)
        return indent
      }

      function enable_profile(line, self_closing) {
        gsub(/[[:space:]]+enabled="[^"]*"/, "", line)
        self_closing = line ~ /\/>[[:space:]]*$/
        sub(/[[:space:]]*\/?>[[:space:]]*$/, "", line)
        return line " enabled=\"true\"" (self_closing ? " />" : ">")
      }

      function print_annotation_processing(indent) {
        print indent "<annotationProcessing>"
        print indent "  <profile default=\"true\" name=\"Default\" enabled=\"true\" />"
        print indent "</annotationProcessing>"
      }

      /<component[[:space:]][^>]*name="CompilerConfiguration"/ {
        compiler_found = 1
        annotation_found = 0
        in_compiler = 1
        if ($0 ~ /\/>[[:space:]]*$/) {
          indent = indent_of($0)
          sub(/[[:space:]]*\/>[[:space:]]*$/, ">", $0)
          print
          print_annotation_processing(indent "  ")
          print indent "</component>"
          annotation_found = 1
          in_compiler = 0
        } else {
          print
        }
        next
      }

      in_compiler && /<annotationProcessing([[:space:]\/>])/ {
        annotation_found = 1
        default_found = 0
        in_annotation = 1
        if ($0 ~ /\/>[[:space:]]*$/) {
          indent = indent_of($0)
          sub(/[[:space:]]*\/>[[:space:]]*$/, ">", $0)
          print
          print indent "  <profile default=\"true\" name=\"Default\" enabled=\"true\" />"
          print indent "</annotationProcessing>"
          default_found = 1
          in_annotation = 0
        } else {
          print
        }
        next
      }

      in_annotation && /<profile([[:space:]\/>])/ {
        if ($0 ~ /default="true"/) {
          default_found = 1
        }
        print enable_profile($0)
        next
      }

      in_annotation && /<\/annotationProcessing>/ {
        if (!default_found) {
          print indent_of($0) "  <profile default=\"true\" name=\"Default\" enabled=\"true\" />"
        }
        in_annotation = 0
        print
        next
      }

      in_compiler && /<\/component>/ {
        if (!annotation_found) {
          print_annotation_processing(indent_of($0) "  ")
        }
        in_compiler = 0
        print
        next
      }

      /<\/project>/ && !compiler_found {
        print "  <component name=\"CompilerConfiguration\">"
        print_annotation_processing("    ")
        print "  </component>"
        compiler_found = 1
      }

      {
        print
      }
    ' "$path" >"$XML_TEMP"
    mv "$XML_TEMP" "$path"
    XML_TEMP=
  fi

  if [ "$created" = true ]; then
    printf 'created'
  else
    printf 'updated'
  fi
}

write_gradle_xml() {
  path=$1
  jdk_name=$2
  has_wrapper=$3
  created=false
  if [ ! -f "$path" ]; then
    created=true
    distribution=
    if [ "$has_wrapper" = true ]; then
      distribution='        <option name="distributionType" value="DEFAULT_WRAPPED" />'
    fi
    cat >"$path" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<project version="4">
  <component name="GradleMigrationSettings" migrationVersion="1" />
  <component name="GradleSettings">
    <option name="linkedExternalProjectsSettings">
      <GradleProjectSettings>
        <option name="delegatedBuild" value="false" />
$distribution
        <option name="externalProjectPath" value="\$PROJECT_DIR\$" />
        <option name="gradleJvm" value="$jdk_name" />
        <option name="modules">
          <set>
            <option value="\$PROJECT_DIR\$" />
          </set>
        </option>
        <option name="testRunner" value="PLATFORM" />
      </GradleProjectSettings>
    </option>
  </component>
</project>
EOF
  else
    validate_project_xml "$path"
    XML_TEMP=$path.idea-open.$$
    cp -p "$path" "$XML_TEMP"
    awk -v jdk_name="$jdk_name" -v has_wrapper="$has_wrapper" '
      function indent_of(line, indent) {
        indent = line
        sub(/[^[:space:]].*$/, "", indent)
        return indent
      }

      function replace_value(line, value, start, tail, finish) {
        start = index(line, "value=\"")
        if (!start) {
          sub(/[[:space:]]*\/>[[:space:]]*$/, " value=\"" value "\" />", line)
          return line
        }
        tail = substr(line, start + 7)
        finish = index(tail, "\"")
        return substr(line, 1, start + 6) value substr(tail, finish)
      }

      function print_root_project(indent) {
        print indent "<GradleProjectSettings>"
        print indent "  <option name=\"delegatedBuild\" value=\"false\" />"
        if (has_wrapper == "true") {
          print indent "  <option name=\"distributionType\" value=\"DEFAULT_WRAPPED\" />"
        }
        print indent "  <option name=\"externalProjectPath\" value=\"$PROJECT_DIR$\" />"
        print indent "  <option name=\"gradleJvm\" value=\"" jdk_name "\" />"
        print indent "  <option name=\"modules\">"
        print indent "    <set>"
        print indent "      <option value=\"$PROJECT_DIR$\" />"
        print indent "    </set>"
        print indent "  </option>"
        print indent "  <option name=\"testRunner\" value=\"PLATFORM\" />"
        print indent "</GradleProjectSettings>"
      }

      function print_linked_projects(indent) {
        print indent "<option name=\"linkedExternalProjectsSettings\">"
        print_root_project(indent "  ")
        print indent "</option>"
      }

      function print_gradle_component(indent) {
        print indent "<component name=\"GradleSettings\">"
        print_linked_projects(indent "  ")
        print indent "</component>"
      }

      function print_project_block(    i, line, indent, in_modules, module_has_set) {
        delegated = 0
        distribution = 0
        gradle_jvm = 0
        test_runner = 0
        modules = 0
        module_root = 0
        module_set = 0
        root_project = 0
        in_modules = 0

        for (i = 1; i <= block_count; i++) {
          line = block[i]
          if (line ~ /<option[[:space:]][^>]*name="externalProjectPath"[^>]*value="\$PROJECT_DIR\$"/ ||
              line ~ /<option[[:space:]][^>]*value="\$PROJECT_DIR\$"[^>]*name="externalProjectPath"/) {
            root_project = 1
          }
          if (line ~ /<option[[:space:]][^>]*name="delegatedBuild"/) delegated = 1
          if (line ~ /<option[[:space:]][^>]*name="distributionType"/) distribution = 1
          if (line ~ /<option[[:space:]][^>]*name="gradleJvm"/) gradle_jvm = 1
          if (line ~ /<option[[:space:]][^>]*name="testRunner"/) test_runner = 1
          if (line ~ /<option[[:space:]][^>]*name="modules"/) {
            modules = 1
            in_modules = 1
          }
          if (in_modules && line ~ /<set([[:space:]>])/) module_set = 1
          if (in_modules && line ~ /<option[[:space:]][^>]*value="\$PROJECT_DIR\$"/) module_root = 1
          if (in_modules && line ~ /<\/option>/) in_modules = 0
        }

        in_modules = 0
        module_has_set = module_set
        for (i = 1; i <= block_count; i++) {
          line = block[i]
          indent = indent_of(line)

          if (line ~ /<option[[:space:]][^>]*name="delegatedBuild"/) {
            line = replace_value(line, "false")
          } else if (line ~ /<option[[:space:]][^>]*name="gradleJvm"/) {
            line = replace_value(line, jdk_name)
          } else if (line ~ /<option[[:space:]][^>]*name="testRunner"/) {
            line = replace_value(line, "PLATFORM")
          }

          if (root_project && line ~ /<option[[:space:]][^>]*name="modules"[^>]*\/>/) {
            sub(/[[:space:]]*\/>[[:space:]]*$/, ">", line)
            print line
            print indent "  <set>"
            print indent "    <option value=\"$PROJECT_DIR$\" />"
            print indent "  </set>"
            print indent "</option>"
            in_modules = 0
            module_root = 1
            module_set = 1
            continue
          }

          if (root_project && line ~ /<option[[:space:]][^>]*name="modules"/) {
            in_modules = 1
          }

          if (root_project && in_modules && !module_root && line ~ /<set[[:space:]][^>]*\/>/) {
            sub(/[[:space:]]*\/>[[:space:]]*$/, ">", line)
            print line
            print indent "  <option value=\"$PROJECT_DIR$\" />"
            print indent "</set>"
            module_root = 1
            continue
          }

          if (root_project && in_modules && !module_root && line ~ /<set([[:space:]>])/) {
            print line
            print indent "  <option value=\"$PROJECT_DIR$\" />"
            module_root = 1
            continue
          }

          if (root_project && in_modules && line ~ /<\/option>/) {
            if (!module_has_set) {
              print indent "  <set>"
              print indent "    <option value=\"$PROJECT_DIR$\" />"
              print indent "  </set>"
              module_root = 1
            }
            in_modules = 0
          }

          if (line ~ /<\/GradleProjectSettings>/) {
            insertion = indent "  "
            if (!delegated) print insertion "<option name=\"delegatedBuild\" value=\"false\" />"
            if (root_project && has_wrapper == "true" && !distribution) {
              print insertion "<option name=\"distributionType\" value=\"DEFAULT_WRAPPED\" />"
            }
            if (!gradle_jvm) print insertion "<option name=\"gradleJvm\" value=\"" jdk_name "\" />"
            if (root_project && !modules) {
              print insertion "<option name=\"modules\">"
              print insertion "  <set>"
              print insertion "    <option value=\"$PROJECT_DIR$\" />"
              print insertion "  </set>"
              print insertion "</option>"
            }
            if (!test_runner) print insertion "<option name=\"testRunner\" value=\"PLATFORM\" />"
          }

          print line
        }
        if (root_project) root_found = 1
      }

      {
        lines[NR] = $0
        if ($0 ~ /<component[[:space:]][^>]*name="GradleMigrationSettings"/) migration_found = 1
        if ($0 ~ /<component[[:space:]][^>]*name="GradleSettings"/) gradle_found = 1
        if ($0 ~ /<GradleProjectSettings>/) project_count++
        if ($0 ~ /<option[[:space:]][^>]*name="externalProjectPath"[^>]*value="\$PROJECT_DIR\$"/ ||
            $0 ~ /<option[[:space:]][^>]*value="\$PROJECT_DIR\$"[^>]*name="externalProjectPath"/) {
          root_exists = 1
        }
      }

      END {
        in_gradle = 0
        in_linked = 0
        buffering = 0
        root_found = root_exists

        for (line_number = 1; line_number <= NR; line_number++) {
          line = lines[line_number]

          if (buffering) {
            block[++block_count] = line
            if (line ~ /<\/GradleProjectSettings>/) {
              print_project_block()
              for (i = 1; i <= block_count; i++) delete block[i]
              block_count = 0
              buffering = 0
            }
            continue
          }

          if (line ~ /<GradleProjectSettings>/) {
            buffering = 1
            block[++block_count] = line
            continue
          }

          if (line ~ /<component[[:space:]][^>]*name="GradleSettings"/) {
            in_gradle = 1
            if (!migration_found) {
              print "  <component name=\"GradleMigrationSettings\" migrationVersion=\"1\" />"
              migration_found = 1
            }
            if (line ~ /\/>[[:space:]]*$/) {
              indent = indent_of(line)
              sub(/[[:space:]]*\/>[[:space:]]*$/, ">", line)
              print line
              print_linked_projects(indent "  ")
              print indent "</component>"
              root_found = 1
              in_gradle = 0
            } else {
              print line
            }
            continue
          }

          if (in_gradle && line ~ /<option[[:space:]][^>]*name="linkedExternalProjectsSettings"/) {
            in_linked = 1
            if (line ~ /\/>[[:space:]]*$/ && !root_found) {
              indent = indent_of(line)
              sub(/[[:space:]]*\/>[[:space:]]*$/, ">", line)
              print line
              print_root_project(indent "  ")
              print indent "</option>"
              root_found = 1
              in_linked = 0
            } else {
              print line
            }
            continue
          }

          if (in_linked && line ~ /<\/option>/) {
            if (!root_found) {
              print_root_project(indent_of(line) "  ")
              root_found = 1
            }
            in_linked = 0
            print line
            continue
          }

          if (in_gradle && line ~ /<\/component>/) {
            if (!root_found) {
              print_linked_projects(indent_of(line) "  ")
              root_found = 1
            }
            in_gradle = 0
            print line
            continue
          }

          if (line ~ /<\/project>/ && !gradle_found) {
            if (!migration_found) {
              print "  <component name=\"GradleMigrationSettings\" migrationVersion=\"1\" />"
            }
            print_gradle_component("  ")
            gradle_found = 1
            root_found = 1
          }

          print line
        }
      }
    ' "$path" >"$XML_TEMP"
    mv "$XML_TEMP" "$path"
    XML_TEMP=
  fi

  if [ "$created" = true ]; then
    printf 'created'
  else
    printf 'updated'
  fi
}

configure_gradle_project() {
  target=$1
  jdk_name=$2
  idea_directory=$target/.idea
  mkdir -p "$idea_directory"

  has_wrapper=false
  [ ! -f "$target/gradle/wrapper/gradle-wrapper.properties" ] || has_wrapper=true

  compiler_path=$idea_directory/compiler.xml
  gradle_path=$idea_directory/gradle.xml
  misc_path=$idea_directory/misc.xml

  for settings_path in "$compiler_path" "$gradle_path" "$misc_path"; do
    [ ! -f "$settings_path" ] || validate_project_xml "$settings_path"
  done

  compiler_status=$(write_compiler_xml "$compiler_path")
  gradle_status=$(write_gradle_xml "$gradle_path" "$jdk_name" "$has_wrapper")
  misc_status=$(write_misc_xml "$misc_path" "$jdk_name")
}

assign_positional() {
  if [ -z "$TARGET_PATH" ]; then
    TARGET_PATH=$1
  elif [ -z "$REQUESTED_JDK" ]; then
    REQUESTED_JDK=$1
  else
    die "too many arguments"
  fi
}

NO_OPEN=false
LAUNCHER_OVERRIDE=
TARGET_PATH=
REQUESTED_JDK=

while [ "$#" -gt 0 ]; do
  case $1 in
    -n | --no-open)
      NO_OPEN=true
      shift
      ;;
    --launcher)
      [ "$#" -ge 2 ] || die "--launcher requires a path"
      [ -n "$2" ] || die "--launcher requires a path"
      LAUNCHER_OVERRIDE=$2
      shift 2
      ;;
    --launcher=*)
      LAUNCHER_OVERRIDE=${1#*=}
      [ -n "$LAUNCHER_OVERRIDE" ] || die "--launcher requires a path"
      shift
      ;;
    --)
      shift
      while [ "$#" -gt 0 ]; do
        assign_positional "$1"
        shift
      done
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    -*)
      die "unrecognized option: $1"
      ;;
    *)
      assign_positional "$1"
      shift
      ;;
  esac
done

[ -n "$TARGET_PATH" ] || TARGET_PATH=.
[ -n "$REQUESTED_JDK" ] || REQUESTED_JDK=$DEFAULT_JDK

TARGET=$(absolute_directory "$TARGET_PATH")
LAUNCHER=
if [ "$NO_OPEN" = false ]; then
  LAUNCHER=$(resolve_launcher "$LAUNCHER_OVERRIDE")
fi

printf 'target   : %s\n' "$TARGET"

if [ -f "$TARGET/settings.gradle" ] ||
  [ -f "$TARGET/settings.gradle.kts" ] ||
  [ -f "$TARGET/build.gradle" ] ||
  [ -f "$TARGET/build.gradle.kts" ]; then
  resolve_jdk_name "$REQUESTED_JDK"
  JDK_XML_NAME=$(xml_escape "$JDK_NAME")
  configure_gradle_project "$TARGET" "$JDK_XML_NAME"

  if [ "$JDK_NAME" = "$REQUESTED_JDK" ]; then
    printf 'jdk      : %s\n' "$JDK_NAME"
  else
    printf 'jdk      : %s (requested %s)\n' "$JDK_NAME" "$REQUESTED_JDK"
  fi
  printf 'compiler : annotationProcessing=true\n'
  printf 'gradle   : delegatedBuild=false, testRunner=PLATFORM, gradleJvm=%s\n' "$JDK_NAME"
  printf 'settings : .idea/compiler.xml %s, .idea/gradle.xml %s, .idea/misc.xml %s\n' \
    "$compiler_status" "$gradle_status" "$misc_status"
else
  printf 'settings : skipped, not a Gradle project\n'
fi

if [ -n "$LAUNCHER" ]; then
  printf 'opening  : %s\n' "$LAUNCHER"
  "$LAUNCHER" "$TARGET"
fi
