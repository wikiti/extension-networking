package networking.utils;

/**
 * Networking types.
 *
 * @author Daniel Herzog
 */
enum NetworkMode {
  /** Server mode. Allows multiple clients to connect to it. **/
  SERVER;

  /** Client mode. Connects to a server. **/
  CLIENT;
}