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
  public var _socket: Socket;

  public function new(raw_socket: Dynamic = null) {
    if (raw_socket)
      _socket = raw_socket;
    else
      _socket = new Socket();
  }

  public function connect(host: String, port: PortType) {
    #if (neko || cpp)
    _socket.connect(new Host(host), port);
    #else
    _socket.connect(host, port);
    #end
  }

  public function close() {
    #if !neko
    _socket.shutdown(true, true);
    #end
    _socket.close();
  }

  public function accept(): SocketWrapper {
    #if (neko || cpp)
    var sk = _socket.accept();
    if (sk != null)
      return new SocketWrapper(sk);
    else
      return null;

    #else
    throw 'Method not available in non-native targets.'
    #end
  }

  public function listen(connections: Int) {
    #if (neko || cpp)
    _socket.listen(connections);
    #else
    throw 'Method not available in non-native targets.'
    #end
  }

  public function bind(host: String, port: PortType) {
    #if (neko || cpp)
    _socket.bind(new Host(host), port);
    #else
    throw 'Method not available in non-native targets.'
    #end
  }

  public function read(): String {
    #if (neko || cpp)
    return _socket.input.readLine();
    #else
    return _socket.readUTF();
    #end
  }

  public function write(data: String) {
    _socket.output.writeString(data);
  }

  public function toString(): String {
    #if (neko || cpp)
    var peer = _socket.peer();
    return '${peer.host}:${peer.port}';
    #else
    return _socket.toString();
    #end
  }
}