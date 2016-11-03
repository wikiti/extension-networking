package;

import networking.Network;
import networking.sessions.Session;
import networking.utils.NetworkEvent;
import networking.utils.NetworkMode;

import openfl.events.MouseEvent;


/**
 * This singleton class represents the logic for a "game" session.
 *
 * This will be the handler of the networking session and game rules.
 * There are two roles in a game session:
 * - Server or host: Will use "O" pieces, and will handle ALL logic: moves, turns, winning moves...
 * - Client: Will use "X" pieces, and will only send click points to the server.
 *
 * The server will follow this flow:
 * - Wait for a client to connect.
 * - While the game is not over:
 *   - If it's the server's turn:
 *     - Wait for the server to put a new piece, and notify the client.
 *   - If it's the client's turn:
 *     - Wait for the client to put a new piece, and notify him.
 * - Show the winner of the game.
 *
 * The client will follow this flow:
 * - Try to connect to a server.
 * - While the game is not over:
 *   - Send a message to the server if the client clicks on the screen.
 *   - Recieve messages from the server, and process them.
 *
 * @author Daniel Herzog
 */
class Game {
  /** Server's piece type ("O"). **/
  private static inline var SERVER_PIECE_TYPE: String = "O";

  /** Client's piece type ("X"). **/
  private static inline var CLIENT_PIECE_TYPE: String = "X";

  /** Gameover state (winner). **/
  private static inline var GAMEOVER_WINNER: String = "winner";

  /** Gameover state (loser). **/
  private static inline var GAMEOVER_LOSER: String = "loser";

  /** Gameover state (draw). **/
  private static inline var GAMEOVER_DRAW: String = "draw";

  /** Singleton instance of this class. **/
  private static var s_instance: Game;

  /** Singleton getter. **/
  public static function getInstance(): Game {
    if (s_instance == null) s_instance = new Game();
    return s_instance;
  }

  /** Current networking session. **/
  private var _session: Session;

  /** Current turn. May be "O" (server) or "X" (client). **/
  private var _current_turn: String;

  /**
   * Empty constructor.
   */
  private function new() {}

  /**
   * Start a new game either as a server or as a client.
   * This method will initialize the networking session, and add the required event listeners.
   *
   * If the current session is a server, a random initial turn ("X" or "O") will be selected.
   *
   * @param mode Networking mode.
   * @param params Networking parameters.
   */
  public function start(mode: NetworkMode, params: Dynamic) {
    StatusMessage.getInstance().setText();
    Board.getInstance().reset();

    _session = Network.registerSession(mode, params);

    _session.addEventListener(NetworkEvent.INIT_SUCCESS, onInit);
    _session.addEventListener(NetworkEvent.INIT_FAILURE, onFailure);
    _session.addEventListener(NetworkEvent.CONNECTED, onConnected);
    _session.addEventListener(NetworkEvent.DISCONNECTED, onDisconnect);
    _session.addEventListener(NetworkEvent.MESSAGE_RECEIVED, onMessageRecieved);

    if (mode == NetworkMode.SERVER) toggleTurn();

    _session.start();
  }

  /**
   * Finish the current game session. This method will close the networking session,
   * and bring back the main menu.
   *
   * @param msg Message to show on the screen after the game is finished.
   */
  public function finish(msg: String = null) {
    StatusMessage.getInstance().setText(msg);
    Menu.getInstance().show();
    Board.getInstance().removeEventListener(MouseEvent.CLICK, onClick);

    Network.destroySession(_session);
  }

  /**
   * Toggle the current turn. This method should be called only from the server.
   *
   * - If the current turn is "X", then this method will swap it to "O".
   * - If the current turn is "O", then this method will swap it to "X".
   * - If the current turn is null, then this method will change to "O" or "X" (random initialization).
   */
  private function toggleTurn() {
    if (_current_turn == null) {
      _current_turn = [SERVER_PIECE_TYPE, CLIENT_PIECE_TYPE][Math.round(Math.random())];
    }
    else if (_current_turn == CLIENT_PIECE_TYPE) {
      _current_turn = SERVER_PIECE_TYPE;
    }
    else {
      _current_turn = CLIENT_PIECE_TYPE;
    }
  }

  /**
   * Show a game over message, and remove click event listeners.
   *
   * @param state Game over state. Can be GAMEOVER_WINNER, GAMEOVER_LOSER or GAMEOVER_DRAW.
   */
  private function gameOverMessage(state: String) {
    Board.getInstance().removeEventListener(MouseEvent.CLICK, onClick);

    if(state == GAMEOVER_WINNER) {
      StatusMessage.getInstance().setText('You win!');
    }
    else if(state == GAMEOVER_LOSER) {
      StatusMessage.getInstance().setText('You lose...');
    }
    else if(state == GAMEOVER_DRAW) {
      StatusMessage.getInstance().setText('Draw');
    }
  }

  /**
   * Show a "Your turn" message.
   */
  private function yourTurn() {
    StatusMessage.getInstance().setText('Your turn');
  }

  /**
   * Remove "Your turn" message.
   */
  private function hisTurn() {
    StatusMessage.getInstance().setText();
  }

  /**
   * Networking - initialize event handler.
   *
   * @param e Networking event.
   */
  private function onInit(e: NetworkEvent) {
    switch(_session.mode) {
      case CLIENT:
        // If we're a client, remove status text, and add click event listeners.
        StatusMessage.getInstance().setText();
        Board.getInstance().addEventListener(MouseEvent.CLICK, onClick);

      case SERVER:
        // If we're a server, let's wait for a client, updating the status text.
        StatusMessage.getInstance().setText("Waiting for client to connect...");
    }
  }

  /**
   * Networking - failure event handler.
   *
   * @param e Networking event.
   */
  private function onFailure(e: NetworkEvent) {
    switch(_session.mode) {
      case SERVER:
        // If we're a server, and we can't initialize the server, close the game session, and show an error.
        finish("Unable to create server");

      case CLIENT:
        // If we're a client, and we can't connect to the server, close the game session, and show an error.
        finish("Unable to connect to host");
    }
  }

  /**
   * Networking - connected event handler.
   *
   * @param e Networking event.
   */
  private function onConnected(e: NetworkEvent) {
    switch(_session.mode) {
      case SERVER:
        // If we're a server, and a client connects:

        // Remove the status text.
        StatusMessage.getInstance().setText();

        // Add click event listeners.
        Board.getInstance().addEventListener(MouseEvent.CLICK, onClick);

        // Handle initial turn.
        if (_current_turn == SERVER_PIECE_TYPE) {
          _session.send({ verb: "my_turn" });
          yourTurn();
        }
        else {
          _session.send({ verb: "your_turn" });
          hisTurn();
        }

      case CLIENT:
        // If we're a client, do nothing (logic is already on `onInitialize()`).
    }
  }

  /**
   * Networking - disconnected event handler.
   *
   * @param e Networking event.
   */
  private function onDisconnect(e: NetworkEvent) {
    // Client: disconnected from the server.
    // Server: client disconnected.
    // In both cases. finish the game session, and show a "Disconnected" message.
    finish("Disconnected");
  }

  /**
   * Networking - messages event handler.
   *
   * @param e Networking event.
   */
  private function onMessageRecieved(e: NetworkEvent) {
    switch(_session.mode) {
      case SERVER:
        // If we're a server...
        switch(e.verb) {
          // Handle the click events. The message data has this structure: { verb: 'click', row: 1, col: 0 }
          case "click":
            // Ignore the clicks if it's not his turn.
            if (_current_turn != CLIENT_PIECE_TYPE) return;

            // If the client can place the piece in that position...
            if (Board.getInstance().canPlacePieceOn(e.data.row, e.data.col)) {
              // Add that piece.
              Board.getInstance().addPiece(CLIENT_PIECE_TYPE, e.data.row, e.data.col);
              // Say the client to put that piece into the board.
              _session.send({ verb: "new_piece", type: CLIENT_PIECE_TYPE, row: e.data.row, col: e.data.col });

              // If the client wins...
              if (Board.getInstance().winningMove(CLIENT_PIECE_TYPE, e.data.row, e.data.col)) {
                // That means we lose :(
                gameOverMessage(GAMEOVER_LOSER);
                _session.send({ verb: "game_over", winner: CLIENT_PIECE_TYPE });
              }
              // If draw...
              else if (Board.getInstance().draw()) {
                gameOverMessage(GAMEOVER_DRAW);
                // Tell the client! { winner: '' } means it's a draw.
                _session.send({ verb: "game_over", winner: '' });
              }
              // Otherwise, the match is still on!
              else {
                // It's the server's turn.
                _session.send({ verb: "my_turn" });
                toggleTurn();
                yourTurn();
              }
            }
        }

      // If we're a client...
      case CLIENT:
        switch(e.verb) {
          // Add new pieces to the board. { verb: 'new_piece', type: 'X', row: 0, col: 2 }
          case "new_piece":
            Board.getInstance().addPiece(e.data.type, e.data.row, e.data.col);

          // Game over! { verb: 'game_over', winner: 'O' }
          case "game_over":
            switch(e.data.winner) {
              case CLIENT_PIECE_TYPE:
                // We've won! :)
                gameOverMessage(GAMEOVER_WINNER);

              case SERVER_PIECE_TYPE:
                // The server has won :(
                gameOverMessage(GAMEOVER_LOSER);

              default:
                // Draw :|
                gameOverMessage(GAMEOVER_DRAW);
            }

          // Clien'ts turn. Show a "Your turn" message. { verb: 'your_turn' }
          case "your_turn":
            _current_turn = CLIENT_PIECE_TYPE;
            StatusMessage.getInstance().setText('Your turn');

          // Server's turn. Hide "Your turn" message. { verb: 'my_turn' }
          case "my_turn":
            _current_turn = SERVER_PIECE_TYPE;
            StatusMessage.getInstance().setText();
        }
    }
  }

  /**
   * Handle click events. This should only be handled if both parts are online.
   *
   * @param e Mouse click event.
   */
  private function onClick(e: MouseEvent) {
    switch(_session.mode) {
      // If we're the server...
      case SERVER:
        // Ignore mouse click if it isn't our turn.
        if(_current_turn != SERVER_PIECE_TYPE) return;

        // Transform the click point into a board position (row, col).
        var point = Board.getInstance().screenToPoint(e.localX, e.localY);

        // If we can put our piece in that position...
        if (Board.getInstance().canPlacePieceOn(point[0], point[1])) {
          // Add the piece, and notify the client.
          Board.getInstance().addPiece(SERVER_PIECE_TYPE, point[0], point[1]);
          _session.send({ verb: "new_piece", type: SERVER_PIECE_TYPE, row: point[0], col: point[1] });

          // If the server wins...
          if (Board.getInstance().winningMove(SERVER_PIECE_TYPE, point[0], point[1])) {
            // Show a message, and notify the client.
            gameOverMessage(GAMEOVER_WINNER);
            _session.send({ verb: "game_over", winner: SERVER_PIECE_TYPE });
          }
          // If draw
          else if (Board.getInstance().draw()) {
            // Show a message, and notify the client.
            gameOverMessage(GAMEOVER_DRAW);
            _session.send({ verb: "game_over", winner: '' });
          }
          // Otherwise, the match is still on!
          else {
            // It's client's turn!
            _session.send({ verb: "your_turn" });
            toggleTurn();
            hisTurn();
          }
        }

      // If we're a client...
      case CLIENT:
        // If it's not our turn, ignore that click.
        if(_current_turn != CLIENT_PIECE_TYPE) return;

        // Send to the server the position of the clicked box!
        var point = Board.getInstance().screenToPoint(e.localX, e.localY);
        _session.send({ verb: 'click', row: point[0], col: point[1] });
    }
  }
}