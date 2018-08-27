package;

import massive.munit.Assert;
import networking.Network;
import networking.utils.NetworkEvent;
import networking.utils.NetworkMode;

class NetworkEventTest {
  @Test
  public function testEventCreation() {
    var raw = { message: { metadata: { meta: 'data' }, data: { attr: 'test', verb: 'test_verb' } } }
    var session = Network.registerSession(NetworkMode.SERVER);
    var event = new NetworkEvent(NetworkEvent.INIT_SUCCESS, session, raw);

    Assert.areEqual(event.type, NetworkEvent.INIT_SUCCESS);
    Assert.areEqual(event.session, session);
    Assert.areEqual(event.netData, raw);
    Assert.areEqual(event.data, raw.message.data);
    Assert.areEqual(event.verb, raw.message.data.verb);
    Assert.areEqual(event.metadata, raw.message.metadata);
  }
}