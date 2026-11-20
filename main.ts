const { spawnSync } = require("node:child_process");
const { existsSync, mkdirSync } = require("node:fs");
const { resolve } = require("node:path");

const projectRoot = __dirname;
const args = process.argv.slice(2);
const outputFlag = args.indexOf("--output-dir");
const outputArgument = outputFlag === -1 ? "out" : args[outputFlag + 1];

if (outputFlag !== -1 && (!outputArgument || outputArgument.startsWith("--"))) {
  console.error("Usage: node main.ts [--output-dir <directory>]");
  process.exitCode = 2;
} else {
  const projectFile = resolve(projectRoot, "default.project.json");
  if (!existsSync(projectFile)) {
    console.error("default.project.json was not found beside main.ts.");
    process.exitCode = 1;
  } else {
    const outputDirectory = resolve(projectRoot, outputArgument);
    mkdirSync(outputDirectory, { recursive: true });

    const build = spawnSync(
      "rojo",
      [
        "build",
        projectFile,
        "--output",
        resolve(outputDirectory, "game.rbxlx"),
      ],
      { cwd: projectRoot, stdio: "inherit" },
    );

    if (build.error) {
      console.error(`Could not start Rojo: ${build.error.message}`);
      process.exitCode = 1;
    } else if (build.status !== 0) {
      process.exitCode = build.status ?? 1;
    }
  }
}
