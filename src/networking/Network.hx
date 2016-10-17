package networking;

import networking.sessions.Session;
import networking.utils.*;
import networking.utils.NetworkMode;

/**
 * Session list.
 *
 * @author Daniel Herzog
 */
typedef Sessions = Array<Session>;


/**
 * A singleton class instance. Use Network.instance or Network.getInstance() to get the global object.
 * Events will be dispatched from instances of this class, and handled from NetworkEventsQueue on each fream (ENTER_FRAME event).
 *
 * For more information about dispatched events, review network.utils.NetworkEvent.
 *
 * @author Daniel Herzog
 */
class Network {
  /** Current registered sessions. **/
  public static var sessions: Sessions = new Sessions();

  private function new() { }

  /**
   * Register a new session. It'll be added to `Network.sessions`.
   *
   * @param mode Networking mode (client, server...).
   * @param params Session parameters.
   * @return The created Session object.
   */
  public static function registerSession(mode: NetworkMode, params: Dynamic = null): Session {
    var session: Session = new Session(mode, params);
    sessions.push(session);
    return session;
  }

  /**
   * Destroy a registered session. It'll be added to `Network.sessions`.
   *
   * @param session Session to destroy.
   * @param auto_stop Auto stop (close) the given session.
   * @return Returns true the session was removed, false otherwise.
   */
  public static function destroySession(session: Session, auto_stop: Bool = true): Bool {
    if(sessions.indexOf(session) == -1) return false;
    if(auto_stop) session.stop();
    sessions.remove(session);
    return sessions.remove(session);
  }
}