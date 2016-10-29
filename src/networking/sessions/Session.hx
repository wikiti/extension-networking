package networking.sessions;

import networking.sessions.client.Client;
import networking.sessions.items.ClientObject;
import networking.sessions.server.Server;
import networking.utils.*;
import networking.utils.NetworkEventsQueue;
import networking.utils.NetworkEvent;
import networking.utils.NetworkLogger;
import networking.utils.NetworkMode;

import openfl.Lib;
import openfl.events.Event;
import openfl.events.EventDispatcher;


/**
 * A networking session. It can be a server or a client. It will a networking session,
 * so events can be registered easily within instances of this class.
 *
 * @author Daniel Herzog
 */
class Session extends EventDispatcher {
  private var _events_queue: NetworkEventsQueue;

  /**
   * Create a new session. Should not be called manually.
   *
   * @param mode Session mode.
   * @param params Session parameters.
   */
  public function new(mode: NetworkMode, params: Dynamic = null) {
    super();
    _events_queue = new NetworkEventsQueue(this);
    this.mode = mode;
    this.params = params;

    addCoreEventListeners();
  }

  /**
   * Current session mode.
   */
  public var mode(default, null): NetworkMode = null;

  /**
   * Current session parameters.
   */
  public var params(default, null): Dynamic = null;

  /**
   * Current session object. May be network.client.Client or network.server.Server.
   */
  public var network_item(default, null): Dynamic = null;

  /**
   * Clients of the current server. Will return [] in client mode.
   */
  public var clients(get, null): Clients = null;

  /**
   * Current session uuid.
   */
  public var uuid(get, null): Uuid = null;

  /**
   * Send an object via networking.
   * As a client, the object will be sent to the server.
   * As a server, the object will be broadcasted to all the clients.
   *
   * The format of the message is explained on network.utils.NetworkMessage.
   *
   * @param obj Any kind of anonymous object (Dynamic). This will be corresponded to the 'data' field of the network.utils.NetworkMessage.
   */
  public function send(obj: Dynamic) {
    if (network_item == null) return;
    if(obj == null) obj = { };

    network_item.send(obj);
  }

  /**
   * Start session.
   *
   * @return Self reference.
   */
  public function start(): Session {
    stop();

    params = params != null ? params : { };

    switch(mode) {
      case SERVER: network_item = new Server(this, params.uuid, params.ip, Std.parseInt(params.port), params.max_connections);
      case CLIENT: network_item = new Client(this, params.uuid, params.ip, Std.parseInt(params.port));
    }

    return this;
  }

  /**
   * Stop the session.
   *
   * @return Self reference.
   */
  public function stop(): Session {
    if (mode == null || network_item == null) return this;

    network_item.stop();
    return this;
  }

  /**
   * Disconnect a client from the server, or disconnect from a server.
   *
   * From example, to disconnect a client from a server, use `server.disconnectClient(server.clients[0])`.
   * To disconnect from a server as a client, use `client.disconnectClient()` or `client.stop()`.
   *
   * @param cl ClientObject to disconnect.
   */
  public function disconnectClient(cl: ClientObject = null) {
    switch(mode) {
      case SERVER:
        if (network_item == null || cl == null) return;
        network_item.disconnectClient(cl);

      case CLIENT:
        if (network_item == null) return;
        stop();
    }
  }

  /**
   * Triggers and event and sends it to the events queue.
   * This method is thread safe. Call this from anywhere!
   *
   * @param label NetworkEvent label.
   * @param data NetworkEvent data.
   */
  public function triggerEvent(label: String, data: Dynamic) {
    _events_queue.dispatchEvent(label, data);
  }

  #if test
  public function eventsQueue(): NetworkEventsQueue {
    return _events_queue;
  }
  #end

  private function get_clients(): Clients {
    if (network_item == null || mode != NetworkMode.SERVER) return [];
    return network_item.clients;
  }

  private function get_uuid(): Uuid {
    if (network_item == null || mode == null) return null;
    return network_item.info.uuid;

  }

  private function addCoreEventListeners() {
    #if !test
    Lib.current.stage.addEventListener(openfl.events.Event.ENTER_FRAME, handleCoreQueuedEvents); // Run it on every frame.
    #end

    addEventListener(NetworkEvent.CONNECTED, debugEvent);
    addEventListener(NetworkEvent.DISCONNECTED, debugEvent);
    addEventListener(NetworkEvent.INIT_FAILURE, debugEvent);
    addEventListener(NetworkEvent.INIT_SUCCESS, debugEvent);
    addEventListener(NetworkEvent.CLOSED, debugEvent);
    addEventListener(NetworkEvent.MESSAGE_RECEIVED, debugEvent);
    addEventListener(NetworkEvent.MESSAGE_SENT, debugEvent);
    addEventListener(NetworkEvent.MESSAGE_SENT_FAILED, debugEvent);
    addEventListener(NetworkEvent.MESSAGE_BROADCAST, debugEvent);
    addEventListener(NetworkEvent.MESSAGE_BROADCAST_FAILED, debugEvent);
    addEventListener(NetworkEvent.SERVER_FULL, debugEvent);

    #if !test
    addEventListener(NetworkEvent.MESSAGE_RECEIVED, handleCoreReceivedMessage);
    #end
  }

  private function debugEvent(e: Dynamic) {
    NetworkLogger.event(e);
  }

  private function handleCoreQueuedEvents(e: NetworkEvent) {
    // NOTE: Just add a timer or a counter here to handle networking every N seconds or frames. This way, it will work as a QUEUE. (Requires core).
    _events_queue.handleQueuedEvents();
  }

  private function handleCoreReceivedMessage(event: NetworkEvent) {
    try {
      var client: ClientObject = event.client;

      switch(event.verb) {
        // Update client information
        case '_core.sync.update_client_data':
          eventMatched(event);
          event.client.update(event.data.uuid);

        // Close client session.
        case '_core.errors.server_full':
          eventMatched(event);
          event.session.triggerEvent(NetworkEvent.SERVER_FULL, event.netData);
          event.session.stop();

        // Not handled
        default:
      }
    }
    catch (e: Dynamic) {
      NetworkLogger.error(e);
    }
  }

  private function eventMatched(event: NetworkEvent) {
    event.stopImmediatePropagation();
  }
}