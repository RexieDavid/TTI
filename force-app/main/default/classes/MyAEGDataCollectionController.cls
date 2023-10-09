public class MyAEGDataCollectionController {
    public Account personAccount { get; set; }
    public Marketing_Campaign__c marketingCampaign { get; set; }

    public String firstName { get; set; }
    public String lastName { get; set; }
    public String email { get; set; }
    public String mobilePhone { get; set; }
    public String postal { get; set; }
    public String trade { get; set; }
    public String apprentice { get; set; }

    private static Id b2cConsumerContactAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Consumer Contact').getRecordTypeId();
    private static Id melbourneGardenShow2018CampaignRecTypeId = Schema.SObjectType.Marketing_Campaign__c.getRecordTypeInfosByName().get('NZ Field Day 2018').getRecordTypeId();

    public MyAEGDataCollectionController() {
        personAccount = new Account();
        marketingCampaign = new Marketing_Campaign__c();
        trade = '';
    }

    public List<SelectOption> getSelectOptionsTrade(String objectKey, String fieldKey) {
        List<SelectOption> options = new List<SelectOption>();

        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(objectKey).getDescribe().fields.getMap().get(fieldKey).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry f : ple) {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }

        return options;
    }

    public List<SelectOption> getTradeSelectOptions() {
        return getSelectOptionsTrade('Marketing_Campaign__c', 'Trade__c');
    }

    public List<SelectOption> getSelectOptionsApp(String objectKey, String fieldKey) {
        List<SelectOption> options = new List<SelectOption>();

        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(objectKey).getDescribe().fields.getMap().get(fieldKey).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry f : ple) {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }

        return options;
    }

    public List<SelectOption> getAppSelectOptions() {
        return getSelectOptionsApp('Marketing_Campaign__c', 'Apprentice__c');
    }

    public PageReference submitForm() {
        PageReference pr = Page.MyAEGDataCollection;

        Savepoint sp = Database.setSavepoint();

        List<Account> existingAccounts = [SELECT Id, Name FROM Account WHERE PersonEmail = :email AND Brand__pc = 'AEG' AND RecordTypeId = :b2cConsumerContactAccRecTypeId];

        personAccount.RecordTypeId = b2cConsumerContactAccRecTypeId;
        personAccount.Brand__pc = 'AEG';
        personAccount.FirstName = firstName;
        personAccount.LastName = lastName;
        personAccount.PersonEmail = email;
        personAccount.PersonMobilePhone = mobilePhone;
        personAccount.PersonMailingPostalCode = postal;
        personAccount.Is_survey_completed__c = true;
        personAccount.Country__pc = 'New Zealand';
        pr.setRedirect(true);

        List<User> connectedAppAdmins = [SELECT Id FROM User WHERE Name = 'Connected App Administrator' LIMIT 1];
        if (!connectedAppAdmins.isEmpty()) {
            personAccount.OwnerId = connectedAppAdmins[0].Id;
        }
        
        if (!existingAccounts.isEmpty()) {
            personAccount.Id = existingAccounts[0].Id;
        }
        
        try {
            insert personAccount;
        } catch (Exception err) {
            Database.rollback(sp);
            pr.getParameters().put('error', err + '');
            System.debug('@@@' + err);
            return pr;
        }

        marketingCampaign.RecordTypeId = melbourneGardenShow2018CampaignRecTypeId;
        marketingCampaign.Person_Account__c = personAccount.Id;
        marketingCampaign.Trade__c = trade;
        marketingCampaign.Apprentice__c = apprentice;

        try {
            insert marketingCampaign;
            pr.getParameters().put('success', '1');
            
        } catch (Exception err) {
            Database.rollback(sp);
            pr.getParameters().put('error', err + '');
            System.debug('@@@' + err);
            return pr;
        }

        return pr;
    }
}