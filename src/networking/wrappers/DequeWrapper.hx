package networking.wrappers;

#if neko
import neko.vm.Deque;
#elseif cpp
import cpp.vm.Deque;
#end

/**
 * ...
 * @author
 */
@:generic class DequeWrapper<T> {

  #if (neko || cpp)
  private var _deque: Deque<T>;
  #else
  private var _array: Array<T>;
  private var _mutex: MutexWrapper
  #end

  public function new() {
    #if (neko || cpp)
    _deque = new Deque<T>();
    #else
    _mutex = MutexWrapper();
    _array = new Array<T>();
    #end
  }

  public function add(x: T) {
    #if (neko || cpp)
    _deque.add(x);
    #else
    _mutex.acquire();
    _array.unshift(x);
    _mutex.release();
    #end
  }

  public function pop(): T {
    #if (neko || cpp)
    return _deque.pop(false);
    #else
    _mutex.acquire();
    var output: T = _array.pop();
    _mutex.release();
    return output;
    #end
  }

}