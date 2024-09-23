open Common
open Types

let xSize = 300
@react.component
let make = (
  ~hues: array<hue>,
  ~selectedElement,
  ~view: view,
  ~setSelectedElement,
  ~setSelectedHue,
  ~onDragTo,
) => {
  let isDragging = React.useRef(false)
  let dragPos = React.useRef(None)
  let dragId = React.useRef(None)
  let gamutEl = React.useRef(Nullable.null)

  let drag = clientX => {
    switch (gamutEl.current, dragId.current) {
    | (Value(dom), Some(id)) => {
        let gamutRect = dom->getBoundingClientRect

        let gamutX = gamutRect["left"]

        let x = (clientX - gamutX)->Int.toFloat->Math.max(0.)->Math.min(xSize->Int.toFloat)

        onDragTo(id, x /. xSize->Int.toFloat)
      }

    | _ => ()
    }
  }
  React.useEffect1(() => {
    let onMouseMove = event => {
      if !isDragging.current {
        ()
      } else {
        drag(event->ReactEvent.Mouse.clientX)
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
        ->Option.mapOr((), touch => drag(touch["clientX"]))
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

  <div className="p-3 bg-black w-fit pt-0">
    <div
      ref={ReactDOM.Ref.domRef(gamutEl)}
      className="flex flex-col gap-1 py-1 bg-white rounded"
      style={{width: xSize->Int.toString ++ "px"}}>
      {hues
      ->Array.map(hue =>
        <div className="relative h-5">
          {hue.elements
          ->Array.map(e => {
            let hex =
              Texel.convert(
                (hue.value, e.saturation, e.lightness),
                Texel.okhsl,
                Texel.srgb,
              )->Texel.rgbToHex

            let percentage = switch view {
            | View_LC => e.lightness
            | View_SV => {
                let (_, _, v) = Texel.convert(
                  (hue.value, e.saturation, e.lightness),
                  Texel.okhsl,
                  Texel.okhsv,
                )
                v
              }
            | View_SL => e.lightness
            }

            <div
              onClick={_ => {
                setSelectedElement(_ => Some(e.id))
                setSelectedHue(_ => Some(hue.id))
              }}
              onMouseDown={_ => {
                isDragging.current = true
                dragPos.current = None
                dragId.current = Some(e.id)
              }}
              onTouchStart={_ => {
                isDragging.current = true
                dragPos.current = None
                dragId.current = Some(e.id)
              }}
              className="absolute w-5 h-5 border border-black flex flex-row items-center justify-center cursor-pointer select-none"
              style={{
                backgroundColor: hex,
                transform: "translate(-50%, 0)",
                left: (percentage *. xSize->Int.toFloat)->Float.toInt->Int.toString ++ "px",
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
    <div className="text-white h-4 font-medium text-center">
      {switch view {
      | View_LC => "lightness"
      | View_SL => "lightness"
      | View_SV => "value"
      }->React.string}
    </div>
  </div>
}
