### Discord Server: https://dsc.gg/ti-nsmm
[![Discord Shield](https://discordapp.com/api/guilds/993588037579702322/widget.png?style=shield)](https://dsc.gg/ti-nsmm)

# nSMM
Repository for nSMM with development resources and assets.

The aim is to make a Super Mario game with a level editor for the TI-nSpire CX line of calculators in Lua. It runs extremely poorly due to hardware limitations but is a fun side project of mine. You are free to inspect the code, suggest changes and tell me how unoptimised things can be to the seasoned developer's eye - just contact me in the Discord server above.

# Build Instructions

Building isn't impossible. All the building and (optional) minifying is gracefully handled with a quick Node.js script.

## Prerequisites

- Node.js (v20.11.1 on Win11 was used in development)

## Steps

1. `npm i`
2. `npm run build`
3. The output directories will be printed to console (typically at `./dist`)