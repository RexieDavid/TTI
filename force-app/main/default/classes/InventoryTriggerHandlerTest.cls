/**
 * @author:                          Jerome Liwanag
 * @date:                            2017-04
*/
@isTest 
private class InventoryTriggerHandlerTest{

    private static final InventoryTriggerDataService SERVICE = 
        (InventoryTriggerDataService) Test.createStub(InventoryTriggerDataService.class, new InventoryTriggerDataServiceMock());
    private static final String FAIL_TO_ASSIGN_ERR_MESSAGE = 'Failed to assign inventory owners';
    private static final Integer MAX_RECORDS = 1000;
    
    /**********************************************************************
     * @description                     Create dummy admin user
     * 
     * @note                            To fully test the functionality,
     *                                  we need at least two user with
     *                                  valid Id.
     * 
     */
    @TestSetup
    static void makeData() {
        insert createAdminUser();
    }

    /**********************************************************************
     * @description                     Insert inventories with SAP
     *                                  Account number
     * 
     */
    @isTest
    private static void insertInventoriesWithSAPAccount() {
        Test.startTest();
            System.runAs(fetchDummyUser()) {
                InventoryTriggerHandler.service = SERVICE;
                insert TestUtilityClass.createInventories('INV-', MAX_RECORDS);
            }
        Test.stopTest();
        List<Inventory__c> inventories = [SELECT Id FROM Inventory__c WHERE OwnerId != :UserInfo.getUserId()];
        System.assertEquals(MAX_RECORDS, inventories.size(), FAIL_TO_ASSIGN_ERR_MESSAGE);
    }

    /**********************************************************************
     * @description                     Update inventories SAP Account
     *                                  number
     */
    @isTest
    private static void updateInventoriesSAPAccount() {
        InventoryTriggerHandler.service = SERVICE;
        insert TestUtilityClass.createInventories('DUMMY-', MAX_RECORDS);
        List<Inventory__c> inventories = [SELECT Id, SAP_Account__c FROM Inventory__c WHERE OwnerId = :UserInfo.getUserId()];
        System.assertEquals(MAX_RECORDS, inventories.size(), FAIL_TO_ASSIGN_ERR_MESSAGE);

        Test.startTest();
            System.runAs(fetchDummyUser()) {
                for (Integer i = 0; i < MAX_RECORDS; i++) { 
                    inventories[i].SAP_Account__c = 'INV-' + i;
                }
                update inventories;
            }
        Test.stopTest();
        inventories = [SELECT Id FROM Inventory__c WHERE OwnerId != :UserInfo.getUserId()];
        System.assertEquals(MAX_RECORDS, inventories.size(), FAIL_TO_ASSIGN_ERR_MESSAGE);
    }

    /**********************************************************************
     * @description                     Create a simple admin user
     * 
     *                                  No need to bulkify, we just need one
     *                                  record
     */
    private static User createAdminUser() {
        Long uniqueKey = Datetime.now().getTime();
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        return new User(
            Alias = 'sysad', 
            Email = 'systemadminuser' + uniqueKey + '@testorg.com', 
            EmailEncodingKey = 'UTF-8', 
            LastName = 'Testing' + uniqueKey, 
            LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', 
            ProfileId = systemAdminProfile.Id, 
            TimeZoneSidKey = 'America/Los_Angeles', 
            UserName = 'systemadminuser' + uniqueKey + '@testorg.com');
    }

    /**********************************************************************
     * @description                     Fetch dummy admin user
     */
    private static User fetchDummyUser() {
        return [SELECT Id FROM User WHERE Username LIKE 'systemadminuser%' LIMIT 1];
    }
}