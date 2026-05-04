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
    fx_panel.FX_ON_OFF(EnumWrapper.ECHO, true)
    var args := fx_panel.GetArgSetter()
    args.SetFXArg(EnumWrapper.ECHO, "EchoDryWet", 0.5)
```

FX argument keys are case-sensitive. Use `GetFXArgKeys(fx)` or
`srcs/FX_ARGS.rst`; do not rewrite key spelling.

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
    PDJE_EDITOR_ARG.FILTER,
    PDJE_EDITOR_ARG.LOW,
    1,
    "0",
    "5000,1000,2000,3000,4000,5000,5500,6000",
    "",
    0, 0, 1,
    16, 0, 1)
editor.AddLine(arg)

var render_message := editor.render("track-title")
if render_message == "RENDER COMPLETE":
    editor.pushTrackToRootDB("track-title")
```

Editor-visible operations include:

| Method | Use |
| --- | --- |
| `ConfigNewMusic(name, composer, path, firstBar = "0")` | Adds new music metadata to the editor project. |
| `AddLine(arg)` | Adds a typed `PDJE_EDITOR_ARG` row. |
| `deleteLine(arg, skipType_if_mix_obj, skipDetail_if_mix_obj)` | Removes matching typed rows. |
| `render(trackTitle)` | Prepares authored editor content for root DB push. |
| `pushTrackToRootDB(trackTitle)` | Pushes rendered track content to the root DB. |
| `pushToRootDB(musicTitle, musicComposer)` | Pushes rendered music content to the root DB. |
| `demoPlayInit(frameBufferSize, trackTitle)` | Creates preview playback from editor-authored content. |
| `getAll()` | Returns current mix, music, note, and key-value dictionaries. |
| `Undo/Redo/Go/GetLogWithJSONGraph/UpdateLog` | History and time-travel helpers. |
| `DESTROY_PROJECT()` | Destructive editor project teardown. |

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

| Initializer | Row type |
| --- | --- |
| `InitNoteArg(Note_Type, Note_Detail, first, second, third, beat, subBeat, separate, Ebeat, EsubBeat, Eseparate, RailID)` | Chart/judge note row. |
| `InitMusicArg(musicName, bpm, beat, subBeat, separate)` | Music BPM timeline row. |
| `InitMixArg(type, details, ID, first, second, third, beat, subBeat, separate, Ebeat, EsubBeat, Eseparate)` | Mix/playback/FX automation row. |
| `InitKeyValueArg(key, value)` | Project-scoped key-value row. |

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

This table preserves the current author-facing mix argument contract from
`docs_harness/important_assets/editor_format/tables.json`.

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
    PDJE_EDITOR_ARG.ECHO,
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

| Method | Use |
| --- | --- |
| `GetUsedFrame()` | Engine time / used frame counter. |
| `GetNowCursor()` | Current playback cursor. |
| `GetMaxCursor()` | Maximum cursor. |
| `GetPreRenderedFrames()` | Pre-rendered PCM frame data. |

Reacquire `CoreLine` after `ResetPlayer()` or a new player init.
