# PDJE Godot User Agent Harness

This directory is the Godot-user-facing agent harness for Project DJ Engine.
It is written for agents building games through the Godot 4 GDExtension API,
not for agents editing the upstream C++ engine directly.

## Reading Order

1. Read [harness/README.md](harness/README.md) for source-of-truth rules.
2. Read [harness/core/README.md](harness/core/README.md) before using
   `PDJE_Wrapper`, playback, editor, or mix data.
3. Read [harness/input/README.md](harness/input/README.md) before using
   `PDJE_Input_Module` or `InputLine`.
4. Read [harness/judge/README.md](harness/judge/README.md) before wiring
   gameplay timing, rails, notes, and judge callbacks.
5. Read [harness/util/README.md](harness/util/README.md) before using DB,
   MIR, STFT, waveform, or Beat This AI helpers.
6. Read
   [harness/basic_troubleshooting/README.md](harness/basic_troubleshooting/README.md)
   before packaging, debugging runtime load failures, or reporting bugs.
7. Use [report/](report/) for copyable Discord-first bug report and feature
    request templates.
8. For official documentation or latest docs info, visit:
   https://rliop913.github.io/Project-DJ-Engine-Docs/

## Source Of Truth

Use the current checkout, in this priority order:

- **Official Documentation**: https://rliop913.github.io/Project-DJ-Engine-Docs/
  For official docs or latest documentation info, always check the official documentation site first.
- `PDJE-Godot-Plugin/Wrapper_Includes/` for Godot class names, bound methods,
  signals, return shapes, and wrapper failure behavior.
- `srcs/*.rst` for maintained user-facing explanations of PDJE modules.
- `PDJE-Godot-Plugin/AGENT_DOCS/` for wrapper architecture and edit
  boundaries.
- `PDJE-Godot-Plugin/Project-DJ-Engine/AGENT_DOCS/` for upstream engine
  behavior.
- `docs_harness/important_assets/editor_format/tables.json` for the preserved
  editor/mix argument tables.

Generated API output under `docs/`, `srcs/api/`, and `srcs/xml/` is reference
material. Do not treat generated pages as the only proof of an intended
workflow.

## Godot Entry Points

The main Godot classes registered by the wrapper are:

- Core: `PDJE_Wrapper`, `PlayerWrapper`, `MusPanelWrapper`, `FXWrapper`,
  `FXArgWrapper`, `EditorWrapper`, `PDJE_EDITOR_ARG`, `CoreLine`
- Input: `PDJE_Input_Module`, `InputLine`
- Judge: `PDJE_Judge_Module`
- Utility: `PDJE_KeyValueDB`, `PDJE_RelationalDB`, `PDJE_VectorDB`,
  `PDJE_MIR`, `PDJE_StftResult`, `PDJE_AI`, `PDJE_BeatThisDetector`,
  `PDJE_BeatThisResult`

Input and judge wrappers are platform/build conditional. Apple builds disable
the input wrapper by default; other platforms currently enable it through
`PDJE_DEVELOP_INPUT` and `PDJE_GODOT_ENABLE_INPUT_WRAPPER`.

## Deployment Snapshot

A game export that uses PDJE must include the `.gdextension` file, the
platform-matching wrapper library, staged PDJE/runtime dependency libraries,
game DB/assets, and any `.onnx` model used by `PDJE_AI`.

The current prebuilt publishing workflow stages runtime libraries into:

- `addons/Project_DJ_Godot/win/release` and `win/debug`
- `addons/Project_DJ_Godot/linux/release` and `linux/debug`
- `addons/Project_DJ_Godot/macos/release` and `macos/debug`

See the troubleshooting page before packaging.

## Repository Chain and Update Checking

Project DJ Godot is the **prebuilt plugin package** (프리빌트 저장소) that receives compiled artifacts from the development chain:

```
Project-DJ-Engine (Core) → PDJE-Godot-Plugin (Wrapper) → Project_DJ_Godot (Prebuilt)
```

### Repository Roles

| Repository | URL | Role | Visibility |
| --- | --- | --- | --- |
| **Project-DJ-Engine** | https://github.com/Rliop913/Project-DJ-Engine | Core C++ engine, PDJE_UTIL, PDJE_INPUT, PDJE_JUDGE modules | Private |
| **PDJE-Godot-Plugin** | https://github.com/Rliop913/PDJE-Godot-Plugin | Godot GDExtension wrapper, binds core to Godot API | Private |
| **Project_DJ_Godot** | https://github.com/Rliop913/Project_DJ_Godot | Prebuilt plugin package with compiled libraries | Private (프리빌트) |

### Check Current Version

The prebuilt repository stores version files at the root:

```bash
# Check current versions in your local checkout
cat PDJE_VERSION        # e.g., "0.9.0"
cat PDJE_WRAPPER_VERSION  # e.g., "0.9.0"

# Compare with the latest in the repository
git fetch origin
git show origin/main:PDJE_VERSION
git show origin/main:PDJE_WRAPPER_VERSION
```

### Check for Updates

Run the Update script to fetch the latest prebuilt artifacts:

```bash
# Linux/macOS
bash ./Update_Project_DJ_Godot.sh

# Windows
Update_Project_DJ_Godot.bat
```

The script will:
1. Clone the latest `Project_DJ_Godot` from GitHub
2. Run `git lfs pull` to fetch actual binaries (not LFS pointers)
3. Extract any `.7z.001` compressed archives
4. Copy updated `addons/Project_DJ_Godot/` to your project
5. Update `PDJE_VERSION` and `PDJE_WRAPPER_VERSION` files

### Check Propagation Status

To see how far core/plugin changes have propagated to the prebuilt:

```bash
# Check the latest commit messages in prebuilt repo
git log --oneline -10

# Check if a specific feature/fix is included
git log --oneline --grep="feature-name-or-bug-id"

# Verify the prebuilt CI status
# Visit: https://github.com/Rliop913/Project_DJ_Godot/actions
```

The CI/CD pipeline chains are:
- Core changes → triggers wrapper build → triggers prebuilt update
- Check the GitHub Actions tab of each repository to see build status
- Delays of a few hours may occur between core → wrapper → prebuilt propagation

If the prebuilt doesn't have the latest core/plugin changes yet:
- Wait for the CI/CD chain to complete (check GitHub Actions)
- Or build from source: clone `Project-DJ-Engine` and `PDJE-Godot-Plugin`, then follow their build instructions

## Bug Contact Policy

For runtime bugs, contact developers through the official Discord first. For
reproducible bugs, also create or prepare a GitHub issue in the relevant
repository with logs, OS, Godot version, wrapper/core versions, reproduction
steps, and sample project details. Copy a report template from
[report/](report/) when preparing a bug report or feature request. Developers
welcome bug reports and feature requests, and agent-generated report drafts are
fine when they make reporting easier. A human developer must directly review
and send Discord or GitHub messages. Automated reporting or unreviewed message
sending is discouraged because reports can leak personal information, private
assets, database content, logs, paths, or model files.
