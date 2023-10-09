@isTest
public class TTI_OrderPartsFromBillControllerTest {

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
        }
    }

    /**
    * @author: Shivam Singh
    * @date: Jan 2018
    * @description: Return list of Product parts
    */  
    @isTest
    static void testGetProductParts() {
        ProductParts__c prodPart = [SELECT Id, External_ID__c, Quantity__c, ProductPart__c, ProductTool__c FROM ProductParts__c];

        Test.startTest();
        List<sObject> prodLst = TTI_OrderPartsFromBillController.getProductParts(prodPart.ProductTool__c);
        Service_Request_Line_Item__c svsReq = TTI_OrderPartsFromBillController.getDummyObj();
        TTI_OrderPartsFromBillController.getFieldDependencies('Case', 'Product_Fault_Category__c', 'Fault_Codes__c');
        Test.stopTest();
        
        System.assert(!prodLst.isEmpty(), ERR_GENERIC_MESSAGE);
        System.assert(svsReq != null, ERR_GENERIC_MESSAGE);
    }
    
    /**********************************************************
    * Description          get product parts negative scenario
    *                      fail to return Product Part
    */
    @isTest
    static void testGetProductPartsNegative() {
        ProductParts__c prodPart = [SELECT Id, External_ID__c, Quantity__c, ProductPart__c, ProductTool__c FROM ProductParts__c];
        String errorMessage;
        Test.startTest();
        try {
            TTI_OrderPartsFromBillController.getProductParts(prodPart.Id);
        } catch (Exception e) {
            errorMessage = e.getMessage();
        }
        Test.stopTest();
        
        System.assert(!String.isBlank(errorMessage), ERR_GENERIC_MESSAGE);
    }

}