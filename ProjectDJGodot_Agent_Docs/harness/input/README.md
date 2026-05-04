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

| Method | Use |
| --- | --- |
| `Init()` | Calls `InitWithOptions(false)`. |
| `InitWithOptions(use_internal_window = false)` | Initializes native input; on Wayland it forwards Godot native display/window handles when available. |
| `GetCurrentInputBackend()` | Returns backend string, such as `rawinput-ipc` on Windows or the current Linux backend. |
| `GetDevs()` | Returns standard keyboard/mouse device dictionaries. |
| `GetMIDIDevs()` | Returns MIDI port names. |
| `Config(devices, MIDIdevices)` | Configures selected standard devices and matching MIDI ports. |
| `InitializeInputLine(input_line)` | Injects the native data line into an `InputLine` node. |
| `Run()` | Starts input capture. |
| `Kill()` | Stops input capture. |
| `GetState()` | Returns `DEVICE_CONFIG_STATE`, `INPUT_LOOP_READY`, `INPUT_LOOP_RUNNING`, or `DEAD`. |

Device dictionaries from `GetDevs()` use:

| Key | Meaning |
| --- | --- |
| `device_specific_id` | Native backend identifier. |
| `name` | Device display name. |
| `type` | `KEYBOARD` or `MOUSE`. |

## Signals

Connect these signals from `InputLine`:

| Signal | Arguments |
| --- | --- |
| `pdje_input_keyboard_signal` | `device_id`, `device_name`, `microsecond_string`, `keyboard_key`, `isPressed` |
| `pdje_input_mouse_signal` | `device_id`, `device_name`, `microsecond_string`, `L_btn`, `R_btn`, `wheel_btn`, `side_btn`, `ex_btn`, `is_wheel_YAxis`, `wheel_move`, `mouse_axis_type`, `x`, `y` |
| `pdje_midi_input_signal` | `port_name`, `input_type`, `channel`, `position`, `value`, `microsecond_string` |

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

