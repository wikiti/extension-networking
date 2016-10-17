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

    Assert.areSame(event.type, NetworkEvent.INIT_SUCCESS);
    Assert.areSame(event.session, session);
    Assert.areSame(event.netData, raw);
    Assert.areSame(event.data, raw.message.data);
    Assert.areSame(event.verb, raw.message.data.verb);
    Assert.areSame(event.metadata, raw.message.metadata);
	}
}