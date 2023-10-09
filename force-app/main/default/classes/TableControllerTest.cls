@isTest
private class TableControllerTest {
	
	@isTest
	private static void test_method_one() {
		TableController.getFieldSet('Active_Redemptions', 'Redemptions__c');
		TableController.getFieldSet('Complete_Redemptions', 'Redemptions__c');
	}
	
}