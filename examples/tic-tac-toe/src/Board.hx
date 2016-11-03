package;

import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.Sprite;

/**
 * A singleton class that visually represents a game board, which will contain multiple pieces.
 *
 * @author Daniel Herzog
 */
class Board extends Sprite {
  /** Singleton instance. **/
  private static var s_instance: Board;

  /** Singleton getter. **/
  public static function getInstance(): Board {
    if (s_instance == null) s_instance = new Board();
    return s_instance;
  }

  /** Size of the board; 3 by 3 **/
  public static inline var SIZE: Int = 3;

  /** Image file of the background. **/
  public static inline var BITMAP: String = "img/board.png";

  /** Horizontal pieces offset, in pixels. **/
  public static inline var PIECES_OFFSET_X: Int = 36;

  /** Vertical pieces offset, in pixels. **/
  public static inline var PIECES_OFFSET_Y: Int = 36;

  /** Background bitmap. **/
  private var _background: Bitmap;

  /** Wrapper for pieces (rendering level). Put the pieces inside this sprite, instead of directly into the board. **/
  private var _pieces_container: Sprite;

  /** Array to track the pieces (logic level). Note that the array is unidimensional. **/
  private var _pieces: Array<Piece>;

  /**
   * Create a new board with no pieces. This is a private method, so only singleton
   * instanced can be created.
   */
  private function new() {
    super();

    _background = new Bitmap(Assets.getBitmapData(BITMAP));
    _pieces_container = new Sprite();
    _pieces_container.x = PIECES_OFFSET_X;
    _pieces_container.y = PIECES_OFFSET_Y;

    addChild(_background);
    addChild(_pieces_container);

    reset();
  }

  /**
   * Restart the board by removing all pieces.
   */
  public function reset() {
    _pieces_container.removeChildren();
    _pieces = new Array<Piece>();
    for (i in 0...(SIZE * SIZE)) {
      _pieces.push(null);
    }
  }

  /**
   * Add a new piece to the board. Pieces can only be placed on empty positions.
   *
   * @param type Piece type to put. Can be "X" or "O".
   * @param row Row to put the piece on, where 0 is most-top row.
   * @param col Column to insert the piece on, where 0 is most-left column.
   */
  public function addPiece(type: String, row: Int, col: Int) {
    if (!canPlacePieceOn(row, col)) return;

    var piece = new Piece(type, row, col);

    _pieces[index(row, col)] = piece;
    _pieces_container.addChild(piece);
  }

  /**
   * Boolean checker to test if a piece can be placed in some position.
   *
   * @param row Row to try to put the piece on.
   * @param col Column to try to insert the piece on.
   * @return true if the piece can be placed; false otherwise.
   */
  public function canPlacePieceOn(row: Int, col: Int): Bool {
    return row >= 0 && row < SIZE && col >= 0 && col < SIZE && _pieces[index(row, col)] == null;
  }

  /**
   * Transform a screen coordinates (pixel) to a board position (row and column).
   *
   * @param mx Pixel horizontal position.
   * @param my Pixel vertical position.
   * @return An array with the column and the row as `[row, col]`.
   */
  public function screenToPoint(mx: Float, my: Float): Array<Int> {
    var col: Float = (mx - PIECES_OFFSET_X) / Piece.WIDTH;
    var row: Float = (my - PIECES_OFFSET_Y) / Piece.HEIGHT;

    return [Std.int(row), Std.int(col)];
  }

  /**
   * Test if the given move is a winning move (makes 3 in a row).
   *
   * This method will test if there is a winning move on the given row, column or diagonal.
   *
   * @param type Type of the given piece. Can be "X" or "O".
   * @param row Piece's row.
   * @param col Piece's column.
   * @return true if it's a winning move; false otherwise.
   */
  public function winningMove(type: String, row: Int, col: Int): Bool {
    return winningColumnMove(type, row, col) || winningRowMove(type, row, col) ||
      winningDiagonalMove(type, row, col) || winningReverseDiagonalMove(type, row, col);
  }

  /**
   * Check if the board its full of pieces (draw).
   *
   * This method should be called after `winningMove`.
   *
   * @return true if the board if full; false otherwise.
   */
  public function draw(): Bool {
    return _pieces_container.numChildren == SIZE * SIZE;
  }

  /**
   * Test if the given move is a column-winning move.
   *
   * @param type Type of the given piece. Can be "X" or "O".
   * @param row Piece's row.
   * @param col Piece's column.
   * @return true if it's a column-winning move; false otherwise.
   */
  private function winningColumnMove(type: String, row: Int, col: Int): Bool {
    var count = 0;

    for (i in 0...SIZE) {
      var piece = _pieces[index(row, i)];
      if (piece != null && piece.type == type) count += 1;
    }

    return count == SIZE;
  }

  /**
   * Test if the given move is a row-winning move.
   *
   * @param type Type of the given piece. Can be "X" or "O".
   * @param row Piece's row.
   * @param col Piece's column.
   * @return true if it's a row-winning move; false otherwise.
   */
  private function winningRowMove(type: String, row: Int, col: Int): Bool {
    var count = 0;

    for (i in 0...SIZE) {
      var piece = _pieces[index(i, col)];
      if (piece != null && piece.type == type) count += 1;
    }

    return count == SIZE;
  }

  /**
   * Test if the given move is a diagonal (descending) winning move.
   *
   * @param type Type of the given piece. Can be "X" or "O".
   * @param row Piece's row.
   * @param col Piece's column.
   * @return true if it's a diagonal (descending) winning move; false otherwise.
   */
  private function winningDiagonalMove(type: String, row: Int, col: Int): Bool {
    // There are only two diagonals
    var count = 0;

    for (i in 0...SIZE) {
      var piece = _pieces[index(i, i)];
      if (piece != null && piece.type == type) count += 1;
    }

    return count == SIZE;
  }

  /**
   * Test if the given move is a diagonal (ascending) winning move.
   *
   * @param type Type of the given piece. Can be "X" or "O".
   * @param row Piece's row.
   * @param col Piece's column.
   * @return true if it's a diagonal (ascending) winning move; false otherwise.
   */
  private function winningReverseDiagonalMove(type: String, row: Int, col: Int): Bool {
    var count = 0;

    for (i in 0...SIZE) {
      var piece = _pieces[index(i, SIZE - 1 - i)];
      if (piece != null && piece.type == type) count += 1;
    }

    return count == SIZE;
  }

  /**
   * Transform a pair (row, column) into an index, accessible by the unidimensiona array `_pieces`.
   *
   * @param row Row.
   * @param col Column.
   * @return Return and index corresponding to the position of (row, col) at `_pieces` array.
   */
  private function index(row: Int, col: Int): Int {
    return row * SIZE + col;
  }
}