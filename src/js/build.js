import {
    bundle
} from 'luabundle';
import luamin from 'luamin';
import fs from 'fs';
import path from 'path';

//oh no! this file is chatgpt generated!
//i cant be bothered to write it out

const luaDir = 'src/lua';

const confLua = fs.readFileSync(path.join(luaDir, 'conf_PROD.lua'), 'utf8');
const metaLua = fs.readFileSync(path.join(luaDir, 'meta.lua'), 'utf8');

const str = `versText="1.4.0a"
versNum=56`;

const match = str.match(/versText="([^"]+)"[\s\S]*?versNum=(\d+)/);

const versText = match[1];
const versNum = parseInt(match[2]);

console.log(versText, versNum)

function bundleNSMM(name, luaFilePath, save) {
    let bundledLuaOG = bundle(luaFilePath, {
        paths: [luaDir + '/?.lua'],
    });

    console.log('Bundled Lua code length:', bundledLuaOG.length);

    function convertSpecialChars(luaCode) {
        for (let iter = 3; iter > 0; iter--) {
            const regex = new RegExp(`\\\\([0-9]{${iter}})[\\\\ A-z@%]`, 'g');

            luaCode = luaCode.replace(regex, (match, digits) => {
                const num = String(parseInt(digits, 10));
                return match.replace(digits, num);
            });
        };
        return luaCode;
    };

    let bundledLua = convertSpecialChars(convertSpecialChars(bundledLuaOG));

    console.log('Converted special characters in Lua code length:', bundledLua.length, (bundledLua.length / bundledLuaOG.length * 100).toFixed(2) + '% of original size');

    const minifiedLua =
        `--nSMM Bundle
    --Generated by nSMM Lua Bundler to reduce file size and improve loading performance
    --Full source available at https://github.com/onlypuppy7/nSMM
    ` +
        luamin.minify(bundledLua);

    console.log('Minified Lua code length:', minifiedLua.length, (minifiedLua.length / bundledLuaOG.length * 100).toFixed(2) + '% of original size');

    const outputBundleFilePath = path.resolve(`dist/${name}.build.lua`);
    const outputMinifiedFilePath = path.resolve(`dist/${name}.min.build.lua`);

    fs.mkdirSync(path.dirname(outputBundleFilePath), {
        recursive: true
    });

    fs.writeFileSync(outputBundleFilePath, bundledLua);
    fs.writeFileSync(outputMinifiedFilePath, minifiedLua);
    console.log('Bundled Lua code written to:', outputBundleFilePath);
    console.log('Minified Lua code written to:', outputMinifiedFilePath);

    return {
        full: bundledLua,
        min: minifiedLua
    };
};

let nsmmcalc = bundleNSMM('nSMM', path.resolve(luaDir + '/nsmm.lua'));
bundleNSMM('nSMM.debug', path.resolve(luaDir + '/nsmm-debug.lua'));

let courseworldcalc = bundleNSMM('nSMMCourseWorld', path.resolve(luaDir + '/courseworld.lua'));
// bundleNSMM('nSMMCourseWorld.debug', path.resolve(luaDir+'/courseworld-debug.lua'));

let pcNSMM = bundleNSMM('pc', path.resolve(luaDir+'/main.lua'));
// bundleNSMM('ds', path.resolve(luaDir + '/ds.lua'));

let releaseDestPath = path.resolve('dist/release');

//delete old html files
fs.rmSync(releaseDestPath, {
    recursive: true,
    force: true
});

fs.mkdirSync(releaseDestPath, {
    recursive: true
});

let htmlFilePath = path.resolve('src/html');
let htmlDestinationPath = path.resolve('dist/html');

//delete old html files
fs.rmSync(htmlDestinationPath, {
    recursive: true,
    force: true
});

fs.mkdirSync(htmlDestinationPath, {
    recursive: true
});

//copy whole directory
fs.cpSync(htmlFilePath, htmlDestinationPath, {
    recursive: true,
    force: true
});
console.log('HTML files copied to:', htmlDestinationPath);

//bundle lua files into zip
import JSZip from 'jszip';

async function addFolderToZip(zip, folderPath, zipFolderPath = '', filterExts = [], ignorePairs = [], baseZipFolderPath = '', isRoot = true) {
    const items = fs.readdirSync(folderPath);

    for (const item of items) {
        const shouldIgnore = ignorePairs.some(([prefix, suffix]) => {
            return item.startsWith(prefix) && item.endsWith(suffix);
        });
        if (shouldIgnore) continue;

        const fullPath = path.join(folderPath, item);
        const stats = fs.statSync(fullPath);

        const targetBase = isRoot ? baseZipFolderPath : '';
        const targetPath = path.join(targetBase, zipFolderPath, item);

        if (stats.isDirectory()) {
            const folder = zip.folder(targetPath);
            await addFolderToZip(folder, fullPath, '', filterExts, ignorePairs, baseZipFolderPath, false);
        } else {
            const ext = path.extname(item).toLowerCase();
            if (filterExts.length === 0 || filterExts.includes(ext)) {
                const content = fs.readFileSync(fullPath);
                zip.file(targetPath, content);
            }
        }
    }
}

async function zipDirectory(folderPath, filterExts = [], customFiles = [], ignorePairs = [], baseZipFolderPath = '') {
    const zip = new JSZip();
    await addFolderToZip(zip, folderPath, '', filterExts, ignorePairs, baseZipFolderPath);

    for (const [filename, content] of customFiles) {
        zip.file(path.join(baseZipFolderPath, filename), content);
    }

    return zip.generateAsync({ type: 'nodebuffer' });
}


const zippedContentPC = await zipDirectory(
    luaDir,
    ['.wav', '.ogg', '.png', '.ttf'],
    [
        ['main.lua', pcNSMM.min],
        ['conf.lua', confLua],
    ],
    [['bgm_', '.wav']], // ignore files starting with 'bgm_' and ending in '.wav'
    ''
);

//import crypto miner
import crypto from 'crypto';

//create hash for the zip file
const hash = crypto.createHash('sha256');
hash.update(zippedContentPC);
const zipHash = hash.digest('hex');
console.log('Zip file hash:', zipHash);

const loveName = `nsmm_${zipHash}`;
const lovePath = path.join('dist', 'html', 'lovejs', loveName + ".love");
fs.mkdirSync(path.dirname(lovePath), {
    recursive: true
});
fs.writeFileSync(lovePath, zippedContentPC);

fs.writeFileSync(path.join('dist', 'release', `nSMM.pc.${versText}.${versNum}.release.love`), zippedContentPC);
console.log("wrote pc love to release");

//edit index.html to include the zip file
const indexFilePath = path.join(htmlDestinationPath, 'lovejs', 'index.html');
let indexContent = fs.readFileSync(indexFilePath, 'utf-8');
indexContent = indexContent.replaceAll("NSMMHERE", loveName);
fs.writeFileSync(indexFilePath, indexContent);

const lovepotion3dsx = fs.readFileSync(path.join(luaDir, '..', '3ds', 'lovepotion.3dsx'));

// console.log(lovepotion3dsx)

const zippedContent3ds = await zipDirectory(
    luaDir,
    ['.wav', '.t3x', '.ttf'],
    [
        ['main.lua', pcNSMM.min],
        ['conf.lua', confLua],
        ['../nsmm.3dsx', lovepotion3dsx],
    ],
    [],
    '3ds/nsmm/game'
);

fs.writeFileSync(path.join('dist', 'release', `nSMM.3ds.${versText}.${versNum}.release.zip`), zippedContent3ds);
console.log("wrote 3ds zip to release");

fs.writeFileSync(path.join('dist', 'release', `nSMM.ti.${versText}.${versNum}.release.lua`), nsmmcalc.full);
console.log("wrote ti lua to release");
fs.writeFileSync(path.join('dist', 'release', `nSMM.ti.${versText}.${versNum}.release.min.lua`), nsmmcalc.min);
console.log("wrote minned ti lua to release");

fs.writeFileSync(path.join('dist', 'release', `nSMMCourseWorld.ti.${versText}.${versNum}.release.lua`), courseworldcalc.full);
console.log("wrote ti courseworld lua to release");
fs.writeFileSync(path.join('dist', 'release', `nSMMCourseWorld.ti.${versText}.${versNum}.release.min.lua`), courseworldcalc.min);
console.log("wrote ti minned courseworld lua to release");

const zippedContentHTML = await zipDirectory(
    htmlDestinationPath,
    [],
    [],
    [],
    ''
);

fs.writeFileSync(path.join('dist', 'release', `nSMM.web.${versText}.${versNum}.release.zip`), zippedContentHTML);
console.log("wrote web archive to release");