package networking.utils;

import networking.sessions.items.ClientObject;
import networking.sessions.items.ServerObject;
import networking.utils.*;

/**
 * Message generated for networking
 *
 * The messages are sent as serialized one-line-strings. For example, a message has the following structure:
 *
 *     {
 *       metadata: {
 *         server: { ... },
 *         client: { ... },
 *         action: 'message'
 *       },
 *       data: {
 *         test: "test"
 *       }
 *     }
 *
 * @author Daniel Herzog
 */
class NetworkMessage {
  private var server: ServerObject;
  private var client: ClientObject;
  private var data: Dynamic;

  /**
   * Create a message object as a Dynamic object.
   *
   * @param server Server info (optional).
   * @param client Client info.
   * @param data Data content. Whatever format you like.
   * @return Generated Dynamic object.
   */
  public static function createRaw(server: ServerObject, client: ClientObject, data: Dynamic = null): Dynamic {
    return new NetworkMessage(server, client, data).toMessage();
  }

  /**
   * Create a low-level message object as a serialized (string) object.
   *
   * @param server Server info (optional).
   * @param client Client info.
   * @param data Data content. Whatever format you like. Should have at least the attribute 'verb', which is a high-level identifier to handle the message.
   * @return Generated serialized (string) object.
   */
  public static function create(server: ServerObject, client: ClientObject, data: Dynamic = null): String {
    return serialize(createRaw(server, client, data));
  }

  /**
   * Serialize an object.
   *
   * @param obj Object to serialize.
   * @return Generated serialized string (bytes).
   */
  public static inline function serialize(obj: Dynamic): String {
    return NetworkSerializer.serialize(obj);
  }

  /**
   * Parse a string to a Dynamic object.
   *
   * @param obj String to parse.
   * @return Generated Dynamic object.
   */
  public static function parse(obj: String): Dynamic {
    return NetworkSerializer.unserialize(obj);
  }

  // Private constructor. Use static methods!
  private function new(server_info: ServerObject, client_info: ClientObject, data: Dynamic = null) {
    this.server = server_info;
    this.client = client_info;
    this.data = data != null ? data : {};
  }

  private function toMessage(): Dynamic {
    return { metadata: { client: (client != null ? client.object : null), server: (server != null ? server.object : null) }, data: data }
  }
}