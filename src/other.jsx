import * as texel from "@texel/color";
import { useCallback, useEffect, useState, useRef } from "react";

// # Setup
// const canvas = document.getElementById("canvas");
// const ctx = canvas.getContext("2d");

let layouts = {
  LCH: "LCH",
  HSV: "HSV",
  HSL: "HSL",
};

let SIZE = 500;
let chromaPeak = 0.35;

// Todo: generate the hue gamuts at start
function updateHueCanvas(canvas, ctx, hueInput, layout) {
  canvas.width = SIZE;
  canvas.height = SIZE;
  // ctx.fillStyle = "#888";
  // ctx.fillRect(0, 0, canvas.width, canvas.height);

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

const useCanvas = (draw) => {
  const canvasRef = useRef(null);

  useEffect(() => {
    const canvas = canvasRef.current;
    const context = canvas.getContext("2d");

    draw(canvas, context);
  }, [draw]);

  return canvasRef;
};

export const Gamut = () => {
  let [hue, setHue] = useState(0);
  let [layout, setLayout] = useState(layouts.LCH);

  let drawHue = useCallback(
    (canvas, context) => {
      updateHueCanvas(canvas, context, hue, layout);
    },
    [hue, layout]
  );

  let hueCanvas = useCanvas(drawHue);

  // useEffect(() => {
  //   updateOklchCanvas(hue, layout);
  // }, [hue, layout]);

  let s100l25 = texel.RGBToHex(
    texel.convert([hue, 1.0, 0.25], texel.OKHSL, texel.sRGB)
  );

  let s100l50 = texel.RGBToHex(
    texel.convert([hue, 1.0, 0.5], texel.OKHSL, texel.sRGB)
  );

  let s100l75 = texel.RGBToHex(
    texel.convert([hue, 1.0, 0.75], texel.OKHSL, texel.sRGB)
  );
  let s50v100 = texel.RGBToHex(
    texel.convert([hue, 0.5, 1.0], texel.OKHSV, texel.sRGB)
  );

  let s100v100 = texel.RGBToHex(
    texel.convert([hue, 1.0, 1.0], texel.OKHSV, texel.sRGB)
  );

  let s100v50 = texel.RGBToHex(
    texel.convert([hue, 1.0, 0.5], texel.OKHSV, texel.sRGB)
  );

  return (
    <div>
      <div>
        <button
          className={[
            "px-4 rounded mr-2 font-medium",
            layout === layouts.LCH ? "bg-blue-600 text-white" : "bg-gray-200",
          ].join(" ")}
          onClick={(_) => setLayout(layouts.LCH)}
        >
          LCH
        </button>
        <button
          className={[
            "px-4 rounded mr-2 font-medium",
            layout === layouts.HSL ? "bg-blue-600 text-white" : "bg-gray-200",
          ].join(" ")}
          onClick={(_) => setLayout(layouts.HSL)}
        >
          HSL
        </button>
        <button
          className={[
            "px-4 rounded mr-2 font-medium",
            layout === layouts.HSV ? "bg-blue-600 text-white" : "bg-gray-200",
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
        step="2"
        value={hue}
        onChange={(e) => setHue(e.target.value)}
      />
      <div className="flex flex-row gap-2 py-2">
        <div
          style={{
            backgroundColor: s100l25,
          }}
          className="w-20 h-20 rounded"
        />
        <div
          style={{
            backgroundColor: s100l50,
          }}
          className="w-20 h-20 rounded"
        />
        <div
          style={{
            backgroundColor: s100l75,
          }}
          className="w-20 h-20 rounded"
        />
        <div
          style={{
            backgroundColor: s100v100,
          }}
          className="w-20 h-20 rounded"
        />
        <div
          style={{
            backgroundColor: s50v100,
          }}
          className="w-20 h-20 rounded"
        />
        <div
          style={{
            backgroundColor: s100v50,
          }}
          className="w-20 h-20 rounded"
        />
      </div>

      <div
        style={{
          backgroundColor: "#555",
        }}
        className="p-4 w-fit rounded-xl"
      >
        <canvas ref={hueCanvas} />
      </div>
    </div>
  );
};
