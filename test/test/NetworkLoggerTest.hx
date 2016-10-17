package;

import massive.munit.Assert;
import networking.utils.NetworkEvent;
import networking.utils.NetworkLogger;
import networking.utils.NetworkLogger.NetworkLogLevel;

class NetworkLoggerTest {
  @Test
	public function testLogging() {
    NetworkLogger.error(null);
    NetworkLogger.event(new NetworkEvent(NetworkEvent.INIT_SUCCESS, null, null));
    NetworkLogger.log('Message', NetworkLogLevel.Info);
	}
}