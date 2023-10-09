@isTest
public class TTI_SaveAndCompleteButtonOnTaskClassTest {
    
    /**
* @author: Shivam Singh
* @date: Jan 2018
* @description: Test class for TTI_SaveAndCompleteButtonOnTaskClass.
*/
    static testmethod void testTTI_SaveAndCompleteButtonOnTaskClass() {
        Group g1 = new Group(Name='group name', type='Queue');
        insert g1;
        QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
        insert q1;
        
        User u = new User(Id=userinfo.getuserid());
        
        system.runAs(u){
            TTI_queueid__c queuiId = new TTI_queueid__c();
            queuiId.Name = 'Warranty Service Request Approval';
            queuiId.id__c = q1.Id;
            insert queuiId;
            list<TTI_Template__c> template = new list<TTI_Template__c>();
            TTI_Template__c consignmentNoteTemplate = new TTI_Template__c();
            consignmentNoteTemplate.Name = 'ConsignmentNoteTemplate';
            consignmentNoteTemplate.Approved_Claim_Notification_Template__c = 'NotificationContainingFreightCompanyConsignmentNoteTemplate';
            template.add(consignmentNoteTemplate);
            
            TTI_Template__c rejectedWarrantyClaimTemplate = new TTI_Template__c();
            rejectedWarrantyClaimTemplate.Name = 'TTI_RejectedWarrantyClaimTemplate';
            rejectedWarrantyClaimTemplate.Approved_Claim_Notification_Template__c = 'TTI_RejectedWarrantyClaimTemplate';
            template.add(rejectedWarrantyClaimTemplate);
            
            TTI_Template__c warrantyClaimApprovedNotification = new TTI_Template__c();
            warrantyClaimApprovedNotification.Name = 'TTI_WarrantyClaimApprovedNotification';
            warrantyClaimApprovedNotification.Approved_Claim_Notification_Template__c = 'TTI_WarrantyClaimApprovedNotification';
            template.add(warrantyClaimApprovedNotification);
            
            TTI_Template__c emailsentToTheServiceAgentTemplate = new TTI_Template__c();
            emailsentToTheServiceAgentTemplate.Name = 'TTI_EmailsentToTheServiceAgentTemplate';
            emailsentToTheServiceAgentTemplate.Approved_Claim_Notification_Template__c = '';
            template.add(emailsentToTheServiceAgentTemplate);
            
            TTI_Template__c rejectedNonWarrantyClaimToCustomer = new TTI_Template__c();
            rejectedNonWarrantyClaimToCustomer.Name = 'TTI_RejectedNonWarrantyClaimToCustomer';
            rejectedNonWarrantyClaimToCustomer.Approved_Claim_Notification_Template__c = 'TTI_RejectedNonWarrantyClaimToCustomer';
            template.add(rejectedNonWarrantyClaimToCustomer);
            
            insert template;
            
            Case caseObj = TTI_CommonUtilityClass.createCase();
            insert caseObj;
            
            Task taskObj = TTI_CommonUtilityClass.createTask();
            taskObj.WhatId = caseObj.Id;
            taskObj.Outcome__c = 'Test';
            insert taskObj;
            
            TTI_SaveAndCompleteButtonOnTaskClass.updateStatusOfTask(taskObj.Id);
            Test.startTest();
            Task objTask = TTI_CommonUtilityClass.createTask();
            objTask.WhatId = caseObj.Id;
            insert objTask;
            Test.stopTest();
            TTI_SaveAndCompleteButtonOnTaskClass.updateStatusOfTask(objTask.Id);
            
            
        }
        
    }
    
}