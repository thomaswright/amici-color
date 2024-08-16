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

let SIZE = 500;
let chromaPeak = 0.35;

// Todo: generate the hue gamuts at start
function updateOklchCanvas(hueInput, layout) {
  canvas.width = SIZE;
  canvas.height = SIZE;
  ctx.fillStyle = "#888";
  ctx.fillRect(0, 0, canvas.width, canvas.height);

  for (let x = 0; x < canvas.width; x++) {
    for (let y = 0; y < canvas.height; y++) {
      let rgb = [0, 0, 0];
      if (layout === layouts.LCH) {
        const l = x / canvas.width;
        const c = (1 - y / canvas.height) * chromaPeak;
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
          className={[
            "px-4 rounded mr-2",
            layout === layouts.LCH ? "bg-blue-400" : "bg-gray-200",
          ].join(" ")}
          onClick={(_) => setLayout(layouts.LCH)}
        >
          LCH
        </button>
        <button
          className={[
            "px-4 rounded mr-2",
            layout === layouts.HSL ? "bg-blue-400" : "bg-gray-200",
          ].join(" ")}
          onClick={(_) => setLayout(layouts.HSL)}
        >
          HSL
        </button>
        <button
          className={[
            "px-4 rounded mr-2",
            layout === layouts.HSV ? "bg-blue-400" : "bg-gray-200",
          ].join(" ")}
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
