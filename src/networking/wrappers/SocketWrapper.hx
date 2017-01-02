package networking.wrappers;

import haxe.io.Bytes;
import networking.sessions.server.Server.PortType;
import networking.utils.NetworkLogger;

#if (cpp)
import sys.net.Socket;
import sys.net.Host;
#else
import openfl.events.*;
import openfl.net.Socket;
#end

/**
 * Wrapper class that represents a socket.
 *
 * @author Daniel Herzog
 */
class SocketWrapper {
  /** Callback used called when a connection is established. This callback should not be handled manually. **/
  public var onConnect(default, default): Dynamic->Void;

  /** Callback used when a connection fails from the beginning. This callback should not be handled manually. **/
  public var onFailure(default, default): Dynamic->Void;

  /** A flag to test if the current socket has connected once (at least) to the server. **/
  public var connected: Bool;

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

    connected = false;
  }

  /**
   * Connect to a given server.
   *
   * @param host Host to connect to.
   * @param port Port to connect to.
   */
  public function connect(host: String, port: PortType) {
    // TODO: Neko
    #if (cpp)
    try {
      _socket.connect(new Host(host), port);
      onConnect(null);
      connected = true;
    }
    catch (e: Dynamic) {
      onFailure(e);
      connected = false;
    }
    #else
    _socket.addEventListener(Event.CONNECT, function(e: Dynamic) {
      try {
        onConnect(e);
        connected = true;
      }
      catch (e: Dynamic) {
        onFailure(e);
      }
    });
    _socket.addEventListener(Event.CLOSE, function(e: Dynamic) {
      if(!connected) {
        onFailure(e);
        connected = false;
      }
      else {
        // Disconnect?
      }
    });

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
    #if (cpp)
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
    #if (cpp)
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
    #if (cpp)
    _socket.bind(new Host(host), port);
    #else
    throw 'Method not available in non-native targets.';
    #end
  }

  /**
   * Read a string from the socket buffer.
   * This is a blocking method.
   *
   * @return A string.
   */
  public function read(): String {
    #if !(cpp)
    if(!connected || (_socket.connected && _socket.bytesAvailable == 0)) return null;
    if(!_socket.connected) throw 'Disconnected from server';
    #end

    return readString();
  }

  /**
   * Write a string into the socket buffer.
   *
   * @param data String to write into the buffer.
   */
  public function write(data: String) {
    #if !(cpp)
    if (!connected || !_socket.connected) {
      return;
    }
    #end

    writeString(data);
    flush();
  }

  /**
   * TODO
   *
   * @param buffer
   * @param length
   * @param offset
   */
  public function writeBytes(buffer: Bytes, length: Int, offset: Int = 0) {
    #if (cpp)
    return _socket.output.writeBytes(buffer, offset, length);
    #else
    throw 'Method not implemented in non native targets.';
    #end
  }

  /**
   * Create a human readable representation of the socket.
   *
   * @return A string that represents the socket.
   */
  public function toString(): String {
    #if (cpp)
    var peer = _socket.peer();
    return '${peer.host}:${peer.port}';
    #else
    return _socket.toString();
    #end
  }

  // Flush output content.
  private function flush() {
    #if (cpp)
    _socket.output.flush();
    #else
    _socket.flush();
    #end
  }

  // Write 2 bytes as an unsigned integer.
  private function writeUnsignedInt16(x: UInt) {
    #if (cpp)
    _socket.output.writeByte((x >> 8) & 0xFF);
    _socket.output.writeByte(x & 0xFF);
    #else
    _socket.writeByte((x >> 8) & 0xFF);
    _socket.writeByte(x & 0xFF);
    #end
  }

  // Write a string (size + bytes).
  private function writeString(s: String) {
    // TODO: Handle max string size

    writeUnsignedInt16(s.length);

    #if (cpp)
    _socket.output.writeString(s);
    #else
    _socket.writeUTFBytes(s);
    #end
  }

  // Read 2 bytes as an unsigned integer.
  private function readUnsignedInt16(): UInt {
    #if (cpp)
    var byte1: Int = _socket.input.readByte() & 0xFF;
    var byte2: Int = _socket.input.readByte() & 0xFF;
    #else
    var byte1: Int = _socket.readByte() & 0xFF;
    var byte2: Int = _socket.readByte() & 0xFF;
    #end

    return (byte1 << 8) | byte2;
  }

  // Read a string (size + bytes).
  private function readString(): String {
    var len: UInt = readUnsignedInt16();

    #if (cpp)
    return _socket.input.readString(len);
    #else
    return _socket.readUTFBytes(len);
    #end
  }
}