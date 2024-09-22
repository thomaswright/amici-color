// Generated by ReScript, PLEASE EDIT WITH CARE

import * as React from "react";
import * as Common from "./Common.res.mjs";
import * as Caml_option from "rescript/lib/es6/caml_option.js";
import * as Color from "@texel/color";
import * as Core__Option from "@rescript/core/src/Core__Option.res.mjs";
import * as JsxRuntime from "react/jsx-runtime";

function updateCanvas(canvas, ctx, hue, view) {
  var xMax = canvas.width;
  var yMax = canvas.height;
  for(var x = 0; x <= xMax; ++x){
    for(var y = 0; y <= yMax; ++y){
      var xVal = x / xMax;
      var yVal = y / yMax;
      var rgb;
      switch (view) {
        case "View_LC" :
            rgb = Color.convert([
                  xVal,
                  yVal * Common.chromaBound,
                  hue
                ], Color.OKLCH, Color.sRGB);
            break;
        case "View_SV" :
            rgb = Color.convert([
                  hue,
                  xVal,
                  yVal
                ], Color.OKHSV, Color.sRGB);
            break;
        case "View_SL" :
            rgb = Color.convert([
                  hue,
                  yVal,
                  xVal
                ], Color.OKHSL, Color.sRGB);
            break;
        
      }
      if (Color.isRGBInGamut(rgb)) {
        ctx.fillStyle = Color.RGBToHex(rgb);
        ctx.fillRect(x, yMax - y | 0, 1, 1);
      }
      
    }
  }
}

var xSizeScaled = 300 * window.devicePixelRatio | 0;

var ySizeScaled = 300 * window.devicePixelRatio | 0;

function ViewGamut(props) {
  var view = props.view;
  var selectedElement = props.selectedElement;
  var selectedHue = props.selectedHue;
  var hues = props.hues;
  var canvasRef = React.useRef(null);
  var hueObj = Core__Option.flatMap(selectedHue, (function (s) {
          return hues.find(function (v) {
                      return v.id === s;
                    });
        }));
  React.useEffect((function () {
          var canvasDom = canvasRef.current;
          if (canvasDom === null || canvasDom === undefined) {
            canvasDom === null;
          } else {
            var context = canvasDom.getContext("2d");
            if (hueObj !== undefined) {
              context.scale(1 / window.devicePixelRatio, 1 / window.devicePixelRatio);
              canvasDom.width = xSizeScaled;
              canvasDom.height = ySizeScaled;
              updateCanvas(canvasDom, context, hueObj.value, view);
            } else {
              context.clearRect(0, 0, xSizeScaled, ySizeScaled);
            }
          }
        }), [
        view,
        canvasRef.current,
        selectedHue,
        Core__Option.flatMap(selectedHue, (function (selectedHue_) {
                return hues.find(function (hue) {
                            return hue.id === selectedHue_;
                          });
              }))
      ]);
  return JsxRuntime.jsx("div", {
              children: JsxRuntime.jsxs("div", {
                    children: [
                      Core__Option.mapOr(hueObj, null, (function (hue) {
                              return hue.elements.map(function (e) {
                                          var hsl_0 = hue.value;
                                          var hsl_1 = e.saturation;
                                          var hsl_2 = e.lightness;
                                          var hsl = [
                                            hsl_0,
                                            hsl_1,
                                            hsl_2
                                          ];
                                          var hex = Color.RGBToHex(Color.convert(hsl, Color.OKHSL, Color.sRGB));
                                          var match;
                                          switch (view) {
                                            case "View_LC" :
                                                var match$1 = Color.convert(hsl, Color.OKHSL, Color.OKLCH);
                                                match = [
                                                  match$1[0],
                                                  match$1[1] / Common.chromaBound
                                                ];
                                                break;
                                            case "View_SV" :
                                                var match$2 = Color.convert([
                                                      hue.value,
                                                      e.saturation,
                                                      e.lightness
                                                    ], Color.OKHSL, Color.OKHSV);
                                                match = [
                                                  match$2[2],
                                                  match$2[1]
                                                ];
                                                break;
                                            case "View_SL" :
                                                match = [
                                                  e.lightness,
                                                  e.saturation
                                                ];
                                                break;
                                            
                                          }
                                          return JsxRuntime.jsx("div", {
                                                      children: Core__Option.mapOr(selectedElement, false, (function (x) {
                                                              return x === e.id;
                                                            })) ? "•" : null,
                                                      className: "absolute w-5 h-5 border border-black flex flex-row items-center justify-center",
                                                      style: {
                                                        backgroundColor: hex,
                                                        bottom: (match[1] * 300 | 0).toString() + "px",
                                                        left: (match[0] * 300 | 0).toString() + "px",
                                                        transform: "translate(-50%, 50%)"
                                                      }
                                                    });
                                        });
                            })),
                      JsxRuntime.jsx("canvas", {
                            ref: Caml_option.some(canvasRef),
                            style: {
                              height: (300).toString() + "px",
                              width: (300).toString() + "px"
                            }
                          })
                    ],
                    className: "w-fit relative bg-black rounded-sm"
                  }),
              className: "p-3 bg-black"
            });
}

var xSize = 300;

var ySize = 300;

var make = ViewGamut;

export {
  updateCanvas ,
  xSize ,
  ySize ,
  xSizeScaled ,
  ySizeScaled ,
  make ,
}
/* xSizeScaled Not a pure module */
