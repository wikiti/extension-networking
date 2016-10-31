package networking.utils;

import networking.wrappers.DequeWrapper;
import networking.wrappers.MutexWrapper;

import networking.sessions.Session;

/**
 * Class to handle network events safely between threads.
 *
 * @author Daniel Herzog
 */
class NetworkEventsQueue {
  private var _queue: DequeWrapper<NetworkEvent>;
  private var _mutex: MutexWrapper;
  private var _queue_size: Int;
  private var _session: Session;

  /**
   * Create a new event queue.
   * @param session Session related to this queue.
   */
  public function new(session: Session) {
    _session = session;
    _queue = new DequeWrapper<NetworkEvent>();
    _mutex = new MutexWrapper();
    _queue_size = 0;
  }

  /**
   * Dispatch an event (send it to the event queue.
   *
   * @param label Label event (from NetworkEvent).
   * @param data Network data to send to the event.
   */
  public function dispatchEvent(label: String, data: Dynamic) {
    addEvent(new NetworkEvent(label, _session, data));
  }

  /**
   * Handle queue events by dispatching them with the related session. Non thread safe.
   * Should only be called periodically from the main thread (i.e. on each frame).
   */
  public function handleQueuedEvents() {
    var event: NetworkEvent;
    while ((event = popEvent()) != null) {
      _session.dispatchEvent(event);
    }
  }

  /**
   * Get the queue size (element count).
   * @return Current size of the queue.
   */
  public function length(): Int {
    _mutex.acquire();
    var value = _queue_size;
    _mutex.release();
    return value;
  }

  /**
   * Pop the first item of the queue.
   *
   * @return Network event. Null if no events are present on the queue.
   */
  public inline function popEvent(): NetworkEvent {
    var event = _queue.pop();
    if (event != null) incrementCounterBy( -1);
    return event;
  }

  /**
   * Adds a new item into the queue.
   *
   * @param event Event to add.
   */
  public function addEvent(event: NetworkEvent) {
    incrementCounterBy(1);
    _queue.add(event);
  }

  private function incrementCounterBy(value: Int) {
    _mutex.acquire();
    _queue_size += value;
    _mutex.release();
  }
}