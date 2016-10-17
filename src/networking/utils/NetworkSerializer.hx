package networking.utils;

import haxe.Serializer;
import haxe.Unserializer;

/**
 * Handle objects serialization. Actually, it works by using Haxe Serialization format.
 *
 * @author Daniel Herzog
 */
class NetworkSerializer {
  private function new() { }

  /**
   * Serialize an object with `haxe.Serializer` into a byte string.
   *
   * @param obj Object to serialize.
   * @return Generated dynamic object.
   */
  public static inline function serialize(obj: Dynamic): String {
    var handler: Serializer = new Serializer();
    handler.serialize(obj);
    return handler.toString();
  }

  /**
   * Unserialize a string (parse) with `haxe.Unserializer` into a haxe object.
   *
   * @param obj String to unserialize.
   * @return Generated dynamic object.
   */
  public static inline function unserialize(obj: String): Dynamic {
    var handler: Unserializer = new Unserializer(obj);
    return handler.unserialize();
  }
}
