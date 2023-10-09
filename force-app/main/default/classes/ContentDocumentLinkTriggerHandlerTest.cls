@isTest
public class ContentDocumentLinkTriggerHandlerTest {
    /**********************************************************************
    * @description             Initialize data
    */
    @TestSetup
    static void makeData() {
        Trigger_Settings__c triggerSetting = new Trigger_Settings__c();
        triggerSetting.ContentDocumentLinkTrigger__c = true;
        insert triggerSetting;
        
        Id oppAEGRecTypeID = [SELECT Id FROM RecordType WHERE Name = 'AEG - Immediate Transaction'].Id;
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
            Pricebook2 nPbook = new Pricebook2(
                Name = 'Standard Price Book Test',
                Description = 'Price Book Test Products',
                IsActive = true 
            );
            insert nPbook;
            
            Product2 nProduct = new Product2(
                Name = 'SLA: Bronze',
                IsActive = true
            );
            insert nProduct;

            Product2 nProduct2 = new Product2(
                SAP_Material_Group__c = 'RG-AC',
                Name = 'SLA: Bronze',
                IsActive = true
            );
            insert nProduct2;
            
            PricebookEntry nPBookEntry = new PricebookEntry(
                unitprice = 0.01,
                Product2Id = nProduct.Id,
                Pricebook2Id = nPbook.Id,
                IsActive = true); 
            insert nPBookEntry;
            
            Account nAccount = new Account (Name = 'Test Account');
            insert nAccount;
            
            Opportunity nOpportunity = new Opportunity(
                Name = 'Test Opportunity',
                StageName = 'Prospecting',
                CloseDate = Date.today() + 30,
                Pricebook2Id = nPbook.Id,
                Accountid = nAccount.id,
                RecordTypeId = oppAEGRecTypeID
            );
            insert nOpportunity;

            Off_Location__c nOffLocation = new Off_Location__c(
                Account__c = nAccount.Id,
                Off_Location_Product__c = nProduct2.Id,
                Status__c = 'Active',
                Type__c = 'Side Stack',
                Expected_Activation_Date__c = Date.today(),
                In_store_Location__c = 'Toolshop',
                Active__c = true
            );
            insert nOffLocation;

            Sales_Transactions__c nSalesTransaction = new Sales_Transactions__c(
                Account__c = nAccount.Id,
                Transaction_Date__c =  Date.today(),
                Comment__c = 'Test Comment'
            );
            insert nSalesTransaction;
        }
    }
    
    /**
    * @author: Ericka Jan Cajucom
    * @date: 2020-06-02
    * @description: This test method checks if Opportunity is updated upon ContentDocumentLink insert
    */
    private static testmethod void insertOpportunityContentDocumentLink() {
        ContentDocumentLink newCDocLink;
        Opportunity aegItOpportunity = [SELECT Id, Document_Attached__c FROM Opportunity];
            
        ContentVersion contentVersion = new ContentVersion(
            title = 'Elephants',
            PathOnClient = 'Elephants.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;
        Test.setCreatedDate(contentVersion.Id, DateTime.now());
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        Test.startTest();
        
        newCDocLink = new ContentDocumentLink(
            LinkedEntityId = aegItOpportunity.Id,
            ContentDocumentId = documents[0].Id,
            shareType = 'V'
        );
        insert newCDocLink;
        
        ContentDocumentLinkTriggerHandler cHandler = new ContentDocumentLinkTriggerHandler();
        cHandler.beforeInsert(new List<SObject>());
        cHandler.beforeUpdate(new Map<Id, SObject>(), new Map<Id, SObject>());
        cHandler.afterUpdate(new Map<Id, SObject>(), new Map<Id, SObject>());
        cHandler.beforeDelete(new Map<Id, SObject>());
        cHandler.afterDelete(new Map<Id, SObject>());
        cHandler.afterUndelete(new Map<Id, SObject>());
        
        Test.stopTest();
        
        System.assertNotEquals(null, newCDocLink.Id , 'No ContentDocumentLink were inserted.');
        
        Opportunity insertedOpp = [SELECT Id, Document_Attached__c FROM Opportunity WHERE ID = :newCDocLink.LinkedEntityId];
        
        System.assert(insertedOpp.Document_Attached__c, 'Opportunity was not updated!');
    }

    /**
    * @author: Ericka Jan Cajucom
    * @date: 2020-06-02
    * @description: This test method checks if Off Location is updated upon ContentDocumentLink insert
    */
    private static testmethod void insertOffLocationContentDocumentLink() {
        ContentDocumentLink newCDocLink;
        Off_Location__c offLocation = [SELECT Id, Document_Attached__c FROM Off_Location__c];
            
        ContentVersion contentVersion = new ContentVersion(
            title = 'Elephants',
            PathOnClient = 'Elephants.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        Test.startTest();
        
        newCDocLink = new ContentDocumentLink(
            LinkedEntityId = offLocation.Id,
            ContentDocumentId = documents[0].Id,
            shareType = 'V'
        );
        insert newCDocLink;
        Test.stopTest();
        
        System.assertNotEquals(null, newCDocLink.Id, 'No ContentDocumentLink were inserted.');
        
        Off_Location__c insertedOff = [SELECT Id, Document_Attached__c FROM Off_Location__c WHERE ID = :newCDocLink.LinkedEntityId];
        
        System.assert(insertedOff.Document_Attached__c, 'Off Location was not updated!');
    }

    /**
    * @author: Ericka Jan Cajucom
    * @date: 2020-06-02
    * @description: This test method checks if invalid file format is barred from Off Location upon ContentDocumentLink insert
    */
    private static testmethod void insertOffLocationContentDocumentLinkInvalid() {
        ContentDocumentLink newCDocLink;
        Off_Location__c offLocation = [SELECT Id, Document_Attached__c FROM Off_Location__c];
            
        ContentVersion contentVersion = new ContentVersion(
            title = 'Elephants',
            PathOnClient = 'Elephants.pdf',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;
        Test.setCreatedDate(contentVersion.Id, DateTime.now());
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        String errorMsg;
        Test.startTest();
        
        newCDocLink = new ContentDocumentLink(
            LinkedEntityId = offLocation.Id,
            ContentDocumentId = documents[0].Id,
            shareType = 'V'
        );
        try{
            insert newCDocLink;
        } catch(Exception e) {
            errorMsg = e.getMessage();
        }

        Test.stopTest();
        
        System.assertEquals(null, newCDocLink.Id , 'No ContentDocumentLink were expected to be inserted.');
        
        Off_Location__c insertedOff = [SELECT Id, Document_Attached__c FROM Off_Location__c WHERE ID = :newCDocLink.LinkedEntityId];
        
        System.assert(!insertedOff.Document_Attached__c, 'Invalid file format inserted!');
        
        System.assertNotEquals(null, errorMsg , errorMsg);
    }
    
    /**
    * @author: Ericka Jan Cajucom
    * @date: 2020-07-10
    * @description: This test method checks if Sales Transactions is updated upon ContentDocumentLink insert
    */
    private static testmethod void insertSalesTransactionDocumentLink() {
        ContentDocumentLink newCDocLink;
        Sales_Transactions__c salesTransaction = [SELECT Id, File_Attached__c FROM Sales_Transactions__c];
            
        ContentVersion contentVersion = new ContentVersion(
            title = 'Elephants',
            PathOnClient = 'Elephants.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        Test.startTest();
        
        newCDocLink = new ContentDocumentLink(
            LinkedEntityId = salesTransaction.Id,
            ContentDocumentId = documents[0].Id,
            shareType = 'V'
        );
        insert newCDocLink;
        Test.stopTest();
        
        System.assertNotEquals(null, newCDocLink.Id, 'No ContentDocumentLink were inserted.');
        
        Sales_Transactions__c insertedsTrans = [SELECT Id, File_Attached__c FROM Sales_Transactions__c WHERE ID = :newCDocLink.LinkedEntityId];
        
        System.assert(insertedsTrans.File_Attached__c, 'Off Location was not updated!');
    }

    /**
    * @author: Ericka Jan Cajucom
    * @date: 2020-07-10
    * @description: This test method checks if invalid file format is barred from Sales Transactions upon ContentDocumentLink insert
    */
    private static testmethod void insertSalesTransactionContentDocumentLinkInvalid() {
        ContentDocumentLink newCDocLink;
        Sales_Transactions__c salesTransaction = [SELECT Id, File_Attached__c FROM Sales_Transactions__c];
            
        ContentVersion contentVersion = new ContentVersion(
            title = 'Elephants',
            PathOnClient = 'Elephants.pdf',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;
        Test.setCreatedDate(contentVersion.Id, DateTime.now());
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        String errorMsg;
        Test.startTest();
        
        newCDocLink = new ContentDocumentLink(
            LinkedEntityId = salesTransaction.Id,
            ContentDocumentId = documents[0].Id,
            shareType = 'V'
        );
        try{
            insert newCDocLink;
        } catch(Exception e) {
            errorMsg = e.getMessage();
        }

        Test.stopTest();
        
        System.assertEquals(null, newCDocLink.Id , 'No ContentDocumentLink were expected to be inserted.');
        
        Sales_Transactions__c insertedsTrans = [SELECT Id, File_Attached__c FROM Sales_Transactions__c WHERE ID = :newCDocLink.LinkedEntityId];
        
        System.assert(!insertedsTrans.File_Attached__c, 'Invalid file format inserted!');
        
        System.assertNotEquals(null, errorMsg , errorMsg);
    }
}