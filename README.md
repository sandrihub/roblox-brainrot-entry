[![make.fun Roblox Brainrot Game](https://make.fun/badge/roblox-brainrot-01.svg)](https://make.fun/bounty/roblox-brainrot-01)
[![make.fun rank](https://make.fun/badge/roblox-brainrot-01/sandrihub/roblox-brainrot-entry/rank.svg)](https://make.fun/bounty/roblox-brainrot-01)
[![make.fun reward](https://make.fun/badge/roblox-brainrot-01/sandrihub/roblox-brainrot-entry/reward.svg)](https://make.fun/bounty/roblox-brainrot-01)

# Neon Nonsense Tycoon

An original 3D Roblox brainrot tycoon set on a floating neon-dusk island. Claim a plot, put the Moss Boss Capybara to work, and climb seven rarity tiers of weirdos at the Oddity Exchange. Every oddity earns passive cash on its display pad; collect from the HUD or walk up and press **E**. Upgrade the research lab, rebirth to double future income, and time your 18-second vault shield before rivals swipe anything but your last oddity.

## Build and run

Build the binary Roblox place from the Rojo project:

```sh
rojo build default.project.json --output game.rbxl
```

Open `game.rbxl` in Roblox Studio. The server script constructs the island, player plots, original brainrot models, passive-income economy, timed vault shields, rival stealing, upgrades, rebirths, and saved progress. The client script builds the rarity shop, live wallet and income display, vault controls, and responsive HUD.

Package the entry with Node 22 or later:

```sh
MAKEFUN_OUTPUT_DIR=out node main.ts
```

The package includes the place, Rojo project and scripts, tour, screenshots, and `PLAY.json`. The published experience link in `PLAY.json` is intentionally retained for place `93544388501249` in universe `10777927879`.
