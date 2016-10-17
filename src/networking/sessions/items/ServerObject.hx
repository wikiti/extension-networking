package networking.sessions.items;

import networking.sessions.Session;
import networking.sessions.items.ClientObject;
import networking.sessions.server.Server;
import networking.utils.*;

import sys.net.Host;
import sys.net.Socket;

/**
 * Low level server info wrapper object.
 *
 * @author Daniel Herzog
 */
class ServerObject extends ClientObject {
  /**
   * Create a new server object. This constructor should not be called manually.
   *
   * @param session Reference to the current session.
   * @param uuid Server uuid.
   * @param sv Server reference.
   */
  public function new(session: Session, uuid: Uuid, sv: Server) {
		super(session, uuid, sv, null);
    generateUuid();
	}

  /**
   * String representation of the server object.
   * @return Returns the string representation of the server object. For example: "server_uuid (local)"
   */
	override public function toString():String {
		return '$uuid (local)';
	}

  /**
   * Send a message. Not implemented on server mode. This task is delegated to the `Server` class.
   *
   * @param msg Message content.
   * @return Status flag.
   */
	override public function send(msg: Dynamic): Bool {
    throw 'Method not implemented';
    return false;
	}

  /**
   * Initialize the server socket, binding to a given ip and port.
   *
   * @param ip Ip host to bind into.
   * @param port Port to bind.
   * @return true if the socket was created, false otherwise.
   */
  override public function initializeSocket(ip: String, port: PortType): Bool {
    if (socket != null) return false;

    socket = new Socket();
		socket.bind(new Host(ip), port);
		socket.listen(Server.MAX_LISTEN_INCOMING_REQUESTS);
    return true;
  }
}