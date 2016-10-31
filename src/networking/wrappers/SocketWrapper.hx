package networking.wrappers;

import networking.sessions.server.Server.PortType;

#if (neko || cpp)
import sys.net.Socket;
import sys.net.Host;
#else
import openfl.net.Socket;
#end

/**
 * Wrapper class that represents a socket.
 *
 * @author Daniel Herzog
 */
class SocketWrapper {
  private var _socket: Socket;

  /**
   * Create a new socket.
   *
   * @param data Data content (native socket).
   */
  public function new(data: Dynamic = null) {
    if (data != null)
      _socket = data;
    else
      _socket = new Socket();
  }

  /**
   * Connect to a given server.
   *
   * @param host Host to connect to.
   * @param port Port to connect to.
   */
  public function connect(host: String, port: PortType) {
    #if (neko || cpp)
    _socket.connect(new Host(host), port);
    #else
    _socket.connect(host, port);
    #end
  }

  /**
   * Close the client or server socket.
   */
  public function close() {
    #if (!neko && cpp)
    _socket.shutdown(true, true);
    #end
    _socket.close();
  }

  /**
   * Accept a new client connection.
   * This is a blocking method.
   * Only available for native targets.
   *
   * @return Accepted socket.
   */
  public function accept(): SocketWrapper {
    #if (neko || cpp)
    var sk = _socket.accept();
    if (sk != null)
      return new SocketWrapper(sk);
    else
      return null;

    #else
    throw 'Method not available in non-native targets.';
    #end
  }

  /**
   * Accept new incoming connections from clients.
   * Only available for native targets.
   *
   * @param connections Max pending requests until they get refused.
   */
  public function listen(connections: Int) {
    #if (neko || cpp)
    _socket.listen(connections);
    #else
    throw 'Method not available in non-native targets.';
    #end
  }

  /**
   * Create a server into the given host and port.
   * Only available for native targets.
   *
   * @param host Host to bind.
   * @param port Port to bind.
   */
  public function bind(host: String, port: PortType) {
    #if (neko || cpp)
    _socket.bind(new Host(host), port);
    #else
    throw 'Method not available in non-native targets.';
    #end
  }

  /**
   * Read a string from the socket buffer.
   * This is a blocking method.
   *
   * @return Readed string.
   */
  public function read(): String {
    #if (neko || cpp)
    var len = _socket.input.readUInt16();
    return _socket.input.readString(len);
    #else
    return _socket.readUTF();
    #end
  }

  /**
   * Write a string into the socket buffer.
   *
   * @param data String to write into the buffer.
   */
  public function write(data: String) {
    #if (neko || cpp)
    _socket.output.writeUInt16(data.length);
    _socket.output.writeString(data);
    #else
    _socket.readUTF();
    #end
  }

  /**
   * Create a human readable representation of the socket.
   *
   * @return A string that represents the socket.
   */
  public function toString(): String {
    #if (neko || cpp)
    var peer = _socket.peer();
    return '${peer.host}:${peer.port}';
    #else
    return _socket.toString();
    #end
  }
}