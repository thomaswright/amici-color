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
  } else if (layout === layouts.HSV) {
    loop((x, y) => {
      const h = (x / xMax) * 360;
      const s = y / yMax;
      const v = lightnessInput;
      const rgb = texel.convert([h, s, v], texel.OKHSV, texel.sRGB);

      ctx.fillStyle = texel.RGBToHex(rgb);
      ctx.fillRect(x, y, 1, 1);
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

function updateSaturationCanvas(canvas, ctx, saturationInput, layout) {
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
      const l = y / yMax;
      const c = saturationInput * chromaPeak;
      const h = (x / xMax) * 360;
      const rgb = texel.convert([l, c, h], texel.OKLCH, texel.sRGB);
      const inside = texel.isRGBInGamut(rgb);
      if (inside) {
        ctx.fillStyle = texel.RGBToHex(rgb);
        ctx.fillRect(x, y, 1, 1);
      }
    });
  } else if (layout === layouts.HSV) {
    loop((x, y) => {
      const h = (x / xMax) * 360;
      const s = saturationInput;
      const v = y / yMax;
      const rgb = texel.convert([h, s, v], texel.OKHSV, texel.sRGB);

      ctx.fillStyle = texel.RGBToHex(rgb);
      ctx.fillRect(x, y, 1, 1);
    });
  } else if (layout === layouts.HSL) {
    loop((x, y) => {
      const h = (x / xMax) * 360;
      const s = saturationInput;
      const l = y / yMax;
      const rgb = texel.convert([h, s, l], texel.OKHSL, texel.sRGB);

      ctx.fillStyle = texel.RGBToHex(rgb);
      ctx.fillRect(x, y, 1, 1);
    });
  }
}

const updateLines = (canvas, ctx, x, y) => {
  let xMax = canvas.width;
  let yMax = canvas.height;

  ctx.clearRect(0, 0, canvas.width, canvas.height);

  ctx.fillStyle = "#fff";
  ctx.fillRect(x * xMax, 0, 1, yMax);
  ctx.fillStyle = "#000";
  ctx.fillRect(x * xMax - 1, 0, 1, yMax);

  ctx.fillStyle = "#fff";
  ctx.fillRect(0, yMax * y, xMax, 1);
  ctx.fillStyle = "#000";
  ctx.fillRect(0, yMax * y - 1, xMax, 1);
};

// Todo: Error catching if canvas isn't loaded

export const Gamut = () => {
  let [hue, setHue] = useState(0.1);
  let [lightness, setLightness] = useState(0.8);
  let [saturation, setSaturation] = useState(0.8);

  let [layout, setLayout] = useState(layouts.LCH);

  const hueCanvas = useRef(null);
  const saturationCanvas = useRef(null);
  const lightnessCanvas = useRef(null);

  const hueLineCanvas = useRef(null);
  const saturationLineCanvas = useRef(null);
  const lightnessLineCanvas = useRef(null);

  useEffect(() => {
    const canvas = hueCanvas.current;
    const context = canvas.getContext("2d");
    canvas.width = SIZE;
    canvas.height = SIZE;
    updateHueCanvas(canvas, context, hue, layout);
  }, [hue, layout]);

  useEffect(() => {
    const canvas = saturationCanvas.current;
    const context = canvas.getContext("2d");
    canvas.width = SIZE;
    canvas.height = SIZE;
    updateSaturationCanvas(canvas, context, saturation, layout);
  }, [saturation, layout]);

  useEffect(() => {
    const canvas = lightnessCanvas.current;
    const context = canvas.getContext("2d");
    canvas.width = SIZE;
    canvas.height = SIZE;
    updateLightnessCanvas(canvas, context, lightness, layout);
  }, [lightness, layout]);

  useEffect(() => {
    const canvas = hueLineCanvas.current;
    const context = canvas.getContext("2d");
    canvas.width = SIZE;
    canvas.height = SIZE;
    updateLines(canvas, context, lightness, saturation);
  }, [lightness, saturation, layout]);

  useEffect(() => {
    const canvas = lightnessLineCanvas.current;
    const context = canvas.getContext("2d");
    canvas.width = SIZE;
    canvas.height = SIZE;
    updateLines(canvas, context, hue, saturation);
  }, [hue, saturation, layout]);

  useEffect(() => {
    const canvas = saturationLineCanvas.current;
    const context = canvas.getContext("2d");
    canvas.width = SIZE;
    canvas.height = SIZE;
    updateLines(canvas, context, hue, lightness);
  }, [hue, lightness, layout]);

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
      <label for="saturation_input">
        {layout === layouts.HSV || layout === layouts.HSL
          ? "Saturation"
          : "Chroma"}
      </label>
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
      <label for="hue_input">{"Hue"}</label>
      <input
        id={"hue_input"}
        type="range"
        min="0"
        max="360"
        step="2"
        value={hue}
        onChange={(e) => setHue(parseInt(e.target.value))}
      />
      <div
        style={{
          backgroundColor: "#555",
        }}
        className="w-fit p-4 rounded-xl"
      >
        <div
          style={{
            width: SIZE + "px",
            height: SIZE + "px",
          }}
        >
          <canvas className="absolute" ref={hueCanvas} />
          <canvas className="absolute" ref={hueLineCanvas} />
        </div>
      </div>

      <input
        id={"saturation_input"}
        type="range"
        min="0"
        max="1"
        step="0.02"
        value={saturation}
        onChange={(e) => {
          setSaturation(parseFloat(e.target.value));
        }}
      />
      <div
        style={{
          backgroundColor: "#555",
        }}
        className="w-fit p-4 rounded-xl"
      >
        <div
          style={{
            width: SIZE + "px",
            height: SIZE + "px",
          }}
        >
          <canvas className="absolute" ref={saturationCanvas} />
          <canvas className="absolute" ref={saturationLineCanvas} />
        </div>
      </div>
      <label for="lightness_input">
        {layout === layouts.LCH || layout === layouts.HSL
          ? "Lightness"
          : "Value"}
      </label>
      <input
        id={"lightness_input"}
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
        className="w-fit p-4 rounded-xl"
      >
        <div
          style={{
            width: SIZE + "px",
            height: SIZE + "px",
          }}
        >
          <canvas className="absolute" ref={lightnessCanvas} />
          <canvas className="absolute" ref={lightnessLineCanvas} />
        </div>
      </div>
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
    </div>
  );
};
