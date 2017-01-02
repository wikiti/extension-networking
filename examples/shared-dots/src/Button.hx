package;
import flash.display.Bitmap;
import flash.display.Sprite;
import openfl.Assets;
import openfl.events.MouseEvent;

/**
 * ...
 * @author
 */
class Button extends Sprite {
  private var _bitmap: Bitmap;

  public function new(file: String, callback: MouseEvent->Void) {
    super();

    _bitmap = new Bitmap(Assets.getBitmapData(file));
    addChild(_bitmap);

    this.addEventListener(MouseEvent.CLICK, function(e: MouseEvent) {
      e.stopPropagation();
      callback(e);
    });
  }

}