@isTest(seeAllData =true)
public class ProductDetailCC_Test {
    /*static testMethod void getLocations_Test() {
        ProductDetailCC.getLocations();
    }*/
    
    static testMethod void saveProductRegistration_Test() {
        User portalUser;
        List<Asset> assetList;

        UserRole role = [Select Id From UserRole WHERE DeveloperName = 'CEO' LIMIT 1];
        Profile sysAd = [Select Id from Profile where Name  = '~System Administrator' Limit 1];
        User sysAdUser = new User(
            UserRoleId = role.Id,
            ProfileId = sysAd.Id,
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            FirstName = 'systemadd',
            LastName = 'systemadd123',
            Username = 'systemadd@appirio.com.ryobi',
            CommunityNickname = 'systemadd',
            Alias = 'systadd',
            Email = 'systemadd@email.com',
            IsActive = true
        );

        insert sysAdUser;

        system.runAs(sysAdUser){
            
            //ProductDetailCC.getLocations();
            //create parent contact
            Parent_Contact__c pc = new Parent_Contact__c();
            pc.Name = 'Test';
            Insert pc;
            //create Person Account
            Account a = TestUtilityClass.createPersonAccount(1)[0];
            a.ParentContact__c = pc.Id;
            insert a;
            //get contact
            Contact c=  [Select Id, country__c FROM Contact Where AccountID =:a.Id];
            
             SerialNumberDisplayType__c snType = new SerialNumberDisplayType__c();
             snType.Name = 'test';
             snType.Serial_Number_Length__c = 10;
             snType.HelperImageURL__c = 'https://www.google.com.au/images/branding/googlelogo/2x/googlelogo_color_120x44dp.png';
             snType.IsDefault__c = true;
             snType.HelpText__c = 'Please enter the ten digit serial number located on your tool.';
             insert snType;
            //create Product
            List<Product2> prods = TestUtilityClass.createProduct(2);
            prods[0].SerialNumberDisplayType__c = snType.Id;
            prods[0].brand__c = 'RY';
            prods[0].category_customer_level1__c =  'Power Tools';
            prods[1].SerialNumberDisplayType__c = snType.Id;
            prods[1].Brand__c = 'RY';
            Insert prods;
            
            assetList = TestUtilityClass.createAsset(1, a.Id, c.Id, prods[0].Id);
            assetList[0].Standard_Warranty_Months__c = 48;
            assetList[0].Extended_Warranty_Months__c = 24;
            assetList[0].AssetSource__c = 'Retailer - Bunnings';
            
            Insert assetList;

            Profile profile1 = [Select Id from Profile where UserType  = 'CspLitePortal' Limit 1];
            portalUser = new User(
                //UserRoleId = portalRole.Id,
                ProfileId = profile1.Id,
                EmailEncodingKey = 'ISO-8859-1',
                LanguageLocaleKey = 'en_US',
                TimeZoneSidKey = 'America/New_York',
                LocaleSidKey = 'en_US',
                FirstName = 'first',
                LastName = 'last',
                Username = 'test@appirio.com.ryobi',
                CommunityNickname = 'testUser123',
                Alias = 't1',
                Email = 'no@email.com',
                IsActive = true,
                ContactId = c.Id,
                Country = 'Australia'
                );
            Database.insert(portalUser);
        }
            
        system.runAs(portalUser){
            
            ProductDetailCC.saveProductRegistrationResult wrap = new ProductDetailCC.saveProductRegistrationResult('test',false);
            ProductDetailCC.saveProductRegistration(assetList, 'Yes', 'TestFile');
        }
    }
    static testMethod void saveProductRegistration_Test2() {
        //ProductDetailCC.getLocations();
        //create parent contact
        Parent_Contact__c pc = new Parent_Contact__c();
        pc.Name = 'Test';
        Insert pc;
        //create Person Account
        Account a = TestUtilityClass.createPersonAccount(1)[0];
        a.ParentContact__c = pc.Id;
        insert a;
        //get contact
        Contact c=  [Select Id, country__c FROM Contact Where AccountID =:a.Id];
        
         SerialNumberDisplayType__c snType = new SerialNumberDisplayType__c();
         snType.Name = 'test';
         snType.Serial_Number_Length__c = 10;
         snType.HelperImageURL__c = 'https://www.google.com.au/images/branding/googlelogo/2x/googlelogo_color_120x44dp.png';
         snType.IsDefault__c = true;
         snType.HelpText__c = 'Please enter the ten digit serial number located on your tool.';
         insert snType;
        //create Product
        List<Product2> prods = TestUtilityClass.createProduct(2);
        prods[0].SerialNumberDisplayType__c = snType.Id;
        prods[0].brand__c = 'RY';
        prods[0].category_customer_level1__c =  'Power Tools';
        prods[1].SerialNumberDisplayType__c = snType.Id;
        prods[1].Brand__c = 'RY';
        Insert prods;
        
        List<Asset> assetList = TestUtilityClass.createAsset(1, a.Id, c.Id, prods[0].Id);
        assetList[0].Standard_Warranty_Months__c = 48;
        assetList[0].Extended_Warranty_Months__c = 24;
        assetList[0].AssetSource__c = 'Retailer - Bunnings';
        
        //Insert assetList;
            
        
            ProductDetailCC.saveProductRegistrationResult wrap = new ProductDetailCC.saveProductRegistrationResult();
            ProductDetailCC.saveProductRegistrationResult wrap2 = new ProductDetailCC.saveProductRegistrationResult('test',false);
            ProductDetailCC.saveProductRegistration(assetList, 'Yes', 'TestFile');
        
    }
    
    static testMethod void updateProductRegistration_Test() {
        //ProductDetailCC.getLocations();
        //create parent contact
        Parent_Contact__c pc = new Parent_Contact__c();
        pc.Name = 'Test';
        Insert pc;
        //create Person Account
        Account a = TestUtilityClass.createPersonAccount(1)[0];
        a.ParentContact__c = pc.Id;
        insert a;
        //get contact
        Contact c=  [Select Id, country__c FROM Contact Where AccountID =:a.Id];
        
         SerialNumberDisplayType__c snType = new SerialNumberDisplayType__c();
         snType.Name = 'test';
         snType.Serial_Number_Length__c = 10;
         snType.HelperImageURL__c = 'https://www.google.com.au/images/branding/googlelogo/2x/googlelogo_color_120x44dp.png';
         snType.IsDefault__c = true;
         snType.HelpText__c = 'Please enter the ten digit serial number located on your tool.';
         insert snType;
        //create Product
        List<Product2> prods = TestUtilityClass.createProduct(2);
        prods[0].SerialNumberDisplayType__c = snType.Id;
        prods[0].brand__c = 'RY';
        prods[0].category_customer_level1__c =  'Power Tools';
        prods[1].SerialNumberDisplayType__c = snType.Id;
        prods[1].Brand__c = 'RY';
        Insert prods;
        
        List<Asset> assetList = TestUtilityClass.createAsset(1, a.Id, c.Id, prods[0].Id);
        assetList[0].Standard_Warranty_Months__c = 48;
        assetList[0].Extended_Warranty_Months__c = 24;
        assetList[0].AssetSource__c = 'Retailer - Bunnings';
        
        Insert assetList;
        
           
            ProductDetailCC.updateProductRegistration(assetList[0], 'Yes', 'TestFile');
        
    }
    static testMethod void updateProductRegistration_Test2() {
        User portalUser;
        List<Asset> assetList;

        UserRole role = [Select Id From UserRole WHERE DeveloperName = 'CEO' LIMIT 1];
        Profile sysAd = [Select Id from Profile where Name  = '~System Administrator' Limit 1];
        User sysAdUser = new User(
            UserRoleId = role.Id,
            ProfileId = sysAd.Id,
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            FirstName = 'systemadd',
            LastName = 'systemadd123',
            Username = 'systemadd@appirio.com.ryobi',
            CommunityNickname = 'systemadd',
            Alias = 'systadd',
            Email = 'systemadd@email.com',
            IsActive = true
        );

        insert sysAdUser;

        system.runAs(sysAdUser){
            //ProductDetailCC.getLocations();
            //create parent contact
            Parent_Contact__c pc = new Parent_Contact__c();
            pc.Name = 'Test';
            Insert pc;
            //create Person Account
            Account a = TestUtilityClass.createPersonAccount(1)[0];
            a.ParentContact__c = pc.Id;
            insert a;
            //get contact
            Contact c=  [Select Id, country__c FROM Contact Where AccountID =:a.Id];
            
             SerialNumberDisplayType__c snType = new SerialNumberDisplayType__c();
             snType.Name = 'test';
             snType.Serial_Number_Length__c = 10;
             snType.HelperImageURL__c = 'https://www.google.com.au/images/branding/googlelogo/2x/googlelogo_color_120x44dp.png';
             snType.IsDefault__c = true;
             snType.HelpText__c = 'Please enter the ten digit serial number located on your tool.';
             insert snType;
            //create Product
            List<Product2> prods = TestUtilityClass.createProduct(2);
            prods[0].SerialNumberDisplayType__c = snType.Id;
            prods[0].brand__c = 'RY';
            prods[0].category_customer_level1__c =  'Power Tools';
            prods[1].SerialNumberDisplayType__c = snType.Id;
            prods[1].Brand__c = 'RY';
            Insert prods;
            //create receipt
            Receipts__c r = new Receipts__c(ReceiptSource__c = 'Bunnings',
                                            Account__c = a.Id
                                            );
            insert r;
            
            assetList = TestUtilityClass.createAsset(1, a.Id, c.Id, prods[0].Id);
            assetList[0].Standard_Warranty_Months__c = 48;
            assetList[0].Extended_Warranty_Months__c = 24;
            assetList[0].AssetSource__c = 'Retailer - Bunnings';
            assetList[0].Receipt__c = r.Id;
            Insert assetList;
            
            Profile profile1 = [Select Id from Profile where UserType  = 'CspLitePortal' Limit 1];
            portalUser = new User(
                //UserRoleId = portalRole.Id,
                ProfileId = profile1.Id,
                EmailEncodingKey = 'ISO-8859-1',
                LanguageLocaleKey = 'en_US',
                TimeZoneSidKey = 'America/New_York',
                LocaleSidKey = 'en_US',
                FirstName = 'first',
                LastName = 'last',
                Username = 'test@appirio.com.ryobi',
                CommunityNickname = 'testUser123',
                Alias = 't1',
                Email = 'no@email.com',
                IsActive = true,
                ContactId = c.Id
                );
            Database.insert(portalUser);
        }
            
        system.runAs(portalUser){
            ProductDetailCC.updateProductRegistration(assetList[0], 'Yes', 'NoFile');
        }

        ProductDetailCC.testDummy();
    }
    
    static testMethod void updateProductRegistration_Test3() {
        User portalUser;
        Receipts__c r;
        Attachment attach;
        List<Asset> assetList;

        UserRole role = [Select Id From UserRole WHERE DeveloperName = 'CEO' LIMIT 1];
        Profile sysAd = [Select Id from Profile where Name  = '~System Administrator' Limit 1];
        User sysAdUser = new User(
            UserRoleId = role.Id,
            ProfileId = sysAd.Id,
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            FirstName = 'systemadd',
            LastName = 'systemadd123',
            Username = 'systemadd@appirio.com.ryobi',
            CommunityNickname = 'systemadd',
            Alias = 'systadd',
            Email = 'systemadd@email.com',
            IsActive = true
        );

        insert sysAdUser;

        system.runAs(sysAdUser){
            //ProductDetailCC.getLocations();
            //create parent contact
            Parent_Contact__c pc = new Parent_Contact__c();
            pc.Name = 'Test';
            Insert pc;
            //create Person Account
            Account a = TestUtilityClass.createPersonAccount(1)[0];
            a.ParentContact__c = pc.Id;
            insert a;
            //get contact
            Contact c=  [Select Id, country__c FROM Contact Where AccountID =:a.Id];
            
             SerialNumberDisplayType__c snType = new SerialNumberDisplayType__c();
             snType.Name = 'test';
             snType.Serial_Number_Length__c = 10;
             snType.HelperImageURL__c = 'https://www.google.com.au/images/branding/googlelogo/2x/googlelogo_color_120x44dp.png';
             snType.IsDefault__c = true;
             snType.HelpText__c = 'Please enter the ten digit serial number located on your tool.';
             insert snType;
            //create Product
            List<Product2> prods = TestUtilityClass.createProduct(2);
            prods[0].SerialNumberDisplayType__c = snType.Id;
            prods[0].brand__c = 'RY';
            prods[0].category_customer_level1__c =  'Power Tools';
            prods[1].SerialNumberDisplayType__c = snType.Id;
            prods[1].Brand__c = 'RY';
            Insert prods;
            //create receipt
            r = new Receipts__c(ReceiptSource__c = 'Bunnings',
                                            Account__c = a.Id
                                            );
            insert r;
            
            attach=new Attachment();     
            attach.Name='TestFile';
            Blob bodyBlob=Blob.valueOf('base64Data');
            attach.body=bodyBlob;
            attach.parentId=r.id;
            insert attach;
            
            assetList = TestUtilityClass.createAsset(1, a.Id, c.Id, prods[0].Id);
            assetList[0].Standard_Warranty_Months__c = 48;
            assetList[0].Extended_Warranty_Months__c = 24;
            assetList[0].AssetSource__c = 'Retailer - Bunnings';
            assetList[0].Receipt__c = r.Id;
            Insert assetList;
            
            Profile profile1 = [Select Id from Profile where UserType  = 'CspLitePortal' Limit 1];
            portalUser = new User(
                //UserRoleId = portalRole.Id,
                ProfileId = profile1.Id,
                EmailEncodingKey = 'ISO-8859-1',
                LanguageLocaleKey = 'en_US',
                TimeZoneSidKey = 'America/New_York',
                LocaleSidKey = 'en_US',
                FirstName = 'first',
                LastName = 'last',
                Username = 'test@appirio.com.ryobi',
                CommunityNickname = 'testUser123',
                Alias = 't1',
                Email = 'no@email.com',
                IsActive = true,
                ContactId = c.Id
                );
            Database.insert(portalUser);
        }
            
        system.runAs(portalUser){
            ProductDetailCC.updateProductRegistration(assetList[0], 'Yes', 'TestFile');
            ProductDetailCC.saveFile(r.Id, 'base64Data', 'Test', 'image/jpeg');
            ProductDetailCC.getFileId(r.Id);
             
            ProductDetailCC.getCommunitySettings();
            ProductDetailCC.getSiteSettings();
        }
        //ProductDetailCC.saveFileChunk(r.Id, 'TestFile', 'base64Data', 'image/jpeg', string.valueOf(attach.Id));
    }

}