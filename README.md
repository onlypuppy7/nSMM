### Discord Server: https://dsc.gg/ti-nsmm
[![Discord Shield](https://discordapp.com/api/guilds/993588037579702322/widget.png?style=shield)](https://dsc.gg/ti-nsmm)

# nSMM

Repository for nSMM with development resources and assets.

The aim was initially to make a Super Mario game with a level editor for the TI-Nspire CX line of calculators in Lua. On the calc, it runs extremely poorly due to hardware limitations but acted as a fun side project of mine. If you like, you may inspect the code, suggest changes and tell me how unoptimised this mess is - just contact me in the Discord server above.

These days, the scope has expanded a little to re-use the base of nSMM as a multiplatform Mario Maker game for the web, PC, Android, 3DS and of course still calculators.

# Build Instructions

Building is as simple as I could make it. All the building and (optional) minifying is gracefully handled with a quick Node.js script.

## Prerequisites

- Node.js (v20.11.1 on Win11 was used in development)

## Steps

1. `npm i`
2. `npm run build`
3. The output directories will be printed to console (typically at `./dist`)

# Hosting the web version

Run `npm run start` in your terminal, this will initiate the build process (same action as above), then start the web server at http://localhost:1985

The web server just hosts the files statically from dist/html, so you could always skip the inbuilt server and use the files in your own applications.

# Quick testing

The fastest way to test nSMM is to have Love2D installed so you can start the game up right away.

1. Download from: https://love2d.org/#download
2. In the root directory, run: `& 'C:\Program Files\LOVE\love.exe' src/lua` (assuming Love2D was installed to this location)

## Credits

TODO, important bc it uses a ton of different things

jim bawens pcspire
https://github.com/love2d/love-android/releases/download/11.5a/love-11.5-android-embed.apk
https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/windows/apktool.bat
https://bitbucket.org/iBotPeaches/apktool/downloads
https://github.com/patrickfav/uber-apk-signer/releases/tag/v1.3.0