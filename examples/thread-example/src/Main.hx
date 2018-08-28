package;

import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.Lib;
import openfl.events.MouseEvent;

import cpp.vm.Thread;

/**
 * Thread test.
 *
 * @author Daniel Herzog
 */
class Main extends Sprite {

  var button_wrapper: Sprite;

  public function new() {
    super();
    setupMenuButtons();
  }

  private function setupMenuButtons() {
    this.removeChildren();

    // Add the client button to the screen.
    var button = new Bitmap(Assets.getBitmapData('img/cube.png'));
    button.x = Lib.current.stage.stageWidth * 0.5 - button.width * 0.5;
    button.y = (Lib.current.stage.stageHeight - button.height) * 0.5;
    button_wrapper = new Sprite();
    button_wrapper.addEventListener(MouseEvent.CLICK, function(e: MouseEvent) {
      e.stopPropagation();
      runThread();
    });
    button_wrapper.addChild(button);
    this.addChild(button_wrapper);
  }

  private function runThread() {
    Thread.create(threadHandler);
  }

  private function threadHandler() {
    trace("Thread start");
    button_wrapper.visible = false;

    var start = haxe.Timer.stamp();

    // Spin lock for 2 seconds
    while(haxe.Timer.stamp() < start + 2.0) {}

    button_wrapper.visible = true;
    trace("Thread end");
  }
}
