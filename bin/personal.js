#!/usr/bin/env node

// Simple demo: personal greet --name Aaron
import { argv } from "node:process";

function parseArgs(args) {
  const out = {};
  for (let i = 0; i < args.length; i++) {
    if (args[i].startsWith("--")) {
      const key = args[i].slice(2);
      const val = args[i + 1] && !args[i + 1].startsWith("--") ? args[i + 1] : true;
      out[key] = val;
      if (val !== true) i++;
    }
  }
  return out;
}

const [,, cmd, ...rest] = argv;
const flags = parseArgs(rest);

switch (cmd) {
  case "greet": {
    const name = flags.name || "world";
    console.log(`Hello, ${name}! 👋 (from personal-cli)`);
    break;
  }
  default:
    console.log(`codex-cli
      Usage: personal greet --name <NAME>`
    );
}
