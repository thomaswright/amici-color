import * as texel from "@texel/color";
import { useEffect, useState } from "react";

// # Setup
const canvas = document.getElementById("canvas");
const ctx = canvas.getContext("2d");

// Todo: generate the hue gamuts at start
function updateCanvas(hueInput) {
  canvas.width = 500;
  canvas.height = 500;
  ctx.fillStyle = "#888";
  ctx.fillRect(0, 0, canvas.width, canvas.height);

  for (let x = 0; x < canvas.width; x++) {
    for (let y = 0; y < canvas.height; y++) {
      const width = 1;
      const height = 1;
      const l = x / canvas.width;
      const c = (1 - y / canvas.height) * 0.4;
      const h = hueInput;

      const rgb = texel.convert([l, c, h], texel.OKLCH, texel.sRGB);

      const inside = texel.isRGBInGamut(rgb);
      if (inside) {
        ctx.fillStyle = texel.RGBToHex(rgb);
        ctx.fillRect(x, y, width, height);
      }
    }
  }
}

export const Gamut = () => {
  let [hue, setHue] = useState(0);
  useEffect(() => {
    updateCanvas(hue);
  }, [hue]);

  return (
    <div>
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
