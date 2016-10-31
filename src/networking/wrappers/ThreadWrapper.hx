package networking.wrappers;

#if neko
import neko.vm.Thread;
#elseif cpp
import cpp.vm.Thread;
#else
import lime.system.ThreadPool;
#end

/**
 * ...
 * @author
 */
class ThreadWrapper {
  private var _active: Bool;
  private var _mutex: MutexWrapper;
  private var _on_start: Void->Bool;
  private var _on_loop: Void->Bool;
  private var _on_stop: Void->Void;

  #if !(neko || cpp)
  private var _thread_pool: ThreadPool;
  #end

  public function new(on_start: Void->Bool, on_loop: Void->Bool, on_stop: Void->Void) {
    _on_start = on_start;
    _on_loop = on_loop;
    _on_stop = on_stop;
    _active = true;
    _mutex = new MutexWrapper();

    #if (neko || cpp)
    Thread.create(handler);
    #else
    _thread_pool = new ThreadPool();
    _thread_pool.doWork.add(handler);
    _thread_pool.queue();
    #end
  }

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
  }
}