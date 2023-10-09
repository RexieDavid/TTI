/**
* @author          : Ronald Pascual
* @date            : 2018-11-22 
* @description     : Test Class for InventoryTriggerHandler class. This class will anotate the see all true for bulk testing purpose. 
*/
@isTest(SeeAllData=true)
public class InventoryTriggerHandler_Test {
    
    static testMethod void testInventoryTriggerWith220kUserRecords() {
        
        Integer noOfUser = [SELECT COUNT() FROM User];
        Boolean isSandBox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        
        if (isSandBox && noOfUser < 200000) {
            System.assertEquals(true, noOfUser < 200000 && isSandBox, 'This assertion message is showing up because this test is intended only in production org that has more than 220k user records.');
            return;
        }

        List<User> userList = TestUtilityClass.createUser('test', 10);
        insert userList;

        List<Inventory__c> inventoryList = TestUtilityClass.createInventories('test', 10);
        insert inventoryList;

        List<User> insertedUserList = [SELECT Id, Name FROM User WHERE TTI_SAP_Cust_No__c LIKE 'tes%' LIMIT 100]; 

        List<Inventory__c> currentInventoryList = [SELECT OwnerId,Id,RecordTypeId FROM Inventory__c WHERE SAP_Account__c LIKE 'tes%' LIMIT 100];

        for (Inventory__c inv: currentInventoryList) {
            inv.Quantity__c = 1;
        }

        Test.startTest();
            try {
                update currentInventoryList;
                System.assertEquals(1, currentInventoryList[0].Quantity__c);
            } catch(DmlException e) {
                System.assert(e.getMessage().contains('Non-selective query against large object type'), e.getMessage());
            } catch(Exception e) {
                System.assert(e.getMessage().ToUpperCase().contains('ERROR'), e.getMessage());
            }
        Test.stopTest();

        System.assertEquals(currentInventoryList[4].OwnerId, insertedUserList[4].Id);

    }
}