package networking.sessions.items;

import networking.sessions.Session;
import networking.sessions.items.ServerObject;
import networking.sessions.server.Server;
import networking.utils.*;
import networking.utils.NetworkEvent;
import networking.utils.NetworkLogger;
import networking.utils.NetworkMessage;
import networking.utils.Utils;

import sys.net.Host;
import sys.net.Socket;

/** Uuid type (string). */
typedef Uuid = String;

/**
 * Low level client information class wrapper.
 *
 * @author Daniel Herzog
 */
class ClientObject {
  /** Networking socket. **/
  public var socket: Socket;

  /** Server related object. Can be null. **/
  public var server: Server;

  /** Boolean flag to check if the client object is active. **/
  public var active(get, null): Bool;

  /** Client uuid. **/
  public var uuid(default, null): Uuid;

  /** Client related object. A dynamic representation of the instances from this class. **/
  public var object(get, null): Dynamic;

  private var _peer_str(default, null): String;
  private var _session: Session;

  /**
   * Creates a new ClientObject. This constructor shouldn't be called manually
   *
   * @param session Reference to the current session.
   * @param uuid Current uuid. If it's `null` or `''`, a random uuid will be generated.
   * @param sv Server reference.
   * @param skt Socket reference. Optional.
   */
  public function new(session: Session, uuid: Uuid, sv: Server, skt: Socket = null) {
    this.server = sv;
    this.socket = skt;
    this.uuid = uuid;

    _peer_str = '?:?';
    _session = session;
  }

  /**
   * Represent the ClientObject as a string.
   * @return String representation of the ClientObject. For example: "client_uuid (127.0.0.1:9696)"
   */
  public function toString(): String {
    try {
      return '$uuid ($_peer_str)';
    }
    catch (e: Dynamic) {
      return '$uuid (?:?)';
    }
  }

  /**
   * Update the ClientObject's information.
   * @param uuid Unique identifier. Can be updated only once!
   */
  public function update(uuid: Uuid = null) {
    if(uuid != null) this.uuid = uuid;
  }

  /**
   * Initialize an empty networking socket, trying to connect to the given host.
   * The ClientObject will be marked as `active`.
   *
   * @param ip Ip host to connect into.
   * @param port TCP port to connect into.
   * @return true if the socket is created, false otherwise.
   */
  public function initializeSocket(ip: String, port: PortType): Bool {
    if (socket != null) return false;

    socket = new Socket();
    socket.connect(new Host(ip), port);
    return true;
  }

  /**
   * Destroy the current socket.
   *
   * @return true if the socket is closed, false otherwise.
   */
  public function destroySocket(): Bool {
    if (socket == null) return false;

    #if !neko
    socket.shutdown(true, true);
    #end
    socket.close();
    socket = null;
    return true;
  }

  /**
   * Initialize the current ClientObject. Should be called after it's connected to the server.
   */
  public function load() {
    try {
      var peer = socket.peer();
      _peer_str = '${peer.host}:${peer.port}';
    }
    catch(e: Dynamic) {
      _peer_str = '?:?';
    }

    generateUuid();
  }

  /**
   * Send a message to the server.
   *
   * @param msg Object to send to it.
   * @return true if the message was sent successfully to the server, false otherwise.
   */
  public function send(msg: Dynamic): Bool {
    try {
      if (socket == null) throw 'Socket is not initialized.';

      var server_info: ServerObject = server != null ? server.info : null;
      var raw_message: Dynamic = NetworkMessage.createRaw(server_info, this, msg);

      socket.output.writeString(NetworkMessage.serialize(raw_message) + '\n');
      _session.triggerEvent(NetworkEvent.MESSAGE_SENT, { obj: this, message: raw_message });
    }
    catch (e: Dynamic) {
      NetworkLogger.error(e);
      active = false;
      return false;
    }
    return true;
  }

  /**
   * Read a message from the current socket buffer. Pending messages will be handled on the events queue.
   */
  public function read() {
    if(active) _session.triggerEvent(NetworkEvent.MESSAGE_RECEIVED, { obj: this, message: NetworkMessage.parse(socket.input.readLine()) });
  }

  private function generateUuid() {
    if (uuid != null && uuid != '') return;
    uuid = Utils.guid();
  }

  private function get_object(): Dynamic {
    return { active: active, uuid: uuid };
  }

  private function get_active(): Bool {
    return socket != null;
  }
}