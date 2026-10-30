# AutoMarkBosses

Lightweight, zero-UI addon for **Azeroth Survivors** (World of Warcraft 1.12.1 client) that silently and automatically marks the **4 corner lair guardians** with raid target icons across all zones, allowing your party to quickly spot them across the map and hunt them down.

[![Download](https://img.shields.io/badge/Download-AutoMarkBosses--v1.0.0.zip-brightgreen.svg)](https://github.com/dilelu94/AutoMarkBosses/releases/latest)

---

## Download

👉 **[Download Latest Release (AutoMarkBosses-v1.0.0.zip)](https://github.com/dilelu94/AutoMarkBosses/releases/latest)**

---

## Features

- **Corner Guardians Only**: Specifically tracks and marks the 4 corner lair elites (`AZS_LAIRS`) across all maps (e.g., Devilsaurs, Thunderers, Ravasaurs in Un'Goro, or the respective guardians in Elwynn, Duskwood, etc.). Scheduled run-timer bosses are left untouched.
- **Fixed Raid Icon Assignment**:
  - **Lair 1 (Corner 1)**: Skull (8)
  - **Lair 2 (Corner 2)**: Cross (7)
  - **Lair 3 (Corner 3)**: Square (6)
  - **Lair 4 (Corner 4)**: Moon (5)
- **Duplicate Name Resolution**: Accurately differentiates guardians by world proximity coordinates even when multiple lairs spawn identical creature types.
- **Continuous Respawn Tracking**: Automatically re-applies the assigned mark when a slain guardian respawns at its lair.
- **Zero UI Clutter**: Completely silent in the background. No minimap buttons, no timers, no chat spam.
- **Zero Combat Interruption**: Utilizes party target inspection, mouseover, and instantaneous exact-name matching to maintain your current target.

---

## Installation

### Desktop (Linux / Windows)
1. Download **[AutoMarkBosses-v1.0.0.zip](https://github.com/dilelu94/AutoMarkBosses/releases/latest)**.
2. Extract the `AutoMarkBosses` folder into your game's addon directory:
   ```
   benilla-config/AddOns/AutoMarkBosses/
   ```
3. Ensure `AutoMarkBosses.toc` and `AutoMarkBosses.lua` are inside that folder.
4. Launch or `/reload` in game.

### In-Game (Browser / Native)
1. Go to `Options -> AddOns -> Install AddOns`.
2. Select the downloaded `AutoMarkBosses-v1.0.0.zip`.

---

## Requirements

- **Client**: Azeroth Survivors (`## Interface: 11200`).
- **Party Play**: You must be the **Party Leader** (or playing solo) for the server to process raid target icon assignments, per standard World of Warcraft 1.12 mechanics.
