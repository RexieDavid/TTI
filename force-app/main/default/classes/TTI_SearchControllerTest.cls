/**
 * @File Name          : TTI_SearchControllerTest.cls
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
public class TTI_SearchControllerTest {

    private static Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Agent').getRecordTypeId();
    private static Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
    private static Date fromDate = Date.parse('01/01/1960');
    private static Date toDate = Date.parse('01/02/2075');
    
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
    }
    
    /**
     * Search service request cases
     */
    @IsTest
    static void positiveSearch() {
        Test.startTest();
        User getUser = [SELECT Id, Alias FROM User WHERE Alias = 'test123' LIMIT 1];
        Case getCase = [SELECT Id, CaseNumber, SuppliedEmail, SuppliedPhone, Freight_in_consignment_number__c,
                            TTI_Service_Agent_Job_Number__c FROM Case WHERE TTI_Service_Agent_Job_Number__c = '12345'];
        
        System.runAs(getUser) {
            TTI_SearchController.doSearchServiceReq(getCase.CaseNumber,
                                                    '',
                                                    '', 
                                                    '',
                                                    '', 
                                                    '', 
                                                    getCase.Freight_in_consignment_number__c, 
                                                    true,
                                                    getCase.TTI_Service_Agent_Job_Number__c, 
                                                    String.valueOf(fromDate), 
                                                    String.valueOf(toDate));
         }
        Test.stopTest();
        Case confirmCase = [SELECT CaseNumber FROM Case WHERE Id = :getCase.Id];
        System.assertEquals(getCase.CaseNumber, confirmCase.CaseNumber, 'No Records Found'); 
    }
    
    /**
     * Checks if search service request fails
     */
    @IsTest
    static void negativeSearch() {
        String errorMessage;
        Test.startTest();
        try {
            User getUser = [SELECT Id, Alias FROM User WHERE Alias = 'test123' LIMIT 1];
            System.runAs(getUser) {
                TTI_SearchController.doSearchServiceReq('', 
                                                        'testing', 
                                                        '', 
                                                        '', 
                                                        '', 
                                                        '', 
                                                        '', 
                                                        true, 
                                                        '',  
                                                        String.valueOf(fromDate), 
                                                        String.valueOf(toDate));
            }
        } catch (Exception e) {
            errorMessage = e.getMessage();
        }
        Test.stopTest();
        System.assertEquals('We could not accurately locate the service request you are looking for. Please try again', errorMessage, 'Successfully search claim record');
    }
}