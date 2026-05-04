# Input Module

Use this page when a Godot game needs low-latency keyboard, mouse, or MIDI
events from PDJE.

## Availability

Input wrappers are conditional:

- Apple builds disable `PDJE_DEVELOP_INPUT` by default.
- Non-Apple builds currently enable it and define
  `PDJE_GODOT_ENABLE_INPUT_WRAPPER`.
- Do not assume `PDJE_Input_Module`, `InputLine`, or `PDJE_Judge_Module` exists
  on every exported build.

## Classes

| Class | Kind | Use |
| --- | --- | --- |
| `PDJE_Input_Module` | `Node` | Owns native `PDJE_Input`, discovers devices, configures selected standard/MIDI devices, runs and kills input capture. |
| `InputLine` | `Node` | Receives a `PDJE_INPUT_DATA_LINE` and emits Godot signals. |

## API Source

The official input lifecycle and native return values are documented at
https://rliop913.github.io/Project-DJ-Engine-Docs/Input_Engine.html. The
Godot wrapper names come from that page's Godot example plus the current
`GAME_TEMPLATE.tscn` and `PDJE_input_module_example.tscn`.
Search `Selected methods`, `Current Lifecycle`, and `Godot Wrapper Example`
on the official page before deciding an input wrapper method is absent.

## Lifecycle

```gdscript
var input := PDJE_Input_Module.new()
if not input.Init():
    return

var selected_devices := []
for device in input.GetDevs():
    if device["type"] == "KEYBOARD":
        selected_devices.push_back(device)

var selected_midi := input.GetMIDIDevs()
if not input.Config(selected_devices, selected_midi):
    return

input.InitializeInputLine($InputLine)
input.Run()
```

Poll the line from `_process` or a timer:

```gdscript
func _process(_delta):
    $InputLine.emit_input_signal()
```

Shut down explicitly:

```gdscript
input.Kill()
```

Reinitialize and reacquire `InputLine` after killing and rebuilding the input
module.

## `PDJE_Input_Module` Methods

| Method | Args | Returns | Failure / Empty value | Source |
| --- | --- | --- | --- | --- |
| `Init()` | None. | `bool`; wrapper shortcut for `InitWithOptions(false)`. | `false`; do not call `GetDevs()`/`Config()` as a valid runtime. | Official input docs; Current examples. |
| `InitWithOptions(use_internal_window = false)` | `bool`; Linux may use it for internal Wayland fallback, Windows ignores it. | `bool`. | `false`; native input did not initialize. | Official input docs. |
| `GetCurrentInputBackend()` | None. | `String`, for example `rawinput-ipc` on Windows. | `"none"` until default devices/backend are initialized. | Official input docs. |
| `GetDevs()` | None. | `Array[Dictionary]` for standard keyboard/mouse devices. | Empty `Array` when no standard devices are visible. | Official input docs; Current examples. |
| `GetMIDIDevs()` | None. | `Array[String]` MIDI port names in the Godot wrapper. | Empty `Array` when no MIDI ports are visible. | Official input docs; Current examples. |
| `Config(devices, MIDIdevices)` | `Array[Dictionary]` from `GetDevs()`, `Array[String]` from `GetMIDIDevs()`. | `bool`. | `false`; input loop is not ready. | Official input docs; Current examples. |
| `InitializeInputLine(input_line)` | `InputLine` node. | Not documented for Godot wrapper; observed as command-style injection. | Later `emit_input_signal()` prints a failure and emits nothing if no data line was injected. | Official input docs; Current examples. |
| `Run()` | None. | `bool`. | `false`; input loop did not start. | Official input docs; Current examples. |
| `Kill()` | None. | `bool` in native docs; current examples call it command-style. | `false` if stop failed; reacquire data lines after teardown/rebuild. | Official input docs; Current examples. |
| `GetState()` | None. | `int`/enum value: `DEVICE_CONFIG_STATE`, `INPUT_LOOP_READY`, `INPUT_LOOP_RUNNING`, or `DEAD`. | `DEAD` or default state after shutdown/failure. | Official input docs. |

Device dictionaries from `GetDevs()` use:

| Key | Meaning |
| --- | --- |
| `device_specific_id` | Native backend identifier. |
| `name` | Device display name. |
| `type` | `KEYBOARD` or `MOUSE`. |

`GetMIDIDevs()` returns MIDI port names only. Pass the selected names back to
`Config()`; do not pass device dictionaries for MIDI.

## `InputLine` Methods

| Method | Args | Returns | Failure / Empty value | Source |
| --- | --- | --- | --- | --- |
| `emit_input_signal()` | None. | `void`/command-style signal pump. | Emits nothing and prints a failure if `InitializeInputLine()` was not called with a valid data line. | Official input docs; Current harness. |

## Signals

Connect these signals from `InputLine`:

| Signal | Arguments | Payload notes |
| --- | --- | --- |
| `pdje_input_keyboard_signal` | `device_id`, `device_name`, `microsecond_string`, `keyboard_key`, `isPressed` | Standard keyboard lane from the injected data line. |
| `pdje_input_mouse_signal` | `device_id`, `device_name`, `microsecond_string`, `L_btn`, `R_btn`, `wheel_btn`, `side_btn`, `ex_btn`, `is_wheel_YAxis`, `wheel_move`, `mouse_axis_type`, `x`, `y` | Mouse button fields use `-1` for down, `1` for up, `0` for unchanged. |
| `pdje_midi_input_signal` | `port_name`, `input_type`, `channel`, `position`, `value`, `microsecond_string` | MIDI lane is separate from the standard input arena but configured through the same module. |

Mouse button fields use `-1` for down, `1` for up, and `0` for unchanged in the
parsed event.

MIDI `input_type` values currently include:

- `NOTE_ON`
- `NOTE_OFF`
- `PITCH_BEND`
- `CONTROL_CHANGE`
- `AFTERTOUCH`
- `POLY_PRESSURE`

## Notes For Judge

The current judge startup path expects the input data line to include a
non-null standard `input_arena`. Even if a game uses MIDI rails, configure at
least one standard keyboard or mouse device when using judge startup paths that
validate standard input.

## Common Failures

- Empty `GetDevs()` can mean the platform backend cannot see devices or Linux
  input permissions are missing.
- `GetMIDIDevs()` returns only MIDI port names; pass the selected names back to
  `Config()`.
- `emit_input_signal()` before `InitializeInputLine()` prints a failure message
  and emits nothing.
- On Linux evdev paths, the user may need group access to `/dev/input/event*`;
  see the troubleshooting page.
