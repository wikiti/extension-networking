package;

import massive.munit.Assert;
import networking.utils.NetworkMessage;


class NetworkMessageTest {
  @Test
  public function testCreateRaw() {
    var data = { data: 'data' };
    var msg = NetworkMessage.createRaw(null, null, data);

    Assert.areEqual(msg.data, data);
  }

  @Test
  public function testCreate() {
    var data = { data: 'data' };
    var msg = NetworkMessage.create(null, null, data);

    Assert.isType(msg, String);
  }

  @Test
  public function testParse() {
    var data = { data: 'data' };
    var msg = NetworkMessage.serialize(data);

    Assert.isType(msg, String);

    var parsed = NetworkMessage.parse(msg);

    Assert.isType(parsed, Dynamic);
    Assert.areEqual(parsed.data, data.data);
  }
}