package networking.wrappers;

#if neko
import neko.vm.Mutex;
#elseif cpp
import cpp.vm.Mutex;
#end

/**
 * Mutex wrapper class. It's thread safe.
 *
 * @author Daniel Herzog
 */
class MutexWrapper {
  #if (neko || cpp)
  private var _mutex: Mutex;
  #else
  private var _active: Bool = false;
  #end

  /**
   * Create a new mutex.
   */
  public function new() {
    #if (neko || cpp)
    _mutex = new Mutex();
    #end
  }

  /**
   * Lock the mutex.
   */
  public function acquire() {
    #if (neko || cpp)
    _mutex.acquire();
    #else
    while(testAndSet()) {};
    #end
  }

  /**
   * Release the mutex.
   */
  public function release() {
    #if (neko || cpp)
    _mutex.release();
    #else
    _active = false;
    #end
  }

  #if !(neko || cpp)
  private function testAndSet() {
    var initial: Bool = _active;
    _active = true;
    return initial;
  }
  #end
}