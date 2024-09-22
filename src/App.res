// %%raw(`import "./other.js"`)

open Common
open Types

module Logo = {
  @module("./assets/amici-prism.svg?react") @react.component
  external make: unit => React.element = "default"
}

module DropdownMenu = {
  @react.component @module("./Dropdown.jsx")
  external make: (~items: array<(string, unit => unit)>) => React.element = "default"
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

let modeName = mode =>
  switch mode {
  | HSL_L => "OKHSL - L"
  | LCH_L => "OKLCH - L"
  }

let viewName = view =>
  switch view {
  | View_LC => "oklch"
  | View_SV => "okhsv"
  | View_SL => "okhsl"
  }

module Palette = {
  let defaultShades = Utils.mapRange(5, i => {
    id: ulid(),
    name: ((i + 1) * 100)->Int.toString,
  })

  let defaultPicks = makeDefaultPicks(5, defaultShades)

  @react.component
  let make = () => {
    let (view, setView) = React.useState(() => View_SV)
    // let (selectedMode, setSelectedMode) = React.useState(() => LCH_L)
    let (picks_, setPicks) = React.useState(() => defaultPicks)
    let (shades, setShades) = React.useState(() => defaultShades)
    let (selectedHue, setSelectedHue) = React.useState(() => None)
    let (selectedElement, setSelectedElement) = React.useState(() => None)

    let handleKeydown = React.useCallback2(event => {
      let updateElement = f => {
        selectedElement->Option.mapOr((), e =>
          setPicks(
            p_ => {
              p_->Array.map(
                hue => {
                  ...hue,
                  elements: hue.elements
                  ->Array.map(
                    hueElement => {
                      if hueElement.id == e {
                        f(hueElement, hue.value)
                      } else {
                        hueElement
                      }
                    },
                  )
                  ->Array.toSorted((a, b) => b.lightness -. a.lightness),
                },
              )
            },
          )
        )
      }

      let updateHue = f => {
        selectedHue->Option.mapOr((), selectedHue_ =>
          setPicks(
            p_ => {
              p_->Array.map(
                hue => {
                  hue.id == selectedHue_
                    ? {
                        ...hue,
                        value: Utils.bound(hue.value->f, 0., 360.),
                      }
                    : hue
                },
              )
            },
          )
        )
      }

      switch event->ReactEvent.Keyboard.key {
      | "u" =>
        updateHue(hue => {
          let result = hue -. 10.0
          result < 0. ? result +. 360. : result
        })

      | "d" =>
        updateHue(hue => {
          let result = hue +. 10.0
          result > 360. ? result -. 360. : result
        })

      | "k" =>
        updateHue(hue => {
          let result = hue -. 1.0
          result < 0. ? result +. 360. : result
        })

      | "j" =>
        updateHue(hue => {
          let result = hue +. 1.0
          result > 360. ? result -. 360. : result
        })

      | "ArrowDown" =>
        updateElement((el, _) => {
          ...el,
          saturation: Math.max(0.0, el.saturation -. 0.01),
        })
        event->ReactEvent.Keyboard.preventDefault

      | "ArrowUp" =>
        updateElement((el, _) => {
          ...el,
          saturation: Math.min(1.0, el.saturation +. 0.01),
        })
        event->ReactEvent.Keyboard.preventDefault

      | "ArrowLeft" =>
        switch view {
        | View_SL =>
          updateElement((el, _) => {
            ...el,
            lightness: Math.max(0.0, el.lightness -. 0.01),
          })
        | View_SV =>
          updateElement((el, hue) => {
            let (_, hsvS, hsvV) = Texel.convert(
              (hue, el.saturation, el.lightness),
              Texel.okhsl,
              Texel.okhsv,
            )

            let newV = Math.max(0.0, hsvV -. 0.01)
            let (_, newSaturation, newLightness) = Texel.convert(
              (hue, hsvS, newV),
              Texel.okhsv,
              Texel.okhsl,
            )

            {
              ...el,
              saturation: newSaturation,
              lightness: newLightness,
            }
          })
        | View_LC =>
          updateElement((el, hue) => {
            let (l, c, h) = Texel.convert(
              (hue, el.saturation, el.lightness),
              Texel.okhsl,
              Texel.oklch,
            )
            let newL = Math.max(0.0, l -. 0.01)
            let (_, outputS, outputL) = Texel.convert((newL, c, h), Texel.oklch, Texel.okhsl)
            let rgb = Texel.convert((hue, outputS, outputL), Texel.okhsl, Texel.srgb)
            if rgb->Texel.isRGBInGamut {
              {
                ...el,
                saturation: outputS,
                lightness: outputL,
              }
            } else {
              el
            }
          })
        }

        event->ReactEvent.Keyboard.preventDefault

      | "ArrowRight" =>
        switch view {
        | View_SL =>
          updateElement((el, _) => {
            ...el,
            lightness: Math.min(1.0, el.lightness +. 0.01),
          })
        | View_SV =>
          updateElement((el, hue) => {
            let (_, hsvS, hsvV) = Texel.convert(
              (hue, el.saturation, el.lightness),
              Texel.okhsl,
              Texel.okhsv,
            )

            let newV = Math.min(1.0, hsvV +. 0.01)
            let (_, newSaturation, newLightness) = Texel.convert(
              (hue, hsvS, newV),
              Texel.okhsv,
              Texel.okhsl,
            )

            {
              ...el,
              saturation: newSaturation,
              lightness: newLightness,
            }
          })
        | View_LC =>
          updateElement((el, hue) => {
            let (l, c, h) = Texel.convert(
              (hue, el.saturation, el.lightness),
              Texel.okhsl,
              Texel.oklch,
            )
            let newL = Math.min(1.0, l +. 0.01)
            let (_, outputS, outputL) = Texel.convert((newL, c, h), Texel.oklch, Texel.okhsl)
            let rgb = Texel.convert((hue, outputS, outputL), Texel.okhsl, Texel.srgb)
            if rgb->Texel.isRGBInGamut {
              {
                ...el,
                saturation: outputS,
                lightness: outputL,
              }
            } else {
              el
            }
          })
        }

        event->ReactEvent.Keyboard.preventDefault

      | _ => ()
      }
    }, (selectedElement, view))

    React.useEffect2(() => {
      addKeyboardListner("keydown", handleKeydown)
      Some(() => removeKeyboardListner("keydown", handleKeydown))
    }, (selectedElement, view))

    let picks = picks_->Array.toSorted((a, b) => a.value -. b.value)

    let hueLen = picks->Array.length
    let shadeLen = shades->Array.length

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
      <div className="font-black text-4xl flex flex-row items-center gap-2 pb-4">
        <div className="h-12 w-12">
          <Logo />
        </div>
        {"Amici Color"->React.string}
      </div>
      <div className="flex flex-row">
        <div>
          <div className="flex flex-row gap-2">
            {[View_LC, View_SL, View_SV]
            ->Array.map(v => {
              let isSelected = view == v
              <button
                className={[
                  "px-2 rounded",
                  isSelected ? "bg-blue-600 text-white" : "bg-blue-200",
                ]->Array.join(" ")}
                onClick={_ => setView(_ => v)}>
                {v->viewName->React.string}
              </button>
            })
            ->React.array}
          </div>
          <div className="flex flex-col py-2">
            <div className="flex flex-row">
              <ViewGamut view={view} hues={picks} selectedHue selectedElement setSelectedElement />
              <YStack
                view={view}
                hues={picks}
                selectedElement
                setSelectedElement
                setSelectedHue
                selectedHue
              />
            </div>
            <XStack view={view} hues={picks} selectedElement setSelectedElement setSelectedHue />
            // <div className="flex flex-row gap-2 ">
            //   <HslSGamut hues={picks} selectedHue selectedElement />
            //   <HueLine hues={picks} selected={selectedHue} />
            // </div>
          </div>
        </div>
        // <div className="flex flex-row gap-2">
        //   {[HSL_L, LCH_L]
        //   ->Array.map(mode => {
        //     let isSelected = selectedMode == mode
        //     <button
        //       className={[
        //         "px-2 rounded",
        //         isSelected ? "bg-blue-600 text-white" : "bg-blue-200",
        //       ]->Array.join(" ")}
        //       onClick={_ => setSelectedMode(_ => mode)}>
        //       {mode->modeName->React.string}
        //     </button>
        //   })
        //   ->React.array}
        // </div>

        <div
          style={{
            display: "grid",
            gridTemplateColumns: `auto repeat(${shadeLen->Int.toString}, 3rem)`,
            gridTemplateRows: `auto repeat(${hueLen->Int.toString}, 3rem)`,
          }}
          className="py-6 w-fit h-fit">
          <div
            className="overflow-hidden"
            style={{
              display: "grid",
              gridRow: "2 / -1",
              gridColumn: "1 / 2",
              gridTemplateRows: "subgrid",
              gridTemplateColumns: "subgrid",
            }}>
            {picks
            ->Array.mapWithIndex((pick, i) => {
              let isLastRow = i == picks->Array.length - 1
              let onDelete = () => {
                setPicks(p_ => p_->Array.filter(v => v.id != pick.id))
                setSelectedHue(v => v->Option.flatMap(p => p == pick.id ? None : Some(p)))
              }

              let onAdd = () => {newInterHue(pick)}

              <div key={pick.id} className=" ">
                <div className="flex-row flex w-full justify-between items-center gap-2 h-full">
                  <DropdownMenu
                    items={[("Add Row Before", onAdd)]
                    ->Array.concat(isLastRow ? [("Add Row After", _ => newEndHue())] : [])
                    ->Array.concat([("Delete Row", onDelete)])}
                  />
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
                </div>
                <div className="flex flex-row justify-start gap-2 w-full" />
              </div>
            })
            ->React.array}
          </div>
          <div
            className="overflow-hidden"
            style={{
              display: "grid",
              gridRow: "1 / 2",
              gridColumn: "2 / -1",
              gridTemplateRows: "subgrid",
              gridTemplateColumns: "subgrid",
            }}>
            {shades
            ->Array.mapWithIndex((shade, i) => {
              let isLastColumn = i == picks->Array.length - 1

              let onDelete = () => {
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
              }

              let onAdd = () => newInterShade(shade)

              <div key={shade.id} className=" flex flex-col gap-2">
                <DropdownMenu
                  items={[("Add Column Before", onAdd)]
                  ->Array.concat(isLastColumn ? [("Add Column After", _ => newEndShade())] : [])
                  ->Array.concat([("Delete Column", onDelete)])}
                />
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
              </div>
            })
            ->React.array}
          </div>
          <div
            style={{
              display: "grid",
              gridRow: "2 / -1",
              gridColumn: "2 / -1",
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
                  className="w-12 h-12 max-h-12 max-w-12 flex flex-row items-center justify-center cursor-pointer"
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
    </div>
  }
}

@react.component
let make = () => {
  <div className="p-6 min-h-screen bg-white">
    <Palette />
    // <Gamut />
  </div>
}
