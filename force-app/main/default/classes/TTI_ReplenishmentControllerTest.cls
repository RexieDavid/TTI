@isTest
public without sharing class TTI_ReplenishmentControllerTest {

    /**
     * Create necessary data for test class
     */
    @testSetup
    static void initData() {        
        UserRole portalRole = [SELECT Id FROM UserRole WHERE PortalType = 'None' LIMIT 1];
        Profile profId = [SELECT Id FROM PROFILE WHERE Name = 'System Administrator' LIMIT 1];

        User newUser = new User(UserRoleId = portalRole.Id,
                                ProfileId = profId.Id,
                                Username = System.now().millisecond() + 'test23@test.com',
                                Alias = 'batman',
                                Email='bruce.wayne@ttibrands.com',
                                EmailEncodingKey='UTF-8',
                                Firstname='Bruce',
                                Lastname='Wayne',
                                LanguageLocaleKey='en_US',
                                LocaleSidKey='en_US',
                                TimeZoneSidKey='America/Chicago');
        insert newUser;

        System.runAs(newUser) {

            SOHRAGStatus__c newSOHRAGStatus = new SOHRAGStatus__c();
            newSOHRAGStatus.Name = 'AMBER';
            newSOHRAGStatus.MaxSOHRange__c = 50;
            newSOHRAGStatus.MinSOHRange__c = 11;
            insert newSOHRAGStatus;

            Product2 prod2 = new Product2(
                Name = 'Laptop X2000',
                SAP_Material_Type__c = 'HAWA',
                Family = 'Hardware',
                AU_Landed_Cost__c = null,
                NZ_Landed_Cost__c = null,
                Maximum_Number_of_Parts__c = 0,
                SOH_BP01__c = 1,
                Standard_Warranty_Months__c = -10.0,
                Height__c = 10,
                Length__c = 12,
                Width__c = 50,
                Weight__c = 150,
                Dangerous_Goods_Text__c = 'CLASS9'
            );
            insert prod2;

            ProductParts__c newProdParts = new ProductParts__c();
            newProdParts.ProductTool__c = prod2.Id;
            newProdParts.Quantity__c = 10;
            newProdParts.External_ID__c = 'QAst-123';
            insert newProdParts;

            Account serviceAgentAcc = TTI_CommonUtilityClass.createAccount();
            serviceAgentAcc.Name = 'Demo Account';
            serviceAgentAcc.Company_Code__c = 'BP01';
            serviceAgentAcc.Freight_Company__c = 'StarTrack';
            serviceAgentAcc.Delivery_Country__c = 'Australia';
            serviceAgentAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Agent').getRecordTypeId();            
            insert serviceAgentAcc;

            Contact serviceAgentContact = TTI_CommonUtilityClass.createContact();
            serviceAgentContact.AccountId = serviceAgentAcc.Id;
            serviceAgentContact.phone = '+614321654987';
            serviceAgentContact.Email = 'Demo.Account@yopmail.com';
            insert serviceAgentContact;

            User serviceAgentUser = TTI_CommonUtilityClass.createUser();
            serviceAgentUser.ContactId = serviceAgentContact.Id;
            serviceAgentUser.LastName = 'Account';
            serviceAgentUser.Email = 'Demo.Account@yopmail.com';
            serviceAgentUser.UserName = 'Demo.Account@yopmail.com';
            serviceAgentUser.TTI_SAP_Cust_No__c = '54321';
            insert serviceAgentUser;

            TTI_Replenishment_Header__c newRepHeader = new TTI_Replenishment_Header__c();
            newRepHeader.TTI_Service_Agent__c = serviceAgentAcc.Id;
            newRepHeader.TTI_Status__c = 'Pending';
            insert newRepHeader;
        }
    }

    /** 
     * Fetch current user details
     */
    @isTest
    static void getUserTypeTest() {
        User resultUser;
        Test.startTest();
            resultUser = TTI_ReplenishmentController.getUserType(UserInfo.getUserId());
        Test.stopTest();
        System.assert(resultUser != null, 'User did not exist');
    }

    /**
     * Fetch existing product parts for specific product
     */
    @isTest
    static void fetchBillOfMaterialsTest() {
        List<ProductParts__c> resultProdPartsList = new List<ProductParts__c>();
        Product2 eProd = [SELECT Id FROM Product2 WHERE Name = 'Laptop X2000']; 

        Test.startTest();
            resultProdPartsList = TTI_ReplenishmentController.fetchBillOfMaterials(eProd.Id);
        Test.stopTest();
        System.assert(!resultProdPartsList.isEmpty(), 'No existing product parts for the listed product');
    }

    /**
     * Fetch replenishment header record
     */
    @isTest
    static void fetchReplenishmentRecordTest() {
        TTI_Replenishment_Header__c resRepHeader;
        TTI_Replenishment_Header__c eRepHeader = [SELECT Id FROM TTI_Replenishment_Header__c LIMIT 1];
        User eUser = [SELECT Id, Name, AccountId FROM User WHERE ContactId IN (SELECT Id FROM Contact) LIMIT 1];
        Test.startTest();
        System.runAs(eUser) {
            resRepHeader = TTI_ReplenishmentController.fetchReplenishmentRecord(eRepHeader.Id);
        }
        Test.stopTest();
        System.assertEquals(eRepHeader.Id,resRepHeader.Id, 'Replenishment header did not exist');
    }

    /**
     * Update replenishment header and save new replenishment line items
     */
    @isTest
    static void saveReplishmentHeaderAndSaveLineItemTest() {
        String result;
        List<TTI_Replenishment_Line_Item__c> newRepLineItemsList = new List<TTI_Replenishment_Line_Item__c>();
        TTI_Replenishment_Header__c eRepHeader = [SELECT Id, TTI_Status__c FROM TTI_Replenishment_Header__c LIMIT 1];
        User eUser = [SELECT Id, Name, AccountId FROM User WHERE ContactId IN (SELECT Id FROM Contact) LIMIT 1];
        eRepHeader.TTI_Status__c = 'Submitted';

        for(Integer counter = 0; counter < 10; counter++) {
            TTI_Replenishment_Line_Item__c newRepLineItem = new TTI_Replenishment_Line_Item__c();
            newRepLineItem.TTI_Replenishment_Header__c = eRepHeader.Id;
            newRepLineItem.TTI_SKU_Number__c = '0000-' + counter;
            newRepLineItem.TTI_Unit_Cost__c = 10;
            newRepLineItem.TTI_Quantity__c = 12;
            newRepLineItemsList.add(newRepLineItem);
        }

        Test.startTest();
        System.runAs(eUser) {
            result = TTI_ReplenishmentController.saveReplishmentHeaderAndItsLineItem(JSON.serialize(eRepHeader), JSON.serialize(newRepLineItemsList), null);
        }
        Test.stopTest();
        System.assertEquals(eRepHeader.Id,result, 'Did not update replenishment header');
    }

    /**
     * Fetch SOHRAG Status custom setting
     */
    @isTest
    static void getSOHRAGStatusCustomSettingTest() {
        String result;

        Test.startTest();
            result = TTI_ReplenishmentController.getSOHRAGStatusCustomSetting();
        Test.stopTest(); 
        System.assert(String.isNotBlank(result), 'SOHRAGStatuses does not exist');
    }
    
}