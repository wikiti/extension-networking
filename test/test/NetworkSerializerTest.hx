package;

import massive.munit.Assert;
import networking.utils.NetworkSerializer;


class NetworkSerializerTest {
  @Test
  public function testSerialization() {
    var data = { data: 'data' };
    var msg = NetworkSerializer.serialize(data);

    Assert.isType(msg, String);

    var parsed = NetworkSerializer.unserialize(msg);

    Assert.isType(parsed, Dynamic);
    Assert.areEqual(parsed.data, data.data);
  }
}