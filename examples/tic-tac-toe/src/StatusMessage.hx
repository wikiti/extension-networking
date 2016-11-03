package;

import openfl.Lib;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;

/**
 * Singleton class to display messages to the user.
 *
 * @author Daniel Herzog
 */
class StatusMessage extends Sprite {
  /** Singleton instance. **/
  private static var s_instance: StatusMessage;

  /** Singleton getter. **/
  public static function getInstance(): StatusMessage {
    if (s_instance == null) s_instance = new StatusMessage();
    return s_instance;
  }

  /** Textfield which will contain the message. **/
  private var _status_text: TextField;

  /**
   * Create a new status message, and initialize the wrapper textfield.
   */
  private function new() {
    super();

    _status_text = new TextField();
    _status_text.defaultTextFormat = new TextFormat('_sans', 24, 0xE74C3C, true);
    _status_text.visible = false;
    _status_text.autoSize = TextFieldAutoSize.RIGHT;
    _status_text.width = 0;

    setText();
    addChild(_status_text);
  }

  /**
   * Display a given text. If no text is present, then the status message will hide.
   *
   * @param msg Message to show. Can be `null`.
   */
  public function setText(msg: String = null) {
    if (msg == null) {
      _status_text.visible = false;
    }
    else {
      _status_text.visible = true;
      _status_text.text = msg;
      center();
    }
  }

  /**
   * Center the text on the screen.
   * - Horizontal align: center.
   * - Vertical align: bottom.
   */
  private function center() {
    _status_text.y = Lib.current.stage.stageHeight - _status_text.height;
    _status_text.x = (Lib.current.stage.stageWidth - _status_text.width) * 0.5;
  }
}