// %%raw(`import "./other.js"`)

module Utils = {
  let mapRange = (n, f) => {
    Array.make(~length=n, 0)->Array.mapWithIndex((_, i) => {
      f(i)
    })
  }
  let bound = (left, right, v) => {
    Math.max(left, Math.min(right, v))
  }
}

@module("ulid") external ulid: unit => string = "ulid"

let hueToName = hue => {
  switch hue {
  | x if x >= 05. && x < 15. => "rose"
  | x if x >= 15. && x < 25. => "crimson"
  | x if x >= 25. && x < 35. => "red"
  | x if x >= 35. && x < 45. => "vermillion"
  | x if x >= 45. && x < 55. => "persimmon"
  | x if x >= 55. && x < 65. => "orange"
  | x if x >= 65. && x < 75. => "pumpkin"
  | x if x >= 75. && x < 85. => "mango"
  | x if x >= 85. && x < 95. => "amber"
  | x if x >= 95. && x < 105. => "gold"
  | x if x >= 105. && x < 115. => "yellow"
  | x if x >= 115. && x < 125. => "citron"
  | x if x >= 125. && x < 135. => "pear"
  | x if x >= 135. && x < 145. => "chartreuse"
  | x if x >= 145. && x < 155. => "lime"
  | x if x >= 155. && x < 165. => "green"
  | x if x >= 165. && x < 175. => "emerald"
  | x if x >= 175. && x < 185. => "mint"
  | x if x >= 185. && x < 195. => "sea"
  | x if x >= 195. && x < 205. => "teal"
  | x if x >= 205. && x < 215. => "cyan"
  | x if x >= 215. && x < 225. => "pacific"
  | x if x >= 225. && x < 235. => "cerulean"
  | x if x >= 235. && x < 245. => "capri"
  | x if x >= 245. && x < 255. => "sky"
  | x if x >= 255. && x < 265. => "blue"
  | x if x >= 265. && x < 275. => "sapphire"
  | x if x >= 275. && x < 285. => "indigo"
  | x if x >= 285. && x < 295. => "veronica"
  | x if x >= 295. && x < 305. => "violet"
  | x if x >= 305. && x < 315. => "amethyst"
  | x if x >= 315. && x < 325. => "purple"
  | x if x >= 325. && x < 335. => "plum"
  | x if x >= 335. && x < 345. => "fuchsia"
  | x if x >= 345. && x < 355. => "magenta"
  | x if x >= 355. || x < 05. => "pink"
  | _ => "?"
  }
}

module Gamut = {
  @react.component @module("./other.jsx") external make: unit => React.element = "Gamut"
}

type shade = {id: string, name: string}

type element = {
  id: string,
  shadeId: string,
  hueId: string,
  lightness: float,
  saturation: float,
}

type hue = {
  id: string,
  value: float,
  name: string,
  elements: array<element>,
}

module Texel = {
  type triple = (float, float, float)
  type texelType

  @module("@texel/color") external okhsv: texelType = "OKHSV"
  @module("@texel/color") external okhsl: texelType = "OKHSL"
  @module("@texel/color") external oklch: texelType = "OKLCH"
  @module("@texel/color") external srgb: texelType = "sRGB"

  @module("@texel/color") external rgbToHex: triple => string = "RGBToHex"
  @module("@texel/color") external hexToRgb: string => triple = "hexToRGB"

  @module("@texel/color") external convert: (triple, texelType, texelType) => triple = "convert"
  @module("@texel/color") external isRGBInGamut: triple => bool = "isRGBInGamut"
}

module Canvas = {
  type canvas
  type context

  @send
  external fillRect: (context, ~x: int, ~y: int, ~w: int, ~h: int) => unit = "fillRect"
  @set external setFillStyle: (context, string) => unit = "fillStyle"
  @get external getWidth: canvas => int = "width"
  @get external getHeight: canvas => int = "height"
  @set external setWidth: (canvas, int) => unit = "width"
  @set external setHeight: (canvas, int) => unit = "height"
  @send external getContext: (canvas, string) => context = "getContext"
  @send external clearRect: (context, ~x: int, ~y: int, ~w: int, ~h: int) => unit = "clearRect"
}

module NameInspection = {
  @react.component
  let make = () => {
    <div>
      {Utils.mapRange(36, i => {
        let hue = (i * 10)->Int.toFloat
        <div className="flex flex-row">
          <div
            className={"w-4 h-4"}
            style={{
              backgroundColor: Texel.rgbToHex(
                Texel.convert((hue, 1.0, 1.0), Texel.okhsv, Texel.srgb),
              ),
            }}
          />
          {hue->hueToName->React.string}
        </div>
      })->React.array}
    </div>
  }
}

let updateHueLineCanvas = (canvas, ctx) => {
  let xMax = canvas->Canvas.getWidth
  let yMax = canvas->Canvas.getHeight

  for x in 0 to xMax {
    let rgb = Texel.convert(
      (x->Int.toFloat /. xMax->Int.toFloat *. 360., 1.0, 1.0),
      Texel.okhsv,
      Texel.srgb,
    )
    ctx->Canvas.setFillStyle(Texel.rgbToHex(rgb))
    ctx->Canvas.fillRect(~x, ~y=0, ~w=1, ~h=yMax)
  }

  // ctx->Canvas.setFillStyle("#000")

  // hues->Array.forEach(hue => {
  //   ctx->Canvas.fillRect(~x=(hue /. 360. *. xMax->Int.toFloat)->Float.toInt, ~y=0, ~w=10, ~h=10)
  // })

  ()
}

module HueLine = {
  let xSize = 500
  @react.component
  let make = (~hues: array<hue>, ~selected) => {
    let canvasRef = React.useRef(Nullable.null)
    // let huesComparison = hues->Array.reduce("", (a, c) => {a ++ c->Float.toString})
    React.useEffect1(() => {
      switch canvasRef.current {
      | Value(canvasDom) => {
          let canvas = canvasDom->Obj.magic
          let context = canvas->Canvas.getContext("2d")
          canvas->Canvas.setWidth(xSize)
          canvas->Canvas.setHeight(20)
          updateHueLineCanvas(canvas, context)
        }
      | Null | Undefined => ()
      }

      None
    }, [canvasRef.current])

    <div className="w-fit relative">
      {hues
      ->Array.map(hue => {
        <div
          className={[
            "w-2 h-2 absolute border-black border",
            selected->Option.mapOr(false, s => s == hue.id) ? "bg-green-500" : "bg-black",
          ]->Array.join(" ")}
          style={{
            left: (hue.value /. 360. *. xSize->Int.toFloat)->Float.toInt->Int.toString ++ "px",
          }}
        />
      })
      ->React.array}
      <canvas ref={ReactDOM.Ref.domRef(canvasRef)} />
    </div>
  }
}

let chromaBound = 0.36

let updateLchHGamutCanvas = (canvas, ctx, hue) => {
  let xMax = canvas->Canvas.getWidth
  let yMax = canvas->Canvas.getHeight

  // context->Canvas.clearRect(~x=0, ~y=0, ~w=xSize, ~h=ySize)

  for x in 0 to xMax {
    for y in 0 to yMax {
      let h = hue
      let l = x->Int.toFloat /. xMax->Int.toFloat
      let c = y->Int.toFloat /. yMax->Int.toFloat *. chromaBound
      let rgb = Texel.convert((l, c, h), Texel.oklch, Texel.srgb)

      if rgb->Texel.isRGBInGamut {
        ctx->Canvas.setFillStyle(Texel.rgbToHex(rgb))
        ctx->Canvas.fillRect(~x, ~y=yMax - y, ~w=1, ~h=1)
      }
    }
  }

  ()
}

module LchHGamut = {
  let xSize = 300
  let ySize = 300

  @react.component
  let make = (~hues: array<hue>, ~selected) => {
    let canvasRef = React.useRef(Nullable.null)
    let hueObj = selected->Option.flatMap(s => hues->Array.find(v => v.id == s))
    // Todo: update on hues change
    React.useEffect2(() => {
      switch canvasRef.current {
      | Value(canvasDom) =>
        let canvas = canvasDom->Obj.magic
        let context = canvas->Canvas.getContext("2d")

        switch hueObj {
        | Some(selectedHue) =>
          canvas->Canvas.setWidth(xSize)
          canvas->Canvas.setHeight(ySize)
          updateLchHGamutCanvas(canvas, context, selectedHue.value)

        | None => context->Canvas.clearRect(~x=0, ~y=0, ~w=xSize, ~h=ySize)
        }
      | Null | Undefined => ()
      }

      None
    }, (canvasRef.current, selected))

    <div className="w-fit relative bg-black">
      {hueObj->Option.mapOr(React.null, hue => {
        hue.elements
        ->Array.map(e => {
          let hsl = (hue.value, e.saturation, e.lightness)
          let (l, c, h) = Texel.convert(hsl, Texel.okhsl, Texel.oklch)

          let hex = Texel.convert(hsl, Texel.okhsl, Texel.srgb)->Texel.rgbToHex

          <div
            className="absolute w-5 h-5 border border-black"
            style={{
              backgroundColor: hex,
              bottom: (c /. chromaBound *. ySize->Int.toFloat)->Float.toInt->Int.toString ++ "px",
              left: (l *. xSize->Int.toFloat)->Float.toInt->Int.toString ++ "px",
            }}
          />
        })
        ->React.array
      })}
      <canvas ref={ReactDOM.Ref.domRef(canvasRef)} />
    </div>
  }
}

let updateHslSGamutCanvas = (canvas, ctx) => {
  let xMax = canvas->Canvas.getWidth
  let yMax = canvas->Canvas.getHeight

  // context->Canvas.clearRect(~x=0, ~y=0, ~w=xSize, ~h=ySize)

  for x in 0 to xMax {
    for y in 0 to yMax {
      let h = y->Int.toFloat /. yMax->Int.toFloat *. 360.
      let l = x->Int.toFloat /. xMax->Int.toFloat
      let s = 0.0
      let rgb = Texel.convert((h, s, l), Texel.okhsl, Texel.srgb)

      ctx->Canvas.setFillStyle(Texel.rgbToHex(rgb))
      ctx->Canvas.fillRect(~x, ~y, ~w=1, ~h=1)
    }
  }

  ()
}

module HslSGamut = {
  let xSize = 300
  let ySize = 300

  @react.component
  let make = (~hues: array<hue>, ~selected) => {
    let canvasRef = React.useRef(Nullable.null)
    let hueObj = selected->Option.flatMap(s => hues->Array.find(v => v.id == s))
    // Todo: update on hues change

    React.useEffect2(() => {
      switch canvasRef.current {
      | Value(canvasDom) =>
        let canvas = canvasDom->Obj.magic
        let context = canvas->Canvas.getContext("2d")

        switch hueObj {
        | Some(_) =>
          canvas->Canvas.setWidth(xSize)
          canvas->Canvas.setHeight(ySize)
          updateHslSGamutCanvas(canvas, context)

        | None => context->Canvas.clearRect(~x=0, ~y=0, ~w=xSize, ~h=ySize)
        }
      | Null | Undefined => ()
      }

      None
    }, (canvasRef.current, selected))

    <div className="w-fit relative border border-black">
      {selected->Option.isNone
        ? React.null
        : {
            hues
            ->Array.map(hue =>
              hue.elements->Array.map(e => {
                let hex =
                  Texel.convert(
                    (hue.value, e.saturation, e.lightness),
                    Texel.okhsl,
                    Texel.srgb,
                  )->Texel.rgbToHex

                <div
                  className="absolute w-5 h-5 border border-black"
                  style={{
                    backgroundColor: hex,
                    left: (e.lightness *. ySize->Int.toFloat)->Float.toInt->Int.toString ++ "px",
                    top: (hue.value /. 360. *. xSize->Int.toFloat)
                    ->Float.toInt
                    ->Int.toString ++ "px",
                  }}
                />
              })
            )
            ->Belt.Array.concatMany
            ->React.array
          }}
      <canvas ref={ReactDOM.Ref.domRef(canvasRef)} />
    </div>
  }
}

@val @scope("document")
external addKeyboardListner: (string, ReactEvent.Keyboard.t => unit) => unit = "addEventListener"

@val @scope("document")
external removeKeyboardListner: (string, ReactEvent.Keyboard.t => unit) => unit =
  "removeEventListener"

let adjustLchLofHex = (hex, f) => {
  let (l, c, h) = hex->Texel.hexToRgb->Texel.convert(Texel.srgb, Texel.oklch)
  Texel.convert((l->f, c, h), Texel.oklch, Texel.srgb)->Texel.rgbToHex
}

let adjustLchCofHex = (hex, f) => {
  let (l, c, h) = hex->Texel.hexToRgb->Texel.convert(Texel.srgb, Texel.oklch)
  Texel.convert((l, c->f, h), Texel.oklch, Texel.srgb)->Texel.rgbToHex
}

let makeDefaultPicks = (xLen, defaultShades: array<shade>) => {
  let xLenF = xLen->Int.toFloat
  let yLenF = defaultShades->Array.length->Int.toFloat

  Utils.mapRange(xLen, x => {
    let xF = x->Int.toFloat
    let hue = xF /. xLenF *. 360. +. 1.
    let hueId = ulid()
    let elements = defaultShades->Array.mapWithIndex((shade, y) => {
      let yF = y->Int.toFloat

      let s = (yF +. 1.) /. yLenF

      let (_, s, l) = Texel.convert((hue, s, 1.0), Texel.okhsv, Texel.okhsl)

      {
        shadeId: shade.id,
        hueId,
        id: ulid(),
        lightness: l,
        saturation: s,
      }
    })

    {
      id: hueId,
      value: hue,
      name: hue->hueToName,
      elements,
    }
  })
}

module Palette = {
  let defaultShades = Utils.mapRange(5, i => {
    id: ulid(),
    name: ((i + 1) * 100)->Int.toString,
  })

  let defaultPicks = makeDefaultPicks(5, defaultShades)

  @react.component
  let make = (~arr) => {
    let (picks_, setPicks) = React.useState(() => defaultPicks)
    let (shades, setShades) = React.useState(() => defaultShades)
    let (selectedHue, setSelectedHue) = React.useState(() => None)
    let (selectedElement, setSelectedElement) = React.useState(() => None)

    let handleKeydown = React.useCallback1(event => {
      let update = f => {
        selectedElement->Option.mapOr((), e =>
          setPicks(
            p_ => {
              p_->Array.map(
                hue => {
                  ...hue,
                  elements: hue.elements->Array.map(
                    hueElement => {
                      if hueElement.id == e {
                        hueElement->f
                      } else {
                        hueElement
                      }
                    },
                  ),
                },
              )
            },
          )
        )
      }

      switch event->ReactEvent.Keyboard.key {
      | "ArrowDown" =>
        Console.log("down")
        update(el => {
          ...el,
          saturation: Math.max(0.0, el.saturation -. 0.01),
        })
        event->ReactEvent.Keyboard.preventDefault

      | "ArrowUp" =>
        update(el => {
          ...el,
          saturation: Math.min(1.0, el.saturation +. 0.01),
        })
        event->ReactEvent.Keyboard.preventDefault

      | "ArrowLeft" =>
        update(el => {
          ...el,
          lightness: Math.max(0.0, el.lightness -. 0.01),
        })
        event->ReactEvent.Keyboard.preventDefault

      | "ArrowRight" =>
        update(el => {
          ...el,
          lightness: Math.min(1.0, el.lightness +. 0.01),
        })
        event->ReactEvent.Keyboard.preventDefault

      | _ => ()
      }
    }, [selectedElement])

    React.useEffect1(() => {
      addKeyboardListner("keydown", handleKeydown)
      Some(() => removeKeyboardListner("keydown", handleKeydown))
    }, [selectedElement])

    let picks = picks_->Array.toSorted((a, b) => a.value -. b.value)

    let hueLen = picks->Array.length
    let shadeLen = shades->Array.length

    let changeHexHueByHSL = (hex, hue) => {
      let (_, s, v) = Texel.convert(hex->Texel.hexToRgb, Texel.srgb, Texel.okhsv)
      let newHex = Texel.convert((hue, s, v), Texel.okhsv, Texel.srgb)->Texel.rgbToHex
      newHex
    }

    let makeNewHue = (copy, left, right) => {
      let newValue = (left +. right) /. 2.
      let hueId = ulid()
      {
        id: hueId,
        name: newValue->hueToName,
        value: newValue,
        elements: copy.elements->Array.map(v => {
          {
            id: ulid(),
            hueId,
            shadeId: v.shadeId,
            saturation: v.saturation,
            lightness: v.lightness,
          }
        }),
      }
    }

    let newInterHue = (pick: hue) => {
      setPicks(p_ => {
        p_->Array.reduceWithIndex([], (acc, cur, i) => {
          let leftValue = i == 0 ? 0. : p_->Array.getUnsafe(i - 1)->{x => x.value}

          cur.id == pick.id ? [...acc, makeNewHue(cur, leftValue, cur.value), cur] : [...acc, cur]
        })
      })
    }

    let newEndHue = () => {
      setPicks(p_ => {
        let lastHue = picks->Array.toReversed->Array.getUnsafe(0)

        let new = makeNewHue(lastHue, lastHue.value, 360.)
        [...p_, new]
      })
    }

    let newEndShade = () => {
      let newShadeId = ulid()
      setShades(s_ => {
        [
          ...s_,
          {
            id: newShadeId,
            name: "New",
          },
        ]
      })
      setPicks(p_ => {
        p_->Array.map(v => {
          {
            ...v,
            elements: v.elements->Array.reduceWithIndex(
              [],
              (a, c, i) => {
                i == v.elements->Array.length - 1
                  ? {
                      [
                        ...a,
                        c,
                        {
                          id: ulid(),
                          shadeId: newShadeId,
                          hueId: v.id,
                          saturation: Utils.bound(0.0, 1.0, (c.saturation +. 1.0) /. 2.),
                          lightness: Utils.bound(0.0, 1.0, (c.lightness +. 1.0) /. 2.),
                        },
                      ]
                    }
                  : [...a, c]
              },
            ),
          }
        })
      })
    }

    let newInterShade = (shade: shade) => {
      let newShadeId = ulid()
      setShades(s_ => {
        s_->Array.reduce([], (a, c) => {
          c.id == shade.id
            ? [
                ...a,
                {
                  id: newShadeId,
                  name: "New",
                },
                c,
              ]
            : [...a, c]
        })
      })
      setPicks(p_ => {
        p_->Array.map(hue => {
          {
            ...hue,
            elements: hue.elements->Array.reduceWithIndex(
              [],
              (a, c, i) => {
                c.shadeId == shade.id
                  ? {
                      // Todo: interpolate value too?

                      let (leftSaturation, leftLightness) =
                        i == 0
                          ? (0.0, 0.0)
                          : hue.elements
                            ->Array.getUnsafe(i - 1)
                            ->{
                              x => (x.saturation, x.lightness)
                            }

                      [
                        ...a,
                        {
                          id: ulid(),
                          shadeId: newShadeId,
                          hueId: hue.id,
                          saturation: Utils.bound(0.0, 1.0, (leftSaturation +. c.saturation) /. 2.),
                          lightness: Utils.bound(0.0, 1.0, (leftLightness +. c.lightness) /. 2.),
                        },
                        c,
                      ]
                    }
                  : [...a, c]
              },
            ),
          }
        })
      })
    }

    <div>
      <HueLine hues={picks} selected={selectedHue} />
      <div className="flex flex-row gap-2 py-2">
        <LchHGamut hues={picks} selected={selectedHue} />
        <HslSGamut hues={picks} selected={selectedHue} />
      </div>
      <div
        style={{
          display: "grid",
          gridTemplateColumns: `auto repeat(${shadeLen->Int.toString}, 2.5rem) 2.5rem`,
          gridTemplateRows: `auto repeat(${hueLen->Int.toString}, 2.5rem) 2.5rem`,
        }}
        className="py-6 w-fit">
        <div
          className="flex flex-col justify-end"
          style={{
            gridRow: "1 / 2",
            gridColumn: "-1 / -2",
          }}>
          <button
            className="w-5 h-5 bg-black rounded-tr-full rounded-tl-full rounded-br-full"
            onClick={_ => {newEndShade()}}
          />
        </div>
        <div
          className="flex flex-col items-end"
          style={{
            gridRow: "-1 / -2",
            gridColumn: "1 / 2",
          }}>
          <button
            className="w-5 h-5 bg-black rounded-bl-full rounded-tl-full rounded-br-full"
            onClick={_ => newEndHue()}
          />
        </div>
        <div
          className="overflow-hidden"
          style={{
            display: "grid",
            gridRow: "2 / -2",
            gridColumn: "1 / 2",
            gridTemplateRows: "subgrid",
            gridTemplateColumns: "subgrid",
          }}>
          {picks
          ->Array.map(pick => {
            <div key={pick.id} className=" ">
              <div className="flex-row flex w-full justify-between">
                <input
                  type_="text"
                  value={pick.name}
                  onChange={e => {
                    let value = (e->ReactEvent.Form.target)["value"]
                    setPicks(cur => {
                      cur->Array.map(
                        v => {
                          v.id == pick.id
                            ? {
                                ...v,
                                name: value,
                              }
                            : v
                        },
                      )
                    })
                  }}
                  className="w-20 h-5"
                />
                <button
                  className="w-5 h-5 bg-black rounded-bl-full rounded-tl-full rounded-br-full"
                  onClick={_ => {newInterHue(pick)}}
                />
              </div>
              <div className="flex flex-row justify-start gap-2 w-full">
                <button
                  className={[
                    "w-3 h-3 border-black border",
                    selectedHue->Option.mapOr(false, s => s == pick.id)
                      ? "bg-green-500"
                      : "bg-black",
                  ]->Array.join(" ")}
                  onClick={_ => setSelectedHue(_ => Some(pick.id))}
                />
                <button
                  className="w-3 h-3 bg-red-500"
                  onClick={_ => {
                    setPicks(p_ => p_->Array.filter(v => v.id != pick.id))
                    setSelectedHue(v => v->Option.flatMap(p => p == pick.id ? None : Some(p)))
                  }}
                />
              </div>
            </div>
          })
          ->React.array}
        </div>
        <div
          className="overflow-hidden"
          style={{
            display: "grid",
            gridRow: "1 / 2",
            gridColumn: "2 / -2",
            gridTemplateRows: "subgrid",
            gridTemplateColumns: "subgrid",
          }}>
          {shades
          ->Array.map(shade => {
            <div key={shade.id} className=" flex flex-col">
              <input
                type_="text"
                onChange={e => {
                  let value = (e->ReactEvent.Form.target)["value"]
                  setShades(cur =>
                    cur->Array.map(
                      v =>
                        v.id == shade.id
                          ? {
                              ...v,
                              name: value,
                            }
                          : v,
                    )
                  )
                }}
                value={shade.name}
                className="w-10 h-5"
              />
              <div className="flex flex-row justify-between">
                <button
                  className="w-5 h-5 bg-black rounded-tr-full rounded-tl-full rounded-br-full"
                  onClick={_ => {newInterShade(shade)}}
                />
                <button
                  className="w-3 h-3 bg-red-500"
                  onClick={_ => {
                    setPicks(p_ =>
                      p_->Array.map(
                        v => {
                          {
                            ...v,
                            elements: v.elements->Array.filter(e => e.shadeId != shade.id),
                          }
                        },
                      )
                    )
                    setShades(s_ => s_->Array.filter(v => v.id != shade.id))
                  }}
                />
              </div>
            </div>
          })
          ->React.array}
        </div>
        <div
          style={{
            display: "grid",
            gridRow: "2 / -2",
            gridColumn: "2 / -2",
            gridTemplateColumns: "subgrid",
            gridTemplateRows: "subgrid",
          }}>
          {picks
          ->Array.map(hue => {
            hue.elements->Array.map(element => {
              let hex =
                Texel.convert(
                  (hue.value, element.saturation, element.lightness),
                  Texel.okhsl,
                  Texel.srgb,
                )->Texel.rgbToHex
              <div
                key={element.id}
                className="w-10 h-10 max-h-10 max-w-10 flex flex-row items-center justify-center text-xl cursor-pointer"
                style={{
                  backgroundColor: hex,
                }}
                onClick={_ => {
                  setSelectedElement(_ => Some(element.id))
                  setSelectedHue(_ => Some(element.hueId))
                }}>
                {selectedElement->Option.mapOr(false, e => e == element.id)
                  ? {"•"->React.string}
                  : React.null}
              </div>
            })
          })
          ->Belt.Array.concatMany
          ->React.array}
        </div>
      </div>
    </div>
  }
}

@react.component
let make = () => {
  <div className="p-6 ">
    <Palette arr={[]} />
    // <Gamut />
  </div>
}
