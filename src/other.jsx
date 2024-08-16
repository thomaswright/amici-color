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

let SIZE = 300;
let chromaPeak = 0.35;

// Todo: generate the hue gamuts at start
function updateHueCanvas(canvas, ctx, hueInput, layout) {
  canvas.width = SIZE;
  canvas.height = SIZE;

  let xMax = canvas.width;
  let yMax = canvas.height;

  let loop = (f) => {
    for (let x = 0; x < xMax; x++) {
      for (let y = 0; y < yMax; y++) {
        f(x, y);
      }
    }
  };

  if (layout === layouts.LCH) {
    loop((x, y) => {
      const l = x / xMax;
      const c = (1 - y / yMax) * chromaPeak;
      const h = hueInput;
      const rgb = texel.convert([l, c, h], texel.OKLCH, texel.sRGB);
      const inside = texel.isRGBInGamut(rgb);
      if (inside) {
        ctx.fillStyle = texel.RGBToHex(rgb);
        ctx.fillRect(x, y, 1, 1);
      }
    });
  } else if (layout === layouts.HSV) {
    loop((x, y) => {
      const h = hueInput;
      const s = x / xMax;
      const v = 1 - y / yMax;
      const rgb = texel.convert([h, s, v], texel.OKHSV, texel.sRGB);
      ctx.fillStyle = texel.RGBToHex(rgb);
      ctx.fillRect(x, y, 1, 1);
    });
  } else if (layout === layouts.HSL) {
    loop((x, y) => {
      const h = hueInput;
      const s = x / xMax;
      const l = 1 - y / yMax;
      const rgb = texel.convert([h, s, l], texel.OKHSL, texel.sRGB);
      ctx.fillStyle = texel.RGBToHex(rgb);
      ctx.fillRect(x, y, 1, 1);
    });
  }
}

function updateLightnessCanvas(canvas, ctx, lightnessInput, layout) {
  canvas.width = SIZE;
  canvas.height = SIZE;

  let xMax = canvas.width;
  let yMax = canvas.height;

  let loop = (f) => {
    for (let x = 0; x < xMax; x++) {
      for (let y = 0; y < yMax; y++) {
        f(x, y);
      }
    }
  };

  if (layout === layouts.LCH) {
    loop((x, y) => {
      const l = lightnessInput;
      const c = (1 - y / yMax) * chromaPeak;
      const h = (x / xMax) * 360;
      const rgb = texel.convert([l, c, h], texel.OKLCH, texel.sRGB);
      const inside = texel.isRGBInGamut(rgb);
      if (inside) {
        ctx.fillStyle = texel.RGBToHex(rgb);
        ctx.fillRect(x, y, 1, 1);
      }
    });
  } else if (layout === layouts.HSL) {
    loop((x, y) => {
      const h = (x / xMax) * 360;
      const s = y / yMax;
      const l = lightnessInput;
      const rgb = texel.convert([h, s, l], texel.OKHSL, texel.sRGB);

      ctx.fillStyle = texel.RGBToHex(rgb);
      ctx.fillRect(x, y, 1, 1);
    });
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
  let [lightness, setLightness] = useState(0.8);
  let [layout, setLayout] = useState(layouts.HSL);

  let drawHue = useCallback(
    (canvas, context) => {
      updateHueCanvas(canvas, context, hue, layout);
    },
    [hue, layout]
  );

  let hueCanvas = useCanvas(drawHue);

  let drawLightness = useCallback(
    (canvas, context) => {
      updateLightnessCanvas(canvas, context, lightness, layout);
    },
    [lightness, layout]
  );

  let lightnessCanvas = useCanvas(drawLightness);

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
        onChange={(e) => setHue(parseInt(e.target.value))}
      />
      <div className="flex flex-row gap-2 py-2">
        <div
          style={{
            backgroundColor: s100l25,
          }}
          className="w-10 h-10 rounded"
        />
        <div
          style={{
            backgroundColor: s100l50,
          }}
          className="w-10 h-10 rounded"
        />
        <div
          style={{
            backgroundColor: s100l75,
          }}
          className="w-10 h-10 rounded"
        />
        <div
          style={{
            backgroundColor: s100v100,
          }}
          className="w-10 h-10 rounded"
        />
        <div
          style={{
            backgroundColor: s50v100,
          }}
          className="w-10 h-10 rounded"
        />
        <div
          style={{
            backgroundColor: s100v50,
          }}
          className="w-10 h-10 rounded"
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
      <input
        type="range"
        min="0"
        max="1"
        step="0.02"
        value={lightness}
        onChange={(e) => {
          setLightness(parseFloat(e.target.value));
        }}
      />
      <div
        style={{
          backgroundColor: "#555",
        }}
        className="p-4 w-fit rounded-xl"
      >
        <canvas ref={lightnessCanvas} />
      </div>
    </div>
  );
};
