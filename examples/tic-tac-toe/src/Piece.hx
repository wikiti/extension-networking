package;

import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.Sprite;

/**
 * Class that represents a single piece on the Board.
 *
 * Note that this class need multiple instances, so it can be a singleton.
 *
 * @author Daniel Herzog
 */
class Piece extends Sprite {
  /** Bitmap file for "O" pieces. **/
  public static inline var BITMAP_O: String = 'img/piece_o.png';
  /** Bitmap file for "X" pieces. **/
  public static inline var BITMAP_X: String = 'img/piece_x.png';

  /** Piece's width, in pixels. **/
  public static inline var WIDTH: Int = 133;

  /** Piece's height, in pixels. **/
  public static inline var HEIGHT: Int = 133;

  /** Piece type. May be "X" or "O". **/
  public var type: String;
  /** Piece's row within the board. **/
  public var row: Int;
  /** Piece's column within the board. **/
  public var col: Int;

  /** Piece's bitmap. **/
  private var _bitmap: Bitmap;

  /**
   * Create a new piece.
   *
   * @param type Piece's type.
   * @param row Piece's row.
   * @param col Piece's column.
   */
  public function new(type: String, row: Int, col: Int) {
    super();

    this.type = type;
    this.row = row;
    this.col = col;

    loadBitmap();
    updatePos();
  }

  /**
   * Update the display position of the piece, given it's coordinates (row, col).
   */
  private function updatePos() {
    x = col * WIDTH;
    y = row * HEIGHT;
  }

  /**
   * Load bitmap data into _bitmap, and display it.
   */
  private function loadBitmap() {
    _bitmap = new Bitmap(Assets.getBitmapData(imageFile()));
    addChild(_bitmap);
  }

  /**
   * Retrieve the name of the file given its type ("X" or "O").
   *
   * Basically, it means:
   * - If the current piece is an "X", use `img/piece_x.png`.
   * - If the current piece is an "O", use `img/piece_o.png`.
   *
   * @return A string with the file name of the current piece.
   */
  private function imageFile(): String {
    switch(type) {
      case "O": return BITMAP_O;
      case "X": return BITMAP_X;
    }
    return null;
  }
}