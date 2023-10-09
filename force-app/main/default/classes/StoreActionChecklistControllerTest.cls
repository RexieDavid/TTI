/**
* @author Capgemini
* @date 2022 -01 -07
* @description Test class for the StoreActionChecklistController class
*/
@isTest
private class StoreActionChecklistControllerTest {
    private static Id b2cRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Consumer Contact').getRecordTypeId();
    private static Id b2rEventRecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Retail_Store_Visit_B2R').getRecordTypeId();    
    
    @TestSetup
    static void testData() {
        Account testAccount = new Account(RecordTypeId = b2cRecTypeId,
                                        PersonEmail = 'test@ryobi.com.au',
                                        Brand__pc = 'Ryobi',
                                        LastName = 'Test',
                                        FirstName = 'Tester'); 
        Insert testAccount;

        Event event = new Event ();
        event.WhatId = testAccount.Id;
        event.Subject = 'Store visit Call';
        event.StartDateTime = System.now();
        event.EndDateTime = System.now() + 10;
        event.Type__c = 'Sales Call';
        event.Sub_Type__c = 'Store Call';
        event.RecordtypeId = b2rEventRecordTypeId;
        insert event;

        List<Store_Action_Checklist__c> checklistToBeAdded = new List<Store_Action_Checklist__c>();
        Store_Action_Checklist__c storeChecklist = new Store_Action_Checklist__c();
        storeChecklist.Parent_Event__c = event.Id;
        storeChecklist.Parent_Event_Name__c = event.Subject;
        storeChecklist.AccountId__c = testAccount.Id;
        storeChecklist.Title__c = 'Standard Checklist 1';
        storeChecklist.Summary__c = 'Standard Checklist Summary 1';
        storeChecklist.IsStandard__c = true;
        storeChecklist.TimeTaken__c = 0;
        storeChecklist.IsCompleted__c = false;
        storeChecklist.IsLocked__c = false;
        checklistToBeAdded.add(storeChecklist);

        Store_Action_Checklist__c storeChecklist2 = new Store_Action_Checklist__c();
        storeChecklist2.Parent_Event__c = event.Id;
        storeChecklist2.Parent_Event_Name__c = event.Subject;
        storeChecklist2.AccountId__c = testAccount.Id;
        storeChecklist2.Title__c = 'Standard Checklist 2';
        storeChecklist2.Summary__c ='Standard Checklist Summary 2';
        storeChecklist2.IsStandard__c = true;
        storeChecklist2.TimeTaken__c = 0;
        storeChecklist2.IsCompleted__c = false;
        storeChecklist2.IsLocked__c = false;
        checklistToBeAdded.add(storeChecklist2);

        insert checklistToBeAdded;

        Product2 product = new Product2();
        product.Name = 'test Product';
        product.Brand__c = 'AEG';
        product.IsActive = true;
        product.ProductCode = 'test123';
        product.SAP_Material_Group__c = 'RY-TL';
        insert product;

        Off_Location__c offLoc = new Off_Location__c();
        offLoc.Account__c = testAccount.Id;
        offLoc.Off_Location_Product__c = product.Id;
        offLoc.Status__c = 'Active';
        offLoc.Active__c = true;
        offLoc.In_store_Location__c = 'Entrance/Atrium';
        offLoc.Type__c = 'Double End';
        insert offLoc;
    }  

    static testMethod void getChecklistTest() {
        Test.startTest();
            List<Event> events = [SELECT Id FROM Event Where Type__c = 'Sales Call'];  
            List<Store_Action_Checklist__c> storeChecklists = StoreActionChecklistController.getChecklist(events[0].Id);
            System.assert(storeChecklists.size() == 2, 'Store checklist is not equals to 2');
        Test.stopTest();
    }
    static testMethod void getChecklistWithBlankEventTest() {
        Test.startTest();
            Event  event = new Event ();
            event.Subject = 'Store visit Call22';
            event.StartDateTime = System.now();
            event.EndDateTime = System.now() + 10;
            event.Type__c = 'Meeting';
            event.Sub_Type__c = 'Business Review';
            insert event;

            List<Event> events = [SELECT Id From Event WHERE Type__c = 'Meeting'];  
            List<Store_Action_Checklist__c> storeChecklists = StoreActionChecklistController.getChecklist(events[0].Id);
            System.assert(storeChecklists.size() == 0, 'Store checklist is not equals to 0');
        Test.stopTest();
    }

    static testMethod void saveChecklistTest() {
        Test.startTest();
            List<Event> events = [SELECT  Id, WhatId, Subject From Event Where Type__c = 'Sales Call']; 
            Event event = events[0];
            StoreActionChecklistController.StoreChecklistSavedArgument argument = new StoreActionChecklistController.StoreChecklistSavedArgument();
            List<StoreActionChecklistController.OtherStoreActionChecklistItem> otherCheckListsToBeAdded = new List<StoreActionChecklistController.OtherStoreActionChecklistItem>();
            List<Store_Action_Checklist__c> standardchecklistToBeUpdated = new List<Store_Action_Checklist__c>();
            //standard
            List<Store_Action_Checklist__c> storeChecklists = StoreActionChecklistController.getChecklist(events[0].Id);
            for (Store_Action_Checklist__c storeChecklist : storeChecklists) {
                storeChecklist.TimeTaken__c = 60;
                standardchecklistToBeUpdated.add(storeChecklist);
            } 

            //Other
            StoreActionChecklistController.OtherStoreActionChecklistItem otherItem = new StoreActionChecklistController.OtherStoreActionChecklistItem();
            otherItem.title = 'Other';
            otherItem.summary = 'Summary for Other1';
            otherItem.timeTaken = 15;
            otherItem.isDeleted = false;
            otherCheckListsToBeAdded.add(otherItem);
            StoreActionChecklistController.OtherStoreActionChecklistItem otherItem2 = new StoreActionChecklistController.OtherStoreActionChecklistItem();

            otherItem2.title = 'Other';
            otherItem2.summary = 'Summary for Other2';
            otherItem2.timeTaken = 30;
            otherItem2.isDeleted = false;
            otherCheckListsToBeAdded.add(otherItem2);
            StoreActionChecklistController.OtherStoreActionChecklistItem otherItemDeleted = new StoreActionChecklistController.OtherStoreActionChecklistItem();

            otherItemDeleted.title = 'Other';
            otherItemDeleted.summary = 'Summary for Other1';
            otherItemDeleted.timeTaken = 15;
            otherItemDeleted.isDeleted = true;
            otherCheckListsToBeAdded.add(otherItemDeleted);

            argument.savedchecklist = standardchecklistToBeUpdated;
            argument.otherItems = otherCheckListsToBeAdded;
            
            String outcome = StoreActionChecklistController.doSaveChecklistActionItems(JSON.serialize(argument));
            System.assertEquals('SUCCESS', outcome);

            List<Store_Action_Checklist__c> storeChecklists2 = StoreActionChecklistController.getChecklist(events[0].Id);
            System.assert(storeChecklists2.size() == 4, 'Store checklist is not equals to 4');

            Decimal timeTakenForOther = 0;
            Decimal timeTakenStandard = 0;
            String eventIdUpdated = '';
            String accountIdUpdated = '';
            for (Store_Action_Checklist__c item : storeChecklists2) {
                if (item.Summary__c == 'Summary for Other2' && !item.IsStandard__c) {
                    timeTakenForOther = item.TimeTaken__c;
                }
                if (item.IsStandard__c) {
                    timeTakenStandard = item.TimeTaken__c;
                } else {
                    eventIdUpdated = item.Parent_Event__c;
                    accountIdUpdated = item.AccountId__c;
                }
            }
            System.assert(timeTakenForOther == 30, 'Other checklist did not updated perfectly');
            System.assert(timeTakenStandard == 60, 'Standard Items updated successfully');
            System.assert(eventIdUpdated == event.Id, 'event Id not updated successfully');
            System.assert(accountIdUpdated == event.WhatId, 'Account Id not updated successfully');
        Test.stopTest();
    }

    static testMethod void saveOffLocationTest() {
        List<Event> events = [SELECT  Id, WhatId, Subject From Event Where Type__c = 'Sales Call']; 
        Event event = events[0];
        Test.startTest();
            List<Off_Location__c> offLocList = StoreActionChecklistController.getOffLocation(event.WhatId, event.Id);
            String inputArgument = JSON.serialize(offLocList);
            String result = StoreActionChecklistController.doSaveOffLocationChanges(inputArgument, 'Reviewed', event.Id);
        Test.stopTest();
        System.assertEquals(result, 'SUCCESS');
    }

    static testMethod void getTimeForAllDayEventTest() {
        String response;
        Event event = createEvent(true);
        insert event;
        Test.startTest();
            response = StoreActionChecklistController.getTotalTime(event.Id);
        Test.stopTest();
        System.assertEquals('8 hrs 0 mins ,480', response, 'Failed to retrieved total time for whole day event');
    }

    static testMethod void getTimeForNonAllDayEventTest() {
        String response;
        Event event = createEvent(false);
        insert event;
        Test.startTest();
            response = StoreActionChecklistController.getTotalTime(event.Id);
        Test.stopTest();
        System.assertEquals('5 hrs 0 mins ,300', response, 'Failed to retrieved total time for non all day event');
    }

    private static Event createEvent(Boolean isAllDayEvent) {
        Datetime currDateTime = System.now();
        Event  event = new Event ();
        event.Subject = 'Sales Call';
        event.StartDateTime = currDateTime;
        event.EndDateTime = currDateTime.addHours(5);
        event.Type__c = 'Sales Call';
        event.Sub_Type__c = 'Store Call';
        event.IsAllDayEvent = isAllDayEvent;
        return event;
    }
}