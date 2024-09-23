// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Color from "@texel/color";
import * as Core__Option from "@rescript/core/src/Core__Option.res.mjs";
import * as JsxRuntime from "react/jsx-runtime";

function XStack(props) {
  var setSelectedHue = props.setSelectedHue;
  var setSelectedElement = props.setSelectedElement;
  var view = props.view;
  var selectedElement = props.selectedElement;
  var tmp;
  switch (view) {
    case "View_SV" :
        tmp = "value";
        break;
    case "View_LC" :
    case "View_SL" :
        tmp = "lightness";
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
                                                case "View_SV" :
                                                    percentage = Color.convert([
                                                            hue.value,
                                                            e.saturation,
                                                            e.lightness
                                                          ], Color.OKHSL, Color.OKHSV)[2];
                                                    break;
                                                case "View_LC" :
                                                case "View_SL" :
                                                    percentage = e.lightness;
                                                    break;
                                                
                                              }
                                              return JsxRuntime.jsx("div", {
                                                          children: Core__Option.mapOr(selectedElement, false, (function (x) {
                                                                  return x === e.id;
                                                                })) ? "•" : null,
                                                          className: "absolute w-5 h-5 border border-black flex flex-row items-center justify-center cursor-pointer select-none",
                                                          style: {
                                                            backgroundColor: hex,
                                                            left: (percentage * 300 | 0).toString() + "px",
                                                            transform: "translate(-50%, 0)"
                                                          },
                                                          onClick: (function (param) {
                                                              setSelectedElement(function (param) {
                                                                    return e.id;
                                                                  });
                                                              setSelectedHue(function (param) {
                                                                    return hue.id;
                                                                  });
                                                            })
                                                        });
                                            }),
                                        className: "relative h-5"
                                      });
                          }),
                      className: "flex flex-col gap-1 py-1 bg-white rounded",
                      style: {
                        width: (300).toString() + "px"
                      }
                    }),
                JsxRuntime.jsx("div", {
                      children: tmp,
                      className: "text-white h-4 font-medium text-center"
                    })
              ],
              className: "p-3 bg-black w-fit pt-0"
            });
}

var size = 300;

var make = XStack;

export {
  size ,
  make ,
}
/* @texel/color Not a pure module */
