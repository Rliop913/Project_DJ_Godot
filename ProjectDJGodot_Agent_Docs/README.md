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

## Source Of Truth

Use the current checkout, in this priority order:

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
