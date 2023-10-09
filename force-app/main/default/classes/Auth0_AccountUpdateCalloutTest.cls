@isTest
public class Auth0_AccountUpdateCalloutTest{
    
    @testSetup
    public static void dataSetUp(){
        Id personAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Redemption Consumer').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test';
        acc.LastName = 'Account';
        acc.PersonEmail = 'vrao1188@gmail.com';
        insert acc;
    }
    
    @isTest
    public static void auth0_testMethod1(){
        Test.setMock(HttpCalloutMock.class, new Auth0_MockCalloutResponse());
        Account acc = [SELECT Id, PersonEmail, Previous_Email__c FROM Account WHERE PersonEmail = 'vrao1188@gmail.com'];
        acc.PersonEmail = 'vrao11880@gmail.com';
        update acc;
    }
}