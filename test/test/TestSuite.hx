import massive.munit.TestSuite;

import NetworkLoggerTest;
import NetworkEventsQueueTest;
import SessionTest;
import UtilsTest;
import NetworkEventTest;
import NetworkMessageTest;
import NetworkTest;
import NetworkSerializerTest;

/**
 * Auto generated Test Suite for MassiveUnit.
 * Refer to munit command line tool for more information (haxelib run munit)
 */
class TestSuite extends massive.munit.TestSuite
{
  public function new()
  {
    super();

    add(NetworkLoggerTest);
    add(NetworkEventsQueueTest);
    add(SessionTest);
    add(UtilsTest);
    add(NetworkEventTest);
    add(NetworkMessageTest);
    add(NetworkTest);
    add(NetworkSerializerTest);
  }
}
