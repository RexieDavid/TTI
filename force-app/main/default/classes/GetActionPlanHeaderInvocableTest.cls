/**
* @author Capgemini
* @date 2021-12-14
* @description Test class for the GetActionPlanHeaderInvocable class
*/
@isTest
private class GetActionPlanHeaderInvocableTest {
  
    private static Id actionPlanTemplateRecordTypeId = Schema.SObjectType.Action_Plan_Template_Header__c.getRecordTypeInfosByDeveloperName().get('Store_Visit_Template').getRecordTypeId();
    private static Id b2cRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Consumer Contact').getRecordTypeId();
    private static Id b2rEventRecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Retail_Store_Visit_B2R').getRecordTypeId();
    @TestSetup
    static void testData(){
        Account testAcc = new Account(RecordTypeId = b2cRecTypeId,
                                        PersonEmail = 'test@ryobi.com.au',
                                        Brand__pc = 'Ryobi',
                                        LastName = 'Test',
                                        FirstName = 'Tester'); 
        Insert testAcc;
        Action_Plan_Template_Header__c testPlanTemplateHeader = new Action_Plan_Template_Header__c(Name='Test Action Plan Header 1', IsActive__c = true, Sales_Representative_Channel__c = 'Sales - Sales Executive;Sales - Trade Field Specialist;Sales Executive - Trade', RecordtypeId = actionPlanTemplateRecordTypeId);
        Insert testPlanTemplateHeader;
        Action_Plan_Template__c testActionPlanTemplate = new Action_Plan_Template__c(Title__c='Test TiTle',Action_Plan_Header_Template_Id__c = testPlanTemplateHeader.id, IsActive__c = true, Summary__c='Test Summary');
        Insert testActionPlanTemplate;
    }  
        
    static testMethod void invocableTestWithChannel() {
        Test.startTest();
        Account testAccount = [Select Id From Account Where PersonEmail = 'test@ryobi.com.au'];            
        Event  event = new Event ();
        event.WhatId = testAccount.Id;
        event.Subject='Send Letter/Quote';
        event.StartDateTime=system.now();
        event.EndDateTime=system.now()+10;
        event.Type__c= 'Sales Call';
        event.Sub_Type__c = 'Store Call';
        event.RecordtypeId = b2rEventRecordTypeId;
        insert event;            
            //to makesure test class is cover, need to call invocable class directly, which in this scenario GetActionPlanHeaderInvocable
            // inner class 
        List<GetActionPlanHeaderInvocable.Requests> listRequest = new List<GetActionPlanHeaderInvocable.Requests>();
        GetActionPlanHeaderInvocable.Requests req = new GetActionPlanHeaderInvocable.Requests();
        req.userChannel = 'Sales - Sales Executive';
        listRequest.add(req);    
        //the call the method directly - execute
        List<GetActionPlanHeaderInvocable.Results> results = GetActionPlanHeaderInvocable.execute(listRequest);
        System.assert(String.isNotBlank(results[0].actionPlanTemplateHeaderId), 'Action Plan Header Id Not Found');
        Test.stopTest();
    }

    static testMethod void invocableTestWithNoChannel() {
        Test.startTest();
            //to makesure test class is cover, need to call invocable class directly, which in this scenario GetActionPlanHeaderInvocable
            // inner class 
        List<GetActionPlanHeaderInvocable.Requests> listRequest = new List<GetActionPlanHeaderInvocable.Requests>();
        GetActionPlanHeaderInvocable.Requests req = new GetActionPlanHeaderInvocable.Requests();
        req.userChannel = '';
        listRequest.add(req);    
        //the call the method directly - execute
        List<GetActionPlanHeaderInvocable.Results> results = GetActionPlanHeaderInvocable.execute(listRequest);
        System.assert(String.isBlank(results[0].actionPlanTemplateHeaderId), 'Action Plan Header Id Found');
        Test.stopTest();
    }

    static testMethod void invocableTestWithDifferentChannel() {
        Test.startTest();
            //to makesure test class is cover, need to call invocable class directly, which in this scenario GetActionPlanHeaderInvocable
            // inner class 
        List<GetActionPlanHeaderInvocable.Requests> listRequest = new List<GetActionPlanHeaderInvocable.Requests>();
        GetActionPlanHeaderInvocable.Requests req = new GetActionPlanHeaderInvocable.Requests();
        req.userChannel = 'Not Existed';
        listRequest.add(req);    
        //the call the method directly - execute
        List<GetActionPlanHeaderInvocable.Results> results = GetActionPlanHeaderInvocable.execute(listRequest);
        System.assert(String.isBlank(results[0].actionPlanTemplateHeaderId), 'Action Plan Header Id Found');
        Test.stopTest();
    }
}