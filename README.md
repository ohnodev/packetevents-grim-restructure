<!--suppress HtmlDeprecatedAttribute -->
<div align="center">
    <h2><i>PacketEvents</i></h2>
    <h3>PacketEvents is a protocol library tailored to Minecraft Java Edition, designed to facilitate the processing and transmission of packets.</h3>
    <a href="https://github.com/retrooper/packetevents/actions"><img src="https://img.shields.io/github/actions/workflow/status/retrooper/packetevents/gradle-publish.yml?style=for-the-badge&logo=github"></a>
    <a href="https://discord.gg/DVHxPPxHZc"><img src="https://img.shields.io/discord/721686193061888071?color=5562e9&logo=discord&logoColor=white&style=for-the-badge"></a>
    <img src="https://img.shields.io/github/license/retrooper/packetevents?style=for-the-badge&logo=github">
    <a href="https://bstats.org/plugin/bukkit/packetevents/11327"><img src="https://img.shields.io/bstats/servers/11327?style=for-the-badge"></a>
    <a href="https://github.com/retrooper/packetevents/releases"><img src="https://img.shields.io/github/downloads/retrooper/packetevents/total.svg?style=for-the-badge&logo=github"></a>
</div>
<h3>Resources</h3>

- [Read documentation](https://docs.packetevents.com/)
    - [Getting Started](https://docs.packetevents.com/development-setup)
    - [JavaDocs](https://javadocs.packetevents.com)
- [Releases](https://github.com/retrooper/packetevents/releases/)
    - [Modrinth](https://modrinth.com/plugin/packetevents)
    - [GitHub](https://github.com/retrooper/packetevents/releases/)
    - [SpigotMC](https://www.spigotmc.org/resources/packetevents-api.80279/)
- [Development Builds](https://ci.codemc.io/job/retrooper/job/packetevents)
- [Statistics](https://bstats.org/plugin/bukkit/packetevents/11327)

<h3>Fork Testing Guide (Fabric Restructure)</h3>

This repository includes a Fabric restructure that supports both:

- **Intermediary chain-loading path** (`1.14` to `1.21.x`) via `fabric-intermediary`
- **Official mappings path** (`26.1+`) via `fabric-official`

You should test **both paths** before opening or merging PRs.

### What to test

1. **26.1 server startup** (official path)
2. **1.21.x server startup** (intermediary chain-loading path)
3. Player join, movement, chat, and respawn on both
4. Packet injection health (no mixin or injector failures in logs)
5. Optional Via stack compatibility (ViaVersion/ViaFabric) if used in your setup

### Recommended minimum matrix

- Fabric `26.1` server (required)
- Fabric `1.21.1` or `1.21.6` server (required)
- Optional extra confidence target: `1.19.4`

### Fresh-server quick start

On a fresh machine:

1. Clone this repository
2. Build the artifacts (if needed for your environment)
3. Download **at least two Fabric server versions**:
   - one `26.1`
   - one `1.21.x`
4. Put the produced PacketEvents Fabric jar in each server `mods/` folder
5. Start each server and confirm clean startup logs
6. Join each server with a matching client and run smoke checks

### Runtime smoke checklist

For each test server:

- [ ] Server boots without crash
- [ ] No `NoClassDefFoundError` / mapping-name errors
- [ ] No mixin apply failures
- [ ] Player can join and stay connected
- [ ] Chat and movement packets work
- [ ] Respawn/reconnect works
- [ ] No repeated packet-exception disconnect loop

### Pass criteria

A test run is considered good when:

- both official (`26.1`) and intermediary (`1.21.x`) paths start successfully,
- the same jar works across both targets,
- and packet flow remains stable during basic gameplay actions.

<h3>Sponsors</h3>

<i>Thanks to the following sponsors for supporting this project:</i>

<a href="https://pebblehost.com"><img src="https://pebblehost.com/src/img/logos/main-old.png" width=150><br>

<a href="https://www.ej-technologies.com"><img src="https://www.ej-technologies.com/images/product_banners/jprofiler_small.png"><br>

<h3>Credits</h3>

<i>Here are some projects that we are heavily inspired by, thus we have integrated</i>\
<i>small portions of their code into our work.</i>

[Protocol Documentation for the Minecraft Java Edition](https://minecraft.wiki/w/Minecraft_Wiki:Projects/wiki.vg_merge/Protocol)\
[ViaVersion](https://github.com/ViaVersion/ViaVersion)\
[ProtocolSupport](https://github.com/ProtocolSupport/ProtocolSupport)\
[adventure](https://github.com/KyoriPowered/adventure)\
[MCProtocolLib](https://github.com/GeyserMC/MCProtocolLib/)  
