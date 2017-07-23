package networking.wrappers;

import haxe.io.Bytes;
import networking.sessions.server.Server.PortType;
import networking.utils.NetworkLogger;

#if (neko || cpp)
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
  /** Max string size, in bytes. */
  public var MAX_DATA_SIZE: Int = 65535;

  /** Callback used called when a connection is established. This callback should not be handled manually. **/
  public var onConnect(default, default): Dynamic->Void;

  /** Callback used when a connection fails from the beginning. This callback should not be handled manually. **/
  public var onFailure(default, default): Dynamic->Void;

  /** A flag to test if the current socket has connected once (at least) to the server. **/
  public var connected: Bool;

  private var _socket: Socket;
  private var _is_server: Bool;

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
    _is_server = false;
  }

  /**
   * Connect to a given server.
   *
   * @param host Host to connect to.
   * @param port Port to connect to.
   */
  public function connect(host: String, port: PortType) {
    #if (neko || cpp)
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

    var on_connect_handler: Dynamic->Void = function(e: Dynamic) {
      try {
        connected = true;
        onConnect(e);
      }
      catch (e: Dynamic) {
        onFailure(e);
      }
    };

    var on_failure_handler: Dynamic->Void = function(e: Dynamic) {
      NetworkLogger.error(e);
      if(!connected) {
        onFailure(e);
        connected = false;
      }
    };

    _socket.addEventListener(Event.CONNECT, on_connect_handler);
    _socket.addEventListener(IOErrorEvent.IO_ERROR, on_failure_handler);
    _socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, on_failure_handler);

    _socket.connect(host, port);
    #end

    _is_server = false;
  }

  /**
   * Close the client or server socket.
   */
  public function close() {
    #if !(cpp || neko)
    if (!_socket.connected) return;
    #end

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

    _is_server = true;
  }

  /**
   * Read a string from the socket buffer.
   * This is a blocking method.
   *
   * @return A string.
   */
  public function read(): String {
    #if !(neko || cpp)
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
    #if !(neko || cpp)
    if (_socket == null) return;
    if (!connected || !_socket.connected) throw 'Connection not established.';
    #end

    writeString(data);
    flush();
  }

  /**
   * Write raw bytes stored in a buffer. Only available in native targets.
   *
   * @param buffer Buffer to wrint onto the socket's buffer.
   * @param length Buffer data's length.
   * @param offset Buffer data's initial byte.
   */
  public function writeBytes(buffer: Bytes, length: Int, offset: Int = 0) {
    #if (neko || cpp)
    _socket.output.writeBytes(buffer, offset, length);
    flush();
    #else
    throw 'Method not available in non-native targets.';
    #end
  }

  /**
   * Create a human readable representation of the socket.
   *
   * @return A string that represents the socket.
   */
  public function toString(): String {
    try {
      #if (neko || cpp)
      if (_is_server) {
        var host = _socket.host();
        return '${host.host}:${host.port}';
      }
      else {
        var peer = _socket.peer();
        return '${peer.host}:${peer.port}';
      }
      #else
      return _socket.toString();
      #end
    }
    catch (e: Dynamic) {
      NetworkLogger.error(e);
      return '?:?';
    }
  }

  // Flush output content.
  private function flush() {
    #if (neko || cpp)
    _socket.output.flush();
    #else
    _socket.flush();
    #end
  }

  // Write 2 bytes as an unsigned integer.
  private function writeUnsignedInt16(x: UInt) {
    #if (neko || cpp)
    _socket.output.writeByte((x >> 8) & 0xFF);
    _socket.output.writeByte(x & 0xFF);
    #else
    _socket.writeByte((x >> 8) & 0xFF);
    _socket.writeByte(x & 0xFF);
    #end
  }

  // Write a string (size + bytes).
  private function writeString(s: String) {
    if (s.length > MAX_DATA_SIZE)
      throw 'String data is too big - ${s.length} bytes (${MAX_DATA_SIZE} bytes max)';

    writeUnsignedInt16(s.length);

    #if (neko || cpp)
    _socket.output.writeString(s);
    #else
    _socket.writeUTFBytes(s);
    #end
  }

  // Read 2 bytes as an unsigned integer.
  private function readUnsignedInt16(): UInt {
    #if (neko || cpp)
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

    #if (neko || cpp)
    return _socket.input.readString(len);
    #else
    return _socket.readUTFBytes(len);
    #end
  }
}