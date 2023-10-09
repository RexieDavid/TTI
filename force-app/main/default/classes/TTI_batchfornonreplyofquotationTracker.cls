@isTest
public class TTI_batchfornonreplyofquotationTracker {
    Private static testmethod void Testbatch(){
        
        Account accObj = TTI_CommonUtilityClass.createAccount();
        Contact conObj = TTI_CommonUtilityClass.createContact();
        
        insert conObj; 
        
        TTI_Non_Warranty_Auto_Reject_Days__c objCS= new TTI_Non_Warranty_Auto_Reject_Days__c();
        objCS.Name='Non Warranty Auto Reject Days';
        objCS.TTI_Non_Warranty_Auto_Reject_Days__c=30;
        insert objCS;
        
        
        TTI_CommonUtilityClass.insertTemplates();
        Case caseObj = TTI_CommonUtilityClass.createCase();
        
        caseObj.Diagnosed_Date__c = System.today().addDays(-3);
        caseObj.Product_Payment_Category__c = 'Generators';
        caseObj.Repair_Type__c = 'Declined Warranty - Inspection fee';
        caseObj.Claim_Type__c = 'Warranty';
        caseObj.Service_Request_Milestone__c = 'New';
        caseObj.Closed_Reason__c = 'Service Request Completed';
        caseObj.TTI_Email_Notification_Opt_In__c = true;
        caseObj.TTI_Customer_Contact__c = conObj.Id;
        caseObj.Invoiced_Approved__c = false;
        caseObj.SuppliedEmail = 'test@test.com';
        insert caseObj;
        
        Attachment objatt= new Attachment();
        objatt.Name = caseObj.CaseNumber+'_Quote.pdf';
        objatt.Body = Blob.valueof('myString');
        objatt.parentId = caseObj.id;
        insert objatt;
        
        Attachment objatt1= new Attachment();
        objatt1.Name = caseObj.CaseNumber+'_Quote.pdf';
        objatt1.Body = Blob.valueof('QWERTRERTYTRT');
        objatt1.parentId = caseObj.id;
        insert objatt1;
        
        caseObj.Service_Request_Milestone__c = 'Awaiting Approval';
        update caseObj;
        caseObj.TTI_Awaiting_Approval_Datetime__c=Date.today().addDays(3);
        update caseObj;
        TTI_batchfornonreplyofquotation obj= new TTI_batchfornonreplyofquotation ();
        TTI_batchfornonreplyofquotationSchedule sh1 = new TTI_batchfornonreplyofquotationSchedule();
        system.debug(Date.today());
        system.debug([SELECT Id,TTI_Is_notification_date__c,TTI_Awaiting_Approval_Datetime__c FROM Case]);
        String sch = '0 0 23 * * ?'; 
        system.schedule('Batch for no reply', sch, sh1); 
    	Database.executeBatch(obj,1);
} 

}