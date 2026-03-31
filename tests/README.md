# PacketEvents Fabric Dev Test Harness

This folder provides reproducible Fabric server harnesses for three validation paths.

Current matrix:
- `intermediary-1194` -> `MC 1.19.4` (Java 17+)
- `intermediary-1216` -> `MC 1.21.6` (Java 17+)
- `official-261` -> `MC 26.1` (Java 25)

This is intentionally simple and script-driven so contributors can run the same steps and get the same artifact layout.

## Prerequisites

- Linux/macOS shell (`bash`)
- `curl`
- `python3`
- Java 17+ installed
- Java 25 installed (for the official 26.1 harness)
- From repo root, `./gradlew build` must work

## Quick Start (One Command All Three)

From repository root:

```bash
./tests/scripts/run-all-harnesses.sh
```

What this does:
1. Builds artifacts
2. Sets up all three server directories
3. Installs matching jar sets per path
4. Starts each server briefly (timeout smoke run)

## Individual Harnesses

### 1) Intermediary 1.19.4

```bash
./tests/scripts/bootstrap-intermediary-1194.sh
./tests/scripts/run-server.sh --server-dir tests/runs/fabric-1.19.4
```

### 2) Intermediary 1.21.6

```bash
./tests/scripts/bootstrap-intermediary-1216.sh
./tests/scripts/run-server.sh --server-dir tests/runs/fabric-1.21.6
```

### 3) Official 26.1

Requires Java 25 runtime for server launch:

```bash
./tests/scripts/bootstrap-official-261.sh
./tests/scripts/run-server.sh --server-dir tests/runs/fabric-26.1 --java-bin /path/to/java25
```

## Scripts

- `tests/scripts/bootstrap-intermediary.sh`
  - Backward-compatible alias to `bootstrap-intermediary-1216.sh`.

- `tests/scripts/bootstrap-intermediary-1194.sh`
  - End-to-end setup for intermediary 1.19.4 path.

- `tests/scripts/bootstrap-intermediary-1216.sh`
  - End-to-end setup for intermediary 1.21.6 path.

- `tests/scripts/bootstrap-official-261.sh`
  - End-to-end setup for official 26.1 path.

- `tests/scripts/bootstrap-case.sh`
  - Generic harness bootstrap used by case scripts.

- `tests/scripts/setup-fabric-server.sh`
  - Creates a Fabric server directory and downloads server jar.
  - Auto-resolves latest Fabric loader/installer versions for the given MC version.

- `tests/scripts/install-packetevents-dev-jars.sh`
  - Copies built PacketEvents jars from `build/libs` into a server `mods/` folder.
  - Supports case profiles:
    - `intermediary-1194`: main + common + intermediary + `mc1140` + `mc1194`
    - `intermediary-1216`: main + common + intermediary + `mc1140` + `mc1194` + `mc1202` + `mc1211` + `mc1215` + `mc1216`
    - `official-261`: common + official

- `tests/scripts/run-server.sh`
  - Runs the server with `nogui` and optional `--java-bin` override.

- `tests/scripts/run-all-harnesses.sh`
  - Runs all three harnesses with a timed startup smoke check.

## Reproducibility Notes

- The scripts always pick the newest local jars in `build/libs` per module/profile.
- Before copying, existing `packetevents-*.jar` files in `mods/` are removed.
- The server jar is downloaded from Fabric Meta API based on explicit MC version.

## Known Quirk (Important)

In dev-mode testing, Fabric does not always include JIJ nested jars as dependency artifacts.  
These scripts explicitly copy sub-version jars into `mods/` to mirror production behavior and avoid false negatives.

## Related Context

For the Grim side of official namespace migration and runtime expectations, see:  
[Grim PR #2564: Fabric 26.1 official namespace support](https://github.com/GrimAnticheat/Grim/pull/2564)
