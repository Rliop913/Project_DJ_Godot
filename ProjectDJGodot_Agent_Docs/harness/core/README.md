# Core, Player, Editor, And Mix Args

Use this page when a Godot game needs playback, editor authoring, note
extraction, core data-line polling, manual music control, FX control, or mix
automation.

## Main Godot Classes

| Class | Kind | Use |
| --- | --- | --- |
| `PDJE_Wrapper` | `Node` | Owns the `PDJE` engine, initializes DB/player/editor, searches music/tracks, exposes notes and core data lines. |
| `PlayerWrapper` | `RefCounted` | Controls playback after `InitPlayer()`. |
| `MusPanelWrapper` | `RefCounted` | Loads, cues, enables, unloads, and BPM-shifts music in manual/hybrid playback. |
| `FXWrapper` | `RefCounted` | Turns FX on/off and exposes `FXArgWrapper`. |
| `FXArgWrapper` | `RefCounted` | Lists and sets case-sensitive runtime FX argument keys. |
| `EditorWrapper` | `RefCounted` | Mutates editor project data and manages render/push/history flows. |
| `PDJE_EDITOR_ARG` | `RefCounted` | Carries one typed editor row: note, music, mix, or key-value. |
| `CoreLine` | `RefCounted` | Polls playback state from `PDJE_CORE_DATA_LINE`. |

## API Source Labels

Tables below use short source labels:

- `Core docs`: https://rliop913.github.io/Project-DJ-Engine-Docs/Core_Engine.html
- `Editor docs`: https://rliop913.github.io/Project-DJ-Engine-Docs/Editor_Workflows.html
- `FX args docs`: https://rliop913.github.io/Project-DJ-Engine-Docs/FX_ARGS.html
- `Current examples`: `addons/Project_DJ_Godot/examples/GAME_TEMPLATE.tscn`
  and `AutoBench/Bench-Core.tscn`

When probing the official Core page, search `Wrapper Bindings`, `GDSCRIPT`,
`Selected facade methods`, `Player Control`, and `Editor Entry Points` before
deciding a wrapper call is undocumented. For editor operations, search the
Editor page for `Project Setup`, `Mutation Workflow`, `Persistence Workflow`,
and `Preview And Validation`.

When a return value is not documented for the Godot wrapper specifically, the
table states the official native return and the observed GDScript usage
separately. Do not invent stricter checks than the source supports.

## `PDJE_Wrapper` Reference

| Method | Args | Returns | Failure / Empty value | Source |
| --- | --- | --- | --- | --- |
| `InitEngine(root_db_path)` | `String` Godot path to the root DB. | `bool` in current harness examples. | `false`; do not continue with search/player/editor setup. | Current examples; Core docs show construction with DB path. |
| `SearchMusic(title, composer, bpm = -1.0)` | `String`, `String`, `float`; empty strings skip text filters, `bpm < 0` skips BPM filter. | `Array` of music metadata wrappers/dictionaries. | Empty `Array` when no match. | Core docs. |
| `SearchTrack(title)` | `String`; empty string skips title filter. | `Array` of track data. | Empty `Array` when no match. | Core docs. |
| `InitPlayer(mode, track_or_title, frame_buffer_size)` | `PDJE_Wrapper.*_RENDER`, current wrapper accepts a track title or searched track data depending on call path, `int`. | `bool`. | `false` on init error or missing track; `FULL_MANUAL_RENDER` examples pass `"void"`. | Core docs; Current examples. |
| `GetPlayer()` | None. | `PlayerWrapper` or `null`. | `null`; check before calling player methods. | Core docs wrapper example. |
| `ResetPlayer()` | None. | Not documented for Godot wrapper; observed as command-style call. | Reacquire `PlayerWrapper` and `CoreLine` after calling it. | Core docs; Current examples. |
| `PullOutCoreLine()` | None. | `CoreLine`. | Empty/default line until a player exists; reacquire after `ResetPlayer()` or new player init. | Core docs document native `PullOutDataLine()`. |
| `InitEditor(author_name, author_email, project_root)` | `String`, `String`, `String`. | `bool`. | `false`; do not call `GetEditor()` as usable. | Core docs; Editor docs. |
| `GetEditor()` | None. | `EditorWrapper` or `null`. | `null`; check before editor mutation. | Core docs. |
| `CloseEditor()` | None. | Not documented for Godot wrapper; native method is `void`. | Editor handle should be treated as closed. | Core docs. |

## `PlayerWrapper` Reference

| Method | Args | Returns | Failure / Empty value | Source |
| --- | --- | --- | --- | --- |
| `Activate()` | None. | `bool` in native docs and examples. | `false` means playback did not start. | Core docs. |
| `Deactivate()` | None. | `bool` in native docs and examples. | `false` means playback did not stop cleanly. | Core docs. |
| `GetConsumedFrames()` | None. | `int` frame counter. | `0` can mean playback has not advanced; divide by 48000 for seconds. | Core docs. |
| `GetFXControlPanel(title = "__PDJE__MAIN__")` | Optional `String` music title; default controls prerendered main output. | `FXWrapper` or `null`. | `null` if the target title/panel does not exist or manual panels are unavailable. | Core docs; Current examples. |
| `GetMusicControlPanel()` | None. | `MusPanelWrapper` or `null`. | `null` if manual panels are unavailable. | Core docs; Current examples. |
| `GetStatus()` | None. | Not documented in official Core docs; observed in AutoBench as status query. | Verify current wrapper before relying on exact enum/value shape. | Current examples. |

## `MusPanelWrapper`, `FXWrapper`, And `FXArgWrapper` Reference

Manual music and FX panels are available for `HYBRID_RENDER` and
`FULL_MANUAL_RENDER` paths. FX enum examples use
`EnumWrapper.PDJE_FX_LIST.*` because that is the current runnable-example
namespace.

| Method | Args | Returns | Failure / Empty value | Source |
| --- | --- | --- | --- | --- |
| `LoadMusic(title, composer, bpm)` | Current Godot wrapper examples pass `String`, `String`, `float`. | Documented native method returns a status/error-like value; current examples do not check strictly. | Treat non-success/falsey values as load failure when the wrapper exposes them. | Core docs; Current examples. |
| `SetMusic(title, on_off)` | `String`, `bool`. | `bool`. | `false`. | Core docs. |
| `CueMusic(title, new_pos)` | `String`, current examples pass `"0"` as string; native docs use integer frame position. | `bool`. | `false`. | Core docs; Current examples. |
| `UnloadMusic(title)` | `String`. | `bool`. | `false`. | Core docs. |
| `ChangeBpm(title, target_bpm, origin_bpm)` | `String`, `float`, `float`. | `bool`. | `false`. | Core docs. |
| `GetLoadedMusicList()` | None. | Loaded music list; exact Godot element shape not documented. | Empty list if no music is loaded. | Core docs. |
| `getFXHandle(title)` | `String` loaded music title. | `FXWrapper` or `null`. | `null`; check before FX calls. | Current examples. |
| `FX_ON_OFF(fx, on_off)` | `EnumWrapper.PDJE_FX_LIST.*`, `bool`. | Native docs say `void`; current GDScript examples treat it as command-style. | No reliable boolean check documented. | Core docs; Current examples. |
| `GetArgSetter(fx = current_panel_fx)` | Current examples call with and without an FX enum depending on panel path. | `FXArgWrapper`/arg handler. | Check for `null` if the wrapper returns a ref. | Core docs; Current examples. |
| `GetFXArgKeys(fx)` | `EnumWrapper.PDJE_FX_LIST.*`. | `Array[String]` observed in AutoBench. | Empty array if keys are unavailable. | Current examples; FX args docs. |
| `SetFXArg(fx, key, value)` | `EnumWrapper.PDJE_FX_LIST.*`, case-sensitive `String`, numeric value. | Not documented for Godot wrapper; observed as command-style setter. | Wrong key spelling does not match; use exact keys from FX args docs. | Current examples; FX args docs. |

## Playback Flow

```gdscript
var engine := PDJE_Wrapper.new()
if not engine.InitEngine("res://database/rootdb"):
    return

var tracks := engine.SearchTrack("track-title")
if tracks.is_empty():
    return

if not engine.InitPlayer(PDJE_Wrapper.HYBRID_RENDER, "track-title", 480):
    return

var player := engine.GetPlayer()
if player == null:
    return

player.Activate()
player.Deactivate()
engine.ResetPlayer()
```

`PDJE_Wrapper` play modes are:

| Enum | Value | Use |
| --- | ---: | --- |
| `FULL_PRE_RENDER` | `0` | Pre-rendered playback path. |
| `HYBRID_RENDER` | `1` | Pre-rendered playback with manual music/FX panels. |
| `FULL_MANUAL_RENDER` | `2` | Manual player path without a searched track constructor payload. |

## Manual Music And FX

```gdscript
var music_panel := player.GetMusicControlPanel()
if music_panel != null:
    music_panel.LoadMusic("title", "composer", -1.0)
    music_panel.SetMusic("title", true)
    music_panel.CueMusic("title", "0")

    var fx_panel := music_panel.getFXHandle("title")
    if fx_panel != null:
        fx_panel.FX_ON_OFF(EnumWrapper.PDJE_FX_LIST.FILTER, true)
        var args := fx_panel.GetArgSetter()
        if args != null:
            args.SetFXArg(EnumWrapper.PDJE_FX_LIST.FILTER, "HLswitch", 0)
```

FX argument keys are case-sensitive. Do not rewrite key spelling. Use
https://rliop913.github.io/Project-DJ-Engine-Docs/FX_ARGS.html for the
complete key list.

## Editor Flow

```gdscript
var engine := PDJE_Wrapper.new()
engine.InitEngine("res://database/rootdb")

if not engine.InitEditor("Author Name", "author@example.com", "res://EditorProject"):
    return

var editor := engine.GetEditor()
if editor == null:
    return

editor.ConfigNewMusic(
    "music-title",
    "composer",
    "res://audio/song.wav",
    "0")

var arg := PDJE_EDITOR_ARG.new()
arg.InitMixArg(
    PDJE_EDITOR_ARG.EDITOR_TYPE_LIST.BPM_CONTROL,
    PDJE_EDITOR_ARG.EDITOR_DETAIL_LIST.TIME_STRETCH,
    1,
    "128",
    "",
    "",
    0, 0, 0,
    0, 0, 0)
editor.AddLine(arg)

var render_message := editor.render("track-title")
if render_message == "RENDER COMPLETE":
    editor.pushTrackToRootDB("track-title")
```

## `EditorWrapper` Reference

| Method | Args | Returns | Failure / Empty value | Source |
| --- | --- | --- | --- | --- |
| `Open(project_path, author_name, author_email)` | `String`, `String`, `String`. | Native docs return `bool`; exact Godot wrapper return should be verified before relying on it. | `false`/failure means project did not open. | Editor docs. |
| `ConfigNewMusic(name, composer, path, first_bar = "0")` | `String`, `String`, Godot audio path `String`, `String`. | `bool` in current GDScript examples. | `false`; music metadata was not staged. | Editor docs; Current examples. |
| `AddLine(arg)` | One initialized `PDJE_EDITOR_ARG`. | `bool` in current examples. | `false`; row was not accepted. | Editor docs; Current examples. |
| `deleteLine(arg, skip_type_if_mix_obj, skip_detail_if_mix_obj)` | `PDJE_EDITOR_ARG`, `bool`, `bool`. | Native docs describe mutation; exact Godot return is not documented. | Verify before using as a boolean guard. | Editor docs. |
| `render(track_title)` | `String`. | Current Godot wrapper returns a lint/render message `String`; native docs return `bool` and fill `lint_msg`. | Treat any value other than the expected success message, currently `"RENDER COMPLETE"` in examples, as failure. | Editor docs; Current examples. |
| `pushTrackToRootDB(track_title)` | `String`. | `bool` in current examples; wrapper helper for native track push. | `false`; root DB was not updated. | Editor docs; Current examples. |
| `pushToRootDB(music_title, music_composer)` | `String`, `String`. | `bool` in current examples; wrapper helper for native music push. | `false`; root DB was not updated. | Editor docs; Current examples. |
| `demoPlayInit(frame_buffer_size, track_title)` | `int`, `String`. | Native docs expose a `void` method that initializes an output player; Godot wrapper behavior is observed as preview setup. | Check `GetPlayer()`/preview handle after calling if the path exposes one. | Editor docs; Current examples. |
| `getAll()` | None. | Current editor state object/dictionaries; exact Godot shape is not documented. | Empty/default data if project state is unavailable. | Editor docs; Current harness. |
| `Undo()` / `Redo()` / `Go(...)` | History/time-travel arguments vary by wrapper binding. | Not documented for Godot wrapper in the official workflow page. | Verify exact signature before generating new GDScript. | Editor docs. |
| `GetLogWithJSONGraph()` / `UpdateLog(...)` | History/log helpers. | Not documented for Godot wrapper in the official workflow page. | Verify exact signature before generating new GDScript. | Editor docs. |
| `DESTROY_PROJECT()` | None. | Destructive cleanup command; exact Godot return is not documented. | Do not use in normal authoring flow. | Editor docs. |

## `PDJE_EDITOR_ARG` Lifetime Rule

Use one `PDJE_EDITOR_ARG` per row. Treat it as a one-shot carrier for the next
`AddLine()` or `deleteLine(...)` call.

Do not reuse a `PDJE_EDITOR_ARG` by calling `InitMixArg()`, `InitNoteArg()`,
`InitMusicArg()`, or `InitKeyValueArg()` again after using it. The wrapper
stores optional row payloads and a `useFlag` on the same object. If an
initializer returns early because an enum or detail value is invalid, stale or
partial payload from a previous initialization can remain visible to later
editor calls.

Safe pattern:

```gdscript
var filter_arg := PDJE_EDITOR_ARG.new()
filter_arg.InitMixArg(...)
editor.AddLine(filter_arg)

var echo_arg := PDJE_EDITOR_ARG.new()
echo_arg.InitMixArg(...)
editor.AddLine(echo_arg)
```

Unsafe pattern:

```gdscript
var arg := PDJE_EDITOR_ARG.new()
arg.InitMixArg(...)
editor.AddLine(arg)

# Do not reuse the same carrier for another row.
arg.InitMixArg(...)
editor.AddLine(arg)
```

## Editor Argument Types

Create `PDJE_EDITOR_ARG` rows through the initializer matching the row type:

Use the nested enum namespaces shown in the runnable examples when creating
new rows: `PDJE_EDITOR_ARG.EDITOR_TYPE_LIST.*` for mix types and
`PDJE_EDITOR_ARG.EDITOR_DETAIL_LIST.*` for mix details. Avoid flat constant
aliases in harness-generated examples unless the current checkout proves that a
specific alias is required.

| Initializer | Args | Returns | Failure / Empty value | Source |
| --- | --- | --- | --- | --- |
| `InitNoteArg(note_type, note_detail, first, second, third, beat, sub_beat, separate, end_beat, end_sub_beat, end_separate, rail_id)` | Note type/detail strings or enum-compatible values, three string payloads, start/end timing integers, rail id. | Not documented; observed as command-style row initialization. | Invalid values can leave the carrier unusable; create a fresh `PDJE_EDITOR_ARG` per row. | Editor docs; Current examples. |
| `InitMusicArg(music_name, bpm, beat, sub_beat, separate)` | `String`, BPM string/number accepted by wrapper path, timing integers. | Not documented; observed as command-style row initialization. | Use a fresh carrier and check `AddLine()` after initialization. | Editor docs; Current examples. |
| `InitMixArg(type, details, id, first, second, third, beat, sub_beat, separate, end_beat, end_sub_beat, end_separate)` | `PDJE_EDITOR_ARG.EDITOR_TYPE_LIST.*`, `PDJE_EDITOR_ARG.EDITOR_DETAIL_LIST.*` or documented integer detail, `int`, three string payloads, start/end timing integers. | Not documented; observed as command-style row initialization. | Wrong enum/detail can make later `AddLine()` fail or use stale carrier data. | Editor docs; Current examples. |
| `InitKeyValueArg(key, value)` | `String`, `String`. | Not documented; observed as command-style row initialization. | Use a fresh carrier and check `AddLine()` after initialization. | Editor docs. |

Editor `type` enum values:

| Value | Name |
| ---: | --- |
| 0 | `FILTER` |
| 1 | `EQ` |
| 2 | `DISTORTION` |
| 3 | `CONTROL` |
| 4 | `VOL` |
| 5 | `LOAD` |
| 6 | `UNLOAD` |
| 7 | `BPM_CONTROL` |
| 8 | `ECHO` |
| 9 | `OSC_FILTER` |
| 10 | `FLANGER` |
| 11 | `PHASER` |
| 12 | `TRANCE` |
| 13 | `PANNER` |
| 14 | `BATTLE_DJ` |
| 15 | `ROLL` |
| 16 | `COMPRESSOR` |
| 17 | `ROBOT` |

Editor `details` enum values:

| Value | Name |
| ---: | --- |
| 0 | `HIGH` |
| 1 | `MID` |
| 2 | `LOW` |
| 3 | `PAUSE` |
| 4 | `CUE` |
| 5 | `TRIM` |
| 6 | `FADER` |
| 7 | `TIME_STRETCH` |
| 8 | `SPIN` |
| 9 | `PITCH` |
| 10 | `REV` |
| 11 | `SCRATCH` |
| 12 | `BSCRATCH` |

## Mix Args Table

This table preserves the current author-facing mix argument contract.
Refer to https://rliop913.github.io/Project-DJ-Engine-Docs/Editor_Workflows.html
and the editor format pages for the latest source format.

| type | ID | details | first | second | third | Interpolated Value |
| --- | --- | --- | --- | --- | --- | --- |
| `FILTER(0)` | `ID` | `HIGH(0)/LOW(2)` | `ITPL` | `8PointValues` | `NONE` | filter Frequency |
| `EQ(1)` | `ID` | `HIGH(0)/MID(1)/LOW(2)` | `ITPL` | `8PointValues` | `NONE` | eq value |
| `DISTORTION(2)` | `ID` | `0` | `ITPL` | `8PointValues` | `NONE` | drive value |
| `CONTROL(3)` | `ID` | `PAUSE(3)/CUE(4)` | `approx_loc` | `X` | `NONE` | `NONE` |
| `VOL(4)` | `ID` | `TRIM(5)/FADER(6)` | `ITPL` | `8PointValues` | `NONE` | volume |
| `LOAD(5)` | `ID` | `0` | `title` | `composer` | `bpm` | `NONE` |
| `UNLOAD(6)` | `ID` | `0` | `X` | `X` | `NONE` | `NONE` |
| `bpmControl(7)` | `ID` | `timeStretch(7)` | `BPM(double)` | `NONE` | `NONE` | `NONE` |
| `ECHO(8)` | `ID` | `0` | `ITPL` | `8PointValues` | `BPM, feedback` | Wet amount |
| `OCS_Filter(9)` | `ID` | `HIGH(0)/LOW(2)` | `ITPL` | `8PointValues` | `BPM, MiddleFreq, RangeHalfFreq` | Wet amount |
| `FLANGER(10)` | `ID` | `0` | `ITPL` | `8PointValues` | `BPM` | Wet amount |
| `PHASER(11)` | `ID` | `0` | `ITPL` | `8PointValues` | `BPM` | Wet amount |
| `TRANCE(12)` | `ID` | `0` | `ITPL` | `8PointValues` | `BPM, GAIN` | Wet amount |
| `PANNER(13)` | `ID` | `0` | `ITPL` | `8PointValues` | `BPM, GAIN` | Wet amount |
| `BATTLE_DJ(14)` | `ID` | `SPIN(8)/PITCH(9)/REV(10)` | `SPEED` | `NONE` | `NONE` | `NONE` |
| `BATTLE_DJ(14)` | `ID` | `SCRATCH(11)` | `StartPosition` | `SPEED` | `NONE` | `NONE` |
| `ROLL(15)` | `ID` | `0` | `ITPL` | `8PointValues` | `BPM` | Wet amount |
| `COMPRESSOR(16)` | `ID` | `0` | `Strength` | `Thresh, Knee` | `ATT, REL` | `NONE` |
| `ROBOT(17)` | `ID` | `0` | `ITPL` | `8PointValues` | `ocsFreq` | Wet amount |

## 8PointValues And Interpolation

Older docs call the second mix argument `8PointValues`. In current terms:

- `MixArgs.first` usually carries the interpolation selector.
- `MixArgs.second` usually carries eight comma-separated data points.
- `MixArgs.third` carries extra per-effect values when the table lists them.
- The runtime stretches the eight control points across the event span from
  `(beat, subBeat, separate)` to `(Ebeat, EsubBeat, Eseparate)`.

Supported interpolation concepts are `linear`, `cosine`, `cubic`, and `flat`,
matching the runtime enum family `ITPL_LINEAR`, `ITPL_COSINE`, `ITPL_CUBIC`,
and `ITPL_FLAT`.

These values can interpolate the table's `Interpolated Value` column, including
filter frequency, EQ value, drive value, volume, and wet amount for echo,
oscillating filter, flanger, phaser, trance, panner, roll, and robot.

Example:

```gdscript
arg.InitMixArg(
    PDJE_EDITOR_ARG.EDITOR_TYPE_LIST.ECHO,
    0,
    1,
    "0",
    "0.0,0.2,0.5,0.8,1.0,0.8,0.5,0.2",
    "128.0,0.35",
    8, 0, 1,
    16, 0, 1)
```

For `ITPL_FLAT`, a single value is often enough conceptually, but preserve the
current accepted source format unless the code path you are using proves a
shorter shape is accepted.

## CoreLine

After a player exists, call `PullOutCoreLine()` and poll:

| Method | Args | Returns | Failure / Empty value | Source |
| --- | --- | --- | --- | --- |
| `GetUsedFrame()` | None. | `int` engine time / used frame counter. | `0` or default value before valid playback state. | Core docs; Current harness. |
| `GetNowCursor()` | None. | `int` current playback cursor. | `0` or default value before valid playback state. | Core docs; Current harness. |
| `GetMaxCursor()` | None. | `int` maximum cursor. | `0` or default value before valid playback state. | Core docs; Current harness. |
| `GetPreRenderedFrames()` | None. | Packed/array PCM frame data; exact Godot container shape is wrapper-defined. | Empty array if no prerendered frames are available. | Core docs; Current harness. |

Reacquire `CoreLine` after `ResetPlayer()` or a new player init.
