/**
* @author      : Ericka Cajucom
* @date        : 2020-05-15
*/
@isTest
private class BatchUpdateBciAccountAssignmentsTest {
    
    private static final String NO_RECORD_UPDATED = 'No Records Were Updated';
    
    @testSetup
    static void testDataSetup() {
        
        Profile stdUsrProfile = [SELECT Id FROM Profile WHERE Name='Standard User'];
        
        List<User> stdUsers = new List<User>();
        for(integer i = 0; i < 2; i++){
            User stdUser = new User(Alias = 'standt' + i,
                            Email ='standarduser@testorg.com',
                            EmailEncodingKey = 'UTF-8',
                            LastName = 'Testing',
                            LanguageLocaleKey = 'en_US',
                            LocaleSidKey = 'en_US',
                            ProfileId = stdUsrProfile.Id,
                            TimeZoneSidKey = 'America/Los_Angeles',
                            UserName = 'teststandard' + i + '@testing.com',
                            TTI_SAP_Cust_No__c='1234' + i,
                            Division = 'Industrial');
            stdUsers.add(stdUser);
        }
        insert stdUsers;
        
        Region__c region = new Region__c(Region_Name__c = 'testTegion', Assigned_to__c = stdUsers[1].id);
        insert region;
        
        Postcode__c nPostCode = new Postcode__c(Suburb__c = 'test Suburb',
                                Postcode__c = '9999',
                                JSS_Region__c = region.id);
        insert nPostCode;
        
        List<Account> accList = new List<Account>();
        for(integer i = 0; i < 10; i++){
            Account accountBCIData = new Account(Name = 'Valtymore' + i, 
                                TTI_SAP_Cust_No__c = '1234' + i,
                                Sales_Organisation__c ='BP01',
                                AccountSource = 'BCI Data',
                                Lock_Record_Owner__c  = false,
                                BillingPostalCode = nPostCode.Postcode__c,
                                OwnerID = stdUsers[0].id);
            accList.add(accountBCIData);
        }
        insert accList;
      
    }
    
    /**********************************************************************
    * @description Update account owner id to the postcode region assigned to
    */
    private static testmethod void testBatchUpdateBCIAccountAssignments() {
   
        Test.startTest();
        Batch_Update_BCI_Account_Assignments obj = new Batch_Update_BCI_Account_Assignments();
        DataBase.executeBatch(obj);
        Test.stopTest();
        
        List<Account> accList = [SELECT OwnerId FROM Account];
        Postcode__c postCode = [SELECT Postcode__c, JSS_Region__r.Assigned_to__c FROM Postcode__c];
        
        System.assertEquals(postCode.JSS_Region__r.Assigned_to__c, accList[0].OwnerId, NO_RECORD_UPDATED);
        
    }
}