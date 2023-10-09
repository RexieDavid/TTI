@IsTest
public class TTI_FreightCompanyAPI_Tracker {
    
    private static testmethod void CourierPost()
    {
        Id serviceAgentId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Agent').getRecordTypeId();
        Id retailerId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Commercial').getRecordTypeId();
        Account ServiceAgent=TTI_CommonUtilityClass.createAccount();
        ServiceAgent.RecordTypeId=serviceAgentId;
        ServiceAgent.Name='TEST_SERVICE_AGENT';
        ServiceAgent.Phone='+6112313131';
        ServiceAgent.Freight_Company__c='Courier Post';
        ServiceAgent.Freight_Company_Account_Number__c='21946011';
        Account Retailer=TTI_CommonUtilityClass.createAccount();
        Retailer.RecordTypeId=retailerId;
        Retailer.Name='Test_Retailer';
        Retailer.Phone='+6112317868';
        insert Retailer;
        insert ServiceAgent;
        Case objCase=TTI_CommonUtilityClass.createCase();
        objCase.Service_Agent__c=ServiceAgent.Id;
        objCase.Retailer_Account__c=Retailer.Id;
        insert objCase;
        TTI_CommonUtilityClass.createFreightAPICustomSettings();
        TTI_SubmtClaimController.sendFreightCompanyRequest(objCase.Id, 'SubmitClaim');
        TTI_SubmtClaimController.sendFreightCompanyRequest(objCase.Id, 'MarkAsComplete');
        TTI_SubmtClaimController.RetriggerFreightRequest(objCase.Id, 'SubmitClaim');
        TTI_SubmtClaimController.RetriggerFreightRequest(objCase.Id, 'MarkAsComplete');
    }
    private static testmethod void TNT()
    {
        Product2 prod = new Product2(Name = 'Laptop X200', Family = 'Hardware');
        prod.Height__c=29.98;
        prod.Weight__c=12.31;
        prod.Length__c=32.12;
        prod.Width__c=12.21;
        insert prod;
        Id serviceAgentId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Agent').getRecordTypeId();
        Id retailerId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Commercial').getRecordTypeId();
        Id customerId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Consumer Contact').getRecordTypeId();
        Account ServiceAgent=TTI_CommonUtilityClass.createAccount();
        ServiceAgent.RecordTypeId=serviceAgentId;
        ServiceAgent.Name='TEST_SERVICE_AGENT';
        ServiceAgent.Phone='+6112313131';
        ServiceAgent.Freight_Company__c='TNT';
        ServiceAgent.Freight_Company_Account_Number__c='21946011';
        Account Retailer=TTI_CommonUtilityClass.createAccount();
        Retailer.RecordTypeId=retailerId;
        Retailer.Name='Test_Retailer';
        Retailer.Phone='+6112317868';
        Account Customer = TTI_CommonUtilityClass.createAccount();
        Customer.RecordTypeId=customerId;
        Customer.FirstName='Customer';
        Customer.LastName='Customer';
        Customer.PersonEmail='test@test.com';
        Customer.PersonMobilePhone='13131312321';
        insert Customer;
        insert Retailer;
        insert ServiceAgent;
        Case objCase=TTI_CommonUtilityClass.createCase();
        objCase.Service_Agent__c=ServiceAgent.Id;
        objCase.Retailer_Account__c=Retailer.Id;
        objCase.TTI_Customer_Account__c=Customer.Id;
        objCase.Product_Name__c=prod.Id;
        insert objCase;
        TTI_CommonUtilityClass.createFreightAPICustomSettings();
        TTI_SubmtClaimController.sendFreightCompanyRequest(objCase.Id, 'SubmitClaim');
        TTI_SubmtClaimController.sendFreightCompanyRequest(objCase.Id, 'MarkAsComplete');
        TTI_SubmtClaimController.RetriggerFreightRequest(objCase.Id, 'SubmitClaim');
        TTI_SubmtClaimController.RetriggerFreightRequest(objCase.Id, 'MarkAsComplete');
    }
}