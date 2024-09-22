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
@send external scale: (context, float, float) => unit = "scale"
