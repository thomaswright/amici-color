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

@val @scope("window")
external devicePixelRatio: float = "devicePixelRatio"

@val @scope("document")
external addKeyboardListner: (string, ReactEvent.Keyboard.t => unit) => unit = "addEventListener"

@val @scope("document")
external removeKeyboardListner: (string, ReactEvent.Keyboard.t => unit) => unit =
  "removeEventListener"

@val @scope("document")
external addMouseListner: (string, ReactEvent.Mouse.t => unit) => unit = "addEventListener"

@val @scope("document")
external removeMouseListner: (string, ReactEvent.Mouse.t => unit) => unit = "removeEventListener"

@val @scope("document")
external addTouchListner: (string, ReactEvent.Touch.t => unit) => unit = "addEventListener"

@val @scope("document")
external removeTouchListner: (string, ReactEvent.Touch.t => unit) => unit = "removeEventListener"

@send
external getBoundingClientRect: Dom.element => {"left": int, "top": int} = "getBoundingClientRect"

let chromaBound = 0.36

module Types = {
  type shade = {id: string, name: string}

  type element = {
    id: string,
    // shadeId: string,
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

  type adjustmentMode = | @as("HSL_L") HSL_L | @as("LCH_L") LCH_L

  type view = | @as("View_LC") View_LC | @as("View_SV") View_SV | @as("View_SL") View_SL
}

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
