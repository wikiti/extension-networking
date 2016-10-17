package;

import massive.munit.Assert;
import networking.Network;
import networking.utils.NetworkMode;

class NetworkTest {
  @After @Before
  public function tearDown() {
    while (Network.sessions.length > 0) {
      Network.sessions.pop();
    }
  }

  @Test
	public function testRegisterClientSession() {
    var session = Network.registerSession(NetworkMode.CLIENT);

    Assert.isNotNull(session);
    Assert.areSame(Network.sessions.length, 1);
    Assert.areSame(session, Network.sessions[0]);
	}

  @Test
	public function testRegisterServerSession() {
    var session = Network.registerSession(NetworkMode.SERVER);

    Assert.isNotNull(session);
    Assert.areSame(Network.sessions.length, 1);
    Assert.areSame(session, Network.sessions[0]);
	}

  @Test
	public function testDestroyClientSession() {
    var session = Network.registerSession(NetworkMode.CLIENT);
    Assert.areSame(Network.sessions.length, 1);

    Assert.isFalse(Network.destroySession(session, false));
    Assert.areSame(Network.sessions.length, 0);
	}

  @Test
	public function testDestroyServerSession() {
    var session = Network.registerSession(NetworkMode.SERVER);
    Assert.areSame(Network.sessions.length, 1);

    Assert.isFalse(Network.destroySession(session, false));
    Assert.areSame(Network.sessions.length, 0);
	}
}