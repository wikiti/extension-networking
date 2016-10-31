package networking.wrappers;

#if neko
import neko.vm.Deque;
#elseif cpp
import cpp.vm.Deque;
#end

/**
 * Thread safe deque wrapper.
 *
 * @author Daniel Herzog
 */
@:generic class DequeWrapper<T> {
  #if (neko || cpp)
  private var _deque: Deque<T>;
  #else
  private var _array: Array<T>;
  private var _mutex: MutexWrapper;
  #end

  /**
   * Create a new deque.
   */
  public function new() {
    #if (neko || cpp)
    _deque = new Deque<T>();
    #else
    _mutex = new MutexWrapper();
    _array = new Array<T>();
    #end
  }

  /**
   * Add a new element to the back of the queue.
   *
   * @param x Element to add to the queue.
   */
  public function add(x: T) {
    #if (neko || cpp)
    _deque.add(x);
    #else
    _mutex.acquire();
    _array.unshift(x);
    _mutex.release();
    #end
  }

  /**
   * Get the first item of the queue.
   *
   * @return Extracted element. Null if not present.
   */
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