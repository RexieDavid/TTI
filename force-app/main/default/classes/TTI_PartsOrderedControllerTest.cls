@isTest
public class TTI_PartsOrderedControllerTest {

    private static final String ERR_GENERIC_MESSAGE = 'Something went wrong. Please contact your administrator.';
    
    /*******************************************
    * Description          Initialize test data
    * 
    */
    @TestSetup
    static void makeData() {
       
        Profile bdmUsrProfile = [SELECT Id FROM Profile WHERE Name = 'Industrial BDM Sales Mgt'];
        User bdmUser = new User(
            Alias = 'standt',
            Email = 'standarduser@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = bdmUsrProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'teststandard@testing.com',
            TTI_SAP_Cust_No__c = '12345',
            Division = 'Industrial'
        );
        insert bdmUser;
        
        System.runAs(bdmUser) {
            Product2 nProductPart = new Product2(
                Name = 'SIDE HANDLE ASSY',
                AU_Landed_Cost__c = 5.98,
                AU_ListPrice__c = 31.06,
                AU_MRPty__c = 'ND',
                Description = 'SIDE HANDLE ASSY',
                NZ_Landed_Cost__c = 6.73,
                NZ_ListPrice__c = 33.18,
                NZ_MRPty__c = 'ZD',
                ProductCode = '203148017',
                SOH_BP01__c = 0,
                SOH_BP05__c = 0,
                SOH_BP06__c = 0,
                IsActive = true
            );
            insert nProductPart;

            Product2 nProductTool = new Product2(
                Name = 'M18 FUEL Drill/Driver 13mm - Tool Only',
                AU_Landed_Cost__c = 76.63,
                AU_ListPrice__c = 308.33,
                AU_MRPty__c = 'ZD',
                BP05_Bin__c = '150',
                Description = 'M18 FUEL Drill/Driver 13mm - Tool Only',
                NZ_Landed_Cost__c = 82.11,
                NZ_ListPrice__c = 275,
                NZ_MRPty__c = 'ZD',
                ProductCode = 'M18FDD-0',
                SOH_BP01__c = 181,
                SOH_BP05__c = 0,
                SOH_BP06__c = 0,
                IsActive = true
            );
            insert nProductTool;
            
            ProductParts__c productPart = new ProductParts__c(
                External_ID__c = String.valueOf(crypto.getRandomLong()),
                Quantity__c = 1,
                ProductPart__c = nProductPart.Id,
                ProductTool__c = nProductTool.Id
            );
            insert productPart;

            Id sAgentRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Agent').getRecordTypeId();
            Account serviceAgtAcct = TTI_CommonUtilityClass.createAccount();
            serviceAgtAcct.RecordTypeId = sAgentRecTypeId;
            serviceAgtAcct.Allow_Delivery_to_Customers__c = false;
            serviceAgtAcct.Name = 'TEST_SERVICE_AGENT';
            serviceAgtAcct.Phone = '+6112313131';
            serviceAgtAcct.Freight_Company__c = 'Courier Post';
            serviceAgtAcct.Freight_Company_Account_Number__c = '21946011';
            serviceAgtAcct.Service_Agent_Status__c = 'Bronze';
            insert serviceAgtAcct;

            Case nCase = TTI_CommonUtilityClass.createCase();
            nCase.AccountId = serviceAgtAcct.Id;
            insert nCase;
            
            Service_Request_Line_Item__c nServiceReqLineItem = new Service_Request_Line_Item__c(
                Service_Request_Number__c = nCase.Id,
                Order_Line_Category__c = 'Manual entry',
                Order_Line_Type__c = 'Part',
                Part_Number__c = nProductPart.Id,
                SKU_Number__c = 'BL18DP-X5',
                Quantity__c = 1
            );
            insert nServiceReqLineItem;
            
            Retail_Charges_Rates__c nRetailChargesRates = new Retail_Charges_Rates__c(
                Name = 'Delivery_Large',
                Charge_Name__c = 'Delivery Charges',
                AUD_Cost__c = 30,
                NZD_Cost__c = 30,
                Retail_Charge_AUD__c = 40,
                Retail_Charge_NZD__c = 40,
                Size__c = 'Large'
            );
            insert nRetailChargesRates;
        }
    }
    
    /**********************************************************
    * Description          get list of service request line item
    */
    @isTest
    static void testGetServiceReqLineItem() {
        Id caseRec = [SELECT Id FROM Case].Id;
        
        Test.startTest();
        List<Service_Request_Line_Item__c> svcReqLi = TTI_PartsOrderedController.getServiceReqLineItem(caseRec);
        Test.stopTest();
        
        System.assert(!svcReqLi.isEmpty(), 'No Service Request Line Item Found.');
    }
    
    /**********************************************************
    * Description          get list of none-warranty
    *                      service request line item
    */
    @isTest
    static void testGetNonWarrantyServiceReqLineItem() {
        Id caseRec = [SELECT Id FROM Case].Id;
        Service_Request_Line_Item__c serviceReqLi = [SELECT Id, Order_Line_Type__c FROM Service_Request_Line_Item__c];
        serviceReqLi.Order_Line_Type__c = 'Quote';
        update serviceReqLi;
        
        Test.startTest();
        String noneWarrantySRLI = TTI_PartsOrderedController.getNonWarrantyServiceReqLineItem(caseRec);
        String retailChargeJSON = TTI_PartsOrderedController.getRetailChargesCustomSetting();
        Test.stopTest();
        
        System.assert(!String.isBlank(noneWarrantySRLI), 'No Service Request Line Item Found.');
        System.assert(!String.isBlank(retailChargeJSON), ERR_GENERIC_MESSAGE);
    }
    
    /**********************************************************
    * Description          get list of service request line item
    *                      fail/negative scenario
    */
    @isTest
    static void testGetServiceReqLineItemNegative() {
        String errorMessage;
        
        Test.startTest();
        try {
            TTI_PartsOrderedController.getServiceReqLineItem(null);
        } catch (Exception e) {
            errorMessage = e.getMessage();
        }
        Test.stopTest();
        
        System.assert(!String.isBlank(errorMessage), ERR_GENERIC_MESSAGE);
    }
}