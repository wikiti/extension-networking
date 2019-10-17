package;

import networking.utils.NetworkMode;

import openfl.Assets;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.events.MouseEvent;

/**
 * Singleton class that represents the main menu, which contains buttons to select
 * a networking mode.
 *
 * @author Daniel Herzog
 */
class Menu extends Sprite {
  /** Client button bitmap. **/
  public static inline var BITMAP_CLIENT: String = 'img/client.png';

  /** Server button bitmap. **/
  public static inline var BITMAP_SERVER: String = 'img/server.png';

  /** Singleton instance. **/
  private static var s_instance: Menu;

  /** Singleton getter. **/
  public static function getInstance(): Menu {
    if (s_instance == null) s_instance = new Menu();
    return s_instance;
  }

  /** Client button sprite wrapper. **/
  private var _client_button: Sprite;

  /** Server button sprite wrapper. **/
  private var _server_button: Sprite;

  /**
   * Create a menu, and initialize everything. But don't show the buttons!
   */
  private function new() {
    super();

    x = Lib.current.stage.stageWidth / 2.0;
    y = Lib.current.stage.stageHeight / 2.0;

    _client_button = new Sprite();
    _server_button = new Sprite();

    var bm = new Bitmap(Assets.getBitmapData(BITMAP_CLIENT));
    bm.x -= bm.width * 0.5;
    bm.y -= bm.height * 0.5;
    _client_button.addChild(bm);

    bm = new Bitmap(Assets.getBitmapData(BITMAP_SERVER));
    bm.x -= bm.width * 0.5;
    bm.y -= bm.height * 0.5;
    _server_button.addChild(bm);

    _client_button.x += _client_button.width * 0.75;
    _server_button.x -= _server_button.width * 0.75;
  }

  /**
   * Show the buttons, and add the event listeners.
   */
  public function show() {
    addChild(_client_button);
    addChild(_server_button);

    _client_button.addEventListener(MouseEvent.CLICK, onClickClient);
    _server_button.addEventListener(MouseEvent.CLICK, onClickServer);
  }

  /**
   * Hide the buttons, and remove the event listeners.
   */
  public function hide() {
    removeChild(_client_button);
    removeChild(_server_button);

    _client_button.removeEventListener(MouseEvent.CLICK, onClickClient);
    _server_button.removeEventListener(MouseEvent.CLICK, onClickServer);
  }

  /**
   * Click event handler for the client button.
   *
   * This method will create a client game session.
   *
   * @param e Mouse click event.
   */
  private function onClickClient(e: MouseEvent) {
    hide();
    Game.getInstance().start(NetworkMode.CLIENT, { ip: '127.0.0.1', port: 9999 });
  }

  /**
   * Click event handler for the server button.
   *
   * This method will create a server game session.
   *
   * @param e Mouse click event.
   */
  private function onClickServer(e: MouseEvent) {
    hide();
    Game.getInstance().start(NetworkMode.SERVER, { ip: '0.0.0.0', port: 9999, max_connections: 1 });
  }
}
