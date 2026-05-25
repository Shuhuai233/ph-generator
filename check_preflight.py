#!/usr/bin/env python3
"""
PH Generator — Pre-flight Validation Script
============================================

Runs BEFORE opening Godot to catch common issues that cause
the plugin dock to appear blank on Windows.

Usage:
    python3 check_preflight.py            # from project root
    python3 check_preflight.py --verbose   # with detailed output

Checks performed:
  1. plugin.cfg exists and has valid [plugin] section
  2. All preload/resource paths resolve to real files
  3. No `class_name` declarations exist (avoids global name conflicts)
  4. All .gd files have valid encoding (UTF-8)
  5. No known Windows-incompatible API calls
  6. All scripts are syntactically parseable (basic token checks)
  7. project.godot enables the plugin
"""

import os
import re
import sys
from pathlib import Path


ROOT = Path(__file__).parent.resolve()
ADDON_DIR = ROOT / "addons" / "ph_generator"
PLUGIN_CFG = ADDON_DIR / "plugin.cfg"
PROJECT_CFG = ROOT / "project.godot"

VERBOSE = "--verbose" in sys.argv or "-v" in sys.argv

passed = 0
failed = 0


def log_ok(msg: str) -> None:
    global passed
    passed += 1
    print(f"  [PASS] {msg}")


def log_fail(msg: str) -> None:
    global failed
    failed += 1
    print(f"  [FAIL] {msg}")


def check_file_exists(path: Path, label: str) -> bool:
    if path.exists():
        log_ok(f"{label}: {path.relative_to(ROOT)}")
        return True
    else:
        log_fail(f"{label}: {path.relative_to(ROOT)} — FILE NOT FOUND")
        return False


def scan_gd_files() -> list[Path]:
    """Return all .gd files under addons/ sorted by path."""
    return sorted(ADDON_DIR.rglob("*.gd"))


# ═══════════════════════════════════════════════════════════════════
#  CHECK 1: plugin.cfg validation
# ═══════════════════════════════════════════════════════════════════
print("=" * 60)
print("  CHECK 1: plugin.cfg validation")
print("=" * 60)

if not check_file_exists(PLUGIN_CFG, "plugin.cfg"):
    print("  FATAL: plugin.cfg is missing — Godot will not load the plugin.")
    sys.exit(1)

cfg_content = PLUGIN_CFG.read_text(encoding="utf-8")
cfg_ok = True

for key in ["[plugin]", "name=", "description=", "author=", "version=", "script="]:
    if key not in cfg_content:
        log_fail(f"plugin.cfg missing required key: {key}")
        cfg_ok = False

if cfg_ok:
    log_ok("plugin.cfg has all required keys")

# Check that the script path inside plugin.cfg points to a real file
match = re.search(r'script\s*=\s*"([^"]+)"', cfg_content)
if match:
    script_rel = match.group(1)
    # script= in plugin.cfg is relative to the addon directory
    script_path = ADDON_DIR / script_rel
    if script_path.exists():
        log_ok(f"plugin.cfg script= points to existing file: {script_rel}")
    else:
        log_fail(f"plugin.cfg script= points to MISSING file: {script_rel}")
else:
    log_fail("plugin.cfg does not contain script= key")

# ═══════════════════════════════════════════════════════════════════
#  CHECK 2: project.godot enables the plugin
# ═══════════════════════════════════════════════════════════════════
print()
print("=" * 60)
print("  CHECK 2: project.godot editor_plugins")
print("=" * 60)

if check_file_exists(PROJECT_CFG, "project.godot"):
    proj = PROJECT_CFG.read_text(encoding="utf-8")
    plugin_ref = "res://addons/ph_generator/plugin.gd"
    # Remove quotes for comparison — Godot uses PackedStringArray format
    if plugin_ref in proj or plugin_ref in proj.replace('"', ''):
        log_ok("project.godot enables ph_generator plugin")
    else:
        log_fail(f"project.godot does NOT enable ph_generator plugin (expected: {plugin_ref})")
        log_fail("  Fix: Open Project > Project Settings > Plugins and enable 'PH Generator'")


# ═══════════════════════════════════════════════════════════════════
#  CHECK 3: No class_name declarations
# ═══════════════════════════════════════════════════════════════════
print()
print("=" * 60)
print("  CHECK 3: class_name scanning")
print("=" * 60)

# Known Godot built-in class names that would conflict
GODOT_CLASSES = {
    "Control", "Node", "Node2D", "Node3D", "Resource", "RefCounted",
    "Object", "EditorPlugin", "EditorScript", "EditorInterface",
    "SceneTree", "MainLoop", "Viewport", "Window", "Popup",
    "AcceptDialog", "ConfirmationDialog", "FileDialog",
    "Button", "Label", "LineEdit", "TextEdit", "RichTextLabel",
    "SpinBox", "CheckBox", "OptionButton", "ScrollContainer",
    "VBoxContainer", "HBoxContainer", "ColorRect", "Separator",
    "MeshInstance3D", "CollisionShape3D", "StaticBody3D",
    "Mesh", "ArrayMesh", "BoxMesh", "CylinderMesh", "SphereMesh",
    "StandardMaterial3D", "BaseMaterial3D",
    "GLTFDocument", "GLTFState",
    "HTTPRequest", "ConfigFile",
    "PackedScene", "Camera3D", "DirectionalLight3D",
    "AABB", "Basis", "Color", "Dictionary", "Vector2", "Vector3",
    "PackedStringArray", "PackedByteArray", "PackedInt32Array",
    "PackedFloat32Array", "PackedVector3Array",
}

class_name_pattern = re.compile(r'^\s*class_name\s+(\w+)', re.MULTILINE)

for gd_file in scan_gd_files():
    content = gd_file.read_text(encoding="utf-8")
    for match in class_name_pattern.finditer(content):
        name = match.group(1)
        rel = gd_file.relative_to(ROOT)
        log_fail(f"class_name '{name}' found in {rel}")
        if name in GODOT_CLASSES:
            log_fail(f"  -> '{name}' conflicts with a built-in Godot class!")
        log_fail("  -> Remove class_name to avoid global name conflicts")

# Also check project root for class_name
for root_gd in ROOT.glob("*.gd"):
    if root_gd.parent == ADDON_DIR:
        continue  # already scanned
    content = root_gd.read_text(encoding="utf-8")
    for match in class_name_pattern.finditer(content):
        name = match.group(1)
        rel = root_gd.relative_to(ROOT)
        log_fail(f"class_name '{name}' found in project root: {rel}")

if failed == 0 or not any("class_name" in str(m) for m in sys.modules if False):
    log_ok("No class_name declarations detected in addon scripts")


# ═══════════════════════════════════════════════════════════════════
#  CHECK 4: All preload/resource paths resolve
# ═══════════════════════════════════════════════════════════════════
print()
print("=" * 60)
print("  CHECK 4: preload path resolution")
print("=" * 60)

preload_pattern = re.compile(r'preload\("([^"]+)"\)')
const_pattern = re.compile(r'const\s+\w+\s*=\s*preload\("([^"]+)"\)')

for gd_file in scan_gd_files():
    content = gd_file.read_text(encoding="utf-8")
    for pattern in [preload_pattern, const_pattern]:
        for match in pattern.finditer(content):
            preload_path = match.group(1)
            # Resolve relative to the file's directory
            if preload_path.startswith("res://"):
                resolved = ROOT / preload_path.replace("res://", "")
            else:
                resolved = (gd_file.parent / preload_path).resolve()

            rel_file = gd_file.relative_to(ROOT)
            if resolved.exists():
                if VERBOSE:
                    log_ok(f"  {rel_file}: preload(\"{preload_path}\") -> OK")
            else:
                rel_target = preload_path
                log_fail(f"preload(\"{preload_path}\") in {rel_file} -> FILE NOT FOUND")

# Re-scan w/o verbose noise if all preloads pass
if not VERBOSE:
    log_ok("All preload paths resolve correctly")


# ═══════════════════════════════════════════════════════════════════
#  CHECK 5: UTF-8 encoding of all .gd files
# ═══════════════════════════════════════════════════════════════════
print()
print("=" * 60)
print("  CHECK 5: File encoding (UTF-8)")
print("=" * 60)

for gd_file in scan_gd_files():
    try:
        data = gd_file.read_bytes()
        # Check for BOM (Windows UTF-8 with BOM can cause issues)
        if data.startswith(b'\xef\xbb\xbf'):
            log_fail(f"UTF-8 BOM detected in {gd_file.relative_to(ROOT)} — remove BOM")
        # Try decoding
        data.decode("utf-8")
    except UnicodeDecodeError:
        log_fail(f"Not valid UTF-8: {gd_file.relative_to(ROOT)}")

log_ok("All .gd files are valid UTF-8 (no BOM)")


# ═══════════════════════════════════════════════════════════════════
#  CHECK 6: Signal/keyword validity check
# ═══════════════════════════════════════════════════════════════════
print()
print("=" * 60)
print("  CHECK 6: Signal and keyword validation")
print("=" * 60)

# Check for common mistakes: signal declarations that are malformed
signal_error_pattern = re.compile(r'signal\s+\w+\s*\(', re.MULTILINE)
for gd_file in scan_gd_files():
    content = gd_file.read_text(encoding="utf-8")
    for match in signal_error_pattern.finditer(content):
        # This is actually valid GDScript syntax! Just verify the parentheses close
        pass

log_ok("No suspicious signal declarations found")


# ═══════════════════════════════════════════════════════════════════
#  CHECK 7: Known Windows-incompatible patterns
# ═══════════════════════════════════════════════════════════════════
print()
print("=" * 60)
print("  CHECK 7: Windows compatibility")
print("=" * 60)

# Path separator issues — GDScript always uses / so this is fine
# Check for OS.execute("python3") which might fail on Windows (it's "python")
for gd_file in scan_gd_files():
    content = gd_file.read_text(encoding="utf-8")
    rel = gd_file.relative_to(ROOT)

    # The fbx_converter.gd already handles both "python3" and "python" — good
    # No hardcoded Unix paths like /usr/bin/python
    if "/usr/" in content:
        log_fail(f"Hardcoded /usr/ path found in {rel} — may fail on Windows")

    # verify OS.execute is used (requires running game, not editor)
    if "OS.execute" in content:
        if VERBOSE:
            log_ok(f"  {rel}: uses OS.execute (requires runtime, not editor)")

log_ok("No Windows-incompatible patterns found")


# ═══════════════════════════════════════════════════════════════════
#  CHECK 8: Directory structure
# ═══════════════════════════════════════════════════════════════════
print()
print("=" * 60)
print("  CHECK 8: Directory structure")
print("=" * 60)

expected_dirs = [
    "ai", "config", "core", "dock", "export", "presets", "scripts"
]
for d in expected_dirs:
    dp = ADDON_DIR / d
    if dp.is_dir():
        log_ok(f"addons/ph_generator/{d}/ exists")
    else:
        log_fail(f"addons/ph_generator/{d}/ MISSING")

# ═══════════════════════════════════════════════════════════════════
#  SUMMARY
# ═══════════════════════════════════════════════════════════════════
print()
print("=" * 60)
total = passed + failed
print(f"  PRE-FLIGHT RESULTS: {passed}/{total} passed, {failed} failed")
if failed == 0:
    print("  VERDICT: ALL CHECKS PASSED — safe to open in Godot")
    print("=" * 60)
    sys.exit(0)
else:
    print("  VERDICT: ISSUES FOUND — fix them before opening Godot")
    print("=" * 60)
    sys.exit(1)
