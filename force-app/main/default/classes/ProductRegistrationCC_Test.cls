@isTest
public class ProductRegistrationCC_Test {
    
    
    static testMethod void getProductsAustralia_Test() {
        //create custom settings
        Community_Settings__c cs = new Community_Settings__c();
        cs.Brand__c = 'Ryobi';
        cs.ProductBrand__c = 'RY';
        cs.Australia_Country__c ='Australia';
        cs.Name = 'myRyobi';
        cs.ProductSelectionIntialCategories__c = 'Outdoor,Power Tools,Accessories';
        insert cs;
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
        
        Profile profile1 = [Select Id from Profile where UserType  = 'CspLitePortal' Limit 1];
        User portalUser = new User(
            //UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = 'test1@yahoo.com.Ryobi',
            Alias = 'batman',
            Email='test1@yahoo.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago',
            ContactId = c.Id
            );
        Database.insert(portalUser);
        system.runAs(portalUser){
            ProductRegistrationCC.getProducts();
            ProductRegistrationCC.getDefaultSerialNumerDisplay();
        }
        
    }
    static testMethod void getProductsNewZealand_Test() {
        //create custom settings
        Community_Settings__c cs = new Community_Settings__c();
        cs.Brand__c = 'Ryobi';
        cs.ProductBrand__c = 'RY';
        cs.Australia_Country__c ='Australia';
        cs.New_Zealand_Country__c = 'New Zealand';
        cs.Name = 'myRyobi';
        cs.ProductSelectionIntialCategories__c = 'Outdoor,Power Tools,Accessories';
        insert cs;
        //create parent contact
        Parent_Contact__c pc = new Parent_Contact__c();
        pc.Name = 'Test';
        Insert pc;
        //create Person Account
        Account a = TestUtilityClass.createPersonAccount(1)[0];
        a.ParentContact__c = pc.Id;
        a.Country__pc = 'New Zealand';
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
        
        Profile profile1 = [Select Id from Profile where UserType  = 'CspLitePortal' Limit 1];
        User portalUser = new User(
            //UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = 'test2@yahoo.com.Ryobi',
            Alias = 'batman',
            Email='test2@yahoo.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago',
            ContactId = c.Id
            );
        Database.insert(portalUser);
        system.runAs(portalUser){
            ProductRegistrationCC.getProducts();
        }
    }        
        static testMethod void getCategoryImages_Test() {
        //create custom settings
        Community_Settings__c cs = new Community_Settings__c();
        cs.Brand__c = 'Ryobi';
        cs.ProductBrand__c = 'RY';
        cs.Australia_Country__c ='Australia';
        cs.New_Zealand_Country__c = 'New Zealand';
        cs.Name = 'myRyobi';
        cs.ProductSelectionIntialCategories__c = 'Outdoor,Power Tools,Accessories';
        insert cs;
        //create category image
        Category_Image__c ci = new Category_Image__c();
       	ci.Name = 'Accessories';
        ci.Image_URL__c = 'https://739a9e17fab0c4e729e1-5436bcca90dbfab4540ef3f0f1183096.ssl.cf4.rackcdn.com/products/photos/large_1040f20b-9c45-41ae-8a37-461f0b12bcfe.png';
        ci.Brand__c = 'Ryobi';
        ci.Display_Order__c = 5;
        ci.External_Id__c = 'Ryobi_LVL1_Accessories';
            
        insert ci;
        ProductRegistrationCC.getCategoryImages();
    }
   
   

}