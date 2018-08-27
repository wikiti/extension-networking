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

    Assert.areEqual(session.mode, NetworkMode.SERVER);
    Assert.areEqual(session.params, params);
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

    Assert.areEqual(session.mode, NetworkMode.CLIENT);
    Assert.areEqual(session.params, params);
    Assert.isNotNull(session.network_item);
    Assert.isType(session.network_item, Client);
  }

  @Test
  public function testTriggerEvent() {
    var params = { ip: '0.0.0.0', port: 9999, max_connections: 4, uuid: 'server_test_id' };
    var session = new Session(NetworkMode.CLIENT, params);

    Assert.areEqual(session.eventsQueue().length(), 0);
    session.triggerEvent(NetworkEvent.INIT_SUCCESS, {});
    Assert.areEqual(session.eventsQueue().length(), 1);
  }
}