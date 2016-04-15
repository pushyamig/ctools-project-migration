package junit.edu.umich.its.cpmtest;

import static org.junit.Assert.*;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import junit.framework.TestCase;

import edu.umich.its.cpm.Utils;

public class UtilsTest extends TestCase {

	@BeforeClass
	public static void setUpBeforeClass() throws Exception {
	}

	@AfterClass
	public static void tearDownAfterClass() throws Exception {
	}

	@Before
	public void setUp() throws Exception {
	}

	@After
	public void tearDown() throws Exception {
	}

	@Test
	public void testSanitizeName() {
		// escape back slash
		assertEquals(Utils.sanitizeName("folder", "test \\ folder"), "test _ folder");
		
		// escape forward slash
		assertEquals(Utils.sanitizeName("folder", "test / folder"), "test _ folder");
		
		// escape : 
		assertEquals(Utils.sanitizeName("folder", "test : folder"), "test _ folder");
		
		// URL as name
		assertEquals(Utils.sanitizeName(Utils.CTOOLS_RESOURCE_TYPE_CITATION, "http://www.npr.org/"), "http___www.npr.org_.html");
	
		// string without extension
		assertEquals(Utils.sanitizeName(Utils.CTOOLS_RESOURCE_TYPE_CITATION, "test_url"), "test_url.html");
			
	}

}
