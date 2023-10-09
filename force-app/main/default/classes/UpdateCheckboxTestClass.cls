@isTest
private class UpdateCheckboxTestClass {

static testMethod void myUnitTest() {

	Account acct = new Account(Name = 'Test Account');
	insert acct;

	Opportunity om = new Opportunity(Name = 'Name', AccountId = acct.Id, StageName = 'Stage', CloseDate = System.today());
	insert om;

	System.assertEquals(om.name, 'Name');

    Attachment attach=new Attachment(); 
    attach.Name='Unit Test Attachment'; 
    Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body'); 
    attach.body=bodyBlob; attach.parentId=om.id;
    insert attach;
    
    List<Attachment> attachments=[select id, name from Attachment where parent.id=:om.id]; 
    System.assertEquals(1, attachments.size());
    	
    attach = [SELECT Id, name from Attachment where parent.id=:om.id];

    	om.Document_Attached__c=True;
    	update om;

		delete attach;
    	om.Document_Attached__c =False;
    	update om;
    
    	undelete attach;
    	om.Document_Attached__c =True;
    	update om;
    
    

    }
}