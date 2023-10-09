@isTest
public class TTI_TaskTriggerHandlerTest {
    
    static testmethod void test1() {
        Group g1 = new Group(Name='group name', type='Queue');
        insert g1;
        QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
        insert q1;
        
        User userObj = new User(Id=userinfo.getuserid());
        Account accObj = TTI_CommonUtilityClass.createAccount();
        Contact conObj = TTI_CommonUtilityClass.createContact();
        system.runAs(userObj){
         insert conObj;
        }
        
        User u = TTI_CommonUtilityClass.createUser();
        u.ContactId = conObj.Id;
        insert u;
        
        system.runAs(u){

            TTI_queueid__c queuiId = new TTI_queueid__c();
            queuiId.Name = 'Warranty Service Request Approval';
            queuiId.id__c = q1.Id;
            insert queuiId;
            
            TTI_CommonUtilityClass.insertTemplates();
            
            Case caseObj = TTI_CommonUtilityClass.createCase();
            insert caseObj;
            Test.startTest();
            Task taskObj = TTI_CommonUtilityClass.createTask();
            taskObj.OwnerId = u.Id;
            taskObj.WhatId = caseObj.Id;
             
            insert taskObj;
            Task tasToUpdate = new Task(Id=taskObj.Id, Outcome__c='Call', Status='Completed', Priority='Normal', subject='Service Request Approval More Information Required');
            update tasToUpdate;
            Test.stopTest();
        }
    }
    
}