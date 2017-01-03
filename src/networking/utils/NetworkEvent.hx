package networking.utils;

import networking.sessions.Session;
import networking.sessions.items.ClientObject;

import openfl.events.Event;

/**
 * A class to wrap network events.
 *
 * @author Daniel Herzog
 */
class NetworkEvent extends Event {
    // Messages

  /** Message sent. **/
  public static inline var MESSAGE_SENT: String = "NETWORK_EVENT_MESSAGE_SENT";
  /** Message received. **/
  public static inline var MESSAGE_RECEIVED: String = "NETWORK_EVENT_MESSAGE_RECEIVED";
  /** Message sent failed. **/
  public static inline var MESSAGE_SENT_FAILED: String = "NETWORK_EVENT_MESSAGE_SENT_FAILED";
  /** Message broadcasted. Server only. **/
  public static inline var MESSAGE_BROADCAST: String = "NETWORK_EVENT_SV_MESSAGE_BROADCAST";
  /** Broadcasted message failure. Server only. **/
  public static inline var MESSAGE_BROADCAST_FAILED: String = "NETWORK_EVENT_SV_MESSAGE_BROADCAST_FAILED";

    // Init Status

  /** Networking init success. Server: binded; Client: connected to server. **/
  public static inline var INIT_SUCCESS: String = "NETWORK_EVENT_INIT_SUCCESS";
  /** Networking init failed. Server: binded; Client: could not connect to server. **/
  public static inline var INIT_FAILURE: String = "NETWORK_EVENT_INIT_FAILURE";

    // Closing status

  /** Networking init success. Server: session closed; Client: session closed. **/
  public static inline var CLOSED: String = "NETWORK_EVENT_CLOSED";

    // Connections

  /** Connection stablished. Server: new client connected; Client: connected to server. **/
  public static inline var CONNECTED: String = "NETWORK_EVENT_CONNECTED";
  /** Connection removed. Server: client disconnected; Client: disconnected from server. **/
  public static inline var DISCONNECTED: String = "NETWORK_EVENT_DISCONNECTED"; // Server: client disconnected; Client: disconnected

    // Error handling

  /** Server is full. Server: a client tryed to connect to the server (full); Client: tried to connect into a full server. **/
  public static inline var SERVER_FULL: String = "NETWORK_EVENT_SERVER_FULL";

  /** Security errors. Related to flash clients. **/
  public static inline var SECURITY_ERROR: String = "NETWORK_EVENT_SECURITY_ERROR";

  /** Event data. A simple haxe object. **/
  public var netData(default, null): Dynamic;

  /** Current session. **/
  public var session(default, null): Session;

  /** Message data. **/
  public var data(get, null): Dynamic;

  /** Message metadata. **/
  public var metadata(get, null): Dynamic;

  /** Target ClientObject of the current event. **/
  public var client(get, null): ClientObject;

  /** Verb (action) of the current event. **/
  public var verb(get, null): String;

  /** The sender of the network message, if present. May be a Dynamic object with the following format: {  }. **/
  public var sender(get, null): Dynamic;

  /**
   * Generate a new event.
   *
   * @param label Event label.
   * @param session Session object.
   * @param netData Network data (message and metadata).
   * @param bubbles ...
   * @param cancelable ...
   */
  public function new(label: String, session: Session, netData: Dynamic = null, bubbles: Bool = false, cancelable: Bool = false) {
    super( label , bubbles, cancelable);
    this.netData = netData;
    this.session = session;
  }

  private function get_data(): Dynamic {
    return netData.message.data;
  }

  private function get_metadata(): Dynamic {
    return netData.message.metadata;
  }

  private function get_client(): ClientObject {
    var cl: ClientObject = netData.client != null ? netData.client : netData.obj;
    return cl;
  }

  private function get_verb(): String {
    return data.verb;
  }

  private function get_sender(): Dynamic {
    try {
      switch(session.mode) {
        case SERVER: return metadata.client;
        case CLIENT: return metadata.server;
      }
    }
    catch (e: Dynamic) {
      NetworkLogger.error(e);
      return null;
    }
  }
}