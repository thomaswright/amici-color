open Common
open Types

let updateCanvas = (canvas, ctx, hue, view) => {
  let xMax = canvas->Canvas.getWidth
  let yMax = canvas->Canvas.getHeight

  // context->Canvas.clearRect(~x=0, ~y=0, ~w=xSize, ~h=ySize)

  for x in 0 to xMax {
    for y in 0 to yMax {
      let h = hue
      let xVal = x->Int.toFloat /. xMax->Int.toFloat
      let yVal = y->Int.toFloat /. yMax->Int.toFloat

      let rgb = switch view {
      | View_LC => Texel.convert((xVal, yVal *. chromaBound, h), Texel.oklch, Texel.srgb)
      | View_SL => Texel.convert((h, yVal, xVal), Texel.okhsl, Texel.srgb)
      | View_SV => Texel.convert((h, yVal, xVal), Texel.okhsv, Texel.srgb)
      }

      if rgb->Texel.isRGBInGamut {
        ctx->Canvas.setFillStyle(Texel.rgbToHex(rgb))
        ctx->Canvas.fillRect(~x, ~y=yMax - y, ~w=1, ~h=1)
      }
    }
  }

  ()
}

let xSize = 300
let ySize = 300
let xSizeScaled = (xSize->Int.toFloat *. devicePixelRatio)->Float.toInt
let ySizeScaled = (ySize->Int.toFloat *. devicePixelRatio)->Float.toInt

module CanvasComp = {
  @react.component
  let make = (~hueObj, ~view) => {
    let canvasRef = React.useRef(Nullable.null)

    // Todo: update on hues change
    React.useEffect3(() => {
      switch canvasRef.current {
      | Value(canvasDom) =>
        let canvas = canvasDom->Obj.magic
        let context = canvas->Canvas.getContext("2d")

        switch hueObj {
        | Some(selectedHue) =>
          context->Canvas.scale(1. /. devicePixelRatio, 1. /. devicePixelRatio)
          canvas->Canvas.setWidth(xSizeScaled)
          canvas->Canvas.setHeight(ySizeScaled)

          updateCanvas(canvas, context, selectedHue.value, view)

        | None => context->Canvas.clearRect(~x=0, ~y=0, ~w=xSizeScaled, ~h=ySizeScaled)
        }
      | Null | Undefined => ()
      }

      None
    }, (view, canvasRef.current, hueObj->Option.mapOr(0., v => v.value)))

    <canvas
      style={{
        width: xSize->Int.toString ++ "px",
        height: ySize->Int.toString ++ "px",
      }}
      ref={ReactDOM.Ref.domRef(canvasRef)}
    />
  }

  let make = React.memoCustomCompareProps(make, (a, b) => {
    a.view == b.view &&
      switch (a.hueObj, b.hueObj) {
      | (Some(a_), Some(b_)) => a_.id == b_.id && a_.value == b_.value
      | (None, None) => true
      | _ => false
      }
  })
}

@react.component
let make = (
  ~hues: array<hue>,
  ~selectedHue,
  ~selectedElement,
  ~view: view,
  ~setSelectedElement,
  ~onDragTo,
) => {
  let hueObj = selectedHue->Option.flatMap(s => hues->Array.find(v => v.id == s))
  let isDragging = React.useRef(false)
  let dragPos = React.useRef(None)
  let dragId = React.useRef(None)
  let gamutEl = React.useRef(Nullable.null)

  let drag = (clientX, clientY) => {
    switch (gamutEl.current, dragId.current) {
    | (Value(dom), Some(id)) => {
        let gamutRect = dom->getBoundingClientRect

        let gamutX = gamutRect["left"]
        let gamutY = gamutRect["top"]

        let x = (clientX - gamutX)->Int.toFloat->Math.max(0.)->Math.min(xSize->Int.toFloat)
        let y = (clientY - gamutY)->Int.toFloat->Math.max(0.)->Math.min(ySize->Int.toFloat)

        onDragTo(id, x /. xSize->Int.toFloat, y /. ySize->Int.toFloat)
      }

    | _ => ()
    }
  }
  React.useEffect1(() => {
    let onMouseMove = event => {
      if !isDragging.current {
        ()
      } else {
        drag(event->ReactEvent.Mouse.clientX, event->ReactEvent.Mouse.clientY)
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
        ->Option.mapOr((), touch => drag(touch["clientX"], touch["clientY"]))
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

  <div className="p-3 bg-black">
    <div className=" relative">
      <CanvasComp hueObj view />
      <div
        ref={ReactDOM.Ref.domRef(gamutEl)}
        className="absolute top-0 left-0 bg-transparent rounded-sm w-full h-full">
        {hueObj->Option.mapOr(React.null, hue => {
          hue.elements
          ->Array.map(e => {
            let hsl = (hue.value, e.saturation, e.lightness)

            let hex = Texel.convert(hsl, Texel.okhsl, Texel.srgb)->Texel.rgbToHex
            let (xPer, yPer) = switch view {
            | View_LC => {
                let (l, c, _h) = Texel.convert(hsl, Texel.okhsl, Texel.oklch)
                (l, c /. chromaBound)
              }
            | View_SL => (e.lightness, e.saturation)
            | View_SV => {
                let (_, s, v) = Texel.convert(
                  (hue.value, e.saturation, e.lightness),
                  Texel.okhsl,
                  Texel.okhsv,
                )

                (v, e.lightness == 0. ? e.saturation : s)
              }
            }

            <div
              key={e.id}
              onMouseDown={_ => {
                isDragging.current = true
                dragPos.current = None
                dragId.current = Some(e.id)
                setSelectedElement(_ => Some(e.id))
              }}
              onTouchStart={_ => {
                isDragging.current = true
                dragPos.current = None
                dragId.current = Some(e.id)
              }}
              // onClick={_ => {}}
              className=" select-none absolute w-5 h-5 border border-black border-t-white border-l-white flex flex-row items-center justify-center cursor-pointer"
              style={{
                backgroundColor: hex,
                transform: "translate(-50%, 50%)",
                left: (xPer *. xSize->Int.toFloat)->Float.toInt->Int.toString ++ "px",
                bottom: (yPer *. ySize->Int.toFloat)->Float.toInt->Int.toString ++ "px",
              }}>
              {selectedElement->Option.mapOr(false, x => x == e.id)
                ? {"•"->React.string}
                : React.null}
            </div>
          })
          ->React.array
        })}
      </div>
    </div>
  </div>
}
