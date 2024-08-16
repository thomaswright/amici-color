import * as texel from "@texel/color";
import { useEffect, useState } from "react";

// # Setup
const canvas = document.getElementById("canvas");
const ctx = canvas.getContext("2d");

let layouts = {
  LCH: "LCH",
  HSV: "HSV",
  HSL: "HSL",
};

function makeNullArray(x, y) {
  const arr = [];
  for (let i = 0; i < x; i++) {
    const row = [];
    for (let j = 0; j < y; j++) {
      row.push(null);
    }
    arr.push(row);
  }
  return arr;
}

function makeHueGamuts() {
  let arrs = {
    LCH: makeNullArray(size, size),
    HSV: makeNullArray(size, size),
    HSL: makeNullArray(size, size),
  };
  for (let hue = 0; hue < 360; hue++) {
    for (let x = 0; x < canvas.width; x++) {
      for (let y = 0; y < canvas.height; y++) {
        {
          const l = x / canvas.width;
          const c = (1 - y / canvas.height) * 0.4;
          const h = hueInput;
          const rgb = texel.convert([l, c, h], texel.OKLCH, texel.sRGB);
          const inside = texel.isRGBInGamut(rgb);
          if (inside) {
            arrs.LCH[(x, y)] = texel.RGBToHex(rgb);
          }
        }
        {
          const h = hueInput;
          const s = x / canvas.width;
          const v = 1 - y / canvas.height;
          const rgb = texel.convert([h, s, v], texel.OKHSV, texel.sRGB);
          arrs.HSV[(x, y)] = texel.RGBToHex(rgb);
        }
        {
          const h = hueInput;
          const s = x / canvas.width;
          const l = 1 - y / canvas.height;
          const rgb = texel.convert([h, s, l], texel.OKHSL, texel.sRGB);
          arrs.HSL[(x, y)] = texel.RGBToHex(rgb);
        }
      }
    }
  }
  return arrs;
}

let hueGamuts = makeHueGamuts;

// Todo: generate the hue gamuts at start
function updateOklchCanvas(hueInput, layout) {
  canvas.width = 500;
  canvas.height = 500;
  ctx.fillStyle = "#888";
  ctx.fillRect(0, 0, canvas.width, canvas.height);

  for (let x = 0; x < canvas.width; x++) {
    for (let y = 0; y < canvas.height; y++) {
      let rgb = [0, 0, 0];
      if (layout === layouts.LCH) {
        const l = x / canvas.width;
        const c = (1 - y / canvas.height) * 0.4;
        const h = hueInput;
        rgb = texel.convert([l, c, h], texel.OKLCH, texel.sRGB);
      } else if (layout === layouts.HSV) {
        const h = hueInput;
        const s = x / canvas.width;
        const v = 1 - y / canvas.height;
        rgb = texel.convert([h, s, v], texel.OKHSV, texel.sRGB);
      } else if (layout === layouts.HSL) {
        const h = hueInput;
        const s = x / canvas.width;
        const l = 1 - y / canvas.height;
        rgb = texel.convert([h, s, l], texel.OKHSL, texel.sRGB);
      }

      const inside = texel.isRGBInGamut(rgb);
      if (inside) {
        ctx.fillStyle = texel.RGBToHex(rgb);
        ctx.fillRect(x, y, 1, 1);
      }
    }
  }
}

export const Gamut = () => {
  let [hue, setHue] = useState(0);
  let [layout, setLayout] = useState(layouts.LCH);
  useEffect(() => {
    updateOklchCanvas(hue, layout);
  }, [hue, layout]);

  return (
    <div>
      <div>
        <button
          className="px-4 bg-gray-200 rounded mr-2"
          onClick={(_) => setLayout(layouts.LCH)}
        >
          LCH
        </button>
        <button
          className="px-4 bg-gray-200 rounded mr-2"
          onClick={(_) => setLayout(layouts.HSL)}
        >
          HSL
        </button>
        <button
          className="px-4 bg-gray-200 rounded mr-2"
          onClick={(_) => setLayout(layouts.HSV)}
        >
          HSV
        </button>
      </div>
      <input
        type="range"
        min="0"
        max="360"
        step="1"
        value={hue}
        onChange={(e) => setHue(e.target.value)}
      />
    </div>
  );
};
