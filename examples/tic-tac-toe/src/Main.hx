package;

import openfl.display.Sprite;

/**
 * Main wrapper class. Will contain all visible elements.
 *
 * @author Daniel Herzog
 */
class Main extends Sprite {
  /**
   * Run our game!
   */
  public function new() {
		super();

    // Order is important! Background, foreground and UI.
    addChild(Board.getInstance());
    addChild(Menu.getInstance());
    addChild(StatusMessage.getInstance());

    // Show the main menu.
    Menu.getInstance().show();
	}
}
