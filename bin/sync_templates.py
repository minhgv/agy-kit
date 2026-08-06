#!/usr/bin/env python3
"""
sync_templates.py — Synchronize active Antigravity configurations into src/templates/ (FR-MNT-001)

Ensures 100% consistency between live working assets (.agents/, AGENTS.md) and installer template assets (src/templates/).
Supports:
  --check: Check for drift without modifying templates (returns exit code 1 if drift detected).
  --sync: Automatically update src/templates/ from active working assets.
"""

import os
import sys
import glob
import shutil
import argparse

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
AGENTS_DIR = os.path.join(PROJECT_ROOT, ".agents/agents")
SKILLS_DIR = os.path.join(PROJECT_ROOT, ".agents/skills")
WORKFLOWS_DIR = os.path.join(PROJECT_ROOT, ".agents/workflows")
MCP_CONFIG = os.path.join(PROJECT_ROOT, ".agents/mcp_config.json")
AGENTS_MD = os.path.join(PROJECT_ROOT, "AGENTS.md")

TEMPLATES_DIR = os.path.join(PROJECT_ROOT, "src/templates")

def get_file_content(path):
    if not os.path.exists(path):
        return None
    with open(path, "r", encoding="utf-8") as f:
        return f.read()

def main():
    parser = argparse.ArgumentParser(description="Template Synchronization CLI for agy-kit")
    parser.add_argument("--check", action="store_true", help="Check for drift without modifying files")
    parser.add_argument("--sync", action="store_true", help="Synchronize active assets to src/templates/")
    args = parser.parse_args()

    if not args.check and not args.sync:
        args.sync = True

    os.makedirs(os.path.join(TEMPLATES_DIR, "agents"), exist_ok=True)
    os.makedirs(os.path.join(TEMPLATES_DIR, "skills"), exist_ok=True)
    os.makedirs(os.path.join(TEMPLATES_DIR, "workflows"), exist_ok=True)

    drift_found = False

    # 1. Sync / Check Agent Specs
    agent_mds = glob.glob(os.path.join(AGENTS_DIR, "*.md"))
    for md_path in agent_mds:
        base_name = os.path.basename(md_path)
        dest_path = os.path.join(TEMPLATES_DIR, "agents", base_name)
        active_content = get_file_content(md_path)
        tpl_content = get_file_content(dest_path)

        if active_content != tpl_content:
            drift_found = True
            print(f"[DRIFT] Agent spec mismatch: {base_name}")
            if args.sync:
                with open(dest_path, "w", encoding="utf-8") as f:
                    f.write(active_content)
                print(f"  -> Synced {base_name} to src/templates/agents/")

    # 2. Sync / Check Workflows
    wf_mds = glob.glob(os.path.join(WORKFLOWS_DIR, "*.md"))
    for wf_path in wf_mds:
        base_name = os.path.basename(wf_path)
        dest_path = os.path.join(TEMPLATES_DIR, "workflows", base_name)
        active_content = get_file_content(wf_path)
        tpl_content = get_file_content(dest_path)

        if active_content != tpl_content:
            drift_found = True
            print(f"[DRIFT] Workflow mismatch: {base_name}")
            if args.sync:
                with open(dest_path, "w", encoding="utf-8") as f:
                    f.write(active_content)
                print(f"  -> Synced {base_name} to src/templates/workflows/")

    # 2.5 Sync / Check Skills
    skill_dirs = [d for d in glob.glob(os.path.join(SKILLS_DIR, "*")) if os.path.isdir(d)]
    for s_dir in skill_dirs:
        s_name = os.path.basename(s_dir)
        dest_s_dir = os.path.join(TEMPLATES_DIR, "skills", s_name)
        
        for root, _, files in os.walk(s_dir):
            rel_path = os.path.relpath(root, s_dir)
            target_root = os.path.join(dest_s_dir, rel_path) if rel_path != "." else dest_s_dir
            
            for file in files:
                active_file = os.path.join(root, file)
                dest_file = os.path.join(target_root, file)
                
                active_content = get_file_content(active_file)
                tpl_content = get_file_content(dest_file)
                
                if active_content != tpl_content:
                    drift_found = True
                    print(f"[DRIFT] Skill file mismatch: {s_name}/{os.path.join(rel_path, file) if rel_path != '.' else file}")
                    if args.sync:
                        os.makedirs(target_root, exist_ok=True)
                        with open(dest_file, "w", encoding="utf-8") as f:
                            f.write(active_content)
                        print(f"  -> Synced {s_name}/{file} to src/templates/skills/")

    # 3. Sync / Check MCP Config
    if os.path.exists(MCP_CONFIG):
        dest_mcp = os.path.join(TEMPLATES_DIR, "mcp_config.json.tpl")
        active_mcp = get_file_content(MCP_CONFIG)
        tpl_mcp = get_file_content(dest_mcp)

        if active_mcp != tpl_mcp:
            drift_found = True
            print("[DRIFT] MCP Config mismatch")
            if args.sync:
                with open(dest_mcp, "w", encoding="utf-8") as f:
                    f.write(active_mcp)
                print("  -> Synced mcp_config.json to src/templates/mcp_config.json.tpl")

    # 4. Sync / Check AGENTS.md
    if os.path.exists(AGENTS_MD):
        dest_agents_md = os.path.join(TEMPLATES_DIR, "AGENTS.md.tpl")
        active_agents_md = get_file_content(AGENTS_MD)
        
        # Tokenize language reference for template
        tpl_agents_md = active_agents_md.replace("Python 3.14", "${LANG}").replace("Primary language adapter configured for python", "Primary language: ${LANG}")
        current_tpl_md = get_file_content(dest_agents_md)

        if tpl_agents_md != current_tpl_md:
            drift_found = True
            print("[DRIFT] AGENTS.md template mismatch")
            if args.sync:
                with open(dest_agents_md, "w", encoding="utf-8") as f:
                    f.write(tpl_agents_md)
                print("  -> Synced AGENTS.md to src/templates/AGENTS.md.tpl")

    print("==================================================")
    if args.check:
        if drift_found:
            print("❌ Template drift detected! Run './bin/sync-templates.sh' to synchronize templates.")
            sys.exit(1)
        else:
            print("✅ All templates in src/templates/ are 100% synchronized with active assets.")
            sys.exit(0)
    else:
        if drift_found:
            print("✅ Successfully synchronized all assets into src/templates/!")
        else:
            print("✅ Templates were already 100% synchronized. Zero drift.")
        sys.exit(0)

if __name__ == "__main__":
    main()
