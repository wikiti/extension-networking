package networking.wrappers;

#if neko
import neko.vm.Mutex;
#elseif cpp
import cpp.vm.Mutex;
#end

/**
 * ...
 * @author
 */
class MutexWrapper {
  #if (neko || cpp)
  private var _mutex: Mutex;
  #else
  private var _active: Bool = false;
  #end

  public function new() {
    #if (neko || cpp)
    _mutex = new Mutex();
    #end
  }

  public function acquire() {
    #if (neko || cpp)
    _mutex.acquire();
    #else
    while(testAndSet()) {};
    #end
  }

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