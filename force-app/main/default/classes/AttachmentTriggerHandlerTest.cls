@isTest
private class AttachmentTriggerHandlerTest {

    @isTest
    private static void myUnitTest() {
    	Account acct = new Account(Name = 'Test Account');
    	insert acct;

    	Opportunity om = new Opportunity(Name = 'Name', AccountId = acct.Id, StageName = GlobalConstantUtility.OPPORTUNITY_STAGENAME_STAGE, CloseDate = System.today());
    	insert om;

    	System.assertEquals(om.Name, 'Name');

        Attachment attach = new Attachment(); 
        attach.Name = 'Unit Test Attachment';
        attach.Body = Blob.valueOf('Unit Test Attachment Body'); 
        attach.ParentId = om.Id;
        insert attach;
        
        List<Attachment> attachments = [SELECT Id, Name FROM Attachment WHERE ParentId = :om.Id]; 
        System.assertEquals(1, attachments.size());
        	
        attach = [SELECT Id, Name FROM Attachment WHERE ParentId = :om.Id];

    	om.Document_Attached__c = true;
    	update om;

		delete attach;
    	om.Document_Attached__c = false;
    	update om;
    
    	undelete attach;
    	om.Document_Attached__c = true;
    	update om;
    }
}