package;

import networking.Network;
import networking.sessions.Session;
import networking.utils.NetworkEvent;
import networking.utils.NetworkMode;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.Lib;
import openfl.events.MouseEvent;

/**
 * Simple application to test the networking extension. This simple application will
 * share the position of an display object (bitmap) between two executables: a server and a client.
 *
 * The sprite wrapper objects for bitmaps are to handle click events, which are not supported
 * by Bitmap.
 *
 * Please, read the console (stdout) logs to understand the fired events.
 *
 * @author Daniel Herzog
 */
class Main extends Sprite {

  /** Cube drawn on screen. **/
  public var cube: Bitmap;

  /**
   * Create the main object container.
   */
  public function new() {
    super();
    setupMenuButtons();
  }

  /**
   * Setup menu buttons (client and server). This method only adds buttons to the
   * screen, so it's not important. Just ignore it!
   */
  private function setupMenuButtons() {
    this.removeChildren();

    // Add the client button to the screen.
    var client_button = new Bitmap(Assets.getBitmapData('img/client.png'));
    client_button.x = Lib.current.stage.stageWidth * 0.33 - client_button.width * 0.5;
    client_button.y = (Lib.current.stage.stageHeight - client_button.height) * 0.5;
    var client_button_wrapper = new Sprite();
    client_button_wrapper.addEventListener(MouseEvent.CLICK, function(e: MouseEvent) {
      e.stopPropagation();
      runClient(); // <-- Run server with a button click.
    });
    client_button_wrapper.addChild(client_button);
    this.addChild(client_button_wrapper);

    // Add the server button to the screen.
    var server_button = new Bitmap(Assets.getBitmapData('img/server.png'));
    server_button.x = Lib.current.stage.stageWidth * 0.66 - server_button.width * 0.5;
    server_button.y = (Lib.current.stage.stageHeight - server_button.height) * 0.5;
    var server_button_wrapper = new Sprite();
    server_button_wrapper.addEventListener(MouseEvent.CLICK, function(e: MouseEvent) {
      e.stopPropagation();
      runServer(); // <-- Run client with a button click.
    });
    server_button_wrapper.addChild(server_button);
    this.addChild(server_button_wrapper);
  }

  /**
   * Run the application in server mode. This methid will be executed after
   * clicking on the `Server` button.
   */
  private function runServer() {
    // Remove the sprites, and add an orange cube.
    this.removeChildren();
    cube = new Bitmap(Assets.getBitmapData('img/cube_server.png'));
    this.addChild(cube);

    // Create the server...
    var server = Network.registerSession(NetworkMode.SERVER, { ip: '0.0.0.0', port: '8888' });

      // ... add some event listeners...

    // When clicking on the screen...
    Lib.current.stage.addEventListener(MouseEvent.CLICK, onScreenClick);

    // When a client is connected...
    server.addEventListener(NetworkEvent.CONNECTED, function(event: NetworkEvent) {
      // Send the current position of the cube.
      event.client.send({ x: cube.x, y: cube.y });
    });

    // When recieving a message from a client...
    server.addEventListener(NetworkEvent.MESSAGE_RECEIVED, function(event: NetworkEvent) {
      // ... update the position...
      cube.x = event.data.x;
      cube.y = event.data.y;
      // ... and broadcast the location to all clients.
      server.send({ x: cube.x, y: cube.y });
    });

      // ... and run it!
    server.start();

    // Show back button
    setupBackButton();
  }

  /**
   * Run the application in client mode. This methid will be executed after
   * clicking on the `Client` button.
   */
  private function runClient() {
    // Remove the sprites, and add a blue cube.
    this.removeChildren();
    cube = new Bitmap(Assets.getBitmapData('img/cube_client.png'));
    this.addChild(cube);

      // Create the client...
    var client = Network.registerSession(NetworkMode.CLIENT, { ip: '127.0.0.1', port: '8888' });

      // ... add some event listeners...

    // When clicking on the screen...
    Lib.current.stage.addEventListener(MouseEvent.CLICK, onScreenClick);

    // When a client recieves a message ...
    client.addEventListener(NetworkEvent.MESSAGE_RECEIVED, function(event: NetworkEvent) {
      // ... update the cube's position.
      cube.x = event.data.x;
      cube.y = event.data.y;
    });

      // ... and run it!
    client.start();

    // Show back button
    setupBackButton();
  }

  /**
   * Handle screen clicks events (server and client).
   * @param e Mouse event.
   */
  private function onScreenClick(event: MouseEvent) {
    // Fetch the current session (first one)
    var session = Network.sessions[0];

    switch(session.mode) {
      // If we're the server...
      case NetworkMode.SERVER:
        // ... move the cube to the click location...
        cube.x = event.localX - cube.width * 0.5;
        cube.y = event.localY - cube.height * 0.5;

        // ... and send information to all clients about where is it. Note that there is a `verb`
        // parameter to identify messages types.
        session.send({ x: event.localX - cube.width * 0.5, y: event.localY - cube.height * 0.5 });

      // If we're the client...
      case NetworkMode.CLIENT:
        // ... send a message to the server about the current location. Note that the position is not updated!
        // It will be updated after the server has processed the request.
        session.send({ x: event.localX - cube.width * 0.5, y: event.localY - cube.height * 0.5 });
    }
  }

  /**
   * This method will restart the application, and move back to the main menu.
   */
  private function setupBackButton() {
    // Setup a `back` button to
    var back_button = new Bitmap(Assets.getBitmapData('img/back.png'));
    back_button.x = (Lib.current.stage.stageWidth - back_button.width) * 0.5;
    back_button.y = Lib.current.stage.stageHeight - back_button.height * 1.5;
    var back_button_wrapper = new Sprite();
    back_button_wrapper.addEventListener(MouseEvent.CLICK, function(e: MouseEvent) {
      e.stopPropagation();

      // Remove event listeners
      Lib.current.stage.removeEventListener(MouseEvent.CLICK, onScreenClick);

      // Destroy last session (client or server).
      Network.destroySession(Network.sessions[0]);

      // Show main menu
      setupMenuButtons();
    });

    back_button_wrapper.addChild(back_button);
    this.addChild(back_button_wrapper);
  }
}
