package;

import networking.Network;
import networking.sessions.Session;
import networking.sessions.items.ClientObject.Uuid;
import networking.utils.NetworkEvent;
import networking.utils.NetworkMode;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.Lib;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.ui.Keyboard;

/**
 * Simple application to show a background with shared dots. Each client will have its unique
 * color dot.
 *
 * Please, read the console (stdout) logs to understand the fired events.
 *
 * @author Daniel Herzog
 */
class Main extends Sprite {
  public static inline var WIDTH: Float = 600;
  public static inline var HEIGHT: Float = 400;

  private var _server_button: Button;
  private var _client_button: Button;
  private var _back_button: Button;

  private var _session: Session;

  /**
   * Store a dot (sprite) for each client, and map both with the client's uuid.
   */
  private var _dots: Map<Uuid, Dot>;

  /**
   * Create the main object container.
   */
  public function new() {
    super();
    _dots = new Map<Uuid, Dot>();

    setupButtons();
    showMenu();
  }

  /**
   * Setup menu buttons (client, server and back). This method only initialize some buttons,
   * so it's not important. Just ignore it!
   */
  private function setupButtons() {
    _server_button = new Button('img/server.png', function(e: MouseEvent) {
      showPlayground();
      runServer();
    });
    _server_button.x = Lib.current.stage.stageWidth * 0.66 - _server_button.width * 0.5;
    _server_button.y = (Lib.current.stage.stageHeight - _server_button.height) * 0.5;

    _client_button = new Button('img/client.png', function(e: MouseEvent) {
      showPlayground();
      runClient();
    });
    _client_button.x = Lib.current.stage.stageWidth * 0.33 - _client_button.width * 0.5;
    _client_button.y = (Lib.current.stage.stageHeight - _client_button.height) * 0.5;

    _back_button = new Button('img/back.png', function(e: MouseEvent) {
      Network.destroySession(Network.sessions[0]);
      showMenu();
    });
    _back_button.x = (Lib.current.stage.stageWidth - _back_button.width) * 0.5;
    _back_button.y = Lib.current.stage.stageHeight - _back_button.height * 1.5;
  }

  /**
   * Run the application in server mode. This methid will be executed after
   * clicking on the `Server` button.
   */
  private function runServer() {
    _session = Network.registerSession(NetworkMode.SERVER);

    // When the server starts
    _session.addEventListener(NetworkEvent.INIT_SUCCESS, function(event: NetworkEvent) {
      // Create the server's dot, and add it to the list.
      var dot: Dot = new Dot();
      addChild(dot);
      _dots[_session.uuid] = dot;

      // Add stage event listeners
      Lib.current.stage.addEventListener(Event.ENTER_FRAME, onFrame); // On each frame
      Lib.current.stage.addEventListener(MouseEvent.CLICK, onClick); // When a key is pressed
    });

    _session.addEventListener(NetworkEvent.CLOSED, function(event: NetworkEvent) {
      // Remove the stage event listeners
      Lib.current.stage.removeEventListener(Event.ENTER_FRAME, onFrame); // On each frame
      Lib.current.stage.removeEventListener(MouseEvent.CLICK, onClick); // When a key is pressed
    });

    // When a client connects
    _session.addEventListener(NetworkEvent.CONNECTED, function(event: NetworkEvent) {
      // Create a dot, and add it to the list.
      var dot: Dot = new Dot();
      addChild(dot);
      _dots[event.client.uuid] = dot;
    });

    // When a client disconnects
    _session.addEventListener(NetworkEvent.DISCONNECTED, function(event: NetworkEvent) {
      // Remove the dot of the client
      var dot: Dot = _dots[event.client.uuid];
      if (dot != null) {
        removeChild(dot);
        _dots.remove(event.client.uuid);
      }
    });

    // When a client moves
    _session.on("click", function(data: Dynamic, event: NetworkEvent) {
      // Update it's position
      var dot: Dot = _dots[event.client.uuid];
      if (dot != null) {
        dot.x = data.x;
        dot.y = data.y;
      }
    });

    _session.start();
  }

  /**
   * Run the application in client mode. This methid will be executed after
   * clicking on the `Client` button.
   */
  private function runClient() {
    _session = Network.registerSession(NetworkMode.CLIENT);

    // When connected to the server
    _session.addEventListener(NetworkEvent.CONNECTED, function(e: NetworkEvent) {
      Lib.current.stage.addEventListener(MouseEvent.CLICK, onClick); // When a key is pressed
    });

    // When disconnected from the server
    _session.addEventListener(NetworkEvent.DISCONNECTED, function(e: NetworkEvent) {
      Lib.current.stage.removeEventListener(MouseEvent.CLICK, onClick); // When a key is pressed
    });

    // When syncing data
    _session.on("sync", function(data: Dynamic, event: NetworkEvent) {
      // Remove all dots from stage
      for (dot in _dots) removeChild(dot);

      // Update all sprite position
      var array: Array<Dynamic> = cast(data.dots);
      for(obj in array) {
        var dot: Dot = _dots[obj.uuid];

        // If it exists, update it
        if (dot != null) {
          dot.x = obj.x;
          dot.y = obj.y;
        }
        // Otherwise, create it
        else {
          dot = new Dot(obj.color);
          dot.x = obj.x;
          dot.y = obj.y;
          _dots[obj.uuid] = dot;
        }

        // Add it to the screen
        addChild(dot);
      }
    });

    _session.start();
  }

  private function onFrame(event: Event) {
    // TODO: Return unless timer

    switch(_session.mode) {
      case SERVER:
        // Send sync information to all clients every 100ms
        _session.trigger("sync", serializeDots());

      default:
        // Do nothing
    }
  }

  private function onClick(event: MouseEvent) {
    var distance: Float = 6.0;
    var dot: Dot = _dots[_session.uuid];

    dot.moveTo(event.stageX, event.stageY);

    if(_session.mode == CLIENT)
      _session.trigger("click", { x: dot.x, y: dot.y });
  }

  private function serializeDots(): Dynamic {
    var array: Array<Dynamic> = [];

    for (uuid in _dots.keys()) {
      var dot: Dot = _dots[uuid];
      array.push({ uuid: uuid, color: dot.color, x: dot.x, y: dot.y });
    }

    return { dots: array };
  }

  /**
   * Exit the menu, and show the play ground.
   */
  private function showPlayground() {
    clear();
    addChild(_back_button);
  }

  /**
   * Exit the play ground, and show the menu buttons.
   */
  private function showMenu() {
    clear();
    addChild(_client_button);
    addChild(_server_button);
  }

  /**
   * Clear all the sprites.
   */
  private function clear() {
    removeChildren();
  }
}
