# Basic Troubleshooting

Use this page before packaging a game, debugging load failures, or contacting
developers.

## Deployment Files

A PDJE Godot game export must include:

| File category | Required location / rule |
| --- | --- |
| GDExtension config | `PDJE_Wrapper.gdextension` must be inside the exported Godot project and point to the platform library path. |
| Wrapper library | Include the platform-matching `PDJE_godot_wrapper` library at the path referenced by the `.gdextension` file. Current local config points Linux to `res://build/libPDJE_godot_wrapper.so` and Windows to `res://build/windows-relwithdebinfo/PDJE_godot_wrapper.dll`. |
| PDJE runtime libraries | Include staged `libPDJE*` or `PDJE*.dll` dependencies next to the wrapper/runtime folder. |
| ONNX Runtime | Include staged ONNX Runtime files when using util AI: Windows `onnxruntime.dll` and `onnxruntime_providers_shared.dll`; Linux `libonnxruntime.so*` and `libonnxruntime_providers_shared.so`; macOS `libonnxruntime*.dylib`. |
| zlib/highway/runtime deps | Include staged zlib and highway libraries when the build artifact references them. |
| Beat This model | Include the `.onnx` model at the same Godot path used in `PDJE_AI.CreateBeatThisDetector()`, for example `res://models/beat_this.onnx`. |
| Game DB | Include the root DB or create it in `user://` before calling `InitEngine()`. |
| Music assets | Include audio files referenced by editor/root DB music metadata. |
| Input permission helper | For Linux evdev deployment, document the user/group permission requirement before expecting raw input to work. |

The current CI prebuilt publishing workflow stages native files into:

- `addons/Project_DJ_Godot/win/release`
- `addons/Project_DJ_Godot/win/debug`
- `addons/Project_DJ_Godot/linux/release`
- `addons/Project_DJ_Godot/linux/debug`
- `addons/Project_DJ_Godot/macos/release`
- `addons/Project_DJ_Godot/macos/debug`

Do not claim a release package is current without checking the external
prebuilt repository.

## GDExtension Load Failures

Check:

- `PDJE_Wrapper.gdextension` exists in the exported project.
- `entry_symbol` is `pdje_wrapper_init`.
- `compatibility_minimum` matches the Godot version family in use.
- The path under `[libraries]` exists in the exported project.
- Runtime dependencies are next to the wrapper or otherwise discoverable by the
  OS loader.
- Linux `libPDJE*.so` targets retain `$ORIGIN` runpath when they reference
  staged sibling libraries.

Use OS tools when needed:

- Linux: `ldd path/to/libPDJE_godot_wrapper.so`
- macOS: `otool -L path/to/libPDJE_godot_wrapper.dylib`
- Windows: `dumpbin /DEPENDENTS path\\to\\PDJE_godot_wrapper.dll`

## Engine And Editor Failures

- `InitEngine(DBPath)` must run before player, editor, MIR `DetectMusic`, or
  judge calls that dereference the engine.
- `SearchTrack()` and `SearchMusic()` can return empty arrays. Check before
  indexing.
- `InitPlayer()` returns `false` when a searched track is missing unless using
  `FULL_MANUAL_RENDER`.
- Reacquire `PlayerWrapper`, `CoreLine`, and judge data lines after resetting or
  recreating engine/player/input state.
- `render()` must complete before `pushTrackToRootDB()` or `pushToRootDB()`.

## Mix Args Failures

- Use exact enum values from `PDJE_EDITOR_ARG`.
- Use the mix args table in the core harness page.
- Keep FX argument keys case-sensitive.
- For interpolation, ensure `MixArgs.first` and `MixArgs.second` match the
  selected mix type. `8PointValues` means eight comma-separated control points
  stretched over the mix event span.
- Do not use old spelling variants unless the current table or code shows that
  spelling.

## Input Failures

- On macOS, input/judge wrappers may not be present.
- On Linux, evdev may require user group access to `/dev/input/event*`.
  The repository contains
  `PDJE-Godot-Plugin/Project-DJ-Engine/scripts_for_distribution/evdev_group_apply.sh`
  as a system-level helper. It changes user/group configuration and must be run
  only by users who understand the privacy/security risk.
- `GetDevs()` is for standard keyboard/mouse devices; `GetMIDIDevs()` is for
  MIDI port names.
- `Config()` must receive selected standard device dictionaries and selected
  MIDI names.
- `InputLine.emit_input_signal()` only emits after
  `InitializeInputLine(input_line)`.

## Judge Failures

`StartJudge()` fails when any of these are missing:

- core data line
- input data line
- event rule
- input rail mapping
- note objects

Fix order first. The normal sequence is:

```text
AddDataLines -> DeviceAdd/MIDI_DeviceAdd -> SetRule -> SetNotes -> StartJudge
```

Rail ids in `DeviceAdd()`/`MIDI_DeviceAdd()` must match note `RailID` values
authored through editor note rows.

## AI Failures

- `PDJE_AI` exposes Beat This only; generic ONNX sessions are not Godot API.
- `CreateBeatThisDetector()` requires a valid `.onnx` file path.
- Include the same model file in the game export.
- `DetectPCM()` requires non-empty interleaved `PackedFloat32Array`, valid
  `channel_count`, and valid `sample_rate`.
- `DetectMusic()` requires an initialized `PDJE_Wrapper` and music metadata
  that can be found by the core search path.
- Null `PDJE_BeatThisResult` means failure; check Godot console diagnostics.

## Bug Reporting

Contact developers through the official Discord first:

- https://discord.gg/2Pwju7xhmS

Copy a bug report or feature request template from
[../../report/](../../report/) before posting when possible.

Developers welcome bug reports and feature requests, and agent-generated report
drafts are fine when they make reporting easier. A human developer must
directly review and send Discord or GitHub messages. Automated reporting or
unreviewed message sending is discouraged because reports can leak personal
information, private assets, database content, logs, paths, or model files.

For reproducible bugs, also prepare a GitHub issue for the relevant repository:

- Core engine: https://github.com/Rliop913/Project-DJ-Engine
- Godot wrapper: https://github.com/Rliop913/PDJE-Godot-Plugin
- Prebuilt plugin package: https://github.com/Rliop913/Project_DJ_Godot

Include:

- OS and architecture
- Godot version
- whether the build is source-built or prebuilt
- `PDJE_VERSION` and `PDJE_WRAPPER_VERSION` when available
- wrapper library path and `.gdextension` content
- exact Godot API call sequence
- logs from the Godot console
- minimal reproduction scene/project
- root DB path and whether it is `res://` or `user://`
- audio asset path and import status
- `.onnx` model path if AI is involved
- selected input devices/MIDI ports if input or judge is involved
- expected behavior and actual behavior

Do not send private music, database, or model files publicly unless you have the
right to share them. Provide a minimal substitute when possible.
