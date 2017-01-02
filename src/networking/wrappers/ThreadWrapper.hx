package networking.wrappers;

#if neko
import neko.vm.Thread;
#elseif cpp
import cpp.vm.Thread;
#else
import lime.system.ThreadPool;
#end

#if flash
import openfl.Lib;
import openfl.events.Event;

enum ThreadState {
  Starting;
  Looping;
  Closing;
  Finished;
}
#end

/**
 * Class wrapper for threads.
 *
 * @author Daniel Herzog
 */
class ThreadWrapper {
  private var _active: Bool;
  private var _mutex: MutexWrapper;
  private var _on_start: Void->Bool;
  private var _on_loop: Void->Bool;
  private var _on_stop: Void->Void;

  #if flash
  private var _thread_state: ThreadState;
  #end

  /**
   * Create a new thread task.
   *
   * @param on_start Initialize callback. Will be called at the beginning of the execution. If it returns false, the thread will stop, and on_loop neither on_stop won't be called.
   * @param on_loop Loop callback. The thread will call this method forever while it returns true. Will stop if it returns false.
   * @param on_stop Close callback. Called after on_loop has stopped running.
   */
  public function new(on_start: Void->Bool, on_loop: Void->Bool, on_stop: Void->Void) {
    _on_start = on_start;
    _on_loop = on_loop;
    _on_stop = on_stop;
    _active = true;
    _mutex = new MutexWrapper();

    #if (neko || cpp)
    Thread.create(handler);
    #elseif flash
    _thread_state = ThreadState.Starting;
    Lib.current.stage.addEventListener(Event.ENTER_FRAME, handler);

    #else
    var thread_pool = new ThreadPool();
    thread_pool.doWork.add(handler);
    thread_pool.queue();

    #end
  }

  /**
   * Stop the thread.
   *
   * `on_stop` will be called.
   */
  public function stop() {
    _mutex.acquire();
    _active = false;
    _mutex.release();
  }

  #if (neko || cpp)
  private function handler() {
  #else
  private function handler(test: Dynamic = null) {
  #end

    handlerLogic();
  }

  private function handlerLogic() {
    #if flash
    switch(_thread_state) {
      case Starting:
        var success: Bool = true;
        if(_on_start != null) success = _on_start();
        if (!success) _thread_state = ThreadState.Finished;
        _thread_state = ThreadState.Looping;

      case Looping:
        if (!_active || !_on_loop()) {
          _thread_state = ThreadState.Closing;
          return;
        }

      case Closing:
        _thread_state = ThreadState.Finished;
        if (_on_stop != null) _on_stop();

      case Finished:
        Lib.current.stage.removeEventListener(Event.ENTER_FRAME, handler);
    }

    #else
    var success: Bool = true;
    if (_on_start != null) success = _on_start();
    if (!success) return;

    while (true) {
      _mutex.acquire();
      if (!_active) {
        _mutex.release();
        break;
      }
      _mutex.release();

      if (!_on_loop()) break;
    }
    if (_on_stop != null) _on_stop();
    #end
  }

}