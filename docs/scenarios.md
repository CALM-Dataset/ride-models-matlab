# Scenarios

A scenario is a struct with a road and some context:

| Field | Content |
| --- | --- |
| `name`, `description`, `source` | text |
| `road` | terrain: a bump list or a measured profile |
| `speed_mps` | a suggested driving speed |
| `meta` | anything the source provides |

Pick one by name with `ride.scenarios.get`:

```matlab
sc = ride.scenarios.get('synthetic:02_two_bumps/s_l');
```

In the config, `"scenario": "synthetic:m"`.

## Synthetic

185 ready-made roads. A name is one letter code per feature, in road order, joined by `_`. An `h` prefix turns a bump into a hole of the same size.

| Code | Feature | Height | Width |
| --- | --- | --- | --- |
| `s` | short bump | 25 mm | 0.92 m |
| `m` | medium bump | 62.5 mm | 2.22 m |
| `l` | long bump | 125 mm | 9.5 m |
| `c` | raised crosswalk | 100 mm | 5.0 m |
| `sv` | severe bump | 100 mm | 1.0 m |

`s_hm_c` is a short bump, a medium hole, then a crosswalk. Features start after a 40 m flat lead-in and sit 30 m apart. The five `pothole_*` scenarios hold a single pothole. List them with `ride.scenarios.synthetic.list()`, or by suite with `list('02_two_bumps')`.

Change the layout with options: `ride.scenarios.get('synthetic:s_l', 'gap_m', 50, 'flat_start_m', 20, 'speed_kmh', 20)`.

Sizes follow the pothole and bump tables in the thesis cited in `CITATION.cff`.

## Real roads

Measured height profiles from drives in Germany and Italy, published as the `CALM-Dataset/CALM-Scenarios` dataset on Hugging Face. Each file holds a height profile every 5 cm and the labelled bump.

```matlab
ride.scenarios.real.sync('germany/eval');           % download into the local cache
ride.scenarios.real.list()                          % what is cached
sc = ride.scenarios.get('real:germany/eval/stuttgart_sb01');
```

Folders: `germany/train`, `germany/eval`, `italy/train`, `italy/eval`, or `'all'`. `train` and `eval` are split by location, so no road in `eval` shares a place with `train`; the dataset's `split.yaml` lists the held-out locations. The dataset is private: set an access token before syncing, `setenv('HF_TOKEN', 'hf_...')`. Without it the sync stops with an error that says so. Files are cached under `data/cache` (set `RIDE_CACHE` to move it). The published files are already trimmed to the labelled bump (with 0.5 m of level road on each side), and `sc.meta.trim` records the offset that was removed. A file without that marker is trimmed when it is loaded; pass `'trim', false` to keep a raw profile. `sc.meta.low_confidence` marks roads where the labelled bump could not be confirmed by the height sensors.

## Your own roads

From a file. Either a bump list or a measured profile:

```json
{"name": "my_road", "speed_mps": 5,
 "bumps": [{"start_m": 10, "height_m": 0.05, "length_m": 1.5},
           {"start_m": 30, "height_m": -0.04, "length_m": 0.8}]}
```

```json
{"road": {"ds_m": 0.05, "z": [0, 0, 0.001, 0.003]},
 "bumps": [{"s_start_m": 12, "s_end_m": 14, "peak_z_m": 0.06}]}
```

```matlab
sc = ride.scenarios.get('file:my_road.json');
```

From code, as a height function of distance:

```matlab
road = ride.core.terrain.from_function(@(s) 0.03 * sin(2 * pi * s / 5), 60, 0.02);
sc = ride.scenarios.make('washboard', road, 'speed_mps', 8);
```

Registered by name, so config files and `ride.scenarios.get` find it:

```matlab
ride.scenarios.register('washboard', @() sc);
ride.scenarios.get('registered:washboard');
```

`examples/extend/add_scenario_source.m` turns a CSV file of heights into a registered road, a pattern for any other source of roads.
