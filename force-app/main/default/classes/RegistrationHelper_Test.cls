@isTest
private class RegistrationHelper_Test {
    
    private static final String ACCOUNT_PROFESSION = 'Appliance Technician';
    private static final String AEG_BRAND = 'AEG';
    private static final String ERR_DID_NOT_UPDATE_ACCOUNT = 'Did not update account record';
    private static final String USERNAME = '1t4e7s8t3@yahoo.com.Aeg';

    /**********************************************************************
     * @description     Initialize data before running test
     */
    @TestSetup
    static void initData() {
        //Community Custom Settings
        Community_Settings__c cs = new Community_Settings__c();
        cs.Name = 'CommonSettings';
        cs.Default_Account_OwnerId__c = UserInfo.getUserId();
        insert cs;

        Account newPersonAccount = TestUtilityClass.createPersonAccount(1)[0];
        newPersonAccount.Brands__c = AEG_BRAND;
        insert newPersonAccount;

        Contact eContact = [SELECT Id, Brand__c FROM Contact WHERE AccountId IN (SELECT Id FROM Account WHERE IsPersonAccount = TRUE)];
        eContact.Email = 'test@mailinator.com';
        eContact.Country__c = 'Australia';
        eContact.Brand__c = AEG_BRAND;
        update eContact;

        System.runAs(new User(Id = UserInfo.getUserId())) {
            Profile aegCommunityProfile = [Select Id from Profile where Name = '~Customer Community AEG' Limit 1];
            User portalUser = new User(
                ProfileId = aegCommunityProfile.Id,
                Username = USERNAME,
                Alias = 'batman',
                Email = 'test@yahoo.com',
                EmailEncodingKey = 'UTF-8',
                Firstname = 'Bruce',
                Lastname = 'Wayne',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago',
                ContactId = eContact.Id,
                Country = 'Australia'
            );
            insert portalUser;
        }
    }

    /**********************************************************************
     * @description     Update person account with the provided information
     *                  
     *                  Given that the user is a community user and have 
     *                  person account related to it.
     * 
     *                  Note: This will execute in @future state and better 
     *                  to have assertion after Test.stopTest();
     */
    @isTest
    private static void updatePersonAccountTest() {
        Contact eContact = [SELECT Id, AccountId FROM Contact WHERE AccountId IN (SELECT Id FROM Account WHERE IsPersonAccount = TRUE)];
        User eUser = [SELECT Id FROM User WHERE ContactId = :eContact.Id];
        Test.startTest();
            System.runAs(eUser) {
                RegistrationHelper.updatePersonAccount(eUser.Id, 
                                                        '1234 Test St.', 
                                                        'Test City', 
                                                        'Kansas',
                                                        'Australia', 
                                                        '1234', 
                                                        AEG_BRAND, 
                                                        '',
                                                        null, 
                                                        'Retailer', 
                                                        ACCOUNT_PROFESSION, 
                                                        '10', 
                                                        false,
                                                        'Mr.');
            }
        Test.stopTest();
        Account eAccount = [SELECT Id, Profession__c, Salutation FROM Account WHERE Id = :eContact.AccountId];
        System.assertEquals(eAccount.Profession__c, ACCOUNT_PROFESSION, ERR_DID_NOT_UPDATE_ACCOUNT);
        System.assertEquals(eAccount.Salutation, 'Mr.', ERR_DID_NOT_UPDATE_ACCOUNT);

    }

    /**********************************************************************
     * @description     Update person account with the provided information.
     *                  Difference in the method above is it will update also
     *                  firstname and lastname of the person account.
     *                  
     *                  Given that the user is a community user and have 
     *                  person account related to it.
     * 
     *                  Note: This will execute in @future state and better 
     *                  to have assertion after Test.stopTest();
     */
    @isTest
    private static void updatePersonAccountWithNames() {
        Contact eContact = [SELECT Id, AccountId FROM Contact WHERE AccountId IN (SELECT Id FROM Account WHERE IsPersonAccount = TRUE)];
        User eUser = [SELECT Id FROM User WHERE ContactId = :eContact.Id];
        Test.startTest();
            System.runAs(eUser) {
                RegistrationHelper.updatePersonAccount(eUser.Id, 
                                                        '1234 Test St.',
                                                        'Test City', 
                                                        'Kansas', 
                                                        'Australia', 
                                                        '1234', 
                                                        'New', 
                                                        'Name', 
                                                        '+61223112231',
                                                        '+61223112231', 
                                                        '1t4e7s8t3@yahoo.com', 
                                                        'Retailer', 
                                                        '100', 
                                                        '', 
                                                        ACCOUNT_PROFESSION);
            }
        Test.stopTest();
        Account eAccount = [SELECT Id, Profession__c FROM Account WHERE Id = :eContact.AccountId];
        System.assertEquals(eAccount.Profession__c, ACCOUNT_PROFESSION, ERR_DID_NOT_UPDATE_ACCOUNT);

    }
}