package networking.utils;

/**
 * Generic utils.
 *
 * @author Daniel Herzog
 */
class Utils {
  private function new() { }

  /**
   * Generate a unique string or uuid.
   *
   * @return A random string with the uuid format. For example: FAF9D2EA-5A8B-77F4-3B0C-9406A5C47F51
   */
  public static function guid(): String {
    return s4() + s4() + '-' + s4() + '-' + s4() + '-' + s4() + '-' + s4() + s4() + s4();
  }

  private static function s4(): String {
    return StringTools.hex(Math.floor((1 + Math.random()) * 0x10000)).substr(1);
  }
}