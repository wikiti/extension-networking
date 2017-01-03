package networking.sessions.server;

import networking.utils.NetworkEvent;
import networking.utils.NetworkLogger;

import networking.sessions.Session;
import networking.sessions.items.ClientObject;
import networking.sessions.items.ServerObject;
import networking.sessions.server.FlashPolicyServer;
import networking.utils.*;

import networking.wrappers.*;

/** Port type (integer). **/
typedef PortType = Null<Int>;

/** Clients list (array of ClientObjects). **/
typedef Clients = Array<ClientObject>;

/**
 * Server wrapper. Represents a server session.
 *
 * Instances from this class shouldn't be handled manually, but with Session instances.
 *
 * @author Daniel Herzog
 */
class Server {
  /** Default IP host to bind into. Used in the constructor. **/
  public static inline var DEFAULT_IP: String = '127.0.0.1';

  /** Default port to bind into. Used in the constructor. **/
  public static inline var DEFAULT_PORT: PortType = 9696;

  /** Max allowed clients connected to the server. Used in the constructor. **/
  public static inline var DEFAULT_MAX_CONNECTIONS: Int = 24;

  /** Default session identifier (random). Used in the constructor. **/
  public static inline var DEFAULT_UUID: String = null;

  /** Flag to allow flash clients. Setting this value to a numeric port will create a FlashPolicyServer object on that port. **/
  public static inline var FLASH_POLICY_FILE_PORT: PortType = null;

  /** Max allowed connection pending requests. This value is hard-coded and should not be modified. **/
  public static inline var MAX_LISTEN_INCOMING_REQUESTS: Int = 200;

  /** Clients connected to the current server. **/
  public var clients: Clients;

  /** Low level information. **/
  public var info: ServerObject;

  /** Server binded ip. **/
  public var ip(default, null): String;

  /** Current server port. **/
  public var port(default, null): PortType;

  /** Max allowed clients. **/
  public var max_connections(default, null): Int;

  /** Flash-clients related. This property is used to setup a flash policy file server on the specified port. If no port is specified, then the file policy server will not be created. **/
  public var flash_policy_file_port(default, null): PortType;

  private var _session: Session;
  private var _mutex: MutexWrapper;
  private var _uuid: Uuid;
  private var _thread: ThreadWrapper;
  private var _policy_server: FlashPolicyServer;

  /**
   * Create a new server session that will bind the given ip and port.
   * This constructor shouldn't be called manually.
   *
   * @param session Reference to session object.
   * @param uuid Session uuid. Random by default.
   * @param ip Server ip to connect into.
   * @param port Server port to connect into.
   * @param max_connections Max allowed clients at the same time.
   */
  public function new(session: Session, uuid: Uuid = DEFAULT_UUID, ip: String = DEFAULT_IP, port: PortType = DEFAULT_PORT, max_connections: Null<Int> = DEFAULT_MAX_CONNECTIONS,
      flash_policy_file_port: PortType = FLASH_POLICY_FILE_PORT) {

    _session = session;
    _mutex = new MutexWrapper();
    _uuid = uuid;

    try {
      #if !(cpp || neko)
      throw 'Server mode is not available in non-native targets.';
      #end

      info = new ServerObject(_session, _uuid, this);
      info.initializeSocket(ip, port);
    }
    catch (e: Dynamic) {
      _session.triggerEvent(NetworkEvent.INIT_FAILURE, { server: this, message: 'Could not bind to $ip:$port. Ensure that no server is running on that port. Reason: $e' } );
      info = null;
      return;
    }

    _session.triggerEvent(NetworkEvent.INIT_SUCCESS, { server: this, message: 'Binded to $ip:$port.' });

    this.ip = ip;
    this.port = port;
    this.max_connections = max_connections;
    this.flash_policy_file_port = flash_policy_file_port;

    clients = [];
    _thread = new ThreadWrapper(null, threadLoop, null);

    if (this.flash_policy_file_port != null) {
      _policy_server = new FlashPolicyServer(this, flash_policy_file_port);
      _policy_server.run();
    }
  }

  /**
   * Sends given object to all active clients, also known as broadcasting.
   * To send messages to a single client, use something like `clients[0].send(...)`.
   *
   * @param obj Message to broadcast.
   */
  public function broadcast(obj: Dynamic) {
    try {
      for (cl in clients) {
        if (!cl.send(obj)) disconnectClient(cl, false);
      }
      _session.triggerEvent(NetworkEvent.MESSAGE_BROADCAST, { server: this, message: obj });
    }
    catch (e: Dynamic) {
      _session.triggerEvent(NetworkEvent.MESSAGE_BROADCAST_FAILED, { server: this, message: obj });
    }
  }

  /**
   * Disconnect a given client from the server. This method should not be called manually, but withing Session instances.
   *
   * @param cl Client to disconnect from the server.
   * @param dispatch Trigger a DISCONNECT event.
   * @return Returns true if the client is disconnected successfully, false otherwise.
   */
  public function disconnectClient(cl: ClientObject, dispatch: Bool = true): Bool {
    try {
      if(!cl.active) return false;

      if(dispatch) {
        _session.triggerEvent(NetworkEvent.DISCONNECTED, { server: this, client: cl } );
      }

      cl.destroySocket();
      clients.remove(cl);
    }
    catch (e:Dynamic) { }
    return true;
  }

  /**
   * Disconnect all clients, and close the current session.
   */
  public function stop() {
    if (_thread != null) _thread.stop();
    if (_policy_server != null) _policy_server.stop();

    _mutex.acquire();
    cleanup();
    _mutex.release();
    if(info != null) _session.triggerEvent(NetworkEvent.CLOSED, { server: this, message: 'Session closed.' } );

    _thread = null;
    _mutex = null;
    _policy_server = null;
  }

  /**
   * An alias for `broadcast`.
   * @param obj Message to broadcast.
   */
  public inline function send(obj: Dynamic) {
    broadcast(obj);
  }

  /**
   * Retrieves the related session to the server.
   *
   * @return A `Session` object related to this server.
   */
  public inline function session(): Session {
    return _session;
  }

  // Accepts new sockets and spawns new threads for them.

  private function threadLoop(): Bool {
    var sk: SocketWrapper = null;
    try {
      sk = info.socket.accept();
    }
    catch (e: Dynamic) {
      NetworkLogger.error(e);
    }
    if (sk != null) {
      var cl = new ClientObject(_session, null, this, sk);

      if (!maxClientsReached()) {
        new ThreadWrapper(getThreadCreate(cl), getThreadListen(cl), getThreadDisconnect(cl));
      }
      else {
        var message = { verb: '_core.errors.server_full', message: 'Server is full.' };
        cl.send(message);
        _session.triggerEvent(NetworkEvent.SERVER_FULL, { client: cl, message: message });
      }
    }

    return true;
  }

  // Destroy the current session.
  private function cleanup() {
    if (clients == null) return;

    for (cl in clients) {
      disconnectClient(cl, false);
    }

    info.destroySocket();
    clients = [];
  }

  // Check if the server is full.
  private function maxClientsReached(): Bool {
    return clients.length >= max_connections;
  }

  // Creates a new thread function to handle given ClientInfo.
  private function getThreadCreate(cl: ClientObject): Void->Bool {
    return function() {
      clients.push(cl);
      cl.load();
      _session.triggerEvent(NetworkEvent.CONNECTED, { server: this, client: cl } );
      return true;
    };
  }

  // Creates a new thread function to handle given ClientInfo.
  private function getThreadListen(cl: ClientObject): Void->Bool {
    return function() {
      if(!cl.active) return false;
      try {
        cl.read();
      }
      catch (z: Dynamic) {
        return false;
      }

      return true;
    };
  }

  private function getThreadDisconnect(cl: ClientObject): Void->Void {
    return function() {
      disconnectClient(cl);
    };
  }
}