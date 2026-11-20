# Rot Rush: Neon Snacklands

[![Make.fun competition](https://make.fun/badge/roblox-brainrot-01.svg)](https://make.fun/bounty/roblox-brainrot-01)
[![Live rank for sandrihub/roblox-brainrot-entry](https://img.shields.io/badge/live%20rank-open%20leaderboard-c41c83?logo=github)](https://make.fun/bounty/roblox-brainrot-01/leaderboard)
[![Live reward](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fmake.fun%2Fapi%2Fcompetitions%2Froblox-brainrot-01&query=%24.rewardAmount&label=reward&prefix=%24)](https://make.fun/bounty/roblox-brainrot-01)

**Bounty:** [Make the best AI Roblox brainrot game — $1,000 in rewards](https://make.fun/bounty/roblox-brainrot-01)

Rot Rush is an original, server-authoritative Roblox tycoon about collecting absurd snack-creatures in a glowing midnight market. Build a little brainrot business, bank its passive income, race the neon hazard ring, and reinvest until your plot becomes the loudest corner of the city.

## Play loop

1. Pick one of three rotating market brainrots. Every creature has an original name, a rarity, a price, and its own cash-per-second rate.
2. Buy with cash, then place the creature on one of the four pads in your plot. If all pads are full, new buys wait in your inventory.
3. Let your collection earn cash into its unbanked balance. Use **COLLECT ALL** in the HUD or interact with a creature's pad to move that balance into spendable cash.
4. Upgrade your income multiplier, chase higher rarities as the market restocks, and rebirth when your balance is large enough.
5. Cross the glowing glitch ring carefully. Its floor zaps players who linger, but a quick dash gets you to the market and home again.

### Rarity ladder

| Rarity | Example | Passive income |
| --- | --- | ---: |
| Common | Bloopi Bananini | $4/s |
| Uncommon | Taco Tornado | $12/s |
| Rare | Orbit Goblini | $34/s |
| Epic | WiFi Wizardini | $95/s |
| Legendary | Comet Cappuccini | $270/s |
| Mythic | Disco Dumpling | $760/s |

The market rotates its three offers on a timer, so the first glance is never the whole ladder. Rarity and income are checked on the server; clients only request actions.

## Project map

- `main.ts` builds the deterministic Rojo XML place into a chosen output directory.
- `default.project.json` maps the server and client Luau scripts into the Roblox DataModel.
- `src/server/init.server.luau` creates the world, plots, market, hazards, persistence, economy, and remotes.
- `src/client/Game.client.luau` builds the HUD and sends validated player actions.
- `TOUR.json` is a compact guide to the gameplay and source layout.

## Build

Use Node.js 22.18+ and the official [Rojo 7.7](https://github.com/rojo-rbx/rojo) release.

```powershell
node main.ts
rojo build default.project.json --output game.rbxl
```

`node main.ts` writes `out/game.rbxlx`. It accepts an alternate destination, which is useful for checking repeatable builds:

```powershell
node main.ts --output-dir .\build-a
node main.ts --output-dir .\build-b
```

The two `game.rbxlx` files should be byte-identical. To syntax-compile the Luau scripts with the official [Luau compiler](https://github.com/luau-lang/luau/releases):

```powershell
luau-compile src/server/init.server.luau
luau-compile src/client/Game.client.luau
```

Open `game.rbxl` in Roblox Studio to play. DataStore access requires a published experience with Studio API access enabled; if it is unavailable, the game still runs with fresh session data and reports the save/load failure in the server output.

## HUD and controls

The screen HUD shows spendable cash, unbanked earnings, current income rate, rebirth count, rotating shop offers, and the next upgrade/rebirth costs. Click or tap the shop offers and action buttons. Use Roblox's normal movement controls to run between the market, plot pads, and hazard ring; the server creates ProximityPrompts on every plot slot as an alternate interaction.

## Live competition status

The competition badge and reward badge read from make.fun. The rank badge links to the live leaderboard for this repository; a numeric placement appears there only after make.fun accepts and ranks an entry.
