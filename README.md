# Neon Nonsense

[![Live brainrot bounty](https://make.fun/badge/roblox-brainrot-01.svg)](https://make.fun/bounty/roblox-brainrot-01)
[![Current rank](https://make.fun/badge/roblox-brainrot-01/sandrihub/roblox-brainrot-entry/rank.svg)](https://make.fun/bounty/roblox-brainrot-01)
[![Reward](https://make.fun/badge/roblox-brainrot-01/sandrihub/roblox-brainrot-entry/reward.svg)](https://make.fun/bounty/roblox-brainrot-01)

**A neon-soaked creature tycoon where the economy is powered by deeply unserious little weirdos.**

Scavenge the glitch market for brainrots, race them back to your plot, and stack a wildly uneven passive-income empire. Eight distinct rarity tiers turn the plaza into a chase for the next ridiculous jackpot. Build your collection, invest in faster income or movement, swipe a rival's display when you spot an opening, then rebirth your operation for a permanent multiplier.

## Play

[Open Neon Nonsense on Roblox](https://www.roblox.com/games/93544388501249/)

## The loop

- Claim a neon plot and collect roaming brainrots from the central market.
- Each creature occupies a display slot and prints cash every second, based on its rarity.
- Spend cash on income and movement upgrades; high-rarity finds are worth protecting.
- Hold the swipe prompt at a rival's display to steal a creature and bring its income home.
- Rebirth at the cash threshold to reset the collection and upgrades for a permanent earnings boost.
- Read the live cash, income, collection, rebirth, and upgrade totals in the in-world HUD.

## Build

The place is built with [Rojo](https://rojo.space/) from `default.project.json`. The original game logic lives in `src/server/init.server.luau` and `src/client/Game.client.luau`; the server creates the 3D world, plots, collectible characters, market, and passive-income loop. `main.ts` packages the built `game.rbxl`, Luau source, screenshots, metadata, and the canonical dossier.

```powershell
rojo build default.project.json -o game.rbxl
$env:MAKEFUN_OUTPUT_DIR = "out"
node main.ts
```

The companion Luau compiler is available in the official [Luau releases](https://github.com/luau-lang/luau/releases).

## Competition

Built for the [Make the best AI Roblox brainrot game bounty](https://make.fun/bounty/roblox-brainrot-01).
