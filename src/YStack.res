open Common
open Types

// let updateCanvas = (canvas, ctx, view, selectedHue: option<hue>) => {
//   let _xMax = canvas->Canvas.getWidth
//   let yMax = canvas->Canvas.getHeight

//   for y in 0 to yMax {
//     let rgb = Texel.convert(
//       (
//         0.75,
//         chromaBound *. (1. -. y->Int.toFloat /. yMax->Int.toFloat),
//         selectedHue->Option.mapOr(0., h => h.value),
//       ),
//       Texel.oklch,
//       Texel.srgb,
//     )
//     Console.log(rgb)
//     if rgb->Texel.isRGBInGamut {
//       ctx->Canvas.setFillStyle(Texel.rgbToHex(rgb))
//       ctx->Canvas.fillRect(~x=0, ~y, ~w=yMax, ~h=1)
//     }
//   }

//   ()
// }

// let xSize = 20
let ySize = 300
// let xSizeScaled = (xSize->Int.toFloat *. devicePixelRatio)->Float.toInt
// let ySizeScaled = (ySize->Int.toFloat *. devicePixelRatio)->Float.toInt

@react.component
let make = (
  ~hues: array<hue>,
  ~selectedElement,
  ~view: view,
  ~setSelectedElement,
  ~setSelectedHue,
  ~selectedHue,
  ~onDragTo,
) => {
  // let canvasRef = React.useRef(Nullable.null)
  // let selectedHueUnwrapped =
  //   selectedHue->Option.flatMap(selectedHue_ => hues->Array.find(hue => hue.id == selectedHue_))
  // React.useEffect3(() => {
  //   switch canvasRef.current {
  //   | Value(canvasDom) => {
  //       let canvas = canvasDom->Obj.magic
  //       let context = canvas->Canvas.getContext("2d")
  //       context->Canvas.scale(1. /. devicePixelRatio, 1. /. devicePixelRatio)
  //       canvas->Canvas.setWidth(xSizeScaled)
  //       canvas->Canvas.setHeight(ySizeScaled)
  //       updateCanvas(canvas, context, view, selectedHueUnwrapped)
  //     }
  //   | Null | Undefined => ()
  //   }

  //   None
  // }, (view, canvasRef.current, selectedHueUnwrapped))

  let isDragging = React.useRef(false)
  let dragPos = React.useRef(None)
  let dragId = React.useRef(None)
  let gamutEl = React.useRef(Nullable.null)

  let drag = clientY => {
    switch (gamutEl.current, dragId.current) {
    | (Value(dom), Some(id)) => {
        let gamutRect = dom->getBoundingClientRect

        let gamutY = gamutRect["top"]

        let y = (clientY - gamutY)->Int.toFloat->Math.max(0.)->Math.min(ySize->Int.toFloat)

        onDragTo(id, y /. ySize->Int.toFloat)
      }

    | _ => ()
    }
  }
  React.useEffect1(() => {
    let onMouseMove = event => {
      if !isDragging.current {
        ()
      } else {
        drag(event->ReactEvent.Mouse.clientY)
      }
    }
    let onTouchMove = event => {
      if !isDragging.current {
        ()
      } else {
        event
        ->ReactEvent.Touch.touches
        ->Obj.magic
        ->Array.get(0)
        ->Option.mapOr((), touch => drag(touch["clientY"]))
      }
    }

    let onTouchEnd = _ => {
      isDragging.current = false
      dragPos.current = None
      dragId.current = None
    }
    let onMouseUp = _ => {
      isDragging.current = false
      dragPos.current = None
      dragId.current = None
    }

    addMouseListner("mousemove", onMouseMove)
    addTouchListner("touchmove", onTouchMove)
    addTouchListner("touchend", onTouchEnd)
    addMouseListner("mouseup", onMouseUp)
    Some(
      () => {
        removeMouseListner("mousemove", onMouseMove)
        removeTouchListner("touchmove", onTouchMove)
        removeTouchListner("touchend", onTouchEnd)
        removeMouseListner("mouseup", onMouseUp)
      },
    )
  }, [view])

  <div className="p-3 bg-black pl-0 flex flex-row">
    // <canvas
    //   style={{
    //     width: xSize->Int.toString ++ "px",
    //     height: ySize->Int.toString ++ "px",
    //   }}
    //   ref={ReactDOM.Ref.domRef(canvasRef)}
    // />
    <div
      ref={ReactDOM.Ref.domRef(gamutEl)}
      className="flex flex-row gap-1 px-1 bg-white rounded"
      style={{height: ySize->Int.toString ++ "px"}}>
      {hues
      ->Array.map(hue =>
        <div className="relative w-5">
          {hue.elements
          ->Array.map(e => {
            let hex =
              Texel.convert(
                (hue.value, e.saturation, e.lightness),
                Texel.okhsl,
                Texel.srgb,
              )->Texel.rgbToHex

            let percentage = switch view {
            | View_LC => {
                let (_, chroma, _) = Texel.convert(
                  (hue.value, e.saturation, e.lightness),
                  Texel.okhsl,
                  Texel.oklch,
                )
                chroma /. chromaBound
              }
            | View_SV => {
                let (_, s, v) = Texel.convert(
                  (hue.value, e.saturation, e.lightness),
                  Texel.okhsl,
                  Texel.okhsv,
                )
                e.lightness == 0. ? e.saturation : s
              }
            | View_SL => e.saturation
            }

            <div
              // onClick={_ => {
              //   setSelectedElement(_ => Some(e.id))
              //   setSelectedHue(_ => Some(hue.id))
              // }}
              onMouseDown={_ => {
                isDragging.current = true
                dragPos.current = None
                dragId.current = Some(e.id)
                setSelectedElement(_ => Some(e.id))
                setSelectedHue(_ => Some(hue.id))
              }}
              onTouchStart={_ => {
                isDragging.current = true
                dragPos.current = None
                dragId.current = Some(e.id)
              }}
              className="absolute w-5 h-5 border border-black flex flex-col items-center justify-center cursor-pointer select-none"
              style={{
                backgroundColor: hex,
                transform: "translate(0, 50%)",
                bottom: (percentage *. ySize->Int.toFloat)
                ->Float.toInt
                ->Int.toString ++ "px",
              }}>
              {selectedElement->Option.mapOr(false, x => x == e.id)
                ? {"•"->React.string}
                : React.null}
            </div>
          })
          ->React.array}
        </div>
      )
      ->React.array}
    </div>
    <div className="text-white w-3 font-medium text-center" style={{writingMode: "vertical-lr"}}>
      {switch view {
      | View_LC => "chroma"
      | View_SL => "saturation"
      | View_SV => "saturation"
      }->React.string}
    </div>
  </div>
}
