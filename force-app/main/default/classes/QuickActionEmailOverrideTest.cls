@isTest
private class QuickActionEmailOverrideTest {
	
	@isTest
	private static void test_method_one() {
		QuickActionEmailOverride qaeo = new QuickActionEmailOverride();
		qaeo.onInitDefaults(new List<QuickAction.QuickActionDefaults>());
		QuickActionEmailOverride.testDummy();
	}

}