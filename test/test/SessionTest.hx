package;

import massive.munit.Assert;
import networking.sessions.Session;
import networking.sessions.client.Client;
import networking.sessions.server.Server;
import networking.utils.NetworkEvent;
import networking.utils.NetworkMode;

class SessionTest {
  @Test
	public function testServerCreation() {
    var params = { ip: '0.0.0.0', port: 9999, max_connections: 4, uuid: 'server_test_id' };
    var session = new Session(NetworkMode.SERVER, params);

    Assert.isNotNull(session);
    session.start();

    Assert.areSame(session.mode, NetworkMode.SERVER);
    Assert.areSame(session.params, params);
    Assert.isNotNull(session.network_item);
    Assert.isType(session.network_item, Server);

    session.stop();
	}

  @Test
	public function testClientCreation() {
    var params = { ip: '0.0.0.0', port: 9999, max_connections: 4, uuid: 'server_test_id' };
    var session = new Session(NetworkMode.CLIENT, params);

    Assert.isNotNull(session);
    session.start();

    Assert.areSame(session.mode, NetworkMode.CLIENT);
    Assert.areSame(session.params, params);
    Assert.isNotNull(session.network_item);
    Assert.isType(session.network_item, Client);
	}

  @Test
  public function testTriggerEvent() {
    var params = { ip: '0.0.0.0', port: 9999, max_connections: 4, uuid: 'server_test_id' };
    var session = new Session(NetworkMode.CLIENT, params);

    Assert.areSame(session.eventsQueue().length(), 0);
    session.triggerEvent(NetworkEvent.INIT_SUCCESS, {});
    Assert.areSame(session.eventsQueue().length(), 1);
  }
}