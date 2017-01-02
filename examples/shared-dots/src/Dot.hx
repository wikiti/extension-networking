package;

import openfl.display.Sprite;

typedef Color = Null<Int>;

/**
 * ...
 * @author
 */
class Dot extends Sprite {
  private static inline var RADIUS: Float = 10;

  public var color(default, null): Color;

  public function new(c: Color = null) {
    super();

    if(c == null) c = generateColor();
    color = c;

    redraw();
    moveTo(Math.random() * Main.WIDTH, Math.random() * Main.HEIGHT);
  }

  public function moveTo(px: Float, py: Float) {
    x = px;
    y = py;
  }

  private function redraw() {
    graphics.clear();
    graphics.beginFill(color);
    graphics.drawCircle(0, 0, RADIUS);
    graphics.endFill();
  }

  private function generateColor(): Color {
    var red = Math.floor(Math.random() * 256);
    var green = Math.floor(Math.random() * 256);
    var blue = Math.floor(Math.random() * 256);

    return (red << 16) | (green << 8) | blue;
  }
}