/**
 * @author                          Jerome Liwanag
 * @date                            2017-04
 * @description                     Handles all CRUD operations for the
 *                                  Inventory Trigger. All logic should be placed 
                                    here and not in the trigger itself
 */ 
public with sharing class InventoryTriggerHandler {
    public static final String TTI_PRODUCT_TYPE = 'TTI_Product';
    
    @TestVisible
    public static InventoryTriggerDataService service = new InventoryTriggerDataService();

    /**********************************************************************
     * @description                 Handles all on Before Insert
     *                              functionalities of the Inventory
    */ 
    public static void onBeforeInsert(List<Inventory__c> invList) {
        changeTypeToTTIProduct(invList);
        assignToSapUser(invList);
    }
    
    /**********************************************************************
     * @description                 Handles all on Before Update
     *                              functionalities of the Inventory
    */ 
    public static void onBeforeUpdate(List<Inventory__c> invList, Map<Id,Inventory__c> invOldMap) {
        changeTypeToTTIProduct(invList);
        assignToSapUser(invList);
    }
    
    
    /**********************************************************************
     * @description                 Assigns owner Id to the Inventory
     *                              if there is a user with the same 
     *                              value of SAP Number
    */ 
    public static void assignToSapUser(List<Inventory__c> inventories){
        Map<String, Id> sapUsers = fetchSapUsers(inventories);
        for (Inventory__c inv : inventories) {
            if (sapUsers.containsKey(inv.SAP_Account__c)) {
                inv.OwnerId = sapUsers.get(inv.SAP_Account__c);
            }
        }
    }

    /**********************************************************************
     * @description                 Update inventory record type
    */ 
    private static void changeTypeToTTIProduct(List<Inventory__c> inventories) {
        Id ttiProductType = Schema.SObjectType.Inventory__c
                                .getRecordTypeInfosByDeveloperName()
                                .get(TTI_PRODUCT_TYPE)
                                .getRecordTypeId();
        for (Inventory__c inv : inventories) {
            inv.RecordTypeId = ttiProductType;
        }
    }

    /**********************************************************************
     * @description                 Fetch SAP users
    */ 
    private static Map<String, Id> fetchSapUsers(List<Inventory__c> inventories) {
        Set<String> sapAccountNumbers = fetchSapAccountNumbers(inventories);
        Map<String, Id> sapUsers = new Map<String, Id>();
        for (User user : service.fetchSAPUsers(sapAccountNumbers)) {
            sapUsers.put(user.TTI_SAP_Cust_No__c, user.Id);
        }
        return sapUsers;
    }

    /**********************************************************************
     * @description                 Fetch SAP account numbers
    */ 
    private static Set<String> fetchSapAccountNumbers(List<Inventory__c> inventories) {
        Set<String> sapAccounts = new Set<String>();
        for (Inventory__c inv : inventories) {
            if (String.isNotBlank(inv.SAP_Account__c)) {
                sapAccounts.add(inv.SAP_Account__c);
            }
        }
        return sapAccounts;
    }
}