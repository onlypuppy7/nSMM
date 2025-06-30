function rgbToTIColor(r, g, b, a, threshold, compressTransparent = false) {
    //below for 100% ti nspire scripting tools compatibility, \255\127 takes up more room though than \0\0

    if (!compressTransparent) {
        const isTransparent = a < threshold;

        if (isTransparent) {
            return [0xFF, 0x7F];
        };
    };

    const alpha = (a >= threshold) ? 1 : 0;
    const r5 = Math.floor(r / 8);
    const g5 = Math.floor(g / 8);
    const b5 = Math.floor(b / 8);

    const color16 = (alpha << 15) | (r5 << 10) | (g5 << 5) | b5;
    return [color16 & 0xFF, (color16 >> 8) & 0xFF];
}

function byteToEscape(byte, pad, dontUseChar = false) {
    if ((byte >= 32 && byte <= 126 && byte !== 92) && !dontUseChar) {
        return String.fromCharCode(byte);
    }
    return "\\" + (pad ? byte.toString().padStart(3, '0') : byte);
}

function buildHeader(width, height) {
    const stride = width * 2;
    const header = new Uint8Array(20);
    const dv = new DataView(header.buffer);

    dv.setUint32(0, width, true);
    dv.setUint32(4, height, true);
    header[8] = 0;
    header[9] = 0;
    dv.setUint16(10, 0, true);
    dv.setUint32(12, stride, true);
    dv.setUint16(16, 16, true);
    dv.setUint16(18, 1, true);

    return header;
}

async function processImage(file, options) {
    return new Promise((resolve) => {
        const img = new Image();
        const url = URL.createObjectURL(file);

        img.onload = () => {
            const canvas = document.createElement("canvas");
            canvas.width = options.resize ? options.resizeWidth : img.width;
            canvas.height = options.resize ? options.resizeHeight : img.height;

            const ctx = canvas.getContext("2d");
            ctx.drawImage(img, 0, 0, canvas.width, canvas.height);

            const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height).data;
            const header = buildHeader(canvas.width, canvas.height);
            const pixels = [];

            for (let i = 0; i < imageData.length; i += 4) {
                const [r, g, b, a] = imageData.slice(i, i + 4);
                pixels.push(...rgbToTIColor(r, g, b, a, options.alphaThreshold, options
                    .compressTransparent));
            }

            const fullData = [...header, ...pixels];
            const escaped = fullData.map(b => byteToEscape(b, options.padNumbers, !options
                .useCharCode)).join('');

            const baseName = file.name.replace(/\.[^/.]+$/, "");
            const prefix = options.prefix || "";
            //   const suffix = options.suffix || "";
            const declaration = `${prefix}${baseName}`;
            resolve(`${declaration}=image.new("${escaped}")`);

            URL.revokeObjectURL(url);
        };

        img.src = url;
    });
}

async function doConvert() {
    const files = Array.from(document.getElementById("fileInput").files);
    const output = document.getElementById("output");

    const options = {
        prefix: document.getElementById("prefix").value,
        // suffix: document.getElementById("suffix").value,
        alphaThreshold: parseInt(document.getElementById("alphaThreshold").value),
        resize: document.getElementById("resizeToggle").checked,
        resizeWidth: parseInt(document.getElementById("resizeWidth").value),
        resizeHeight: parseInt(document.getElementById("resizeHeight").value),
        padNumbers: document.getElementById("padEscapeNumbers").checked,
        compressTransparent: document.getElementById("compressTransparent").checked,
        useCharCode: document.getElementById("useCharCode").checked,
    };

    output.value = "Processing...\n";
    const results = await Promise.all(files.map(file => processImage(file, options)));
    output.value = results.join("\n");
}

function downloadOutput() {
    const text = document.getElementById("output").value;
    const blob = new Blob([text], {
        type: "text/plain"
    });
    const a = document.createElement("a");
    a.href = URL.createObjectURL(blob);
    a.download = "ti-images.txt";
    a.click();
}

function copyOutput() {
    const output = document.getElementById("output");
    output.select();
    document.execCommand("copy");
}

document.getElementById("fileInput").addEventListener("change", async (e) => {
    await doConvert();
});

function convertTIImage() {
    const input = document.getElementById("tiImageInput").value;
    const bytes = parseTIImageBytes(input);

    if (bytes.length < 20) {
        document.getElementById("outputInfo").textContent = "Invalid TI-Image format.";
        return;
    }

    const header = bytes.slice(0, 20);
    const dv = new DataView(new Uint8Array(header).buffer);
    const width = dv.getUint32(0, true);
    const height = dv.getUint32(4, true);

    const canvas = document.getElementById("outputCanvas");
    canvas.width = width;
    canvas.height = height;

    const ctx = canvas.getContext("2d");
    const imageData = ctx.createImageData(width, height);

    const pixelBytes = bytes.slice(20);
    let px = 0;
    for (let i = 0; i < pixelBytes.length; i += 2) {
        const color16 = (pixelBytes[i + 1] << 8) | pixelBytes[i];
        const alpha = (color16 & 0x8000) ? 255 : 0;
        const r = ((color16 >> 10) & 0x1F) * 255 / 31;
        const g = ((color16 >> 5) & 0x1F) * 255 / 31;
        const b = (color16 & 0x1F) * 255 / 31;

        imageData.data[px++] = Math.round(r);
        imageData.data[px++] = Math.round(g);
        imageData.data[px++] = Math.round(b);
        imageData.data[px++] = alpha;
    }

    ctx.putImageData(imageData, 0, 0);
    document.getElementById("outputInfo").textContent =
        `Width: ${width}, Height: ${height}, Pixels: ${pixelBytes.length / 2}`;
}

let originalImageData = null;

const originalCanvas = document.getElementById("originalCanvas");
const convertedCanvas = document.getElementById("convertedCanvas");
const colorImageInput = document.getElementById("colorImageInput");
const conversionJson = document.getElementById("conversionJson");

function hexToRGB(hex) {
    const r = parseInt(hex.slice(0, 2), 16);
    const g = parseInt(hex.slice(2, 4), 16);
    const b = parseInt(hex.slice(4, 6), 16);
    return [r, g, b];
}

function rgbToHex(r, g, b) {
    return [r, g, b].map(v => v.toString(16).padStart(2, '0')).join('').toUpperCase();
}

function onUpdatedRules() {
    const rules = getColorRules();
    if (originalImageData) {
        processReplacementImage(originalImageData, rules);
    }
}

function getColorRules() {
    const fromInputs = document.querySelectorAll('.fromColor');
    const toInputs = document.querySelectorAll('.toColor');
    const rules = {};
    for (let i = 0; i < fromInputs.length; i++) {
        const from = fromInputs[i].value.trim().toUpperCase();
        const to = toInputs[i].value.trim().toUpperCase();
        if (/^[0-9A-F]{6}$/.test(from) && /^[0-9A-F]{6}$/.test(to)) {
            rules[from] = to;
        }
    }
    conversionJson.textContent = JSON.stringify(rules, null, 2);
    const luaRules = Object.entries(rules).map(([from, to]) => {
        const [fr, fg, fb] = hexToRGB(from);
        const [tr, tg, tb] = hexToRGB(to);
        const tiFrom = rgbToTIColor(fr, fg, fb, 255, 128);
        const tiTo = rgbToTIColor(tr, tg, tb, 255, 128);

        //byte to escape
        const fromEscaped = tiFrom.map(b => byteToEscape(b, true, true)).join('');
        const toEscaped = tiTo.map(b => byteToEscape(b, true, true)).join('');
        return `{"${fromEscaped}", "${toEscaped}"}`;
    }).join(",");
    document.getElementById("conversionLua").textContent = luaRules;
    return rules;
}

function addColorRule() {
    const div = document.createElement('div');
    div.innerHTML =
        `Replace <input type="text" value="FF00AA" maxlength="6" class="fromColor"> → <input type="text" value="000000" maxlength="6" class="toColor">`;
    document.getElementById("colorRulesContainer").appendChild(div);
}

function processReplacementImage(img, rules) {
    const ow = img.naturalWidth;
    const oh = img.naturalHeight;

    originalCanvas.width = ow;
    originalCanvas.height = oh;
    convertedCanvas.width = ow;
    convertedCanvas.height = oh;

    const ctx1 = originalCanvas.getContext("2d");
    const ctx2 = convertedCanvas.getContext("2d");

    ctx1.clearRect(0, 0, ow, oh);
    ctx2.clearRect(0, 0, ow, oh);

    ctx1.drawImage(img, 0, 0, ow, oh);

    const imageData = ctx1.getImageData(0, 0, ow, oh);
    const data = imageData.data;

    for (let i = 0; i < data.length; i += 4) {
        const r = data[i],
            g = data[i + 1],
            b = data[i + 2];
        const hex = rgbToHex(r, g, b);
        if (rules[hex]) {
            const [nr, ng, nb] = hexToRGB(rules[hex]);
            data[i] = nr;
            data[i + 1] = ng;
            data[i + 2] = nb;
        }
    }

    ctx2.putImageData(imageData, 0, 0);
}

colorImageInput.addEventListener("change", () => {
    const file = colorImageInput.files[0];
    if (!file) return;

    const rules = getColorRules();

    const img = new Image();
    img.onload = () => processReplacementImage(img, rules);
    img.src = URL.createObjectURL(file);
    originalImageData = img; // Store the original image data for color picking
});

document.getElementById("colorRulesContainer").addEventListener("input", onUpdatedRules);

function updateColorPickerDisplay(r, g, b) {
    const hex = rgbToHex(r, g, b);
    document.getElementById("pickedColorHex").value = hex;
    document.getElementById("pickedColorRGB").value = `(${r}, ${g}, ${b})`;
    document.getElementById("pickedColorSwatch").style.backgroundColor = `#${hex}`;

    const tiColor = rgbToTIColor(r, g, b, 255, 128);
    document.getElementById("pickedColorTI").value = `${byteToEscape(tiColor[0], true, true)}${byteToEscape(tiColor[1], true, true)}`;
    document.getElementById("pickedColorTIOptimised").value = `${byteToEscape(tiColor[0])}${byteToEscape(tiColor[1])}`;
}

function addCanvasColorPicker(canvas) {
    canvas.addEventListener("click", function (e) {
        const rect = canvas.getBoundingClientRect();
        const scaleX = canvas.width / rect.width;
        const scaleY = canvas.height / rect.height;
        const x = Math.floor((e.clientX - rect.left) * scaleX);
        const y = Math.floor((e.clientY - rect.top) * scaleY);

        const ctx = canvas.getContext("2d");
        const data = ctx.getImageData(x, y, 1, 1, {
            willReadFrequently: true
        }).data;
        updateColorPickerDisplay(data[0], data[1], data[2]);
    });
};

Array.from(document.getElementsByClassName("pixel-preview")).forEach(canvas => {
    addCanvasColorPicker(canvas);
});

function parseTIImageBytes(str) {
    const bytes = [];
    let i = 0;

    while (i < str.length) {
        if (str[i] === "\\") {
            i++;
            let num = "";
            while (i < str.length && /[0-9]/.test(str[i]) && num.length < 3) {
                num += str[i++];
            }
            if (num.length > 0) {
                bytes.push(parseInt(num, 10));
                continue;
            }
        }

        // Fallback to literal char code
        bytes.push(str.charCodeAt(i));
        i++;
    }

    return bytes;
}

function tiColorToRGB(tiColor) {
    const bytes = parseTIImageBytes(tiColor.trim());
    if (bytes.length !== 2) return null;

    const color16 = (bytes[1] << 8) | bytes[0];
    const r5 = (color16 >> 10) & 0x1F;
    const g5 = (color16 >> 5) & 0x1F;
    const b5 = color16 & 0x1F;

    const r = ((r5 + 1) * 8) - 1;
    const g = ((g5 + 1) * 8) - 1;
    const b = ((b5 + 1) * 8) - 1;

    return {
        r,
        g,
        b,
        alpha: 1
    };
}

document.getElementById("tiColorInput").addEventListener("input", function () {
    const tiColor = this.value.trim();
    const rgb = tiColorToRGB(tiColor);
    if (rgb) {
        document.getElementById("rgbOutput").textContent =
            `RGB: (${rgb.r}, ${rgb.g}, ${rgb.b}), Alpha: ${rgb.alpha}` +
            `\nHex: #${((rgb.r << 16) | (rgb.g << 8) | rgb.b).toString(16).padStart(6, '0').toUpperCase()}`;
        document.getElementById("colorSwatch").style.backgroundColor =
            `rgba(${rgb.r}, ${rgb.g}, ${rgb.b}, ${rgb.alpha})`;
    } else {
        document.getElementById("rgbOutput").textContent = "Invalid TI Color format.";
    }
});

function downloadOutputtedImage() {
    const canvas = document.getElementById("outputCanvas");
    const link = document.createElement("a");
    link.download = prompt("filename?", "converted_image") + ".png";
    link.href = canvas.toDataURL("image/png");
    link.click();
}