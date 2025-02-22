module V = Vector;

module Bullet = Bullet;

type t = {
  position: (float, float),
  velocity: (float, float),
  bullets: list<(float, float, float)>
};

let initialState = {position: (300., 500.), velocity: (0., 0.), bullets: list{}};

let maxSpeed = 7.; /* max # of pixels moved per tick */

let maxThrust = 10.; /* maximum impact of holding a key down */

let size = 20.;

let noseLength = size /. 2.;

let wingWidth = size /. 2.;

let tailLength = size /. 4.;

let color = "white";

let draw = (ctx, state) => {
  open Canvas2d;
  let {position: (x, y), velocity: (vx, vy)} = state;
  let w = wingWidth -. abs_float(vx /. 3.); /* narrower wings when moving to side ("tilting") */
  strokeStyle(ctx, color);
  ctx -> beginPath;
  ctx -> moveTo(~x, ~y=y +. tailLength);
  ctx -> lineTo(~x=x +. w, ~y=y +. noseLength);
  ctx -> lineTo(~x, ~y=y -. noseLength); /* Front end of the ship */
  ctx -> lineTo(~x=x -. w, ~y=y +. noseLength);
  ctx -> closePath;
  ctx -> stroke;
  /* Draw booster if ship is moving up */
  if (vy <= (-1.5)) {
    let boosterLength = -. vy *. 2.;
    ctx -> beginPath;
    ctx -> moveTo(~x, ~y=y +. noseLength);
    ctx -> lineTo(~x=x +. 3., ~y=y +. noseLength +. 2.);
    ctx -> lineTo(~x, ~y=y +. noseLength +. boosterLength);
    ctx -> lineTo(~x=x -. 3., ~y=y +. noseLength +. 2.);
    ctx -> closePath;
    ctx -> stroke
  };
  List.iter(Bullet.draw(ctx), state.bullets)
};

let ticksToThrust = (n) => min(maxThrust, float_of_int(n));

let enforceBoundaries = ((bwidth, bheight), (x, y)) => {
  let margin = 20.;
  let newX = x |> max(margin) |> min(bwidth -. margin);
  let newY = y |> max(margin) |> min(bheight -. margin);
  (newX, newY)
};

let tick = (state, cmds) => {
  let stateFromInputs =
    List.fold_left(
      (state, cmd) => {
        module I = Input;
        let {velocity: (vx, vy), position: (x, y)} = state;
        switch cmd {
        | I.ShipUp(n) => {...state, velocity: (vx, vy -. ticksToThrust(n))}
        | I.ShipDown(n) => {...state, velocity: (vx, vy +. ticksToThrust(n))}
        | I.ShipLeft(n) => {...state, velocity: (vx -. ticksToThrust(n), vy)}
        | I.ShipRight(n) => {...state, velocity: (vx +. ticksToThrust(n), vy)}
        | I.ShipShoot => {...state, bullets: Bullet.tryToShoot(state.bullets, (x, y))}
        }
      },
      state,
      cmds
    );
  let bullets = List.map(Bullet.tick, stateFromInputs.bullets) |> List.filter(Bullet.isVisible);
  let applyFriction = V.scale(0.9);
  let (vx, vy) = stateFromInputs.velocity -> applyFriction |> V.limitMagnitide(maxSpeed);
  let (x, y) = state.position;
  let position = (x +. vx, y +. vy) -> enforceBoundaries((V.worldWidth, V.worldHeight));
  {bullets, velocity: (vx, vy), position}
};
