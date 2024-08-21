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
  hex: string,
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

let makeDefaultPicks = (xLen, defaultShades: array<shade>) => {
  let xLenF = xLen->Int.toFloat
  let yLenF = defaultShades->Array.length->Int.toFloat

  Utils.mapRange(xLen, x => {
    let xF = x->Int.toFloat
    let hue = xF /. xLenF *. 360. +. 1.
    let elements = defaultShades->Array.mapWithIndex((shade, y) => {
      let yF = y->Int.toFloat

      let s = (yF +. 1.) /. yLenF
      let hex = Texel.rgbToHex(Texel.convert((hue, s, 1.0), Texel.okhsv, Texel.srgb))

      {
        shadeId: shade.id,
        id: ulid(),
        hex,
      }
    })

    {
      id: ulid(),
      value: hue,
      name: hue->hueToName,
      elements,
    }
  })
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
          let (l, c, h) = Texel.convert(e.hex->Texel.hexToRgb, Texel.srgb, Texel.oklch)

          <div
            className="absolute w-5 h-5 border border-black"
            style={{
              backgroundColor: e.hex,
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
      let h = x->Int.toFloat /. xMax->Int.toFloat *. 360.
      let l = y->Int.toFloat /. yMax->Int.toFloat
      let s = 1.0
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

    <div className="w-fit relative bg-black">
      {selected->Option.isNone
        ? React.null
        : {
            hues
            ->Array.map(hue => hue.elements)
            ->Belt.Array.concatMany
            ->Array.map(e => {
              let (h, _, l) = Texel.convert(e.hex->Texel.hexToRgb, Texel.srgb, Texel.okhsl)

              <div
                className="absolute w-5 h-5 border border-black"
                style={{
                  backgroundColor: e.hex,
                  top: (l *. ySize->Int.toFloat)->Float.toInt->Int.toString ++ "px",
                  left: (h /. 360. *. xSize->Int.toFloat)
                  ->Float.toInt
                  ->Int.toString ++ "px",
                }}
              />
            })
            ->React.array
          }}
      <canvas ref={ReactDOM.Ref.domRef(canvasRef)} />
    </div>
  }
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

    let picks = picks_->Array.toSorted((a, b) => a.value -. b.value)

    let hueLen = picks->Array.length
    let shadeLen = shades->Array.length
    let picksFlat =
      picks
      ->Array.map(pick => pick.elements)
      ->Belt.Array.concatMany

    let changeHexHueByHSV = (hex, hue) => {
      let (_, s, v) = Texel.convert(hex->Texel.hexToRgb, Texel.srgb, Texel.okhsv)
      let newHex = Texel.convert((hue, s, v), Texel.okhsv, Texel.srgb)->Texel.rgbToHex
      newHex
    }

    let makeNewHue = (copy, left, right) => {
      let newValue = (left +. right) /. 2.
      {
        id: ulid(),
        name: newValue->hueToName,
        value: newValue,
        elements: copy.elements->Array.map(v => {
          {
            id: ulid(),
            shadeId: v.shadeId,
            hex: changeHexHueByHSV(v.hex, newValue),
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
                      let (h, s, left) = Texel.convert(
                        c.hex->Texel.hexToRgb,
                        Texel.srgb,
                        Texel.okhsv,
                      )

                      let right = 1.0
                      let avg = (left +. right) /. 2.

                      let newValue = Utils.bound(0.0, 1.0, avg)
                      let newHex =
                        Texel.convert((h, s, newValue), Texel.okhsv, Texel.srgb)->Texel.rgbToHex

                      [
                        ...a,
                        c,
                        {
                          id: ulid(),
                          shadeId: newShadeId,
                          hex: newHex,
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
        p_->Array.map(v => {
          {
            ...v,
            elements: v.elements->Array.reduceWithIndex(
              [],
              (a, c, i) => {
                c.shadeId == shade.id
                  ? {
                      // Todo: interpolate value too?

                      let left =
                        i == 0
                          ? 0.0
                          : v.elements
                            ->Array.getUnsafe(i - 1)
                            ->{
                              x => {
                                let (_, result, _) = Texel.convert(
                                  x.hex->Texel.hexToRgb,
                                  Texel.srgb,
                                  Texel.okhsv,
                                )

                                result
                              }
                            }

                      let (h, right, v) = Texel.convert(
                        c.hex->Texel.hexToRgb,
                        Texel.srgb,
                        Texel.okhsv,
                      )

                      let avg = (left +. right) /. 2.

                      let newValue = Utils.bound(0.0, 1.0, avg)

                      let newHex =
                        Texel.convert((h, newValue, v), Texel.okhsv, Texel.srgb)->Texel.rgbToHex

                      Console.log4(left, right, newValue, newHex)

                      [
                        ...a,
                        {
                          id: ulid(),
                          shadeId: newShadeId,
                          hex: newHex,
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
      <div className="flex flex-row">
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
          {picksFlat
          ->Array.map(element => {
            <div
              key={element.id}
              className="w-10 h-10 max-h-10 max-w-10"
              style={{
                backgroundColor: element.hex,
              }}
            />
          })
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
