# Brainrot Bazaar

A 3D Roblox tycoon built as a Rojo project. Claim a candy-colored plot and receive a free Soggy Capybara, then buy six increasingly ridiculous brainrots. Collect their cash from the shop panel or by walking up and pressing **E**. Upgrade the goober lab, rebirth for doubled income, and swipe a rival's brainrot (leave them at least one!) with a 25-second stealing cooldown.

## Build and run

Build the place from the Rojo project:

```sh
rojo build default.project.json --output game.rbxl
```

Open `game.rbxl` in Roblox Studio. The server script creates the island, plots, creatures, shop economy, and server-validated interactions; the client script builds the responsive shop and progress UI. Progress is saved in the `BrainrotBazaar_v1` DataStore when the experience is published with API services enabled.

Package the entry with Node 22:

```sh
MAKEFUN_OUTPUT_DIR=out node main.ts
```

The package includes the place, Rojo project and scripts, tour, screenshots, and `PLAY.json`. Set the place URL and IDs in `PLAY.json` after publishing; this repository does not include a published Roblox place.
