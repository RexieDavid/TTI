@isTest
private class AssetTriggerHandlerTest {
    
    @testSetup
    private static void testData() {
        
        Id b2cRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Consumer Contact').getRecordTypeId();
        Account testAcc = new Account(RecordTypeId = b2cRecTypeId,
                                      PersonEmail = 'test@yahoo.com',
                                      Brand__pc = 'Ryobi',
                                      LastName = 'Test',
                                      FirstName = 'Tester');
                                      
        insert testAcc;

        Product2 p1 = new Product2();
        p1.Name = 'P1';
        p1.Brand__c = 'ML';
        insert p1;
        
        Marketing_Preference__c testMP = new Marketing_Preference__c(Person_Account__c = testAcc.Id);
        insert testMP;
    }
    
    @isTest
	private static void testMethod1() {
	    Account testAcc = [SELECT Id, PersonContactId FROM Account WHERE PersonEmail = 'test@yahoo.com' LIMIT 1];
        Product2 testProduct = [SELECT Id FROM Product2 WHERE Name = 'P1' LIMIT 1];

        Asset testAsset = new Asset(Name = 'Test', 
                                    AccountId = testAcc.Id, 
                                    ContactId = testAcc.PersonContactId, 
                                    Product2Id = testProduct.Id, 
                                    Allow_Numbers_Only__c = true, 
                                    Display_Week__c = true, 
                                    Display_Year__c = true,
                                    HelpText__c = 'Test Helper Text',
                                    Regexpression_Validator__c = 'Exp',
                                    Serial_Number_Length__c = 20);
        insert testAsset;
        
        Asset testAsset2 = [SELECT Id FROM Asset WHERE Id = :testAsset.Id];
        
        Test.startTest();
            delete testAsset2;
        Test.stopTest();
	}
}