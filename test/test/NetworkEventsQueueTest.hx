package;

import massive.munit.Assert;

import networking.Network;
import networking.utils.NetworkEvent;
import networking.utils.NetworkEventsQueue;
import networking.utils.NetworkMode;


class NetworkEventsQueueTest {
  @Test
  public function testAsyncEventQueue() {
    var dispatchedEvents = new Array<NetworkEvent>();
    var session = Network.registerSession(NetworkMode.SERVER);
    var queue = new NetworkEventsQueue(session);

    queue.dispatchEvent(NetworkEvent.INIT_SUCCESS, { test: 'a' });
    queue.dispatchEvent(NetworkEvent.MESSAGE_RECEIVED, { test: 'b' });
    queue.dispatchEvent(NetworkEvent.MESSAGE_SENT, { test: 'c' });

    session.addEventListener(NetworkEvent.INIT_SUCCESS, function(event: NetworkEvent) { dispatchedEvents.push(event); });
    session.addEventListener(NetworkEvent.MESSAGE_RECEIVED, function(event: NetworkEvent) { dispatchedEvents.push(event); });
    session.addEventListener(NetworkEvent.MESSAGE_SENT, function(event: NetworkEvent) { dispatchedEvents.push(event); });

    Assert.isNotNull(session);
    Assert.areEqual(dispatchedEvents.length, 0);

    queue.handleQueuedEvents();

    Assert.areEqual(dispatchedEvents.length, 3);
    Assert.areEqual(dispatchedEvents[0].type, NetworkEvent.INIT_SUCCESS);
    Assert.areEqual(dispatchedEvents[1].type, NetworkEvent.MESSAGE_RECEIVED);
    Assert.areEqual(dispatchedEvents[2].type, NetworkEvent.MESSAGE_SENT);

    Assert.areEqual(dispatchedEvents[0].netData.test, 'a');
    Assert.areEqual(dispatchedEvents[1].netData.test, 'b');
    Assert.areEqual(dispatchedEvents[2].netData.test, 'c');
  }
}
