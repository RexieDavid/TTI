/**
* @author: Francis Nasalita
* @date: Feb 2018
* @description: This class handles the logic for uploading files
* in VAX Registration Page
*/ 
public class FileController {

	public Attachment attachment {get;set;}

	public FileController() {
		attachment = new Attachment();
	}

	public PageReference createReceipt() {
		String status = '';
		try {
			String filename = ApexPages.currentPage().getParameters().get('id');
			Receipts__c	 r = new Receipts__c();
			r.Receipt_Name__c = filename;
			insert r;

			attachment.ParentId = r.Id;
			insert attachment;	

			status = 'success';
		} catch(Exception e) {
			status = 'failed';
		}

		PageReference page = new PageReference('/fileuploader/?status=' + status);
		page.setRedirect(true);

		return page;
	}	
}