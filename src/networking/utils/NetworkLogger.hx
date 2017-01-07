package networking.utils;

import haxe.CallStack;

#if flash
import flash.external.ExternalInterface;
#end

/**
 * Network log levels.
 *
 * @author Daniel Herzog
 */
@:enum abstract NetworkLogLevel(String) {
  /** Info level. **/
  var Info = "INFO";

  /** Event level. **/
  var EventLog = "EVENT";

  /** Error level. **/
  var Error = "ERROR";
}

/**
 * Network logger tool (tracer).
 *
 * @author Daniel Herzog
 */
class NetworkLogger {
  private function new() { }

  /**
   * Log an error or exception. To include backtrace, use the `network_logging_with_backtrace` haxedef.
   *
   * @param exception Error to log.
   */
  public static inline function error(exception: Dynamic) {
    #if network_logging_with_backtrace
    var msg = '$exception\n${CallStack.toString(CallStack.callStack())}';
    #else
    var msg = exception;
    #end
    log(msg, NetworkLogLevel.Error);
  }

  /**
   * Log a network event.
   *
   * @param event Network event to log.
   */
  public static inline function event(event: NetworkEvent) {
    log('${event.type} -- ${event.netData}', NetworkLogLevel.EventLog);
  }

  /**
   * Log anything.
   *
   * @param msg Message to log.
   * @param level Log level (tag).
   */
  public static inline function log(msg: String, level:NetworkLogLevel = NetworkLogLevel.Info) {
    #if (network_logging || network_logging_with_backtrace)
    trace('# NETWORK $level -- $ -- $msg');

    #if (flash || html5)
    try { ExternalInterface.call("console.log", '# NETWORK $level -- $ -- $msg'); }
    catch(e: Dynamic) {}
    #end
    #end
  }
}