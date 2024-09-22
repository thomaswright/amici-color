// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Common from "./Common.res.mjs";
import * as Color from "@texel/color";
import * as Core__Option from "@rescript/core/src/Core__Option.res.mjs";
import * as JsxRuntime from "react/jsx-runtime";

function YStack(props) {
  var view = props.view;
  var selectedElement = props.selectedElement;
  var tmp;
  switch (view) {
    case "View_LC" :
        tmp = "chroma";
        break;
    case "View_SV" :
    case "View_SL" :
        tmp = "saturation";
        break;
    
  }
  return JsxRuntime.jsxs("div", {
              children: [
                JsxRuntime.jsx("div", {
                      children: props.hues.map(function (hue) {
                            return JsxRuntime.jsx("div", {
                                        children: hue.elements.map(function (e) {
                                              var hex = Color.RGBToHex(Color.convert([
                                                        hue.value,
                                                        e.saturation,
                                                        e.lightness
                                                      ], Color.OKHSL, Color.sRGB));
                                              var percentage;
                                              switch (view) {
                                                case "View_LC" :
                                                    var match = Color.convert([
                                                          hue.value,
                                                          e.saturation,
                                                          e.lightness
                                                        ], Color.OKHSL, Color.OKLCH);
                                                    percentage = match[1] / Common.chromaBound;
                                                    break;
                                                case "View_SV" :
                                                    percentage = Color.convert([
                                                            hue.value,
                                                            e.saturation,
                                                            e.lightness
                                                          ], Color.OKHSL, Color.OKHSV)[1];
                                                    break;
                                                case "View_SL" :
                                                    percentage = e.saturation;
                                                    break;
                                                
                                              }
                                              return JsxRuntime.jsx("div", {
                                                          children: Core__Option.mapOr(selectedElement, false, (function (x) {
                                                                  return x === e.id;
                                                                })) ? "•" : null,
                                                          className: "absolute w-5 h-5 border border-black flex flex-col items-center justify-center",
                                                          style: {
                                                            backgroundColor: hex,
                                                            bottom: (percentage * 300 | 0).toString() + "px",
                                                            transform: "translate(0, 50%)"
                                                          }
                                                        });
                                            }),
                                        className: "relative w-5"
                                      });
                          }),
                      className: "flex flex-row gap-1 px-1 bg-white rounded",
                      style: {
                        height: (300).toString() + "px"
                      }
                    }),
                JsxRuntime.jsx("div", {
                      children: tmp,
                      className: "text-white w-3 font-medium text-center",
                      style: {
                        writingMode: "vertical-lr"
                      }
                    })
              ],
              className: "p-3 bg-black pl-0 flex flex-row"
            });
}

var size = 300;

var make = YStack;

export {
  size ,
  make ,
}
/* @texel/color Not a pure module */
