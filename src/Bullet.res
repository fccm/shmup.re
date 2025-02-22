module Canvas = Canvas2d

let color = "white";

let speed = 18.;

let maxCount = 15;

let angleRange = Js.Math._PI /. 32.;

let draw = (ctx, (x, y, _)) => {
  Canvas.fillStyle(ctx, color)
  Canvas.fillRect(ctx, ~x, ~y, ~w=2., ~h=4.)
};

let tick = ((x, y, angle)) => {
  let dx = speed *. Js.Math.sin(angle);
  let dy = speed *. Js.Math.cos(angle);
  (x +. dx, y -. dy, angle)
};

let isVisible = ((_, y, _)) => y > 0.;

let tryToShoot = (bullets, (x, y)) => {
  let angle = Js.Math.random() *. angleRange -. angleRange /. 2.;
  List.length(bullets) >= maxCount ? bullets : List.append(bullets, list{(x, y, angle)});
};
