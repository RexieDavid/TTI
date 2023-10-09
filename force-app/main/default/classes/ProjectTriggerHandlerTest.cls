@isTest
private class ProjectTriggerHandlerTest {
    
    private static Id jssRecTypeId = Schema.SObjectType.Region__c.getRecordTypeInfosByName().get('Industrial JSS Region').getRecordTypeId();
    
    @testSetup
    private static void testData() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='teststandard@testing.com', TTI_SAP_Cust_No__c='12345', Division = 'Industrial');
        insert u;
        
        Region__c testRegion = new Region__c(recordTypeId = jssRecTypeId, Assigned_to__c = u.Id, Region_Name__c = 'Test Region', Region_State__c = 'NSW');
        insert testRegion;
        
        Postcode__c testPostCode = new Postcode__c(JSS_Region__c = testRegion.Id, Postcode__c = '1234', Territory__c = 'NSW');
        insert testPostCode;
        
        State_Names__c cs2 = new State_Names__c();
        cs2.Name='Test';
        cs2.State__c = 'Earl';
        cs2.State_ABV__c = 'EAS';
        insert cs2;
    }
    
	private static testMethod void testMethod1() {
        Project__c testProject = new Project__c(State__c = 'NSW', Postcode__c = '1234');
        insert testProject;
        
        testProject = [SELECT OwnerId, Id FROM Project__c WHERE Postcode__c = '1234'];
        User u  = [SELECT Id FROM User WHERE TTI_SAP_Cust_No__c = '12345'];
        
        system.assertEquals(u.Id, testProject.OwnerId);
        
        update testProject;
	}

}