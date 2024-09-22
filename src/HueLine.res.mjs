// Generated by ReScript, PLEASE EDIT WITH CARE

import * as React from "react";
import * as Caml_option from "rescript/lib/es6/caml_option.js";
import * as Color from "@texel/color";
import * as Core__Option from "@rescript/core/src/Core__Option.res.mjs";
import * as JsxRuntime from "react/jsx-runtime";

function updateHueLineCanvas(canvas, ctx) {
  var yMax = canvas.height;
  for(var y = 0; y <= yMax; ++y){
    var rgb = Color.convert([
          y / yMax * 360,
          1.0,
          1.0
        ], Color.OKHSV, Color.sRGB);
    ctx.fillStyle = Color.RGBToHex(rgb);
    ctx.fillRect(0, y, yMax, 1);
  }
}

var xSizeScaled = 20 * window.devicePixelRatio | 0;

var ySizeScaled = 300 * window.devicePixelRatio | 0;

function HueLine(props) {
  var selected = props.selected;
  var canvasRef = React.useRef(null);
  React.useEffect((function () {
          var canvasDom = canvasRef.current;
          if (canvasDom === null || canvasDom === undefined) {
            canvasDom === null;
          } else {
            var context = canvasDom.getContext("2d");
            context.scale(1 / window.devicePixelRatio, 1 / window.devicePixelRatio);
            canvasDom.width = xSizeScaled;
            canvasDom.height = ySizeScaled;
            updateHueLineCanvas(canvasDom, context);
          }
        }), [canvasRef.current]);
  return JsxRuntime.jsxs("div", {
              children: [
                props.hues.map(function (hue) {
                      return JsxRuntime.jsx("div", {
                                  className: [
                                      "w-3 h-3 absolute border-black rounded-full",
                                      Core__Option.mapOr(selected, false, (function (s) {
                                              return s === hue.id;
                                            })) ? "border-4" : "border "
                                    ].join(" "),
                                  style: {
                                    left: "0.25rem",
                                    top: (hue.value / 360 * 300 | 0).toString() + "px"
                                  }
                                });
                    }),
                JsxRuntime.jsx("canvas", {
                      ref: Caml_option.some(canvasRef),
                      style: {
                        height: (300).toString() + "px",
                        width: (20).toString() + "px"
                      }
                    })
              ],
              className: "w-fit relative h-full rounded-sm overflow-hidden"
            });
}

var xSize = 20;

var ySize = 300;

var make = HueLine;

export {
  updateHueLineCanvas ,
  xSize ,
  ySize ,
  xSizeScaled ,
  ySizeScaled ,
  make ,
}
/* xSizeScaled Not a pure module */
