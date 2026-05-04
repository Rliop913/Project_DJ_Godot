# Utility Module

Use this page when a Godot game needs PDJE utility wrappers: key-value DB,
relational DB, vector DB, MIR/STFT/waveform helpers, or Beat This AI detection.

## Godot Utility Classes

| Class | Use |
| --- | --- |
| `PDJE_KeyValueDB` | RocksDB-backed key-value storage. |
| `PDJE_RelationalDB` | SQLite-backed execute/query/transaction wrapper. |
| `PDJE_VectorDB` | Annoy-backed nearest-neighbor vector index. |
| `PDJE_VectorItem` | Vector DB item carrier. |
| `PDJE_VectorHit` | Vector DB search hit carrier. |
| `PDJE_RelationalRow` | SQL row carrier. |
| `PDJE_RelationalExecResult` | SQL exec result carrier. |
| `PDJE_MIR` | Waveform, RGB waveform, and STFT facade. |
| `PDJE_StftResult` | STFT real/imag arrays. |
| `PDJE_AI` | Beat This detector factory. |
| `PDJE_BeatThisDetector` | Beat/downbeat detector handle. |
| `PDJE_BeatThisResult` | Beat/downbeat timestamp arrays. |

## DB Examples

Key-value:

```gdscript
var kv := PDJE_KeyValueDB.new()
if kv.Open("user://pdje-cache/kv", true):
    kv.PutText("artist", "RLIOP913")
    print(kv.GetText("artist"))
    kv.Close()
```

Relational:

```gdscript
var sql := PDJE_RelationalDB.new()
if sql.Open("user://pdje-cache/library.sqlite3", true):
    sql.Execute("CREATE TABLE IF NOT EXISTS notes(id INTEGER, lane TEXT)")
    sql.Execute("INSERT INTO notes(id, lane) VALUES(?1, ?2)", [1, "left"])
    for row in sql.Query("SELECT lane FROM notes WHERE id = ?1", [1]):
        print(row.values)
    sql.Close()
```

Vector:

```gdscript
var vectors := PDJE_VectorDB.new()
if vectors.Open("user://pdje-cache/vectors", 3, 10, false, true):
    var item := PDJE_VectorItem.new()
    item.id = "track-a"
    item.embedding = PackedFloat32Array([0.9, 0.1, 0.0])
    item.text_payload = "high-energy intro"
    vectors.UpsertItem(item)

    for hit in vectors.Search(PackedFloat32Array([1.0, 0.0, 0.0]), 3):
        print(hit.id, " ", hit.distance)
    vectors.Close()
```

Use `user://` for mutable game caches. Use `res://` only for packaged
read-only resources or project assets.

## MIR And STFT

`PDJE_MIR` uses a `PDJE_Wrapper` for music search and PCM extraction. A
`PDJE_KeyValueDB` cache is optional where the method accepts it.

```gdscript
var mir := PDJE_MIR.new()
var pcm := PackedFloat32Array()
pcm.resize(1024)

var stft_frames := mir.STFT_PCM_DATA(
    pcm,
    1,
    PDJE_MIR.HANNING,
    10,
    0.5,
    true,
    true,
    true,
    true,
    true,
    true)

for frame in stft_frames:
    print(frame.real.size(), " ", frame.imag.size())
```

Waveform example:

```gdscript
var mir := PDJE_MIR.new()
var cache_db := PDJE_KeyValueDB.new()
cache_db.Open("user://pdje-cache/waveforms", true)

var images := mir.SoundToWaveform(
    $PDJE_Wrapper,
    cache_db,
    "music-title",
    "composer",
    128.0,
    256,
    4096,
    256)

for webp_bytes in images:
    print(webp_bytes.size())
```

## `util/ai`

Native `PDJE_UTIL::ai` has a generic ONNX Runtime facade and Beat This
pipeline, but the current Godot wrapper exposes only Beat This. Do not tell
Godot users they can create arbitrary ONNX sessions through the wrapper.

Godot AI classes:

| Class | Use |
| --- | --- |
| `PDJE_AI` | `Node` facade with `CreateBeatThisDetector(model_path)`. |
| `PDJE_BeatThisDetector` | Owns native `PDJE_UTIL::ai::BeatThisDetector`. |
| `PDJE_BeatThisResult` | Has `beats` and `downbeats` `PackedFloat64Array` properties. |

The model path must be:

- non-empty
- an existing file
- a regular file
- `.onnx`
- reachable from Godot path conversion, such as `res://models/beat_this.onnx`

The checkout includes a native model asset at
`PDJE-Godot-Plugin/Project-DJ-Engine/third_party/onnx_models/beat_this_model_final0.onnx`.
For a game export, copy the model you use into the Godot project, for example
`res://models/beat_this.onnx`, and include it in the export.

## Beat This Examples

From PCM:

```gdscript
var ai := PDJE_AI.new()
var detector := ai.CreateBeatThisDetector("res://models/beat_this.onnx")
if detector == null:
    return

var interleaved_pcm := PackedFloat32Array()
interleaved_pcm.resize(44100)

var result := detector.DetectPCM(interleaved_pcm, 1, 44100)
if result != null:
    print(result.beats)
    print(result.downbeats)
```

From PDJE music metadata:

```gdscript
var ai := PDJE_AI.new()
var detector := ai.CreateBeatThisDetector("res://models/beat_this.onnx")
if detector == null:
    return

var result := detector.DetectMusic(
    $PDJE_Wrapper,
    "music-title",
    "composer",
    128.0)

if result != null:
    for downbeat in result.downbeats:
        print(downbeat)
```

`DetectPCM(pcm, channel_count, sample_rate)` validates frame alignment, channel
count, sample rate, and non-empty PCM. It downmixes interleaved audio to mono
before running detection.

`DetectMusic(core_api, music_title, composer, bpm)` requires an initialized
`PDJE_Wrapper`, searches music through the core engine, requests PCM, and runs
Beat This using the core decoder sample rate.

Failures return null `PDJE_BeatThisResult` references and print method-level
diagnostic errors.

