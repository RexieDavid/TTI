@isTest
private class CreateAccountControllerTest {
    @testSetup
    private static void testData() {
    
        Product2 p1 = new Product2();
        p1.Name = 'P1';
        p1.Brand__c = 'ML';
        p1.ProductCode = '1';
        insert p1;
    }
    
    private static testMethod void testMethod1() {
        PageReference pageRef = Page.CreateAccount;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('brand','Ryobi');
        ApexPages.currentPage().getParameters().put('First Name','RyobiFirst');
        ApexPages.currentPage().getParameters().put('Last Name','RyobiLast');
        ApexPages.currentPage().getParameters().put('Email Address','Ryobi@yahoo.com');
        ApexPages.currentPage().getParameters().put('Country','AU');
        ApexPages.currentPage().getParameters().put('retUrl','ryobi.com.au');
        

        CreateAccountController controller = new CreateAccountController();
        controller.CreateAccount();
    }

    private static testMethod void testMethod2() {
        PageReference pageRef = Page.CreateAccount;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('brand','AEG');
        ApexPages.currentPage().getParameters().put('First Name','AEGFirst');
        ApexPages.currentPage().getParameters().put('Last Name','AEGLast');
        ApexPages.currentPage().getParameters().put('Email Address','aeg@yahoo.com');
        ApexPages.currentPage().getParameters().put('Country','AU');
        ApexPages.currentPage().getParameters().put('retUrl','aegpowertools.com.au');
        

        CreateAccountController controller = new CreateAccountController();
        controller.CreateAccount();
    }
    
    private static testMethod void testMethod3() {
        PageReference pageRef = Page.CreateAccount;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('brand','RyobiShed');
        ApexPages.currentPage().getParameters().put('Person.pFirstName','RyobiFirst');
        ApexPages.currentPage().getParameters().put('Person.pLastName','RyobiLast');
        ApexPages.currentPage().getParameters().put('Person.pEmail','Ryobi@yahoo.com');
        ApexPages.currentPage().getParameters().put('Person.pAddress','AU');
        ApexPages.currentPage().getParameters().put('Person.pSuburb','Suberp');
        ApexPages.currentPage().getParameters().put('Person.pPostCode','1234');
        ApexPages.currentPage().getParameters().put('Person.pState','Suberp123');
        ApexPages.currentPage().getParameters().put('Person.pTelephone','1234567890');
        ApexPages.currentPage().getParameters().put('drill','1');
        ApexPages.currentPage().getParameters().put('saw','0');
        ApexPages.currentPage().getParameters().put('sander','1');
        ApexPages.currentPage().getParameters().put('lifestyleproduct','1');
        ApexPages.currentPage().getParameters().put('nailer','0');
        ApexPages.currentPage().getParameters().put('linetrimmer','0');
        ApexPages.currentPage().getParameters().put('lawnmower','0');
        ApexPages.currentPage().getParameters().put('blower','0');
        ApexPages.currentPage().getParameters().put('homemaintenance','0');
        ApexPages.currentPage().getParameters().put('homeimprovement','0');
        ApexPages.currentPage().getParameters().put('woodworkproject','1');
        ApexPages.currentPage().getParameters().put('gardening','1');
        ApexPages.currentPage().getParameters().put('subscribe','yes');
        ApexPages.currentPage().getParameters().put('UnlockCode','123456674');
        ApexPages.currentPage().getParameters().put('retUrl','ryobi.com.au');

        CreateAccountController controller = new CreateAccountController();
        controller.CreateAccount();
    }
    
    private static testMethod void vaxTelevision() {
        PageReference pageRef = Page.CreateAccount;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('brand','Vax');
        ApexPages.currentPage().getParameters().put('first_name','RyobiFirst');
        ApexPages.currentPage().getParameters().put('last_name','RyobiLast');
        ApexPages.currentPage().getParameters().put('email','Ryobi@yahoo.com');
        ApexPages.currentPage().getParameters().put('city','Suberp');
        ApexPages.currentPage().getParameters().put('postcode','1234');
        ApexPages.currentPage().getParameters().put('state','Suberp123');
        ApexPages.currentPage().getParameters().put('telephone','1234567890');
        
        ApexPages.currentPage().getParameters().put('model','1');
        ApexPages.currentPage().getParameters().put('guarantee','2 years');
        ApexPages.currentPage().getParameters().put('document','1');
        ApexPages.currentPage().getParameters().put('documentbody','1');
        ApexPages.currentPage().getParameters().put('serial_number_step_1','11');
        ApexPages.currentPage().getParameters().put('serial_number_step_2','02');
        ApexPages.currentPage().getParameters().put('serial_number_step_3','03');
        ApexPages.currentPage().getParameters().put('purchased','02/01/2018');
        ApexPages.currentPage().getParameters().put('location','bunnings');
        ApexPages.currentPage().getParameters().put('retUrl','ryobi.com.au');
        // have conditions
        ApexPages.currentPage().getParameters().put('marketing', 'Television');
        ApexPages.currentPage().getParameters().put('purchased_online','1'); // assetPurchaseOnline 1 or 0
        ApexPages.currentPage().getParameters().put('phone_type','Mobile'); // accountPhoneType Mobile/Home/Work
        ApexPages.currentPage().getParameters().put('opt_in','0'); // mpSubscribe 1 or 0
        
        Account newAccount = new Account(Salutation = 'Mr.', FirstName = 'Dirk', LastName = 'Nowit', Delivery_Country__c = 'Africa', PersonMailingStreet = 'Paeo', PersonMailingCity = 'Sudan', 
        PersonMailingState = 'Saudi', PersonMailingPostalCode = '4116', PersonMailingCountry = 'Japan', PersonEmail = 'lll@tti.com', Brand__pc = 'Vax', Country__pc = 'Japan', 
        PersonLeadSource = 'Web', RecordTypeId = getObjectRecordTypeId(Account.sObjectType, 'B2C Consumer Contact'), Record_Status__c = 'Active');
        insert newAccount;
        
        Product2 p = new Product2(Name='Prod Record', Description='Product entry1', isActive=true);
        insert p;
        
        Receipts__c receipt = new Receipts__c(Account__c = newAccount.Id, ReceiptSource__c = 'Bunnings', Receipt_Name__c = ApexPages.currentPage().getParameters().get('documentbody'));   
        insert receipt;
        
        Asset newAsset = new Asset(Product2Id = p.Id, AccountId = newAccount.Id, ContactId = newAccount.PersonContactId, PurchaseDate = System.today() - 5,
        SerialNumber = '11' + '12' + '13', Name = 'Temporary Name', Standard_Warranty_Months__c = 12, 
        WarrantyCalculatedEndDate__c = System.today() + 360, Receipt__c = receipt.Id,
        HelpText__c='Help Text Test', Serial_Number_Length__c=6);
        insert newAsset;
        
        Attachment parentAtt = new Attachment(Name = 'Att1', ParentId = newAsset.Id, Body =  Blob.valueOf('Attachment 1, Attachment 2, Attachment 3'));
        insert parentAtt;
        
        CreateAccountController controller = new CreateAccountController();
        controller.CreateAccount();  
    }

    private static testMethod void vaxMagazineNewspaper() {
        PageReference pageRef = Page.CreateAccount;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('brand','Vax');
        ApexPages.currentPage().getParameters().put('first_name','RyobiFirst');
        ApexPages.currentPage().getParameters().put('last_name','RyobiLast');
        ApexPages.currentPage().getParameters().put('email','Ryobi@yahoo.com');
        ApexPages.currentPage().getParameters().put('city','Suberp');
        ApexPages.currentPage().getParameters().put('postcode','1234');
        ApexPages.currentPage().getParameters().put('state','Suberp123');
        ApexPages.currentPage().getParameters().put('telephone','1234567890');
        
        ApexPages.currentPage().getParameters().put('model','1');
        ApexPages.currentPage().getParameters().put('guarantee','2 years');
        ApexPages.currentPage().getParameters().put('document','1');
        ApexPages.currentPage().getParameters().put('documentbody','1');
        ApexPages.currentPage().getParameters().put('serial_number_step_1','11');
        ApexPages.currentPage().getParameters().put('serial_number_step_2','02');
        ApexPages.currentPage().getParameters().put('serial_number_step_3','03');
        ApexPages.currentPage().getParameters().put('purchased','02/01/2018');
        ApexPages.currentPage().getParameters().put('location','bunnings');
        ApexPages.currentPage().getParameters().put('retUrl','ryobi.com.au');
        // have conditions
        ApexPages.currentPage().getParameters().put('marketing', 'Magazine-Newspaper');
        ApexPages.currentPage().getParameters().put('purchased_online','0'); // assetPurchaseOnline 1 or 0
        ApexPages.currentPage().getParameters().put('phone_type','Home'); // accountPhoneType Mobile/Home/Work
        ApexPages.currentPage().getParameters().put('opt_in','1'); // mpSubscribe 1 or 0
        
        Account newAccount = new Account(Salutation = 'Mr.', FirstName = 'Dirk', LastName = 'Nowit', Delivery_Country__c = 'Africa', PersonMailingStreet = 'Paeo', PersonMailingCity = 'Sudan', 
        PersonMailingState = 'Saudi', PersonMailingPostalCode = '4116', PersonMailingCountry = 'Japan', PersonEmail = 'lll@tti.com', Brand__pc = 'Vax', Country__pc = 'Japan', 
        PersonLeadSource = 'Web', RecordTypeId = getObjectRecordTypeId(Account.sObjectType, 'B2C Consumer Contact'), Record_Status__c = 'Active');
        insert newAccount;
        
        Product2 p = new Product2(Name='Prod Record', Description='Product entry1', isActive=true);
        insert p;
        
        Receipts__c receipt = new Receipts__c(Account__c = newAccount.Id, ReceiptSource__c = 'Bunnings', Receipt_Name__c = ApexPages.currentPage().getParameters().get('documentbody'));   
        insert receipt;
        
        Asset newAsset = new Asset(Product2Id = p.Id, AccountId = newAccount.Id, ContactId = newAccount.PersonContactId, PurchaseDate = System.today() - 5,
        SerialNumber = '11' + '12' + '13', Name = 'Temporary Name', Standard_Warranty_Months__c = 12, 
        WarrantyCalculatedEndDate__c = System.today() + 360, Receipt__c = receipt.Id,
        HelpText__c='Help Text Test', Serial_Number_Length__c=6);
        insert newAsset;
        
        Attachment parentAtt = new Attachment(Name = 'Att1', ParentId = newAsset.Id, Body =  Blob.valueOf('Attachment 1, Attachment 2, Attachment 3'));
        insert parentAtt;
        
        CreateAccountController controller = new CreateAccountController();
        controller.CreateAccount();  
    }

    private static testMethod void vaxRetailCatalogue() {
        PageReference pageRef = Page.CreateAccount;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('brand','Vax');
        ApexPages.currentPage().getParameters().put('first_name','RyobiFirst');
        ApexPages.currentPage().getParameters().put('last_name','RyobiLast');
        ApexPages.currentPage().getParameters().put('email','Ryobi@yahoo.com');
        ApexPages.currentPage().getParameters().put('city','Suberp');
        ApexPages.currentPage().getParameters().put('postcode','1234');
        ApexPages.currentPage().getParameters().put('state','Suberp123');
        ApexPages.currentPage().getParameters().put('telephone','1234567890');
        
        ApexPages.currentPage().getParameters().put('model','1');
        ApexPages.currentPage().getParameters().put('guarantee','2 years');
        ApexPages.currentPage().getParameters().put('document','1');
        ApexPages.currentPage().getParameters().put('documentbody','1');
        ApexPages.currentPage().getParameters().put('serial_number_step_1','11');
        ApexPages.currentPage().getParameters().put('serial_number_step_2','02');
        ApexPages.currentPage().getParameters().put('serial_number_step_3','03');
        ApexPages.currentPage().getParameters().put('purchased','02/01/2018');
        ApexPages.currentPage().getParameters().put('location','bunnings');
        ApexPages.currentPage().getParameters().put('retUrl','ryobi.com.au');
        // have conditions
        ApexPages.currentPage().getParameters().put('marketing', 'Retail-Catalogue');
        ApexPages.currentPage().getParameters().put('purchased_online','1'); // assetPurchaseOnline 1 or 0
        ApexPages.currentPage().getParameters().put('phone_type','Work'); // accountPhoneType Mobile/Home/Work
        ApexPages.currentPage().getParameters().put('opt_in','0'); // mpSubscribe 1 or 0
        
        Account newAccount = new Account(Salutation = 'Mr.', FirstName = 'Dirk', LastName = 'Nowit', Delivery_Country__c = 'Africa', PersonMailingStreet = 'Paeo', PersonMailingCity = 'Sudan', 
        PersonMailingState = 'Saudi', PersonMailingPostalCode = '4116', PersonMailingCountry = 'Japan', PersonEmail = 'lll@tti.com', Brand__pc = 'Vax', Country__pc = 'Japan', 
        PersonLeadSource = 'Web', RecordTypeId = getObjectRecordTypeId(Account.sObjectType, 'B2C Consumer Contact'), Record_Status__c = 'Active');
        insert newAccount;
        
        Product2 p = new Product2(Name='Prod Record', Description='Product entry1', isActive=true);
        insert p;
        
        Receipts__c receipt = new Receipts__c(Account__c = newAccount.Id, ReceiptSource__c = 'Bunnings', Receipt_Name__c = ApexPages.currentPage().getParameters().get('documentbody'));   
        insert receipt;
        
        Asset newAsset = new Asset(Product2Id = p.Id, AccountId = newAccount.Id, ContactId = newAccount.PersonContactId, PurchaseDate = System.today() - 5,
        SerialNumber = '11' + '12' + '13', Name = 'Temporary Name', Standard_Warranty_Months__c = 12, 
        WarrantyCalculatedEndDate__c = System.today() + 360, Receipt__c = receipt.Id,
        HelpText__c='Help Text Test', Serial_Number_Length__c=6);
        insert newAsset;
        
        Attachment parentAtt = new Attachment(Name = 'Att1', ParentId = newAsset.Id, Body =  Blob.valueOf('Attachment 1, Attachment 2, Attachment 3'));
        insert parentAtt;
        
        CreateAccountController controller = new CreateAccountController();
        controller.CreateAccount();  
    }

    private static testMethod void vaxRetailInStore() {
        PageReference pageRef = Page.CreateAccount;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('brand','Vax');
        ApexPages.currentPage().getParameters().put('first_name','RyobiFirst');
        ApexPages.currentPage().getParameters().put('last_name','RyobiLast');
        ApexPages.currentPage().getParameters().put('email','Ryobi@yahoo.com');
        ApexPages.currentPage().getParameters().put('city','Suberp');
        ApexPages.currentPage().getParameters().put('postcode','1234');
        ApexPages.currentPage().getParameters().put('state','Suberp123');
        ApexPages.currentPage().getParameters().put('telephone','1234567890');
        
        ApexPages.currentPage().getParameters().put('model','1');
        ApexPages.currentPage().getParameters().put('guarantee','2 years');
        ApexPages.currentPage().getParameters().put('document','1');
        ApexPages.currentPage().getParameters().put('documentbody','1');
        ApexPages.currentPage().getParameters().put('serial_number_step_1','11');
        ApexPages.currentPage().getParameters().put('serial_number_step_2','02');
        ApexPages.currentPage().getParameters().put('serial_number_step_3','03');
        ApexPages.currentPage().getParameters().put('purchased','02/01/2018');
        ApexPages.currentPage().getParameters().put('location','bunnings');
        ApexPages.currentPage().getParameters().put('retUrl','ryobi.com.au');
        // have conditions
        ApexPages.currentPage().getParameters().put('marketing', 'Retail-In-Store');
        ApexPages.currentPage().getParameters().put('purchased_online','1'); // assetPurchaseOnline 1 or 0
        ApexPages.currentPage().getParameters().put('phone_type','Mobile'); // accountPhoneType Mobile/Home/Work
        ApexPages.currentPage().getParameters().put('opt_in','0'); // mpSubscribe 1 or 0
        
        Account newAccount = new Account(Salutation = 'Mr.', FirstName = 'Dirk', LastName = 'Nowit', Delivery_Country__c = 'Africa', PersonMailingStreet = 'Paeo', PersonMailingCity = 'Sudan', 
        PersonMailingState = 'Saudi', PersonMailingPostalCode = '4116', PersonMailingCountry = 'Japan', PersonEmail = 'lll@tti.com', Brand__pc = 'Vax', Country__pc = 'Japan', 
        PersonLeadSource = 'Web', RecordTypeId = getObjectRecordTypeId(Account.sObjectType, 'B2C Consumer Contact'), Record_Status__c = 'Active');
        insert newAccount;
        
        Product2 p = new Product2(Name='Prod Record', Description='Product entry1', isActive=true);
        insert p;
        
        Receipts__c receipt = new Receipts__c(Account__c = newAccount.Id, ReceiptSource__c = 'Bunnings', Receipt_Name__c = ApexPages.currentPage().getParameters().get('documentbody'));   
        insert receipt;
        
        Asset newAsset = new Asset(Product2Id = p.Id, AccountId = newAccount.Id, ContactId = newAccount.PersonContactId, PurchaseDate = System.today() - 5,
        SerialNumber = '11' + '12' + '13', Name = 'Temporary Name', Standard_Warranty_Months__c = 12, 
        WarrantyCalculatedEndDate__c = System.today() + 360, Receipt__c = receipt.Id,
        HelpText__c='Help Text Test', Serial_Number_Length__c=6);
        insert newAsset;
        
        Attachment parentAtt = new Attachment(Name = 'Att1', ParentId = newAsset.Id, Body =  Blob.valueOf('Attachment 1, Attachment 2, Attachment 3'));
        insert parentAtt;
        
        CreateAccountController controller = new CreateAccountController();
        controller.CreateAccount();  
    }
    private static testMethod void vaxWebsite() {
        PageReference pageRef = Page.CreateAccount;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('brand','Vax');
        ApexPages.currentPage().getParameters().put('first_name','RyobiFirst');
        ApexPages.currentPage().getParameters().put('last_name','RyobiLast');
        ApexPages.currentPage().getParameters().put('email','Ryobi@yahoo.com');
        ApexPages.currentPage().getParameters().put('city','Suberp');
        ApexPages.currentPage().getParameters().put('postcode','1234');
        ApexPages.currentPage().getParameters().put('state','Suberp123');
        ApexPages.currentPage().getParameters().put('telephone','1234567890');
        
        ApexPages.currentPage().getParameters().put('model','1');
        ApexPages.currentPage().getParameters().put('guarantee','2 years');
        ApexPages.currentPage().getParameters().put('document','1');
        ApexPages.currentPage().getParameters().put('documentbody','1');
        ApexPages.currentPage().getParameters().put('serial_number_step_1','11');
        ApexPages.currentPage().getParameters().put('serial_number_step_2','02');
        ApexPages.currentPage().getParameters().put('serial_number_step_3','03');
        ApexPages.currentPage().getParameters().put('purchased','02/01/2018');
        ApexPages.currentPage().getParameters().put('location','bunnings');
        ApexPages.currentPage().getParameters().put('retUrl','ryobi.com.au');
        // have conditions
        ApexPages.currentPage().getParameters().put('marketing', 'Website');
        ApexPages.currentPage().getParameters().put('purchased_online','1'); // assetPurchaseOnline 1 or 0
        ApexPages.currentPage().getParameters().put('phone_type','Mobile'); // accountPhoneType Mobile/Home/Work
        ApexPages.currentPage().getParameters().put('opt_in','0'); // mpSubscribe 1 or 0
        
        Account newAccount = new Account(Salutation = 'Mr.', FirstName = 'Dirk', LastName = 'Nowit', Delivery_Country__c = 'Africa', PersonMailingStreet = 'Paeo', PersonMailingCity = 'Sudan', 
        PersonMailingState = 'Saudi', PersonMailingPostalCode = '4116', PersonMailingCountry = 'Japan', PersonEmail = 'lll@tti.com', Brand__pc = 'Vax', Country__pc = 'Japan', 
        PersonLeadSource = 'Web', RecordTypeId = getObjectRecordTypeId(Account.sObjectType, 'B2C Consumer Contact'), Record_Status__c = 'Active');
        insert newAccount;
        
        Product2 p = new Product2(Name='Prod Record', Description='Product entry1', isActive=true);
        insert p;
        
        Receipts__c receipt = new Receipts__c(Account__c = newAccount.Id, ReceiptSource__c = 'Bunnings', Receipt_Name__c = ApexPages.currentPage().getParameters().get('documentbody'));   
        insert receipt;
        
        Asset newAsset = new Asset(Product2Id = p.Id, AccountId = newAccount.Id, ContactId = newAccount.PersonContactId, PurchaseDate = System.today() - 5,
        SerialNumber = '11' + '12' + '13', Name = 'Temporary Name', Standard_Warranty_Months__c = 12, 
        WarrantyCalculatedEndDate__c = System.today() + 360, Receipt__c = receipt.Id,
        HelpText__c='Help Text Test', Serial_Number_Length__c=6);
        insert newAsset;
        
        Attachment parentAtt = new Attachment(Name = 'Att1', ParentId = newAsset.Id, Body =  Blob.valueOf('Attachment 1, Attachment 2, Attachment 3'));
        insert parentAtt;
        
        CreateAccountController controller = new CreateAccountController();
        controller.CreateAccount();  
    }

    private static testMethod void vaxMarketing() {
        PageReference pageRef = Page.CreateAccount;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('brand','Vax');
        ApexPages.currentPage().getParameters().put('first_name','RyobiFirst');
        ApexPages.currentPage().getParameters().put('last_name','RyobiLast');
        ApexPages.currentPage().getParameters().put('email','Ryobi@yahoo.com');
        ApexPages.currentPage().getParameters().put('city','Suberp');
        ApexPages.currentPage().getParameters().put('postcode','1234');
        ApexPages.currentPage().getParameters().put('state','Suberp123');
        ApexPages.currentPage().getParameters().put('telephone','1234567890');
        
        ApexPages.currentPage().getParameters().put('model','1');
        ApexPages.currentPage().getParameters().put('guarantee','2 years');
        ApexPages.currentPage().getParameters().put('document','1');
        ApexPages.currentPage().getParameters().put('documentbody','1');
        ApexPages.currentPage().getParameters().put('serial_number_step_1','11');
        ApexPages.currentPage().getParameters().put('serial_number_step_2','02');
        ApexPages.currentPage().getParameters().put('serial_number_step_3','03');
        ApexPages.currentPage().getParameters().put('purchased','02/01/2018');
        ApexPages.currentPage().getParameters().put('location','bunnings');
        ApexPages.currentPage().getParameters().put('retUrl','ryobi.com.au');
        // have conditions
        ApexPages.currentPage().getParameters().put('marketing', 'Marketing');
        ApexPages.currentPage().getParameters().put('purchased_online','1'); // assetPurchaseOnline 1 or 0
        ApexPages.currentPage().getParameters().put('phone_type','Mobile'); // accountPhoneType Mobile/Home/Work
        ApexPages.currentPage().getParameters().put('opt_in','0'); // mpSubscribe 1 or 0
        
        Account newAccount = new Account(Salutation = 'Mr.', FirstName = 'Dirk', LastName = 'Nowit', Delivery_Country__c = 'Africa', PersonMailingStreet = 'Paeo', PersonMailingCity = 'Sudan', 
        PersonMailingState = 'Saudi', PersonMailingPostalCode = '4116', PersonMailingCountry = 'Japan', PersonEmail = 'lll@tti.com', Brand__pc = 'Vax', Country__pc = 'Japan', 
        PersonLeadSource = 'Web', RecordTypeId = getObjectRecordTypeId(Account.sObjectType, 'B2C Consumer Contact'), Record_Status__c = 'Active');
        insert newAccount;
        
        Product2 p = new Product2(Name='Prod Record', Description='Product entry1', isActive=true);
        insert p;
        
        Receipts__c receipt = new Receipts__c(Account__c = newAccount.Id, ReceiptSource__c = 'Bunnings', Receipt_Name__c = ApexPages.currentPage().getParameters().get('documentbody'));   
        insert receipt;
        
        Asset newAsset = new Asset(Product2Id = p.Id, AccountId = newAccount.Id, ContactId = newAccount.PersonContactId, PurchaseDate = System.today() - 5,
        SerialNumber = '11' + '12' + '13', Name = 'Temporary Name', Standard_Warranty_Months__c = 12, 
        WarrantyCalculatedEndDate__c = System.today() + 360, Receipt__c = receipt.Id,
        HelpText__c='Help Text Test', Serial_Number_Length__c=6);
        insert newAsset;
        
        Attachment parentAtt = new Attachment(Name = 'Att1', ParentId = newAsset.Id, Body =  Blob.valueOf('Attachment 1, Attachment 2, Attachment 3'));
        insert parentAtt;
        
        CreateAccountController controller = new CreateAccountController();
        controller.CreateAccount();  
    }

    public static testMethod void milwaukeeTestMethod() {
        PageReference pageRef = Page.CreateAccount;
        Test.setCurrentPage(pageRef);

        ApexPages.currentPage().getParameters().put('brand','Milwaukee');
        ApexPages.currentPage().getParameters().put('First Name', 'MilFirst');
        ApexPages.currentPage().getParameters().put('Surname', 'MilLast');
        ApexPages.currentPage().getParameters().put('Address', 'address');
        ApexPages.currentPage().getParameters().put('Suburb', 'suburb');
        ApexPages.currentPage().getParameters().put('State', 'state');
        ApexPages.currentPage().getParameters().put('Postcode', '1234');
        ApexPages.currentPage().getParameters().put('email', 'MilFirst.Last@mil.com');
        ApexPages.currentPage().getParameters().put('Mobile', '1234567890');
        ApexPages.currentPage().getParameters().put('Phone', '1234567890');
        
        ApexPages.currentPage().getParameters().put('Product Purchased', 'prodCode0001');
        ApexPages.currentPage().getParameters().put('Redemption Product', 'prodCode0002');
        ApexPages.currentPage().getParameters().put('Scan/Photograph and upload your receipt', 'alsdkjhfadhsfdasflkhjasdflkjasdf');
        ApexPages.currentPage().getParameters().put('receipt_number', 'R-000001');
        ApexPages.currentPage().getParameters().put('Store', 'Test Store');
        ApexPages.currentPage().getParameters().put('Suburb', 'Test Suburb');

        ApexPages.currentPage().getParameters().put('retUrl', 'ttest/com.au');

        SerialNumberDisplayType__c snType = new SerialNumberDisplayType__c();
        snType.Name = 'test';
        snType.Serial_Number_Length__c = 10;
        snType.HelperImageURL__c = 'https://www.google.com.au/images/branding/googlelogo/2x/googlelogo_color_120x44dp.png';
        snType.IsDefault__c = true;
        snType.HelpText__c = 'Please enter the ten digit serial number located on your tool.';
        insert snType;

        List<Product2> prods = TestUtilityClass.createProduct(2);
        prods[0].SerialNumberDisplayType__c = snType.Id;
        prods[0].brand__c = 'RY';
        prods[0].category_customer_level1__c =  'Power Tools';
        prods[0].Kit__c = true;
        prods[0].ProductCode = 'prodCode0001';
        prods[1].SerialNumberDisplayType__c = snType.Id;
        prods[1].Brand__c = 'RY';
        prods[1].ProductCode = 'prodCode0002';
        Insert prods;

        Account newAccount = new Account(Salutation = 'Mr.', FirstName = 'Dirk', LastName = 'Nowit', Delivery_Country__c = 'Africa', PersonMailingStreet = 'Paeo', PersonMailingCity = 'Sudan', 
        PersonMailingState = 'Saudi', PersonMailingPostalCode = '4116', PersonMailingCountry = 'Japan', PersonEmail = 'lll@tti.com', Brand__pc = 'Milwaukee', Country__pc = 'Japan', 
        PersonLeadSource = 'Web', RecordTypeId = getObjectRecordTypeId(Account.sObjectType, 'B2C Consumer Contact'), Record_Status__c = 'Active');
        insert newAccount;
        
        Receipts__c receipt = new Receipts__c(Account__c = newAccount.Id, ReceiptSource__c = 'Bunnings', Receipt_Name__c = ApexPages.currentPage().getParameters().get('Scan/Photograph and upload your receipt'));   
        insert receipt;

        Test.startTest();
            CreateAccountController controller = new CreateAccountController();
            controller.CreateAccount();  
        Test.stopTest();
    }
    
    public static testMethod void createRyobiPersonAccountAndMCampaignTest() {
        PageReference pageRef = Page.CreateAccount;
        Test.setCurrentPage(pageRef);

        ApexPages.currentPage().getParameters().put('brand', 'RyobiSubscribe');
        ApexPages.currentPage().getParameters().put('retUrl', 'www.google.com');
        ApexPages.currentPage().getParameters().put('First Name', 'address');
        ApexPages.currentPage().getParameters().put('Last Name', 'suburb');
        ApexPages.currentPage().getParameters().put('Email Address', 'address.suburb@yopmail.com');
        ApexPages.currentPage().getParameters().put('Country', 'Australia');
        ApexPages.currentPage().getParameters().put('MCName', 'August 2018');
        ApexPages.currentPage().getParameters().put('MCUrl', 'www.google.com');
        ApexPages.currentPage().getParameters().put('MCArea', 'Footer');

        Test.startTest();
            CreateAccountController controller = new CreateAccountController();
            controller.CreateAccount();  
        Test.stopTest();
    }
    
    //Dynamic method to get Record type id
    public static String getObjectRecordTypeId(SObjectType sObjectType, String recordTypeName){
       //Generate a map of tokens for all the Record Types for the desired object
       Map<String, Schema.RecordTypeInfo> recordTypeInfo = sObjectType.getDescribe().getRecordTypeInfosByName();

       //Retrieve the record type id by name
       return recordTypeInfo.get(recordTypeName).getRecordTypeId();
    }

}