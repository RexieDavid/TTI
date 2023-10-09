@isTest
private class TTIBrandsHelperClassTest {

	private static testMethod void getNewReplenishmentButtonTestNotNull() {
        insert new TTIBrandsSiteSettings__c(SetupOwnerId=UserInfo.getOrganizationId(), NewReplenishmentButtonURL__c='www.testurl.com');
        
        Test.startTest();
            String urlTest = TTIBrandsHelperClass.getNewReplenishmentButton();
        Test.stopTest();
	}

	private static testMethod void getNewReplenishmentButtonTestNull() {
        Test.startTest();
            String urlTest = TTIBrandsHelperClass.getNewReplenishmentButton();
            String maxRecords = TTIBrandsHelperClass.getTableMaxRecords();
        Test.stopTest();
	}

}