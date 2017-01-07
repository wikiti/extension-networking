package networking.sessions.client;

import networking.server.*;
import networking.sessions.Session;
import networking.sessions.items.ClientObject;
import networking.sessions.server.Server;
import networking.sessions.server.Server.PortType;
import networking.utils.*;
import networking.wrappers.*;

import openfl.system.Security;


/**
 * Client wrapper. Represents a client session.
 *
 * Instances from this class shouldn't be handled manually, but with Session instances.
 *
 * @author Daniel Herzog
 */
class Client {
  /** Default IP to connect into. Used in the constructor. **/
  public static inline var DEFAULT_IP: String = '127.0.0.1';

  /** Default port to connect into. Used in the constructor. **/
  public static inline var DEFAULT_PORT: PortType = 9696;

  /** Default session identifier (random). Used in the constructor. **/
  public static inline var DEFAULT_UUID: String = null;

  /** Default flash policy file url to download the policy file. **/
  public static inline var DEFAULT_FLASH_POLICY_FILE_URL: String = null;

  /** ClientObject info. Contains low level objects (sockets). **/
  public var info(default, null): ClientObject;

  /** Current server's ip. **/
  public var ip(default, null): String;

  /** Current server port. **/
  public var port(default, null): PortType;

  /** Flash-clients related. This property is used to setup a download url for policy files. **/
  public var flash_policy_file_url(default, null): String;

  private var _session: Session;
  private var _mutex: MutexWrapper;
  private var _uuid: Uuid;
  private var _thread: ThreadWrapper;
  private var _disconnected_message: String;

  /**
   * Create a new client session that tries connects to the given server. This constructor shouldn't be called manually.
   *
   * @param session Reference to session object.
   * @param uuid Session uuid. Random by default.
   * @param ip Server ip to connect into.
   * @param port Server port to connect into.
   */
  public function new(session: Session, uuid: Uuid = DEFAULT_UUID, ip: String = DEFAULT_IP, port: PortType = DEFAULT_PORT,
      flash_policy_file_url: String = DEFAULT_FLASH_POLICY_FILE_URL) {

    this._session = session;
    this.ip = ip;
    this.port = port;
    this.flash_policy_file_url = flash_policy_file_url;

    _uuid = uuid;
    _mutex = new MutexWrapper();
    _thread = new ThreadWrapper(threadCreate, threadListen, threadClose);
  }

  /**
   * Send an object to the server.
   *
   * @param obj Object to send to the server.
   */
  public function send(obj: Dynamic) {
    try {
      if (!info.send(obj))
        throw 'Could not send message to server.';
    }
    catch (z: Dynamic) {
      var server: Server = info != null ? info.server : null;
      _session.triggerEvent(NetworkEvent.MESSAGE_SENT_FAILED, { server: server, client: info, message: obj } );
    }
  }

  /**
   * Stop the client session, to disconnect from the server.
   */
  public function stop() {
    if(info.socket != null && info.socket.connected) {
      _session.triggerEvent(NetworkEvent.CLOSED, { client: this, message: 'Session closed.' } );
    }
    disconnect();
  }

  private function threadCreate(): Bool {
    _disconnected_message = '';

    if (flash_policy_file_url != null) {
      Security.allowDomain("*");
      Security.loadPolicyFile(flash_policy_file_url);
    }

    // To avoid lagging the main thread, the initialization code is moved right here.
    // If this generates some errors, move it to the new method.
    info = new ClientObject(_session, _uuid, null, null);

    var on_connect = function(data: Dynamic) {
      _session.triggerEvent(NetworkEvent.INIT_SUCCESS, { message: 'Connected to $ip:$port' } );
      _session.triggerEvent(NetworkEvent.CONNECTED, { message: 'Connected to $ip:$port' });

      info.load();
      if (!info.send({ verb: '_core.sync.update_client_data', uuid: info.uuid })) {
        throw "Could not update client's data";
      }

      _disconnected_message = 'Disconnected';
    };

    var on_failure = function(error: Dynamic) {
      _session.triggerEvent(NetworkEvent.INIT_FAILURE, { message: 'Could not connect to server.' });
      stop();
    };

    info.initializeSocket(ip, port, on_connect, on_failure);

    return true;
  }

  // Listener thread
  private function threadListen(): Bool {
    try {
      info.read();
    }
    catch (e: Dynamic) {
      NetworkLogger.error(e);
      _disconnected_message = 'Connection lost: ${e}';
      return false;
    }

    return true;
  }

  private function threadClose(): Void {
    if(info.socket != null && info.socket.connected) {
      _session.triggerEvent(NetworkEvent.DISCONNECTED, { message: _disconnected_message });
    }
    disconnect();
  }

  private function disconnect() {
    _mutex.acquire();
    info.destroySocket();
    if(_thread != null) _thread.stop();
    _mutex.release();
  }
}