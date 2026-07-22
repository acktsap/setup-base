#!/usr/bin/env python3
import argparse
import json
from pathlib import Path
import re
import sys
import xml.etree.ElementTree as ET


GRADLE_MARKERS = (
    "settings.gradle",
    "settings.gradle.kts",
    "build.gradle",
    "build.gradle.kts",
)

INTELLIJ_PRODUCT_INFO = Path("/Applications/IntelliJ IDEA.app/Contents/Resources/product-info.json")
JETBRAINS_CONFIG_ROOT = Path.home() / "Library/Application Support/JetBrains"


def indent(element, level=0):
    if hasattr(ET, "indent"):
        ET.indent(element, space="  ")
        return

    prefix = "\n" + "  " * level
    child_prefix = "\n" + "  " * (level + 1)
    children = list(element)
    if children:
        if not element.text or not element.text.strip():
            element.text = child_prefix
        for child in children:
            indent(child, level + 1)
        if not children[-1].tail or not children[-1].tail.strip():
            children[-1].tail = prefix
    if level and (not element.tail or not element.tail.strip()):
        element.tail = prefix


def parse_xml(path):
    try:
        return ET.parse(path)
    except ET.ParseError as exc:
        raise SystemExit("{} is not valid XML: {}".format(path, exc))


def read_value(element, tag):
    child = element.find(tag)
    if child is None:
        return None
    return child.get("value")


def java_sdk_tables():
    paths = []
    if INTELLIJ_PRODUCT_INFO.exists():
        try:
            data = json.loads(INTELLIJ_PRODUCT_INFO.read_text(encoding="UTF-8"))
            data_dir = data.get("dataDirectoryName")
            if data_dir:
                path = JETBRAINS_CONFIG_ROOT / data_dir / "options" / "jdk.table.xml"
                if path.exists():
                    paths.append(path)
        except (OSError, ValueError):
            pass

    if JETBRAINS_CONFIG_ROOT.exists():
        for pattern in ("IntelliJIdea*/options/jdk.table.xml", "IdeaIC*/options/jdk.table.xml"):
            paths.extend(sorted(JETBRAINS_CONFIG_ROOT.glob(pattern), reverse=True))

    unique = []
    seen = set()
    for path in paths:
        if path not in seen:
            unique.append(path)
            seen.add(path)
    return unique


def registered_java_sdks():
    sdks = []
    for table_rank, path in enumerate(java_sdk_tables()):
        try:
            root = ET.parse(str(path)).getroot()
        except (OSError, ET.ParseError):
            continue
        for order, jdk in enumerate(root.findall(".//jdk")):
            if read_value(jdk, "type") != "JavaSDK":
                continue
            name = read_value(jdk, "name")
            if not name:
                continue
            sdks.append(
                {
                    "name": name,
                    "version": read_value(jdk, "version") or "",
                    "homePath": read_value(jdk, "homePath") or "",
                    "table": str(path),
                    "tableRank": table_rank,
                    "order": order,
                }
            )
    return sdks


def requested_java_major(value):
    normalized = value.strip().lower()
    if normalized in ("#java_home", "java_home"):
        return None
    match = re.fullmatch(r"(?:jdk|java)?-?(\d+)(?:\.\d+)?", normalized)
    if match:
        major = match.group(1)
        return "8" if major == "1" and ".8" in normalized else major
    match = re.search(r"(?:^|[^0-9])1\.8(?:[^0-9]|$)", normalized)
    if match:
        return "8"
    match = re.search(r"(?:^|[^0-9])(\d{1,2})(?:\.\d+)?(?:[^0-9]|$)", normalized)
    return match.group(1) if match else None


def sdk_matches_major(sdk, major):
    fields = (sdk["name"], sdk["version"], sdk["homePath"])
    patterns = (
        r"(?:^|[^0-9]){}(?:\.[0-9]+)?(?:[^0-9]|$)".format(re.escape(major)),
        r"(?:jdk|java|temurin|liberica|corretto|zulu)-{}".format(re.escape(major)),
    )
    return any(re.search(pattern, field.lower()) for field in fields for pattern in patterns)


def resolve_jdk_name(requested):
    sdks = registered_java_sdks()
    available = ", ".join(dict.fromkeys(sdk["name"] for sdk in sdks)) or "none"
    for sdk in sdks:
        if sdk["name"] == requested:
            return requested, requested, sdk["table"]

    major = requested_java_major(requested)
    if major is None:
        raise SystemExit(
            "No registered IntelliJ Java SDK is named '{}'. Available Java SDKs: {}".format(requested, available)
        )

    candidates = [sdk for sdk in sdks if sdk_matches_major(sdk, major)]
    if not candidates:
        raise SystemExit(
            "No registered IntelliJ Java SDK matches '{}'. Available Java SDKs: {}".format(requested, available)
        )

    preferred_names = ("temurin-{}".format(major), major, "jdk-{}".format(major), "jdk{}".format(major))

    def sort_key(sdk):
        lower_name = sdk["name"].lower()
        lower_home = sdk["homePath"].lower()
        try:
            preferred_rank = preferred_names.index(lower_name)
        except ValueError:
            preferred_rank = len(preferred_names)
        temurin_rank = 0 if "temurin" in lower_name or "temurin" in lower_home else 1
        return (sdk["tableRank"], preferred_rank, temurin_rank, sdk["order"])

    chosen = sorted(candidates, key=sort_key)[0]
    return requested, chosen["name"], chosen["table"]


def write_xml(tree, path):
    indent(tree.getroot())
    tree.write(str(path), encoding="UTF-8", xml_declaration=True)
    text = path.read_text(encoding="UTF-8")
    if text.startswith("<?xml version='1.0' encoding='UTF-8'?>"):
        text = text.replace(
            "<?xml version='1.0' encoding='UTF-8'?>",
            '<?xml version="1.0" encoding="UTF-8"?>',
            1,
        )
    if not text.endswith("\n"):
        text += "\n"
    path.write_text(text, encoding="UTF-8")


def find_component(root, name):
    for component in root.findall("component"):
        if component.get("name") == name:
            return component
    return None


def ensure_component(root, name):
    component = find_component(root, name)
    if component is not None:
        return component
    component = ET.Element("component", {"name": name})
    root.append(component)
    return component


def ensure_option(parent, name, value=None):
    for option in parent.findall("option"):
        if option.get("name") == name:
            if value is not None:
                option.set("value", value)
            return option
    attrs = {"name": name}
    if value is not None:
        attrs["value"] = value
    option = ET.Element("option", attrs)
    parent.append(option)
    return option


def ensure_option_if_missing(parent, name, value):
    for option in parent.findall("option"):
        if option.get("name") == name:
            return option
    return ensure_option(parent, name, value)


def ensure_module_root(settings):
    modules = ensure_option(settings, "modules")
    option_set = modules.find("set")
    if option_set is None:
        option_set = ET.Element("set")
        modules.append(option_set)

    for option in option_set.findall("option"):
        if option.get("value") == "$PROJECT_DIR$":
            return
    option_set.insert(0, ET.Element("option", {"value": "$PROJECT_DIR$"}))


def root_gradle_settings(project_settings):
    for settings in project_settings:
        external_path = settings.find("option[@name='externalProjectPath']")
        if external_path is not None and external_path.get("value") == "$PROJECT_DIR$":
            return settings
    return None


def ensure_gradle_xml(path, jdk_name, has_wrapper):
    created = not path.exists()
    if created:
        root = ET.Element("project", {"version": "4"})
        tree = ET.ElementTree(root)
    else:
        tree = parse_xml(path)
        root = tree.getroot()

    if find_component(root, "GradleMigrationSettings") is None:
        root.insert(0, ET.Element("component", {"name": "GradleMigrationSettings", "migrationVersion": "1"}))

    gradle_settings = ensure_component(root, "GradleSettings")
    linked = ensure_option(gradle_settings, "linkedExternalProjectsSettings")
    project_settings = linked.findall(".//GradleProjectSettings")
    settings = root_gradle_settings(project_settings)
    if settings is None:
        settings = ET.Element("GradleProjectSettings")
        ensure_option(settings, "externalProjectPath", "$PROJECT_DIR$")
        linked.append(settings)
        project_settings = linked.findall(".//GradleProjectSettings")

    for settings in project_settings:
        ensure_option(settings, "delegatedBuild", "false")
        ensure_option(settings, "testRunner", "PLATFORM")
        ensure_option(settings, "gradleJvm", jdk_name)

    settings = root_gradle_settings(project_settings)
    if settings is not None:
        if has_wrapper:
            ensure_option_if_missing(settings, "distributionType", "DEFAULT_WRAPPED")
        ensure_module_root(settings)

    write_xml(tree, path)
    return "created" if created else "updated"


def ensure_misc_xml(path, jdk_name):
    created = not path.exists()
    if created:
        root = ET.Element("project", {"version": "4"})
        tree = ET.ElementTree(root)
    else:
        tree = parse_xml(path)
        root = tree.getroot()

    project_root = ensure_component(root, "ProjectRootManager")
    project_root.set("version", "2")
    project_root.set("default", "true")
    project_root.set("project-jdk-name", jdk_name)
    project_root.set("project-jdk-type", "JavaSDK")
    project_root.attrib.pop("languageLevel", None)

    write_xml(tree, path)
    return "created" if created else "updated"


def configure_gradle_project(target, jdk_name):
    idea_dir = target / ".idea"
    idea_dir.mkdir(exist_ok=True)
    has_wrapper = (target / "gradle" / "wrapper" / "gradle-wrapper.properties").is_file()
    return {
        "gradleXml": ensure_gradle_xml(idea_dir / "gradle.xml", jdk_name, has_wrapper),
        "miscXml": ensure_misc_xml(idea_dir / "misc.xml", jdk_name),
    }


def main():
    parser = argparse.ArgumentParser(description="Configure IntelliJ project-local Gradle and JDK settings.")
    parser.add_argument("target_path")
    parser.add_argument("jdk_name", nargs="?", default="jdk21")
    parser.add_argument("--phase", choices=("prepare", "finalize", "apply"), default="prepare")
    parser.add_argument("--wait-seconds", type=int, default=120)
    args = parser.parse_args()

    target = Path(args.target_path).expanduser().resolve()
    if not target.is_dir():
        raise SystemExit("{} is not a directory".format(target))

    gradle_project = any((target / marker).is_file() for marker in GRADLE_MARKERS)
    if gradle_project:
        requested_jdk_name, resolved_jdk_name, sdk_table = resolve_jdk_name(args.jdk_name)
    else:
        requested_jdk_name, resolved_jdk_name, sdk_table = args.jdk_name, args.jdk_name, None

    result = {
        "targetPath": str(target),
        "requestedJdkName": requested_jdk_name,
        "jdkName": resolved_jdk_name,
        "sdkTable": sdk_table,
        "gradleProject": gradle_project,
        "gradleXml": "skipped",
        "miscXml": "skipped",
        "phase": args.phase,
        "preOpenSettingsApplied": False,
        "settingsApplied": False,
    }

    if gradle_project:
        result.update(configure_gradle_project(target, resolved_jdk_name))
        result["settingsApplied"] = True
        result["preOpenSettingsApplied"] = args.phase == "prepare"

    print(json.dumps(result, ensure_ascii=True, sort_keys=True))
    return 0


if __name__ == "__main__":
    sys.exit(main())
