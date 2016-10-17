import massive.munit.TestSuite;

import NetworkEventsQueueTest;
import NetworkEventTest;
import NetworkLoggerTest;
import NetworkMessageTest;
import NetworkSerializerTest;
import NetworkTest;
import SessionTest;
import UtilsTest;

/**
 * Auto generated Test Suite for MassiveUnit.
 * Refer to munit command line tool for more information (haxelib run munit)
 */

class TestSuite extends massive.munit.TestSuite
{		

	public function new()
	{
		super();

		add(NetworkEventsQueueTest);
		add(NetworkEventTest);
		add(NetworkLoggerTest);
		add(NetworkMessageTest);
		add(NetworkSerializerTest);
		add(NetworkTest);
		add(SessionTest);
		add(UtilsTest);
	}
}
