public class MilwaukeeBatteryController {
    public Account accountToInsert;
    public Asset assetToInsert;
    public Case caseToInsert;

    public List<SelectOption> countryList {get; set;}
    public List<SelectOption> productList {get; set;}

    public Boolean isInserted {get; set;}

    public String firstName {get; set;}
    public String lastName {get; set;}
    public String emailAdd {get; set;}
    public String contactNumber {get; set;}
    public String contactCountry {get; set;}

    public String productName {get; set;}
    public String productQuantity {get; set;}
    public String productDatePurchased {get; set;}
    public String productDescription {get; set;}
    
    public String debug {get; set;}
    public String currentPage {get; set;}

    private static Id b2cConsumerContactAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Consumer Contact').getRecordTypeId();
    private static Id caseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Product Complaint').getRecordTypeId();

    public String standardWarranty;
    public String extendedWarranty;

    public MilwaukeeBatteryController() {
        accountToInsert = new Account();
        assetToInsert = new Asset();
        caseToInsert = new Case();

        countryList = setCountryList();
        productList = setProductList();

        isInserted = false;

        currentPage = ApexPages.currentPage().getUrl(); //used in deleting/viewing/uploading a file, to avoid list has no rows for SObject

        debug = '';
        firstName = '';
        lastName = '';
        emailAdd = '';
        contactNumber = '';
        contactCountry = '';
        productName = '';
        productQuantity = '';
        productDatePurchased = '';
        productDescription = '';

        standardWarranty = Label.MilwaukeeStandard;
        extendedWarranty = Label.MilwaukeeExtended;
    }

    public List<SelectOption> setCountryList() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Australia','Australia'));
        options.add(new SelectOption('New Zealand','New Zealand'));

        return options;
    }

    public List<SelectOption> setProductList() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Milwaukee 9.0Ah High Demand Battery (M18B9)','Milwaukee 9.0Ah High Demand Battery (M18B9)'));

        return options;
    }

    public void doSubmit() {
        Savepoint sp = Database.setSavepoint();
        accountToInsert = new Account();
        assetToInsert = new Asset();
        caseToInsert = new Case();

        List<Account> existingAccountsEmailBrand = [SELECT Id, Name, PersonContactId 
                                                    FROM Account 
                                                    WHERE PersonEmail =: emailAdd 
                                                    AND Brand__pc =: 'Milwaukee' 
                                                    AND RecordTypeId =: b2cConsumerContactAccRecTypeId];

        List<Account> existingAccountsNameMobileBrand = [SELECT Id, Name, PersonContactId 
                                                         FROM Account 
                                                         WHERE PersonMobilePhone =: contactNumber
                                                         AND FirstName =: firstName 
                                                         AND LastName =: lastName 
                                                         AND Brand__pc =: 'Milwaukee' 
                                                         AND RecordTypeId =: b2cConsumerContactAccRecTypeId];

        if (!String.isEmpty(firstName) && !String.isEmpty(lastName) && !String.isEmpty(emailAdd) && !String.isEmpty(contactNumber) && !String.isEmpty(contactCountry)) {
            accountToInsert.Firstname = firstName;
            accountToInsert.Lastname = lastName;
            accountToInsert.PersonEmail = emailAdd;
            accountToInsert.PersonMobilePhone = contactNumber;
            accountToInsert.Country__pc = contactCountry;
            accountToInsert.Brand__pc = 'Milwaukee';
            accountToInsert.RecordTypeId = b2cConsumerContactAccRecTypeId;
        } else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Please provide values for Firname, Lastname, Email and Contact Number.'));
        }

        if (!existingAccountsEmailBrand.isEmpty()) {
            accountToInsert.Id = existingAccountsEmailBrand[0].Id;
        } else if (!existingAccountsNameMobileBrand.isEmpty()) {
            accountToInsert.Id = existingAccountsNameMobileBrand[0].Id;
        }

        List<User> connectedAppAdmins = [SELECT Id FROM User WHERE Name = 'Connected App Administrator' LIMIT 1];
        if (!connectedAppAdmins.isEmpty()) {
            accountToInsert.OwnerId = connectedAppAdmins[0].Id;
        }

        try {
            upsert accountToInsert;
        } catch (Exception err) {
            System.debug('\n\n***Error= '+err+'\n');
            Database.rollback(sp);
            isInserted = false;
        }

        if (accountToInsert.Id != null) {
            accountToInsert = [SELECT Id FROM Account WHERE Id =: accountToInsert.Id];
        }

        if (!String.isEmpty(productName) && productQuantity != null && productDatePurchased != null && !String.isEmpty(productDescription)) {
            assetToInsert.AccountId = accountToInsert.Id;
            assetToInsert.Name = productName;
            assetToInsert.Quantity = Integer.valueOf(productQuantity);
            assetToInsert.PurchaseDate = Date.valueOf(productDatePurchased);
            assetToInsert.Description = productDescription;
            assetToInsert.Standard_Warranty_Months__c = Integer.valueOf(standardWarranty);
            assetToInsert.Extended_Warranty_Months__c = Integer.valueOf(extendedWarranty);
        } else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Please create an Asset for this Account.'));
        }

        try {
            insert assetToInsert;
            //assetList = [SELECT AccountId, Quantity, PurchaseDate, Description, Name From Asset WHERE AccountId =: accountToInsert.Id ORDER BY CreatedDate ASC];
        } catch (Exception err) {
            System.debug('\n\n***Error= '+err+'\n');
            Database.rollback(sp);
            isInserted = false;
        }

        if (assetToInsert.Id != null) {
            assetToInsert = [SELECT Id FROM Asset WHERE Id =: assetToInsert.Id];
        }

        QueuesObject queueId = [SELECT QueueId, Queue.DeveloperName, Queue.Name FROM QueuesObject WHERE SObjectType = 'Case' AND Queue.Name = 'Customer Service'];

        if (accountToInsert.Id != null && assetToInsert.Id != null && queueId.QueueId != null) {
            caseToInsert.AccountId = accountToInsert.Id;
            caseToInsert.AssetId = assetToInsert.Id;
            caseToInsert.Subject = 'M18B9 Battery Refresh Program';
            caseToInsert.Origin = 'M18B9 Refresh';
            caseToInsert.OwnerId = queueId.QueueId;
            caseToInsert.RecordTypeId = caseRecTypeId;
        }

        try {
            insert caseToInsert;
            isInserted = true;
        } catch (Exception err) {
            System.debug('\n\n***Error= '+err+'\n');
            Database.rollback(sp);
            isInserted = false;
        }

        firstName = '';
        lastName = '';
        emailAdd = '';
        contactNumber = '';
        contactCountry = '';
        productName = '';
        productQuantity = '';
        productDatePurchased = '';
        productDescription = '';
    }
}