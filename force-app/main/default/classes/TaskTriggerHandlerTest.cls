@isTest
private class TaskTriggerHandlerTest {
    
	private static testMethod void testMethod1() {
	    Id b2cRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Consumer Contact').getRecordTypeId();
	    Account acc = new Account(LastName = 'Last', FirstName = 'First', Brand__pc = 'Ryobi' , Country__pc = 'Australia', personMobilePhone = '1234', recordTypeId=b2cRecTypeId);
	    insert acc;
	    
	    Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='teststandard@testing.com', TTI_SAP_Cust_No__c='12345', Division = 'Industrial',NVMContactWorld__NVM_Agent_Id__c='12341');
        insert u;
	    
	    Post_Call_Survey__c pcs = new Post_Call_Survey__c(Call_Guid__c = 'test');
	    insert pcs;
	    
	    system.runAs(u){
            List<Task> taskList = new List<Task>();
            taskList.add(new Task(CallObject = 'test',whatId = acc.ID, subject='Subj'));
            insert taskList;
	    }
        
	}

}