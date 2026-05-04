# Judge Module

Use this page when a Godot game needs gameplay timing, hit/miss judgment, note
rails, or judge callbacks.

## Classes

| Class | Kind | Use |
| --- | --- | --- |
| `PDJE_Judge_Module` | `Node` | Connects core and input data lines, maps devices/MIDI to rails, stages notes, starts/stops judge loop, emits result signals. |
| `PDJE_Input_Module` | `Node` | Required input provider for standard wrapper flow. |
| `PDJE_Wrapper` | `Node` | Required core/player provider for core data line and note extraction. |

Input and judge wrappers are build conditional. Verify
`PDJE_GODOT_ENABLE_INPUT_WRAPPER` for the target platform.

## Required Order

1. Initialize `PDJE_Wrapper`.
2. Initialize player with a track, or otherwise ensure a valid core data line.
3. Initialize and configure `PDJE_Input_Module`.
4. Call `AddDataLines(input, core)`.
5. Add standard rails with `DeviceAdd(...)` and/or MIDI rails with
   `MIDI_DeviceAdd(...)`.
6. Call `SetRule(...)`.
7. Call `SetNotes(core, track_title)`.
8. Call `StartJudge()`.
9. Start input with `Run()` and playback with `player.Activate()`.
10. On shutdown, call `player.Deactivate()`, `input.Kill()`, and `EndJudge()`.

## Godot Flow

```gdscript
var core := $PDJE_Wrapper
var input := $PDJE_Input_Module
var judge := $PDJE_Judge_Module

core.InitEngine("res://database/rootdb")
core.InitPlayer(PDJE_Wrapper.HYBRID_RENDER, "track-title", 480)
var player := core.GetPlayer()

input.Init()
var selected_devices := []
for device in input.GetDevs():
    if device["type"] == "KEYBOARD":
        selected_devices.push_back(device)
var selected_midi := input.GetMIDIDevs()
input.Config(selected_devices, selected_midi)

if not judge.AddDataLines(input, core):
    return

for device in selected_devices:
    judge.DeviceAdd(device, InputLine.A, 0, 1)

for midi_port in selected_midi:
    judge.MIDI_DeviceAdd(midi_port, 1, "NOTE_ON", 1, 48, 0)

judge.SetRule(60000, 61000, 1, 3, false)
if not judge.SetNotes(core, "track-title"):
    return

if not judge.StartJudge():
    return

input.Run()
player.Activate()
```

Shutdown:

```gdscript
player.Deactivate()
input.Kill()
judge.EndJudge()
```

## Rail Setup

Standard device rail:

```gdscript
judge.DeviceAdd(device_dictionary, InputLine.A, 0, 1)
```

| Argument | Meaning |
| --- | --- |
| `device_dictionary` | One dictionary from `PDJE_Input_Module.GetDevs()`. |
| `PDJE_KEY_CODE` | Bound key/mouse enum value from `InputLine`. |
| `offset_microsecond` | Timing offset applied to this route. |
| `MatchRail_id` | Logical gameplay rail id used by note rows. |

MIDI rail:

```gdscript
judge.MIDI_DeviceAdd("Port Name", 1, "NOTE_ON", 1, 48, 0)
```

| Argument | Meaning |
| --- | --- |
| `midi_device_name` | Port name from `GetMIDIDevs()`. |
| `match_rail_id` | Logical gameplay rail id. |
| `input_type` | `NOTE_ON`, `CONTROL_CHANGE`, or `PITCH_BEND` in current wrapper code. |
| `ch` | MIDI channel. |
| `pos` | MIDI note/controller position. |
| `offset_microsecond` | Timing offset. |

Rail ids must match the `RailID` field in editor note rows.

## Rules

```gdscript
judge.SetRule(
    use_range_half_us,
    miss_range_half_us,
    useloop_sleep_time_ms,
    missloop_sleep_time_ms,
    enable_custom_mouse_signal)
```

Use and miss ranges are microsecond windows. Keep callback work light; the
native judge dispatches callbacks through worker queues, and the wrapper emits
signals through `call_deferred`.

## Signals

| Signal | Arguments |
| --- | --- |
| `pdje_judge_miss_signal` | `missed_list` dictionary grouped by rail id. |
| `pdje_judge_use_signal` | `rail_id`, `is_pressed`, `is_late`, `time_diff`. |
| `pdje_judge_custom_mouse_parse_signal` | `microsecond`, `found_events`, `rail_id`, `X`, `Y`, `AXIS_ENUM`. |

Missed/found note dictionaries include:

- `TYPE`
- `DETAIL`
- `ISDOWN`
- `MICROSECOND`
- `FIRST`
- `SECOND`
- `THIRD`
- `USED` for custom mouse found events

## Start Failures

`StartJudge()` returns `false` and prints an error when any prerequisite is
missing:

- core data line
- input data line
- event rule
- input rail mapping
- note objects

Do not start judge before `SetNotes()` and rail registration. Adding rails does
not create note objects.

