#!/usr/bin/env python3
"""
glb2fbx.py - Convert GLTF Binary (.glb) to FBX (.fbx)
Requires one of: trimesh with fbx support, assimp CLI, or bpy (Blender Python)
Usage: python3 glb2fbx.py input.glb output.fbx
"""

import sys
import os
import subprocess
import shutil
import tempfile


def convert_with_trimesh(src: str, dst: str) -> bool:
    try:
        import trimesh
        scene = trimesh.load(src)
        scene.export(dst)
        return True
    except ImportError:
        return False
    except Exception as e:
        print(f"trimesh error: {e}")
        return False


def _find_assimp() -> str | None:
    if shutil.which("assimp"):
        return "assimp"
    prog = os.environ.get("ProgramFiles", "C:\\Program Files")
    candidates = [os.path.join(prog, "Assimp", "bin", "assimp.exe")]
    for c in candidates:
        if os.path.isfile(c):
            return c
    return None


def convert_with_assimp(src: str, dst: str) -> bool:
    assimp_cmd = _find_assimp()
    if assimp_cmd is None:
        return False
    try:
        result = subprocess.run(
            [assimp_cmd, "export", src, dst],
            capture_output=True, text=True, timeout=30
        )
        if result.returncode == 0:
            return True
        print(f"assimp error: {result.stderr}")
        return False
    except FileNotFoundError:
        return False
    except Exception as e:
        print(f"assimp exception: {e}")
        return False


def _find_blender() -> str | None:
    if shutil.which("blender"):
        return "blender"
    prog = os.environ.get("ProgramFiles", "C:\\Program Files")
    candidates = [os.path.join(prog, "Blender Foundation", "Blender", "blender.exe")]
    for c in candidates:
        if os.path.isfile(c):
            return c
    return None


def convert_with_blender(src: str, dst: str) -> bool:
    blender_cmd = _find_blender()
    if blender_cmd is None:
        return False

    blender_script = f'''
import bpy, sys, os
src = {repr(src)}
dst = {repr(dst)}
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)
bpy.ops.import_scene.gltf(filepath=src)
bpy.ops.export_scene.fbx(filepath=dst, use_selection=True)
bpy.ops.wm.quit_blender()
'''
    script_path = os.path.join(tempfile.gettempdir(), "glb2fbx_blender.py")
    with open(script_path, "w") as f:
        f.write(blender_script)

    try:
        result = subprocess.run(
            [blender_cmd, "--background", "--python", script_path],
            capture_output=True, text=True, timeout=60
        )
        os.unlink(script_path)
        if os.path.exists(dst) and os.path.getsize(dst) > 0:
            return True
        print(f"blender error: {result.stderr}")
        return False
    except FileNotFoundError:
        if os.path.exists(script_path):
            os.unlink(script_path)
        return False
    except Exception as e:
        print(f"blender exception: {e}")
        if os.path.exists(script_path):
            os.unlink(script_path)
        return False


def fallback_copy(src: str, dst: str) -> bool:
    print("ERROR: No FBX converter available (not trimesh, not assimp, not Blender).")
    print("Install one of: pip install trimesh, assimp CLI, or Blender.")
    return False


def main():
    if len(sys.argv) < 3:
        print("Usage: python3 glb2fbx.py input.glb output.fbx")
        sys.exit(1)

    src = sys.argv[1]
    dst = sys.argv[2]

    if not os.path.exists(src):
        print(f"Source file not found: {src}")
        sys.exit(1)

    if convert_with_trimesh(src, dst):
        print(f"FBX exported (trimesh): {dst}")
        return

    if convert_with_assimp(src, dst):
        print(f"FBX exported (assimp): {dst}")
        return

    if convert_with_blender(src, dst):
        print(f"FBX exported (blender): {dst}")
        return

    fallback_copy(src, dst)
    sys.exit(1)


if __name__ == "__main__":
    main()
