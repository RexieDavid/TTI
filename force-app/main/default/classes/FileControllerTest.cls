@isTest
private class FileControllerTest {
	
	@isTest static void testCreateReceipt() {
		String filename = 'test123';
		Test.startTest();

    		ApexPages.currentPage().getParameters().put('id',filename);
    		FileController controller = new FileController();
    		controller.attachment.Body = Blob.valueOf('test');
    		controller.attachment.Name = 'test';
    		controller.createReceipt();

    		Receipts__c r = [SELECT Id, Receipt_Name__c FROM Receipts__c WHERE Receipt_Name__c = :filename];
    		System.assertEquals(filename, r.Receipt_Name__c);

    		Attachment a = [SELECT Id, ParentId FROM Attachment WHERE ParentId = :r.Id];
    		System.assertEquals(r.Id, a.ParentId);
		Test.stopTest();
	}
	
}