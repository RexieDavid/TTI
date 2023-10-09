@IsTest
private class RYLoginSurveyModalControllerTest {
    private static final String ERR_GENERIC_MESSAGE = 'An error was encountered, Please contact your administrator';
    private static final String ERR_MESSAGE_RETURN_NONE = 'List has no rows for assignment to SObject';
    private static final String RY_BRAND = 'Ryobi';
    private static final String PORTAL_USER_NAME = '1t4e7s8t3@yahoo.com.ryobi';
    private static final String USER_NO_ACCESS_NAME = '2t4e7s8t3@yahoo.com.ryobi';

    @TestSetup
    static void makeData() {
        List<User> userList = new List<User>();
        Profile profileWithoutAccess = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        Profile ryCommunityProfile = [SELECT Id FROM Profile WHERE Name = '~Customer Community Ryobi' LIMIT 1];

        List<Account> newPersonAccount = RyTestDataFactory.buildPersonAccountList(2);
        insert newPersonAccount;

        List<Account> bussinessAccount = RyTestDataFactory.buildBussinessAccount(2);
        insert bussinessAccount;

        Contact eContact = [SELECT Id, Brand__c FROM Contact WHERE AccountId = :newPersonAccount[0].Id];
        eContact.Brand__c = RY_BRAND;
        update eContact;

        for (Integer counter = 0; counter < 2; counter ++) {
            Boolean separator = counter == 0;
            User newUser = RyTestDataFactory.buildUser(separator ? ryCommunityProfile.Id : profileWithoutAccess.Id, 
                                                       separator ? eContact.Id : null,
                                                       separator ? PORTAL_USER_NAME : USER_NO_ACCESS_NAME);
            userList.add(newUser);
        }   
        insert userList;
    }


    /**********************************************************************
     * @description             Perform Postivie Test WHERE user return a Account record
     */
    @isTest
    private static void getAccountPositiveTest() {
        Account accRetrieved = new Account();
        Account acc = [SELECT Id FROM Account WHERE FirstName = 'test0'];
        User ryUser = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE Username = :PORTAL_USER_NAME];
        Test.startTest();
            System.runAs(ryUser) {
                accRetrieved = RYLoginSurveyModalController.getAccount(new List<String>{'Id'});
            }
        Test.stopTest();
        System.assertEquals(accRetrieved.Id, acc.Id, 'User returned no Account');
    }

    /**********************************************************************
     * @description             Perform Negative Test WHERE user has no Account returned
     */
    @isTest
    private static void getAccountNegativeTest() {
        String errorMessage;
        Account accRetrieved = new Account();
        User ryUser = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE Username = :USER_NO_ACCESS_NAME];
        Test.startTest();
            System.runAs(ryUser) {
                try {
                    accRetrieved = RYLoginSurveyModalController.getAccount(new List<String>{'Id'});
                } catch (Exception ex) {
                    errorMessage = ex.getMessage();
                }
            }
        Test.stopTest();
        System.assertEquals(ERR_MESSAGE_RETURN_NONE, errorMessage, 'User returned Account');
    }


    /*****************************************************************************
     * @description             Handle positive scenario in updating account record
     */
    @isTest
    private static void updateDetailsTestPositive() {
        User ryUser = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE Username = :PORTAL_USER_NAME];
        Account acc = [SELECT Is_survey_completed__c, LastName FROM Account WHERE FirstName = 'test0'];
        Account newAccount = new Account();
        System.runAs(ryUser) {
            acc.Is_survey_completed__c = true;
            Test.startTest();
                newAccount = RYLoginSurveyModalController.updateAccount(acc);
            Test.stopTest();
        }
        System.assertEquals(true, newAccount.Is_survey_completed__c, 'Account has not been updated!');
    }

    /*****************************************************************************
     * @description             Handle negative scenario in updating account record
     */
    @isTest
    private static void updateDetailTestNegative() {
        String errorMessage;
        User ryUser = [SELECT Id FROM User WHERE Username = :PORTAL_USER_NAME];
        Account acc = [SELECT Id, FirstName, Is_survey_completed__c, LastName FROM Account WHERE FirstName = 'test0'];
        Account newAccount = new Account();
        System.runAs(ryUser) {
            acc.Is_survey_completed__c = null;
            Test.startTest();
                try {
                newAccount = RYLoginSurveyModalController.updateAccount(acc);
                } catch (Exception ex) {
                    errorMessage = ex.getMessage();
                }
            Test.stopTest();
        }
        System.assertEquals(errorMessage, ERR_GENERIC_MESSAGE, 'Successfully update user record');
    }

    /**********************************************************************
     * @description             Fetch Is_survey_completed__c value
     */
    @isTest
    private static void getSurveyDetailsTest() {
        User ryUser = [SELECT Id, Account.Is_survey_completed__c FROM User WHERE Username = :PORTAL_USER_NAME];
        User getUser = new User();
        System.runAs(ryUser) {
            Test.startTest();
                getUser = RYLoginSurveyModalController.getSurveyDetails(ryUser.Id);
            Test.stopTest();
        }
        System.assertEquals(getUser.Account.Is_survey_completed__c, ryUser.Account.Is_survey_completed__c, 'No account record found');
    }

    /**********************************************************************
     * @description             Fetch bunning account records
     */
    @isTest
    private static void getBunningStoreAccountTest() {
        List<Account> acct = new List<Account>();
        User ryUser = [SELECT Id FROM User WHERE Username = :PORTAL_USER_NAME];
        Test.startTest();
           System.runAs(ryUser) {
                acct = RYLoginSurveyModalController.getRyobiAccounts('AU');
           }
        Test.stopTest();
        System.assert(!acct.isEmpty(), 'User returned no Account');
        System.assertEquals(acct[0].Name , 'Bunnings', 'No Bunnings account found');
    }
}