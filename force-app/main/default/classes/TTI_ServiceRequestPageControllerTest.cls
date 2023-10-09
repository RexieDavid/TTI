/**
 * @File Name          : TTI_ServiceRequestPageControllerTest.cls
 * @Description        : 
 * @Author             : 
 * @Group              : 
 * @Last Modified By   : Ericka Cajucom
 * @Last Modified On   : 28/08/2020
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    28/08/2020, 9:42:01 AM   Ericka Cajucom     removed hack() method
**/
@isTest
public class TTI_ServiceRequestPageControllerTest {
    private static Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Agent').getRecordTypeId();
    private static Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
    
    /**
     * Create necessary data for test class
     */
    @testSetup
    static void createRecords() {
        Id profId = [SELECT id FROM Profile WHERE name = '~Customer Community Warranty'].Id;
        Account objAccount = new Account();
        objAccount.Name = 'Service Agent - External';
        objAccount.RecordTypeId = accountRecordTypeId;
        insert objAccount;

        Contact objContact = new Contact();
        objContact.FirstName ='Josh';
        objContact.LastName ='Smith';
        objContact.Email = 'joshSmith@gmail.com';
        objContact.Phone = '+61403839591';
        objContact.AccountId = objAccount.Id;
        insert objContact;  
        
        User objUser = new User();
        objUser.alias = 'test123';
        objUser.email = 'test123@noemail.com';
        objUser.emailencodingkey = 'UTF-8'; 
        objUser.lastname = 'Testing';
        objUser.languagelocalekey = 'en_US';
        objUser.localesidkey = 'en_US';
        objUser.profileid = profId;
        objUser.country = 'United States';
        objUser.IsActive = true;
        objUser.ContactId = objContact.Id;
        objUser.timezonesidkey = 'America/Los_Angeles';
        objUser.username = 'tester@noemail.com';
        insert objUser;
        
        Case objCase = new Case();
        objCase.AccountId = objAccount.Id;
        objCase.Subject = 'Service Request for M18FID-0';
        objCase.Status = 'In Progress';
        objCase.Priority = 'Critical';
        objCase.RecordTypeId = caseRecordTypeId;
        objCase.TTI_Customer_Account__c = objAccount.Id;
        objCase.SuppliedEmail = 'joshSmith@gmail.com';
        objCase.SuppliedPhone = '+61403839591';
        objCase.Freight_in_consignment_number__c = '12345';
        objCase.TTI_Service_Agent_Job_Number__c = '12345';
        insert objCase;
        
        TTIBrandsSiteSettings__c objBrandsSiteSetting = new TTIBrandsSiteSettings__c();
        objBrandsSiteSetting.NewReplenishmentButtonURL__c = 'https://ttisp-ttibrandsanz.cs31.force.com/ttiservice/s/replenishment';
        objBrandsSiteSetting.Case_Lists_No_Records_to_Display__c = '5';
        insert objBrandsSiteSetting;
    }
    
    /**
     * Fetch case record via filter
     */
    @isTest
    static void getCasedeatilsTest() {
        String result;
        User eUser = [SELECT Id, Name, AccountId FROM User WHERE ContactId IN (SELECT Id FROM Contact) LIMIT 1];
        Test.startTest();
        System.runAs(eUser) {
            result = TTI_ServiceRequestPageController.getCasedeatils('AccountId != NULL', 'Id');
        }
        Test.stopTest();
        System.assert(String.isNotBlank(result), 'Did not fetch any case records');
    }
    
    /**
     * Search service request cases
     */
    @IsTest
    static void testDoSearchServiceReq() {
        Test.startTest();
        User getUser = [SELECT Id, Alias FROM User WHERE Alias = 'test123' LIMIT 1];
        Case getCase = [SELECT Id, CaseNumber, SuppliedEmail, SuppliedPhone, Freight_in_consignment_number__c,
                            TTI_Service_Agent_Job_Number__c FROM Case WHERE TTI_Service_Agent_Job_Number__c = '12345'];
        
        System.runAs(getUser) {
            TTI_ServiceRequestPageController.doSearchServiceReq(getCase.CaseNumber);
         }
        Test.stopTest();
        Case confirmCase = [SELECT CaseNumber FROM Case WHERE Id = :getCase.Id];
        System.assertEquals(getCase.CaseNumber, confirmCase.CaseNumber, 'No Records Found'); 
    }
    
    /** 
     * Fetch current user details
     */
    @isTest
    static void testGetUserType() {
        User resultUser;
        User eUser = [SELECT Id, Name FROM User WHERE ContactId IN (SELECT Id FROM Contact) LIMIT 1];
        Test.startTest();
        System.runAs(eUser) {
            resultUser = TTI_ServiceRequestPageController.getUserType();
        }
        Test.stopTest();
        System.assertEquals(eUser.Id, resultUser.Id, 'User did not exist');
    }
    
    /** 
     * Fetch Table Max Records
     */
    @isTest
    static void testGetTableMaxRecords() {
        TTIBrandsSiteSettings__c bSSetting = [SELECT Id, NewReplenishmentButtonURL__c, Case_Lists_No_Records_to_Display__c FROM TTIBrandsSiteSettings__c LIMIT 1];
        
        String result;
        User eUser = [SELECT Id, Name FROM User WHERE ContactId IN (SELECT Id FROM Contact) LIMIT 1];
        Test.startTest();
        System.runAs(eUser) {
            result = TTI_ServiceRequestPageController.getTableMaxRecords();
        }
        Test.stopTest();
        System.assertEquals(bSSetting.Case_Lists_No_Records_to_Display__c, result, 'No case records to display');
    }
}