@isTest
public class TTI_SearchOrCreateCustomerControllerTest {
/**
* @author: Shivam Singh
* @date: Jan 2018
* @description: Test class for TTI_SearchOrCreateCustomerController.
*/
  
    static testmethod void testTTI_SearchOrCreateCustomerController() {
       Id RecordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Commercial (Trade or Employee)').getRecordTypeId();
       Contact conObj = TTI_CommonUtilityClass.createContact();
       conObj.Brand__c = 'VAX';
       conObj.MobilePhone = '0245675675678';
       conObj.HomePhone = '0245675675679';
       conObj.RecordTypeId = RecordTypeIdContact;
       insert conObj;
       
       //S1 - Scenario when everything is populated
       TTI_SearchOrCreateCustomerController.searchCustomer(conObj.Brand__c, conObj.LastName, conObj.Email, conObj.MobilePhone, conObj.HomePhone);
       //S2 - Scenario when last name and home phone is blank but email and mobile is populated
       TTI_SearchOrCreateCustomerController.searchCustomer(conObj.Brand__c, null, conObj.Email, conObj.MobilePhone, null);
       //S3 - Scenario when email and home phone is blank but lastname and mobile is populated
       TTI_SearchOrCreateCustomerController.searchCustomer(conObj.Brand__c, conObj.LastName, null, conObj.MobilePhone, null);
       //S4 - Scenario when mobile and home phone is blank but lastname and email is populated
       TTI_SearchOrCreateCustomerController.searchCustomer(conObj.Brand__c, conObj.LastName, conObj.Email, null, null);
       //S5 - Scenario when email and mobile is blank but lastname and home phone is populated
       TTI_SearchOrCreateCustomerController.searchCustomer(conObj.Brand__c, conObj.LastName, null, null, conObj.HomePhone);
       //S6 - Scenario when last name and mobile is blank but email and home phone is populated
       TTI_SearchOrCreateCustomerController.searchCustomer(conObj.Brand__c, null, conObj.Email, null, conObj.HomePhone);
       //S7 - Scenario when last name and email is blank but mobile and home phone is populated
       TTI_SearchOrCreateCustomerController.searchCustomer(conObj.Brand__c, null, null, conObj.MobilePhone, conObj.HomePhone);
       //S8 - Scenario when only home phone is blank
       TTI_SearchOrCreateCustomerController.searchCustomer(conObj.Brand__c, conObj.LastName, conObj.Email, conObj.MobilePhone, null);
       //S9 - Scenario when only mobile is blank
       TTI_SearchOrCreateCustomerController.searchCustomer(conObj.Brand__c, conObj.LastName, conObj.Email, null, conObj.HomePhone);
       //S10 - Scenario when only email is blank
       TTI_SearchOrCreateCustomerController.searchCustomer(conObj.Brand__c, conObj.LastName, null, conObj.MobilePhone, conObj.HomePhone);
       //S11 - Scenario when only last name is blank
       TTI_SearchOrCreateCustomerController.searchCustomer(conObj.Brand__c, null, conObj.Email, conObj.MobilePhone, conObj.HomePhone);
       
       
       
    }

}