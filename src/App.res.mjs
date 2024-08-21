// Generated by ReScript, PLEASE EDIT WITH CARE

import * as React from "react";
import * as Belt_Array from "rescript/lib/es6/belt_Array.js";
import * as OtherJsx from "./other.jsx";
import * as Caml_option from "rescript/lib/es6/caml_option.js";
import * as Core__Array from "@rescript/core/src/Core__Array.res.mjs";
import * as Color from "@texel/color";
import * as JsxRuntime from "react/jsx-runtime";

function mapRange(n, f) {
  return Core__Array.make(n, 0).map(function (param, i) {
              return f(i);
            });
}

function updateHueLineCanvas(canvas, ctx, hues) {
  var xMax = canvas.width;
  var yMax = canvas.height;
  for(var x = 0; x <= xMax; ++x){
    var rgb = Color.convert([
          x / xMax * 360,
          1.0,
          1.0
        ], Color.OKHSV, Color.sRGB);
    ctx.fillStyle = Color.RGBToHex(rgb);
    ctx.fillRect(x, 0, 1, yMax);
  }
  ctx.fillStyle = "#000";
  hues.forEach(function (hue) {
        ctx.fillRect(hue / 360 * xMax | 0, 0, 10, 10);
      });
}

function App$HueLine(props) {
  var hues = props.hues;
  var canvasRef = React.useRef(null);
  var huesComparison = Core__Array.reduce(hues, "", (function (a, c) {
          return a + c.toString();
        }));
  React.useEffect((function () {
          var canvasDom = canvasRef.current;
          if (canvasDom === null || canvasDom === undefined) {
            canvasDom === null;
          } else {
            var context = canvasDom.getContext("2d");
            canvasDom.width = 500;
            canvasDom.height = 20;
            updateHueLineCanvas(canvasDom, context, hues);
          }
        }), [
        canvasRef.current,
        huesComparison
      ]);
  return JsxRuntime.jsx("div", {
              children: JsxRuntime.jsx("canvas", {
                    ref: Caml_option.some(canvasRef)
                  })
            });
}

function App$Palette(props) {
  var match = React.useState(function () {
        var xLen = 5;
        var yLen = 5;
        return mapRange(xLen, (function (x) {
                      var hue = x / xLen * 360;
                      var elements = mapRange(yLen, (function (y) {
                              var s = (y + 1) / yLen;
                              var hex = Color.RGBToHex(Color.convert([
                                        hue,
                                        s,
                                        1.0
                                      ], Color.OKHSV, Color.sRGB));
                              return {
                                      id: y.toString() + x.toString(),
                                      hueId: x.toString(),
                                      hex: hex
                                    };
                            }));
                      return {
                              hueId: x.toString(),
                              hue: hue,
                              elements: elements
                            };
                    }));
      });
  var picks = match[0];
  var hueLen = picks.length;
  var shadeLen = (function (x) {
        return x.elements.length;
      })(picks[0]);
  var picksFlat = Belt_Array.concatMany(picks.map(function (pick) {
            return pick.elements;
          }));
  console.log(picksFlat);
  var addHue = JsxRuntime.jsx("div", {
        className: "w-5 h-5 bg-neutral-500 rounded-bl-full rounded-tl-full rounded-br-full"
      });
  var addShade = JsxRuntime.jsx("div", {
        className: "w-5 h-5 bg-neutral-500 rounded-tr-full rounded-tl-full rounded-br-full"
      });
  return JsxRuntime.jsxs("div", {
              children: [
                JsxRuntime.jsx(App$HueLine, {
                      hues: picks.map(function (param) {
                            return param.hue;
                          })
                    }),
                JsxRuntime.jsxs("div", {
                      children: [
                        JsxRuntime.jsx("div", {
                              children: addShade,
                              style: {
                                gridArea: "addShade"
                              }
                            }),
                        JsxRuntime.jsx("div", {
                              children: addHue,
                              style: {
                                gridArea: "addHue"
                              }
                            }),
                        JsxRuntime.jsx("div", {
                              children: mapRange(shadeLen, (function (i) {
                                      return JsxRuntime.jsxs("div", {
                                                  children: [
                                                    addHue,
                                                    JsxRuntime.jsx("input", {
                                                          className: "w-10 h-5",
                                                          type: "text",
                                                          value: "test"
                                                        })
                                                  ],
                                                  className: "h-10 w-10"
                                                }, i.toString());
                                    })),
                              style: {
                                display: "grid",
                                gridArea: "yAxis",
                                gridTemplateRows: "repeat(" + shadeLen.toString() + ", 1fr)"
                              }
                            }),
                        JsxRuntime.jsx("div", {
                              children: mapRange(hueLen, (function (i) {
                                      return JsxRuntime.jsxs("div", {
                                                  children: [
                                                    addShade,
                                                    JsxRuntime.jsx("input", {
                                                          className: "w-10 h-5",
                                                          type: "text",
                                                          value: "test"
                                                        })
                                                  ],
                                                  className: "h-10 w-10"
                                                }, i.toString());
                                    })),
                              style: {
                                display: "grid",
                                gridArea: "xAxis",
                                gridTemplateColumns: "repeat(" + shadeLen.toString() + ", 1fr)"
                              }
                            }),
                        JsxRuntime.jsx("div", {
                              children: picksFlat.map(function (element) {
                                    return JsxRuntime.jsx("div", {
                                                className: "w-10 h-10 rounded",
                                                style: {
                                                  backgroundColor: element.hex
                                                }
                                              }, element.id);
                                  }),
                              style: {
                                display: "grid",
                                gridArea: "main",
                                gridTemplateColumns: "repeat(" + hueLen.toString() + ", 1fr)",
                                gridTemplateRows: "repeat(" + shadeLen.toString() + ", 1fr)"
                              }
                            })
                      ],
                      className: "p-6 w-fit",
                      style: {
                        display: "grid",
                        gridTemplateAreas: "\"... xAxis addShade\" \"yAxis main ...\" \"addHue ... ...\"",
                        gridTemplateColumns: "2.5rem 1fr 2.5rem",
                        gridTemplateRows: "2.5rem 1fr 2.5rem"
                      }
                    })
              ]
            });
}

function App(props) {
  return JsxRuntime.jsx("div", {
              children: JsxRuntime.jsx(App$Palette, {
                    arr: []
                  }),
              className: "p-6 "
            });
}

var make = App;

export {
  make ,
}
/*  Not a pure module */
