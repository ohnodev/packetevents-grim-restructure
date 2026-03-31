# PacketEvents Fabric Dev Test Harness

This folder provides a reproducible local test path for Fabric server validation.

Current focus:
- Intermediary path smoke test (`MC 1.21.1`, Java 17+)

This is intentionally simple and script-driven so contributors can run the same steps and get the same artifact layout.

## Prerequisites

- Linux/macOS shell (`bash`)
- `curl`
- `python3`
- Java 17+ installed
- From repo root, `./gradlew build` must work

## Quick Start (Intermediary Path)

From repository root:

```bash
./tests/scripts/bootstrap-intermediary.sh
```

What this does:
1. Builds artifacts (`./gradlew :fabric:build`)
2. Downloads a Fabric server jar for `1.21.1` into `tests/runs/fabric-1.21.1/`
3. Copies PacketEvents dev jars (main + intermediary chain-load jars) into `mods/`
4. Writes `eula.txt=true`

Then start server:

```bash
./tests/scripts/run-server.sh --server-dir tests/runs/fabric-1.21.1
```

## Scripts

- `tests/scripts/bootstrap-intermediary.sh`
  - End-to-end setup for one reproducible intermediary test path.

- `tests/scripts/setup-fabric-server.sh`
  - Creates a Fabric server directory and downloads server jar.
  - Auto-resolves latest Fabric loader/installer versions for the given MC version.

- `tests/scripts/install-packetevents-dev-jars.sh`
  - Copies built PacketEvents jars from `build/libs` into a server `mods/` folder.
  - Supports:
    - `--path intermediary` (default): includes `fabric-common`, `fabric-intermediary`, and `fabric-mc*` jars
    - `--path official`: includes `fabric-common` and `fabric-official` jars

- `tests/scripts/run-server.sh`
  - Runs the server with `nogui`.

## Reproducibility Notes

- The scripts always pick the newest local jars in `build/libs`.
- Before copying, existing `packetevents-*.jar` files in `mods/` are removed.
- The server jar is downloaded from Fabric Meta API based on explicit MC version.

## Known Quirk (Important)

In dev-mode testing, Fabric does not always include JIJ nested jars as dependency artifacts.  
These scripts explicitly copy sub-version jars into `mods/` to mirror production behavior and avoid false negatives.
