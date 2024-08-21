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

let SIZE = 200;
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

  ctx.clearRect(-10, -10, canvas.width + 20, canvas.height + 20);

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

const Chart = ({ yInput, xInput, gamut, lines, name, flip = false }) => {
  return (
    <div
      style={{
        display: "grid",
        gridTemplateColumns: "40px 1fr",
        gridTemplateRows: "40px 1fr 40px",
        gridTemplateAreas: `"... title" "yAxis chart" "... xAxis"`,
      }}
    >
      <div
        style={{ gridArea: "title" }}
        className=" font-black text-lg text-center"
      >
        {name}
      </div>
      <input
        className="my-2"
        style={{
          gridArea: "yAxis",
          writingMode: flip ? "sideways-lr" : "vertical-lr",
        }}
        type="range"
        min={yInput.min}
        max={yInput.max}
        step={yInput.step}
        value={yInput.value}
        onChange={(e) => {
          yInput.set(parseFloat(e.target.value));
        }}
      />

      <div
        style={{
          gridArea: "chart",
          backgroundColor: "#555",
        }}
        className="p-4 rounded-xl"
      >
        <div
          style={{
            width: SIZE + "px",
            height: SIZE + "px",
          }}
        >
          <canvas className="absolute" ref={gamut} />
          <canvas className="absolute" ref={lines} />
        </div>
      </div>
      <input
        style={{
          gridArea: "xAxis",
        }}
        type="range"
        className="mx-2"
        min={xInput.min}
        max={xInput.max}
        step={xInput.step}
        value={xInput.value}
        onChange={(e) => {
          xInput.set(parseFloat(e.target.value));
        }}
      />
    </div>
  );
};

let makeDefaultPalette = (xMax, yMax) => {
  let result = [];
  for (let x = 0; x < xMax; x++) {
    result.push([]);
    for (let y = 0; y < yMax; y++) {
      let hex = texel.RGBToHex(
        texel.convert(
          [(x / xMax) * 360, (y + 1) / yMax, 1.0],
          texel.OKHSV,
          texel.sRGB
        )
      );

      result[x].push(hex);
    }
  }

  return result;
};

const Palette = () => {
  let [picks, setPicks] = useState(() => makeDefaultPalette(5, 5));
  let addColumn = (i) => {};
  return (
    <div>
      <div className="flex flex-row gap-1">
        {picks.map((group, i) => {
          return (
            <div className="flex flex-col gap-1">
              <button
                onClick={(_) => addColumn(i)}
                className="-ml-[25%] bg-blue-200 w-fit p-1 flex flex-row items-center justify-center rounded"
              >
                {"+"}
              </button>
              {group.map((hex, j) => {
                return (
                  <div
                    key={"swatch" + i + "" + j}
                    className="w-10 h-10 rounded-xl"
                    style={{ backgroundColor: hex }}
                  />
                );
              })}
            </div>
          );
        })}
      </div>
    </div>
  );
};

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
    updateLines(
      canvas,
      context,
      lightness,
      layout === layouts.LCH ? 1 - saturation : saturation
    );
  }, [lightness, saturation, layout]);

  useEffect(() => {
    const canvas = lightnessLineCanvas.current;
    const context = canvas.getContext("2d");
    canvas.width = SIZE;
    canvas.height = SIZE;
    updateLines(
      canvas,
      context,
      hue / 360,
      layout === layouts.LCH ? 1 - saturation : saturation
    );
  }, [hue, saturation, layout]);

  useEffect(() => {
    const canvas = saturationLineCanvas.current;
    const context = canvas.getContext("2d");
    canvas.width = SIZE;
    canvas.height = SIZE;
    updateLines(canvas, context, hue / 360, lightness);
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
    <div className="flex flex-row">
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

        <Chart
          yInput={{
            min: "0",
            max: "1",
            step: "0.02",
            value: saturation,
            set: (v) => setSaturation(v),
          }}
          xInput={{
            min: "0",
            max: "1",
            step: "0.02",
            value: lightness,
            set: (v) => setLightness(v),
          }}
          gamut={hueCanvas}
          lines={hueLineCanvas}
          flip={layout === layouts.LCH}
          name={"Hue"}
        />
        <Chart
          yInput={{
            min: "0",
            max: "1",
            step: "0.02",
            value: lightness,
            set: (v) => setLightness(v),
          }}
          xInput={{
            min: "0",
            max: "360",
            step: "2",
            value: hue,
            set: (v) => setHue(v),
          }}
          gamut={saturationCanvas}
          lines={saturationLineCanvas}
          name={layout === layouts.LCH ? "Chroma" : "Saturation"}
        />
        <Chart
          yInput={{
            min: "0",
            max: "1",
            step: "0.02",
            value: saturation,
            set: (v) => setSaturation(v),
          }}
          xInput={{
            min: "0",
            max: "360",
            step: "2",
            value: hue,
            set: (v) => setHue(v),
          }}
          gamut={lightnessCanvas}
          lines={lightnessLineCanvas}
          flip={layout === layouts.LCH}
          name={layout === layouts.HSV ? "value" : "Lightness"}
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
      </div>
      {/* <Palette /> */}
    </div>
  );
};

// <div>
// {layout === layouts.HSV || layout === layouts.HSL
//   ? "Saturation"
//   : "Chroma"}
// </div>
// <div>
//         {layout === layouts.LCH || layout === layouts.HSL
//           ? "Lightness"
//           : "Value"}
//       </div>
