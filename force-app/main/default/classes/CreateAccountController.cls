public class CreateAccountController {
    
    private String accountTitle;
    private String accountFirstName;
    private String accountLastName;
    private String accountEmail;
    private String accountDeliveryCountry;
    private String accountStreet;
    private String accountCity;
    private String accountPostCode;
    private String accountState;
    private String accountTelephone;
    private String accountPhone;
    private String accountMobile;
    private String accountPhoneType;
    private String mpDrill;
    private String mpSaw;
    private String mpSander;
    private String mpLifeStyleProduct;
    private String mpNailer;
    private String mpLineTrimmer;
    private String mpLawnMower;
    private String mpBlower;
    private String mpHomeMaintenance;
    private String mpHomeImprovement;
    private String mpWoodWorkProject;
    private String mpGardening;
    private String mpUnlockCode;
    private String mpAgreePrivacy;
    private String mpSubscribe = '';
    private String assetModel;
    private String redemptionProductModel;
    private String assetWarranty;
    private String receiptFile = '';
    private String receiptFileBody;
    private String assetSerial1;
    private String assetSerial2;
    private String assetSerial3;
    private String assetStore;
    private String assetStoreSuburb;
    private String assetReceiptNumber;
    private String assetPurchaseDate;
    private String assetPurchaseType;
    private String retUrl;
    private String assetPurchaseOnline;
    private String marketing;
    
    public String debug { get; set; }
    
    private static Id b2cConsumerContactAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Consumer Contact').getRecordTypeId();
    private static Id inPackPromoMarketingCampaignRecTypeId = Schema.SObjectType.Marketing_Campaign__c.getRecordTypeInfosByName().get('In Pack Promo').getRecordTypeId();
    private static Id vaxBladePromo2018MarketingCampaignRecTypeId = Schema.SObjectType.Marketing_Campaign__c.getRecordTypeInfosByName().get('Vax Blade Promotion 2018').getRecordTypeId();
    private static Id redemptionCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Redemption').getRecordTypeId();
    private static Id ryobiSignUpMarketingCampaignRecTypeId = Schema.SObjectType.Marketing_Campaign__c.getRecordTypeInfosByName().get('Ryobi Signup').getRecordTypeId();

    public PageReference createAccount() {
        String brand = ApexPages.currentPage().getParameters().get('brand');
        system.debug('### brand: ' + brand);
        system.debug('### URL Parameters: ' + ApexPages.currentPage().getParameters());
        
        if (brand == 'Ryobi') {
            return createRyobiPersonAccount('Ryobi');
        } else if (brand == 'RyobiShed') {
            return createRyobiShedPersonAccountAndPreference('Ryobi');
        } else if (brand == 'AEG') {
            return createAegPersonAccount('AEG');
        } else if (brand == 'Vax') {
            return createVaxPersonAccount('Vax');
        } else if (brand == 'Milwaukee') {
            return createMilwaukeePersonAccount('Milwaukee');
        } else if (brand == 'RyobiSubscribe') {
            return createRyobiPersonAccountAndMCampaign('Ryobi');
        }
        
        return null;
    }

    public PageReference createRyobiPersonAccountAndMCampaign(String brand) {
        Boolean hasError = false;
        Savepoint sp = Database.setSavepoint();

        accountTitle = ApexPages.currentPage().getParameters().get('Salutation');
        accountFirstName = ApexPages.currentPage().getParameters().get('First Name');
        accountLastName = ApexPages.currentPage().getParameters().get('Last Name');
        accountEmail = ApexPages.currentPage().getParameters().get('Email Address');
        accountDeliveryCountry = ApexPages.currentPage().getParameters().get('Country');
        accountPostCode = ApexPages.currentPage().getParameters().get('Post Code');
        accountTelephone = ApexPages.currentPage().getParameters().get('Mobile Phone');

        String marketingCampaignName = ApexPages.currentPage().getParameters().get('MCName');
        String marketingCampaignURL = ApexPages.currentPage().getParameters().get('MCUrl');
        String marketingCampaignArea = ApexPages.currentPage().getParameters().get('MCArea');

        String diySkill = ApexPages.currentPage().getParameters().get('input-confidence_value');
        String diyPassion = ApexPages.currentPage().getParameters().get('input-enjoyment_value');

        system.debug('### diySkill: ' + diySkill);
        system.debug('### diyPassion: ' + diyPassion);

        retUrl = ApexPages.currentPage().getParameters().get('retUrl');

        List<Account> existingAccounts = [SELECT Id, Name FROM Account Where PersonEmail = :accountEmail AND Brand__pc = :brand AND RecordTypeId = :b2cConsumerContactAccRecTypeId];

        Account newAccount = new Account();
        newAccount.Salutation = accountTitle;
        newAccount.FirstName = accountFirstName;
        newAccount.LastName = accountLastName;
        newAccount.Delivery_Country__c = accountDeliveryCountry;
        newAccount.PersonmailingCountry = accountDeliveryCountry;
        newAccount.PersonMailingPostalCode = accountPostCode;
        newAccount.PersonEmail = accountEmail;
        newAccount.PersonMobilePhone = accountTelephone;        
        newAccount.Brand__pc = brand;
        newAccount.PersonLeadSource = 'Web';
        newAccount.RecordTypeId = b2cConsumerContactAccRecTypeId;
        newAccount.Record_Status__c = 'Active';
        newAccount.Confidence_in_Power_Tools__c = diySkill;
        newAccount.DIY_Enjoyment__c = diyPassion;
        

        List<User> connectedAppAdmins = [SELECT Id FROM User WHERE Name = 'Connected App Administrator' LIMIT 1];

        if(!connectedAppAdmins.isEmpty()) {
            newAccount.OwnerId = connectedAppAdmins[0].Id;
        }

        if(!existingAccounts.isEmpty()) {
            newAccount.Id = existingAccounts[0].Id;
        }

        try {
            upsert newAccount;
        } catch (Exception e) {
            hasError = true;
        }

        List<Marketing_Preference__c> marketingPreferences = [SELECT Id FROM Marketing_Preference__c WHERE Person_Account__c = :newAccount.Id LIMIT 1];

        Marketing_Preference__c marketingPreference = new Marketing_Preference__c();

        if(!marketingPreferences.isEmpty()) {
            marketingPreference.Id = marketingPreferences[0].Id;
            marketingPreference.Newsletter__c = true;
            marketingPreference.DIY_Inspiration__c = true;
            marketingPreference.New_Product_Updates__c = true;
            marketingPreference.SMS__c = true;
            marketingPreference.Feedback__c = true;
            marketingPreference.Product_Updates__c = true;
            marketingPreference.Promotion_Updates__c = true;
            marketingPreference.Maintenance__c = true;
        } else {
            marketingPreference.Person_Account__c = newAccount.Id;
        }

        try {
            upsert marketingPreference;
        } catch(Exception e) {
            hasError = true;  
        }

        // TODO: Marketing Campaign
        Marketing_Campaign__c marketingCampaign = new Marketing_Campaign__c();
        marketingCampaign.RecordTypeId = ryobiSignUpMarketingCampaignRecTypeId;
        marketingCampaign.Page_Source__c = marketingCampaignURL;
        marketingCampaign.Campaign__c = marketingCampaignName;
        marketingCampaign.Form_Position__c = marketingCampaignArea;
        marketingCampaign.Person_Account__c = newAccount.Id;

        try {
            upsert marketingCampaign;
        } catch(Exception e) {
            hasError = true; 
        }

        if(hasError == true) {
            Database.rollback(sp);
            return new PageReference(retUrl); // TODO: redirect to error page
        } else {
            return new PageReference(retUrl); // TODO: redirect to success page
        }
        
    }
    
    public PageReference createRyobiPersonAccount(String brand) {
        debug = '';
        Savepoint sp = Database.setSavepoint();
        
        accountFirstName = ApexPages.currentPage().getParameters().get('First Name');
        accountLastName = ApexPages.currentPage().getParameters().get('Last Name');
        accountEmail = ApexPages.currentPage().getParameters().get('Email Address');
        accountDeliveryCountry = ApexPages.currentPage().getParameters().get('Country');
        accountTitle = ApexPages.currentPage().getParameters().get('Salutation');
        
        retUrl = ApexPages.currentPage().getParameters().get('retUrl');
        
        List<Account> existingAccounts = [SELECT Id, Name FROM Account WHERE PersonEmail = :accountEmail AND Brand__pc = :brand AND RecordTypeId = :b2cConsumerContactAccRecTypeId];
        Account newAccount = new Account();
        newAccount.PersonTitle = accountTitle;
        newAccount.FirstName = accountFirstName;
        newAccount.LastName = accountLastName;
        newAccount.Country__pc = getCountryLongName(accountDeliveryCountry);
        newAccount.Delivery_Country__c = accountDeliveryCountry;
        newAccount.PersonMailingCountry = accountDeliveryCountry;
        newAccount.PersonEmail = accountEmail;
        newAccount.PersonHasOptedOutOfEmail = false;
        newAccount.Brand__pc = brand;
        newAccount.PersonLeadSource = 'Web';
        newAccount.RecordTypeId = b2cConsumerContactAccRecTypeId;
        newAccount.Record_Status__c = 'Active';

        List<User> connectedAppAdmins = [SELECT Id FROM User WHERE Name = 'Connected App Administrator' LIMIT 1];
        if (!connectedAppAdmins.isEmpty()) {
            newAccount.OwnerId = connectedAppAdmins[0].Id;
        }
        
        if (!existingAccounts.isEmpty()) {
            newAccount.Id = existingAccounts[0].Id;
        }
        
        try {
            upsert newAccount;
        } catch (Exception err) {
            System.debug(err);
            debug += 'Error #1: ' + err;
            return null;
        }
        
        List<Marketing_Preference__c> marketingPreferences = [SELECT Id, Newsletter__c, Person_Account__c FROM Marketing_Preference__c WHERE Person_Account__c = :newAccount.Id LIMIT 1];
        Marketing_Preference__c marketingPreference = new Marketing_Preference__c();
        marketingPreference.Newsletter__c = true;

        if (!marketingPreferences.isEmpty()) {
            marketingPreference.Id = marketingPreferences[0].Id;
        } else {
            marketingPreference.Person_Account__c = newAccount.Id;
        }
        
        try {
            upsert marketingPreference;
        } catch (Exception err) {
            System.debug(err);
            debug += 'Error #2: ' + err;
            Database.rollback(sp);
            return null;
        }
        
        return new PageReference(retUrl);
    }

    public PageReference createAegPersonAccount(String brand) {
        debug = '';
        Savepoint sp = Database.setSavepoint();
        
        accountFirstName = ApexPages.currentPage().getParameters().get('First Name');
        accountLastName = ApexPages.currentPage().getParameters().get('Last Name');
        accountEmail = ApexPages.currentPage().getParameters().get('Email Address');
        accountDeliveryCountry = ApexPages.currentPage().getParameters().get('Country');
        accountTitle = ApexPages.currentPage().getParameters().get('Salutation');
        
        retUrl = ApexPages.currentPage().getParameters().get('retUrl');
        
        List<Account> existingAccounts = [SELECT Id, Name FROM Account WHERE PersonEmail = :accountEmail AND Brand__pc = :brand AND RecordTypeId = :b2cConsumerContactAccRecTypeId];
        Account newAccount = new Account();
        newAccount.PersonTitle = accountTitle;
        newAccount.FirstName = accountFirstName;
        newAccount.LastName = accountLastName;
        newAccount.Country__pc = getCountryLongName(accountDeliveryCountry);
        newAccount.Delivery_Country__c = accountDeliveryCountry;
        newAccount.PersonMailingCountry = accountDeliveryCountry;
        newAccount.PersonEmail = accountEmail;
        newAccount.PersonHasOptedOutOfEmail = false;
        newAccount.Brand__pc = brand;
        newAccount.PersonLeadSource = 'Web';
        newAccount.RecordTypeId = b2cConsumerContactAccRecTypeId;
        newAccount.Record_Status__c = 'Active';

        List<User> connectedAppAdmins = [SELECT Id FROM User WHERE Name = 'Connected App Administrator' LIMIT 1];
        if (!connectedAppAdmins.isEmpty()) {
            newAccount.OwnerId = connectedAppAdmins[0].Id;
        }
        
        if (!existingAccounts.isEmpty()) {
            newAccount.Id = existingAccounts[0].Id;
        }
        
        try {
            upsert newAccount;
        } catch (Exception err) {
            System.debug(err);
            debug += 'Error #1: ' + err;
            return null;
        }
        
        List<Marketing_Preference__c> marketingPreferences = [SELECT Id, Newsletter__c, SMS__c, Person_Account__c FROM Marketing_Preference__c WHERE Person_Account__c = :newAccount.Id LIMIT 1];
        Marketing_Preference__c marketingPreference = new Marketing_Preference__c();
        marketingPreference.Newsletter__c = true;
        marketingPreference.SMS__c = true;

        if (!marketingPreferences.isEmpty()) {
            marketingPreference.Id = marketingPreferences[0].Id;
        } else {
            marketingPreference.Person_Account__c = newAccount.Id;
        }
        
        try {
            upsert marketingPreference;
        } catch (Exception err) {
            System.debug(err);
            debug += 'Error #2: ' + err;
            Database.rollback(sp);
            return null;
        }
        
        return new PageReference(retUrl);
    }
    
    public PageReference createRyobiShedPersonAccountAndPreference(String brand) {
        debug = '';
        Savepoint sp = Database.setSavepoint();
        
        accountFirstName = ApexPages.currentPage().getParameters().get('Person.pFirstName');
        accountLastName = ApexPages.currentPage().getParameters().get('Person.pLastName');
        accountEmail = ApexPages.currentPage().getParameters().get('Person.pEmail');
        accountDeliveryCountry = 'Australia';
        accountStreet = ApexPages.currentPage().getParameters().get('Person.pAddress');
        accountCity = ApexPages.currentPage().getParameters().get('Person.pSuburb');
        accountPostCode = ApexPages.currentPage().getParameters().get('Person.pPostCode');
        accountState = ApexPages.currentPage().getParameters().get('Person.pState');
        accountTelephone = ApexPages.currentPage().getParameters().get('Person.pTelephone');
        
        mpDrill = ApexPages.currentPage().getParameters().get('drill');
        mpSaw = ApexPages.currentPage().getParameters().get('saw');
        mpSander = ApexPages.currentPage().getParameters().get('sander');
        mpLifeStyleProduct = ApexPages.currentPage().getParameters().get('lifestyleproduct');
        mpNailer = ApexPages.currentPage().getParameters().get('nailer');
        mpLineTrimmer = ApexPages.currentPage().getParameters().get('linetrimmer');
        mpLawnMower = ApexPages.currentPage().getParameters().get('lawnmower');
        mpBlower = ApexPages.currentPage().getParameters().get('blower');
        mpHomeMaintenance = ApexPages.currentPage().getParameters().get('homemaintenance');
        mpHomeImprovement = ApexPages.currentPage().getParameters().get('homeimprovement');
        mpWoodWorkProject = ApexPages.currentPage().getParameters().get('woodworkproject');
        mpGardening = ApexPages.currentPage().getParameters().get('gardening');
        mpUnlockCode = ApexPages.currentPage().getParameters().get('UnlockCode');
        mpAgreePrivacy = ApexPages.currentPage().getParameters().get('agreeprivacy');
        mpSubscribe = ApexPages.currentPage().getParameters().get('subscribe');
        
        retUrl = ApexPages.currentPage().getParameters().get('retUrl');
        
        List<Account> existingAccounts = [SELECT Id, Name FROM Account WHERE PersonEmail = :accountEmail AND Brand__pc = :brand AND RecordTypeId = :b2cConsumerContactAccRecTypeId];
        Account newAccount = new Account();
        newAccount.FirstName = accountFirstName;
        newAccount.LastName = accountLastName;
        newAccount.Delivery_Country__c = accountDeliveryCountry;
        newAccount.PersonMailingStreet = accountStreet;
        newAccount.PersonMailingCity = accountCity;
        newAccount.PersonMailingState = accountState;
        newAccount.PersonMailingPostalCode = accountPostCode;
        newAccount.PersonMailingCountry = accountDeliveryCountry;
        newAccount.PersonEmail = accountEmail;
        newAccount.PersonHasOptedOutOfEmail = false;
        newAccount.Brand__pc = brand;
        newAccount.PersonMobilePhone = accountTelephone;
        newAccount.PersonLeadSource = 'Web';
        newAccount.RecordTypeId = b2cConsumerContactAccRecTypeId;
        newAccount.Record_Status__c = 'Active';

        List<User> connectedAppAdmins = [SELECT Id FROM User WHERE Name = 'Connected App Administrator' LIMIT 1];
        if (!connectedAppAdmins.isEmpty()) {
            newAccount.OwnerId = connectedAppAdmins[0].Id;
        }
        
        if (!existingAccounts.isEmpty()) {
            newAccount.Id = existingAccounts[0].Id;
        }
        
        try {
            upsert newAccount;
        } catch (Exception err) {
            System.debug(err);
            debug += 'Error #3: ' + err;
            return null;
        }

        List<Marketing_Preference__c> marketingPreferences = [SELECT Id, DIY_Inspiration__c, New_Product_Updates__c, Newsletter__c, SMS__c FROM Marketing_Preference__c WHERE Person_Account__c = :newAccount.Id LIMIT 1];
        Marketing_Preference__c marketingPreference = new Marketing_Preference__c();

        List<Marketing_Campaign__c> marketingCampaigns = [SELECT Id, Next_Project_Tools__c, To_Do_List__c, Unique_Code__c FROM Marketing_Campaign__c WHERE Person_Account__c = :newAccount.Id LIMIT 1];
        Marketing_Campaign__c marketingCampaign = new Marketing_Campaign__c();
        
        marketingCampaign.RecordTypeId = inPackPromoMarketingCampaignRecTypeId;
        
        marketingCampaign.Next_Project_Tools__c = '';
        if (mpDrill.equals('1')) {
            marketingCampaign.Next_Project_Tools__c += 'Drill;';
        }
        if (mpSaw.equals('1')) {
            marketingCampaign.Next_Project_Tools__c += 'Saw;';
        }
        if (mpSander.equals('1')) {
            marketingCampaign.Next_Project_Tools__c += 'Sander;';
        }
        if (mpLifeStyleProduct.equals('1')) {
            marketingCampaign.Next_Project_Tools__c += 'Lifestyle Product;';
        }
        if (mpNailer.equals('1')) {
            marketingCampaign.Next_Project_Tools__c += 'Nailer;';
        }
        if (mpLineTrimmer.equals('1')) {
            marketingCampaign.Next_Project_Tools__c += 'Line Trimmer;';
        }
        if (mpLawnMower.equals('1')) {
            marketingCampaign.Next_Project_Tools__c += 'Lawn Mower;';
        }
        if (mpBlower.equals('1')) {
            marketingCampaign.Next_Project_Tools__c += 'Blower;';
        }
        
        marketingCampaign.To_Do_List__c = '';
        if (mpHomeMaintenance.equals('1')) {
            marketingCampaign.To_Do_List__c += 'Home Maintenance;';
        }
        if (mpHomeImprovement.equals('1')) {
            marketingCampaign.To_Do_List__c += 'Home Improvement;';
        }
        if (mpWoodWorkProject.equals('1')) {
            marketingCampaign.To_Do_List__c += 'Woodwork Project;';
        }
        if (mpGardening.equals('1')) {
            marketingCampaign.To_Do_List__c += 'Gardening;';
        }
        
        if (mpSubscribe.equalsIgnoreCase('yes')) {
            marketingPreference.Newsletter__c = true;
            marketingPreference.DIY_Inspiration__c = true;
            marketingPreference.New_Product_Updates__c = true;
        }
        
        marketingCampaign.Unique_Code__c = mpUnlockCode;
        
        if (!marketingPreferences.isEmpty()) {
            marketingPreference.Id = marketingPreferences[0].Id;
        } else {
            marketingPreference.Person_Account__c = newAccount.Id;
        }
        
        marketingCampaign.Person_Account__c = newAccount.Id;
        
        try {
            upsert marketingPreference;
        } catch (Exception err) {
            System.debug(err);
            debug += 'Error #4: ' + err;
            Database.rollback(sp);
            return null;
        }
        
        try {
            insert marketingCampaign;
        } catch (Exception err) {
            System.debug(err);
            debug += 'Error #5: ' + err;
            Database.rollback(sp);
            return null;
        }
        
        return new PageReference(retUrl);
    }
    
    public PageReference createVaxPersonAccount(String brand) {
        debug = '';
        Savepoint sp = Database.setSavepoint();
        
        accountTitle = ApexPages.currentPage().getParameters().get('title');
        accountFirstName = ApexPages.currentPage().getParameters().get('first_name');
        accountLastName = ApexPages.currentPage().getParameters().get('last_name');
        accountStreet = ApexPages.currentPage().getParameters().get('street');
        accountCity = ApexPages.currentPage().getParameters().get('city');
        accountState = ApexPages.currentPage().getParameters().get('state');
        accountPostCode = ApexPages.currentPage().getParameters().get('post_code');
        accountEmail = ApexPages.currentPage().getParameters().get('email');
        accountTelephone = ApexPages.currentPage().getParameters().get('telephone');
        accountPhoneType = ApexPages.currentPage().getParameters().get('phone_type');
        
        assetModel = ApexPages.currentPage().getParameters().get('model');
        assetWarranty = ApexPages.currentPage().getParameters().get('guarantee');
        receiptFile = ApexPages.currentPage().getParameters().get('document');
        receiptFileBody = ApexPages.currentPage().getParameters().get('documentbody');
        assetSerial1 = ApexPages.currentPage().getParameters().get('serial_number_step_1');
        assetSerial2 = ApexPages.currentPage().getParameters().get('serial_number_step_2');
        assetSerial3 = ApexPages.currentPage().getParameters().get('serial_number_step_3');
        assetPurchaseDate = ApexPages.currentPage().getParameters().get('purchased');
        assetPurchaseType = ApexPages.currentPage().getParameters().get('location');
        assetPurchaseOnline = ApexPages.currentPage().getParameters().get('purchased_online');
        accountDeliveryCountry = ApexPages.currentPage().getParameters().get('country');

        marketing = ApexPages.currentPage().getParameters().get('marketing');
        
        mpSubscribe = ApexPages.currentPage().getParameters().get('opt_in');
        
        retUrl = ApexPages.currentPage().getParameters().get('retUrl');
        
        List<Account> existingAccountsEmailBrand = [SELECT Id, Name, PersonContactId FROM Account WHERE PersonEmail = :accountEmail AND Brand__pc = :brand AND RecordTypeId = :b2cConsumerContactAccRecTypeId];
        List<Account> existingAccountsNameMobileBrand = [SELECT Id, Name, PersonContactId FROM Account WHERE PersonMobilePhone = :accountTelephone
                                                         AND FirstName = :accountFirstName AND LastName = :accountLastName AND Brand__pc = :brand AND RecordTypeId = :b2cConsumerContactAccRecTypeId];
        Account newAccount = new Account();
        newAccount.Salutation = accountTitle;
        newAccount.FirstName = accountFirstName;
        newAccount.LastName = accountLastName;
        newAccount.Delivery_Country__c = accountDeliveryCountry;
        newAccount.PersonMailingStreet = accountStreet;
        newAccount.PersonMailingCity = accountCity;
        newAccount.PersonMailingState = accountState;
        newAccount.PersonMailingPostalCode = accountPostCode;
        newAccount.PersonMailingCountry = accountDeliveryCountry;
        newAccount.PersonEmail = accountEmail;
        newAccount.Brand__pc = brand;
        newAccount.Country__pc = accountDeliveryCountry;
        newAccount.PersonLeadSource = 'Web';
        newAccount.RecordTypeId = b2cConsumerContactAccRecTypeId;
        newAccount.Record_Status__c = 'Active';
        
        if (accountPhoneType == 'Mobile') {
            newAccount.PersonMobilePhone = accountTelephone.deleteWhitespace();
        } else if (accountPhoneType == 'Home') {
            newAccount.PersonHomePhone = accountTelephone.deleteWhitespace();
        } else if (accountPhoneType == 'Work') {
            newAccount.Phone = accountTelephone.deleteWhitespace();
        }
        
        if (mpSubscribe == '1') {
            newAccount.PersonHasOptedOutOfEmail = false;
        } else {
            newAccount.PersonHasOptedOutOfEmail = true;
        }
        
        if (!existingAccountsEmailBrand.isEmpty()) {
            newAccount.Id = existingAccountsEmailBrand[0].Id;
        } else if (!existingAccountsNameMobileBrand.isEmpty()) {
            newAccount.Id = existingAccountsNameMobileBrand[0].Id;
        }

        List<User> connectedAppAdmins = [SELECT Id FROM User WHERE Name = 'Connected App Administrator' LIMIT 1];
        if (!connectedAppAdmins.isEmpty()) {
            newAccount.OwnerId = connectedAppAdmins[0].Id;
        }
        
        try {
            upsert newAccount;
        } catch (Exception err) {
            System.debug(err);
            debug += 'Error #1: ' + err;
            Database.rollback(sp);
            return null;
        }
        
        Set<Id> accIds = new Set<Id>();
             
        newAccount = [SELECT PersonContactId, Id FROM Account WHERE Id = :newAccount.Id];
        
        Product2 existingProduct = [SELECT Id FROM Product2 WHERE ProductCode = :assetModel LIMIT 1];
        Asset newAsset = new Asset();
        newAsset.Product2Id = existingProduct.Id;
        newAsset.AccountId = newAccount.Id;
        newAsset.ContactId = newAccount.PersonContactId;
        newAsset.PurchaseDate = Date.parse(assetPurchaseDate);
        newAsset.SerialNumber = assetSerial1 + assetSerial2 + assetSerial3;
        newAsset.Name = 'Temporary Name';
        newAsset.Standard_Warranty_Months__c = Integer.valueOf(assetWarranty.split(' ')[0]) * 12;
        newAsset.WarrantyCalculatedEndDate__c = newAsset.PurchaseDate.addMonths(Integer.valueOf(newAsset.Standard_Warranty_Months__c));

        if (assetPurchaseOnline == '1') {
            newAsset.Purchased_Online__c = 'Online';    
        } else if (assetPurchaseOnline == '0') {
            newAsset.Purchased_Online__c = 'In-Store';
        }
        
        newAsset.AssetSource__c = 'Retailer - ' + assetPurchaseType;
        
        try {
            insert newAsset;
        } catch (Exception err) {
            System.debug(err);
            debug += 'Error #2: ' + err;
            Database.rollback(sp);
            return null;
        }
        
        if (receiptFileBody != '') {
            try {
                Receipts__c receipt = [SELECT Id, Receipt_Name__c FROM Receipts__c WHERE Receipt_Name__c = :receiptFileBody];
                receipt.Account__c = newAccount.Id;
                receipt.ReceiptSource__c = 'Bunnings';

                update receipt;

                newAsset.Receipt__c = receipt.Id;
                update newAsset;
            } catch (Exception err) {
                System.debug(err);
                debug += 'Error #3: ' + err;
            }
        }

        List<Marketing_Preference__c> marketingPreferences = [SELECT Id, Newsletter__c, SMS__c, Person_Account__c FROM Marketing_Preference__c WHERE Person_Account__c = :newAccount.Id LIMIT 1];
        Marketing_Preference__c marketingPreference = new Marketing_Preference__c();
        if (mpSubscribe == '0') {
            marketingPreference.Newsletter__c = true;
            marketingPreference.DIY_Inspiration__c = true;
            marketingPreference.New_Product_Updates__c = true;
        }

        if (!marketingPreferences.isEmpty()) {
            marketingPreference.Id = marketingPreferences[0].Id;
        } else {
            marketingPreference.Person_Account__c = newAccount.Id;
        }
        
        if (newAccount.Id != null) {
            try {
                upsert marketingPreference;
            } catch (Exception err) {
                System.debug(err);
                debug += 'Error #4: ' + err;
                Database.rollback(sp);
                return null;
            }

            if (marketing != null && marketing != '') {
                Marketing_Campaign__c vaxBladePromotionMC = new Marketing_Campaign__c();
                vaxBladePromotionMC.RecordTypeId = vaxBladePromo2018MarketingCampaignRecTypeId;
                vaxBladePromotionMC.Person_Account__c = newAccount.Id;

                if (marketing == 'Television') {
                    vaxBladePromotionMC.Campaign_Source__c = 'Television';
                } else if (marketing == 'Magazine-Newspaper') {
                    vaxBladePromotionMC.Campaign_Source__c = 'Magazine/Newspaper';
                } else if (marketing == 'Retail-Catalogue') {
                    vaxBladePromotionMC.Campaign_Source__c = 'Retail Catalogue';
                } else if (marketing == 'Retail-In-Store') {
                    vaxBladePromotionMC.Campaign_Source__c = 'Retail (In-store)';
                } else if (marketing == 'Website') {
                    vaxBladePromotionMC.Campaign_Source__c = 'Website (vax.com.au)';
                } else {
                    vaxBladePromotionMC.Campaign_Source__c = null;
                }
                
                try {
                    upsert vaxBladePromotionMC;
                } catch (Exception err) {
                    System.debug(err);
                    debug += 'Error #5: ' + err;
                    Database.rollback(sp);
                    return null;
                }
            }
        }

        /*newAsset = [SELECT Id FROM Asset WHERE Id =: newAsset.Id];
        
        PageReference pageRef = Page.BVPixel;
        pageRef.getParameters().put('accIdVAX',newAccount.Id);
        pageRef.getParameters().put('accBrand',newAccount.Brand__pc);
        pageRef.getParameters().put('astIdVAX',newAsset.Id);
        pageRef.getParameters().put('returlVAX',retUrl);*/
        return new PageReference(retUrl);
    }

    public PageReference createMilwaukeePersonAccount(String brand) {
        debug = '';
        Savepoint sp = Database.setSavepoint();
        
        accountFirstName = ApexPages.currentPage().getParameters().get('First Name');
        accountLastName = ApexPages.currentPage().getParameters().get('Surname');
        accountStreet = ApexPages.currentPage().getParameters().get('Address');
        accountCity = ApexPages.currentPage().getParameters().get('Suburb');
        accountState = ApexPages.currentPage().getParameters().get('State');
        accountPostCode = ApexPages.currentPage().getParameters().get('Postcode');
        accountEmail = ApexPages.currentPage().getParameters().get('email');
        accountMobile = ApexPages.currentPage().getParameters().get('Mobile');
        accountPhone = ApexPages.currentPage().getParameters().get('Phone');
        
        assetModel = ApexPages.currentPage().getParameters().get('Product Purchased');
        redemptionProductModel = ApexPages.currentPage().getParameters().get('Redemption Product');
        receiptFileBody = ApexPages.currentPage().getParameters().get('Scan/Photograph and upload your receipt');
        //receiptFileBody = '';
        assetReceiptNumber = ApexPages.currentPage().getParameters().get('receipt_number');
        assetStore = ApexPages.currentPage().getParameters().get('Store');
        assetStoreSuburb = ApexPages.currentPage().getParameters().get('Suburb');
        accountDeliveryCountry = 'Australia';

        retUrl = ApexPages.currentPage().getParameters().get('retUrl');
        
        List<Account> existingAccountsEmailBrand = [SELECT Id, Name, PersonContactId FROM Account WHERE PersonEmail = :accountEmail AND Brand__pc = :brand AND RecordTypeId = :b2cConsumerContactAccRecTypeId];
        List<Account> existingAccountsNameMobileBrand = [SELECT Id, Name, PersonContactId FROM Account WHERE PersonMobilePhone = :accountMobile
                                                         AND FirstName = :accountFirstName AND LastName = :accountLastName AND Brand__pc = :brand AND RecordTypeId = :b2cConsumerContactAccRecTypeId];
        Account newAccount = new Account();
        newAccount.FirstName = accountFirstName;
        newAccount.LastName = accountLastName;
        newAccount.Delivery_Country__c = accountDeliveryCountry;
        newAccount.PersonMailingStreet = accountStreet;
        newAccount.PersonMailingCity = accountCity;
        newAccount.PersonMailingState = accountState;
        newAccount.PersonMailingPostalCode = accountPostCode;
        newAccount.PersonMailingCountry = accountDeliveryCountry;
        newAccount.PersonEmail = accountEmail;
        newAccount.Brand__pc = brand;
        newAccount.Country__pc = accountDeliveryCountry;
        newAccount.PersonLeadSource = 'Web';
        newAccount.RecordTypeId = b2cConsumerContactAccRecTypeId;
        newAccount.Record_Status__c = 'Active';
        newAccount.PersonMobilePhone = accountMobile.deleteWhitespace();
        newAccount.Phone = accountPhone.deleteWhitespace();
        
        if (!existingAccountsEmailBrand.isEmpty()) {
            newAccount.Id = existingAccountsEmailBrand[0].Id;
        } else if (!existingAccountsNameMobileBrand.isEmpty()) {
            newAccount.Id = existingAccountsNameMobileBrand[0].Id;
        }

        List<User> connectedAppAdmins = [SELECT Id FROM User WHERE Name = 'Connected App Administrator' LIMIT 1];
        if (!connectedAppAdmins.isEmpty()) {
            newAccount.OwnerId = connectedAppAdmins[0].Id;
        }
        
        try {
            upsert newAccount;
        } catch (Exception err) {
            System.debug(err);
            debug += 'Error #1: ' + err;
            Database.rollback(sp);
            return null;
        }
        
        Set<Id> accIds = new Set<Id>();
        
        newAccount = [SELECT PersonContactId, Id FROM Account WHERE Id = :newAccount.Id];
        
        Product2 existingProduct = [SELECT Id FROM Product2 WHERE ProductCode = :assetModel LIMIT 1];
        Product2 redemptionProduct = [SELECT Id FROM Product2 WHERE ProductCode = :redemptionProductModel LIMIT 1];

        Asset newAsset = new Asset();
        newAsset.Product2Id = redemptionProduct.Id;
        newAsset.AccountId = newAccount.Id;
        newAsset.ContactId = newAccount.PersonContactId;
        newAsset.Name = 'Temporary Name';
        newAsset.Purchased_Online__c = 'In-Store';
        newAsset.AssetSource__c = 'Redemption';
        newAsset.Assest__c = 'Redeemed';
        
        try {
            insert newAsset;
        } catch (Exception err) {
            System.debug(err);
            debug += 'Error #2: ' + err;
            Database.rollback(sp);
            return null;
        }
        
        if (receiptFileBody != '') {
            Receipts__c receipt = [SELECT Id, Receipt_Name__c FROM Receipts__c WHERE Receipt_Name__c = :receiptFileBody];
            receipt.Account__c = newAccount.Id;
            //receipt.ReceiptSource__c = assetStore + ' ' + assetStoreSuburb;
            receipt.ReceiptSource__c = 'Other';
            receipt.Receipt_Name__c = assetReceiptNumber;

            try {
                update receipt;
            } catch (Exception err) {
                System.debug(err);
                debug += 'Error #3: ' + err;
                Database.rollback(sp);
                return null;
            }

            try {
                newAsset.Receipt__c = receipt.Id;
                update newAsset;
            } catch (Exception err) {
                System.debug(err);
                debug += 'Error #3: ' + err;
                Database.rollback(sp);
                return null;
            }
        }

        Case redemptionCase = new Case();
        redemptionCase.RecordTypeId = redemptionCaseRecTypeId;
        redemptionCase.Brand__c = 'Milwaukee';
        redemptionCase.Receipt_No__c = assetReceiptNumber;
        redemptionCase.Store__c = assetStore + ' ' + assetStoreSuburb;
        redemptionCase.ProductId = existingProduct.Id;
        redemptionCase.Redemption_Product__c = redemptionProduct.Id;
        redemptionCase.AccountId = newAccount.Id;
        redemptionCase.ContactId = newAccount.PersonContactId;
        
        try {
            insert redemptionCase;
        } catch (Exception err) {
            System.debug(err);
            debug += 'Error #4: ' + err;
            Database.rollback(sp);
            return null;
        }
        
        List<Marketing_Preference__c> marketingPreferences = [SELECT Id, Newsletter__c, SMS__c, Person_Account__c FROM Marketing_Preference__c WHERE Person_Account__c = :newAccount.Id LIMIT 1];
        Marketing_Preference__c marketingPreference = new Marketing_Preference__c();
        if (mpSubscribe == '0') {
            marketingPreference.Newsletter__c = true;
            marketingPreference.DIY_Inspiration__c = true;
            marketingPreference.New_Product_Updates__c = true;
        }

        if (!marketingPreferences.isEmpty()) {
            marketingPreference.Id = marketingPreferences[0].Id;
        } else {
            marketingPreference.Person_Account__c = newAccount.Id;
        }
        
        try {
            upsert marketingPreference;
        } catch (Exception err) {
            System.debug(err);
            debug += 'Error #5: ' + err;
            Database.rollback(sp);
            return null;
        }
        
        return new PageReference(retUrl);
    }

    private String getCountryLongName(String countryCode) {
        String countryLongName;

        if (countryCode.equalsIgnoreCase('au')) {
            countryLongName = 'Australia';
        } else if (countryCode.equalsIgnoreCase('nz')) {
            countryLongName = 'New Zealand';
        } else {
            countryLongName = '';
        }

        return countryLongName;
    }
}