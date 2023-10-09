@isTest
private class DMCPreferencesControllerTest {
    
    private static Id commercialAccountRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Commercial').getRecordTypeId();
    private static final PageReference DMC_PAGE = Page.DirectMarketingContactPreferences;

    private static final String CREATE_DMC_RECORD_ERR = 'Failed to create direct marketing contacts';
    private static final String SAVE_ERR_MESSAGE = 'Failed to commit records to database';
    private static final String CANCEL_ERR_MESSAGE = 'Failed to cancel transaction';

    /**********************************************************************
     * @description                 Setup test data
     */
    @TestSetup
    static void makeData() {
        // Make test data records
        List<Contact> newContacts = new List<Contact>();
        Account account = createAccount();
        insert account;

        for (Integer ctr = 0; ctr < 10; ctr++) {
            Contact contact = createContact(ctr, account.Id);
            newContacts.add(contact);
        }
        insert newContacts;
    }

    /**********************************************************************
     * @description                 Initialize controller without direct
     *                              marketing contact.
     * 
     *                              It will create direct marketing contact
     *                              record for each active contact related to 
     *                              the account
     */
    @isTest
    static void pageLoadWithoutDMCRecordsTest() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        List<Contact> contacts = [SELECT Id FROM Contact WHERE AccountId = :account.Id LIMIT 10];
        Test.startTest();
            DMCPreferencesController controller = navigateToDMCVFPage(account);
        Test.stopTest();
        System.assertEquals(controller.directMarketingContacts.size(), contacts.size(), CREATE_DMC_RECORD_ERR);
    }

    /**********************************************************************
     * @description                 Initialize controller with direct
     *                              marketing contact.
     */
    @isTest
    static void pageLoadWithDMCRecordsTest() {
        List<Direct_Marketing_Contact__c> directMarketingContacts = new List<Direct_Marketing_Contact__c>();
        Account account = [SELECT Id FROM Account LIMIT 1];
        List<Contact> contacts = [SELECT Id, AccountId FROM Contact LIMIT 10];
        for (Contact cont : contacts) {
            Direct_Marketing_Contact__c directMarketingContact = createDirectMarketingContact(cont);
            directMarketingContacts.add(directMarketingContact);
        }
        insert directMarketingContacts;
        Test.startTest();
            DMCPreferencesController controller = navigateToDMCVFPage(account);
        Test.stopTest();
        System.assertEquals(controller.directMarketingContacts.size(), contacts.size(), CREATE_DMC_RECORD_ERR);
    }

    /**********************************************************************
     * @description                 Save selected direct marketing contact
     *                              records with its related marketing 
     *                              preference
     */
    @isTest
    static void saveSelectedContactsTest() {
        PageReference res;
        Account account = [SELECT Id FROM Account LIMIT 1];
        DMCPreferencesController controller = navigateToDMCVFPage(account);
        for (DMCPreferencesController.DirectMarketingContactWrapper dmcWrapper : controller.directMarketingContacts) {
            dmcWrapper.isSelected = true;
            dmcWrapper.marketingPreferences[0].General_Communication__c = true;
            dmcWrapper.marketingPreferences[0].Press_Release__c = true;
        }

        Test.startTest();
            res =  controller.save();
        Test.stopTest();

        List<Direct_Marketing_Contact__c> directMarketingContacts = [SELECT Id FROM Direct_Marketing_Contact__c];
        List<Marketing_Preference__c> marketingPreferences = [SELECT Id FROM Marketing_Preference__c];
        System.assertEquals(res.getUrl(), '/' + account.Id, SAVE_ERR_MESSAGE);
        System.assertEquals(directMarketingContacts.size(), 10, SAVE_ERR_MESSAGE);
        System.assertEquals(marketingPreferences.size(), 10, SAVE_ERR_MESSAGE);
    }

    /**********************************************************************
     * @description                 Save unselected direct marketing contact
     *                              records with its related marketing 
     *                              preference
     * 
     *                              It will delete direct marketing records for
     *                              unselected items but will still update the 
     *                              marketing preferences
     */
    @isTest
    static void saveUnSelectedContactsTest() {
        PageReference res;
        Integer counter = 0;
        Account account = [SELECT Id FROM Account LIMIT 1];
        DMCPreferencesController controller = navigateToDMCVFPage(account);
        for (DMCPreferencesController.DirectMarketingContactWrapper dmcWrapper : controller.directMarketingContacts) {
            dmcWrapper.isSelected = true;
            dmcWrapper.marketingPreferences[0].General_Communication__c = true;
            dmcWrapper.marketingPreferences[0].Press_Release__c = true;
        }
        controller.save();
        
        for (DMCPreferencesController.DirectMarketingContactWrapper dmcWrapper : controller.directMarketingContacts) {
            if (counter < 5) {
                dmcWrapper.isSelected = false;
                dmcWrapper.marketingPreferences[0].General_Communication__c = false;
                counter++;
            }
        }

        Test.startTest();
            res = controller.save();
        Test.stopTest();

        List<Direct_Marketing_Contact__c> directMarketingContacts = [SELECT Id FROM Direct_Marketing_Contact__c];
        List<Marketing_Preference__c> marketingPreferences = [SELECT Id FROM Marketing_Preference__c WHERE General_Communication__c = TRUE];
        System.assertEquals(res.getUrl(), '/' + account.Id, SAVE_ERR_MESSAGE);
        System.assertEquals(directMarketingContacts.size(), 5, SAVE_ERR_MESSAGE);
        System.assertEquals(marketingPreferences.size(), 5, SAVE_ERR_MESSAGE);
    }

    /**********************************************************************
     * @description                 Cancel button to navigate back to 
     *                              account record
     */
    @isTest
    static void cancelButtonTest() {
        PageReference res;
        Account account = [SELECT Id FROM Account LIMIT 1];
        DMCPreferencesController controller = navigateToDMCVFPage(account);
        Test.startTest();
            res = controller.cancel();
        Test.stopTest();
        System.assertEquals(res.getUrl(), '/' + account.Id, CANCEL_ERR_MESSAGE);
    }

    /**********************************************************************
     * @description                 Create dummy account record
     * 
     * @example
     * createAccount();
     */
    private static Account createAccount() {
        Account account = new Account();
        account.Name = 'Destination XYZ';
        account.TTI_SAP_Cust_No__c = '02231994';
        account.RecordTypeId = commercialAccountRecId;
        account.BCI_ProjectID__c = 'Potakte';
        return account;
    }

    /**********************************************************************
     * @description                 Create dummy contact record
     * 
     * @param uniqueIdentifier      Unique identifier of records
     * @param accountId             Parent Account Id
     * 
     * @example
     * createContact('1', '001......');
     */
    private static Contact createContact(Integer uniqueIdentifier, String accountId) {
        Contact contact = new Contact();
        contact.AccountId = accountId;
        contact.FirstName = 'Venus' + uniqueIdentifier;
        contact.LastName = 'Rolle' + uniqueIdentifier;
        contact.Email = 'venus.rolle@bbc.com' + uniqueIdentifier;
        contact.HomePhone = '05123412' + uniqueIdentifier;
        contact.MobilePhone = '05123123' + uniqueIdentifier;
        contact.Phone = '05141241' + uniqueIdentifier;
        contact.OtherPhone = '05142141' + uniqueIdentifier;
        contact.MailingCountry = 'NZ';
        contact.Record_Status__c = 'Active';
        return contact;
    }

    /**********************************************************************
     * @description                 Create dummy direct marketing contact record
     * 
     * @param cont                  Parent contact record
     * 
     * @example
     * createDirectMarketingContact(new Contact(Id = '003.....'));
     */
    private static Direct_Marketing_Contact__c createDirectMarketingContact(Contact cont) {
        Direct_Marketing_Contact__c directMarketingContact = new Direct_Marketing_Contact__c();
        directMarketingContact.Account__c = cont.AccountId;
        directMarketingContact.Contact__c = cont.Id;
        return directMarketingContact;
    }

    /**********************************************************************
     * @description                 Setup VF page dependencies
     *                               - Setting of current page
     *                               - Instantiate controller
     * 
     * @param account               Account record to process
     * 
     * @example
     * navigateToDMCVFPage(new Account(Id = '001.....'));
     */
    private static DMCPreferencesController navigateToDMCVFPage(Account account) {
        // Setup VF page dependencies
        Test.setCurrentPage(DMC_PAGE);
        ApexPages.StandardController sc = new ApexPages.StandardController(account);
        return new DMCPreferencesController(sc);
    }
}