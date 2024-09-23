// Generated by ReScript, PLEASE EDIT WITH CARE

import * as React from "react";
import * as Caml_option from "rescript/lib/es6/caml_option.js";
import * as Color from "@texel/color";
import * as Core__Option from "@rescript/core/src/Core__Option.res.mjs";
import * as JsxRuntime from "react/jsx-runtime";

function XStack(props) {
  var onDragTo = props.onDragTo;
  var setSelectedHue = props.setSelectedHue;
  var setSelectedElement = props.setSelectedElement;
  var view = props.view;
  var selectedElement = props.selectedElement;
  var isDragging = React.useRef(false);
  var dragPos = React.useRef(undefined);
  var dragId = React.useRef(undefined);
  var gamutEl = React.useRef(null);
  var drag = function (clientX) {
    var match = gamutEl.current;
    var match$1 = dragId.current;
    if (match === null || match === undefined) {
      return ;
    }
    if (match$1 === undefined) {
      return ;
    }
    var gamutRect = match.getBoundingClientRect();
    var gamutX = gamutRect.left;
    var x = Math.min(Math.max(clientX - gamutX | 0, 0), 300);
    onDragTo(match$1, x / 300);
  };
  React.useEffect((function () {
          var onMouseMove = function ($$event) {
            if (isDragging.current) {
              return drag($$event.clientX);
            }
            
          };
          var onTouchMove = function ($$event) {
            if (isDragging.current) {
              return Core__Option.mapOr($$event.touches[0], undefined, (function (touch) {
                            drag(touch.clientX);
                          }));
            }
            
          };
          var onTouchEnd = function (param) {
            isDragging.current = false;
            dragPos.current = undefined;
            dragId.current = undefined;
          };
          var onMouseUp = function (param) {
            isDragging.current = false;
            dragPos.current = undefined;
            dragId.current = undefined;
          };
          document.addEventListener("mousemove", onMouseMove);
          document.addEventListener("touchmove", onTouchMove);
          document.addEventListener("touchend", onTouchEnd);
          document.addEventListener("mouseup", onMouseUp);
          return (function () {
                    document.removeEventListener("mousemove", onMouseMove);
                    document.removeEventListener("touchmove", onTouchMove);
                    document.removeEventListener("touchend", onTouchEnd);
                    document.removeEventListener("mouseup", onMouseUp);
                  });
        }), [view]);
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
                                                          onMouseDown: (function (param) {
                                                              isDragging.current = true;
                                                              dragPos.current = undefined;
                                                              dragId.current = e.id;
                                                              setSelectedElement(function (param) {
                                                                    return e.id;
                                                                  });
                                                              setSelectedHue(function (param) {
                                                                    return hue.id;
                                                                  });
                                                            }),
                                                          onTouchStart: (function (param) {
                                                              isDragging.current = true;
                                                              dragPos.current = undefined;
                                                              dragId.current = e.id;
                                                            })
                                                        });
                                            }),
                                        className: "relative h-5"
                                      });
                          }),
                      ref: Caml_option.some(gamutEl),
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

var xSize = 300;

var make = XStack;

export {
  xSize ,
  make ,
}
/* react Not a pure module */
