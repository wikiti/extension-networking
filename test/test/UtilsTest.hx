package;

import massive.munit.Assert;
import networking.utils.Utils;

class UtilsTest {
  @Test
  public function testUuidGeneration() {
    var uuid = Utils.guid();

    var r = ~/^[A-Z0-9]*\-[A-Z0-9]*\-[A-Z0-9]*\-[A-Z0-9]*\-[A-Z0-9]*$/i;
    Assert.isTrue(r.match(uuid));
  }
}