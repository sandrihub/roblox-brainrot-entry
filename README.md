[![make.fun Roblox Brainrot Game](https://make.fun/badge/roblox-brainrot-01.svg)](https://make.fun/bounty/roblox-brainrot-01)
[![make.fun rank](https://make.fun/badge/roblox-brainrot-01/sandrihub/roblox-brainrot-entry/rank.svg)](https://make.fun/bounty/roblox-brainrot-01)
[![make.fun reward](https://make.fun/badge/roblox-brainrot-01/sandrihub/roblox-brainrot-entry/reward.svg)](https://make.fun/bounty/roblox-brainrot-01)

# Neon Nonsense

A bright, original brainrot tycoon on a neon boardwalk in the clouds. Claim one of eight plots, fill its display pads with increasingly absurd collectibles, and build an automatic cash machine. Seven collectible rarities range from the Common Moss Boss Capybara to the Celestial Quantum Froggo. Rebirth trades your collection for a permanent income multiplier; the hazard pool in the shared plaza can cost careless visitors a slice of their wallet.

## Play

The published experience is [Neon Nonsense on Roblox](https://www.roblox.com/games/93544388501249/). In-game, use the shop cards to buy collectibles, watch your plot earn passive cash, and press **REBIRTH** when you can afford the next reset. The HUD shows your cash, income rate, rebirth count, and display capacity. Keep clear of the magenta hazard pool.

Progress is saved per Roblox account when DataStore access is enabled for the published place. If Roblox storage is unavailable, the tycoon remains playable for the current server session.

## Build

Install the official [Rojo](https://rojo.space/) CLI and build the binary place:

```sh
rojo build default.project.json --output game.rbxl
```

Open `game.rbxl` in Roblox Studio. The server creates the island, plots, collectible models, passive-income loop, shop validation, rebirth system, and hazard. The client creates the live, responsive HUD and rarity shop.

Package the entry with Node.js 22 or later:

```sh
MAKEFUN_OUTPUT_DIR=out node main.ts
```

The package contains the place, its source, project configuration, tour, screenshots, and published-place metadata.
