@isTest
private class MarketingPreferenceSiteControllerTest {

    private static Id commercialAccountRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Commercial').getRecordTypeId();
    private static Id industrialRetailPreferenceRecTypeId = Schema.SObjectType.Marketing_Preference__c.getRecordTypeInfosByName().get('Industrial Retail Preferences').getRecordTypeId();
    private static Id b2cRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Consumer Contact').getRecordTypeId();
    private static final Map<String, String> prefNamesMap = new Map<String, String>{
        'MarketResearch' => 'ML', 
        'ToolTesting' => 'ML',
        'Research' => 'RY'
    };
    
    @testSetup 
    static void testData() {
        List<PreferenceTopic__c> nPrefTopicsList = new List<PreferenceTopic__c>();
        List<Preference__c> nPrefsList = new List<Preference__c>();
        List<Account> nAccountsList = new List<Account>();
        Account testAcc = new Account(RecordTypeId = b2cRecTypeId,
                                      PersonEmail = 'test@ryobi.com.au',
                                      Brand__pc = 'Ryobi',
                                      LastName = 'Test',
                                      FirstName = 'Tester'); 
        nAccountsList.add(testAcc);

        Account testAcc2 = new Account(RecordTypeId = b2cRecTypeId,
                                      PersonEmail = 'test@aegpowertools.com.au',
                                      Brand__pc = 'AEG',
                                      LastName = 'Test2',
                                      FirstName = 'Tester2');
                                      
        nAccountsList.add(testAcc2);

        Account testAcc3 = new Account(RecordTypeId = b2cRecTypeId,
                                      PersonEmail = 'venus.rolle@bbc.com',
                                      Brand__pc = 'Milwaukee',
                                      LastName = 'Rolle',
                                      FirstName = 'Venus',
                                      PersonMobilePhone = '0212345678');
                                      
        nAccountsList.add(testAcc3);

        Account testAcc4 = new Account(RecordTypeId = b2cRecTypeId,
                                      PersonEmail = 'test4@aegpowertools.com.au',
                                      Brand__pc = 'AEG',
                                      LastName = 'Test4',
                                      FirstName = 'Tester4');
                                      
        nAccountsList.add(testAcc4);

        Account testAcc5 = new Account(RecordTypeId = b2cRecTypeId,
                                      PersonEmail = 'test5@vax.com.au',
                                      Brand__pc = 'VAX',
                                      LastName = 'Test5',
                                      FirstName = 'Tester5');
                                      
        nAccountsList.add(testAcc5);
        insert nAccountsList;
        
        Marketing_Preference__c testMP = new Marketing_Preference__c(Person_Account__c = testAcc.Id);
        insert testMP;

        Marketing_Preference__c testMP2 = new Marketing_Preference__c(Person_Account__c = testAcc2.Id);
        insert testMP2;

        Marketing_Preference__c testMP3 = new Marketing_Preference__c(Person_Account__c  = testAcc3.Id, RecordTypeId = industrialRetailPreferenceRecTypeId);
        testMP3.General_Communication__c = true;
        testMP3.Monthly_Communication__c = true;
        testMP3.Image_Relay__c = true;
        testMP3.Press_Release__c = true;
        testMP3.Product_Launch_2_WEEK__c = true;
        testMP3.Product_Launch_4_WEEK__c = true;
        insert testMP3;

        Marketing_Preference__c testMP4 = new Marketing_Preference__c(Person_Account__c = testAcc4.Id);
        testMP4.Newsletter__c = false;
        testMP4.New_Product_Updates__c = false;
        testMP4.DIY_Inspiration__c = false;
        insert testMP4;

        Marketing_Preference__c testMP5 = new Marketing_Preference__c(Person_Account__c = testAcc5.Id);
        testMP5.Feedback__c = true;
        testMP5.Product_Updates__c = true;
        testMP5.Promotion_Updates__c = true;
        testMP5.Maintenance__c = true;
        insert testMP5;

        for (String name : prefNamesMap.keySet()) {
            nPrefTopicsList.add(createPreferenceTopic(name));
        }

        insert nPrefTopicsList;

        Integer ctr = 0;
        for (String prefName : prefNamesMap.keySet()) {
            nPrefsList.add(createPreference(prefName, nPrefTopicsList[ctr].Id, prefNamesMap.get(prefName)));
            ctr++;
        }

        insert nPrefsList;
    }
    
    private static testMethod void testMethod1() {
        PageReference pageRef = Page.MarketingPreferenceSite;
        Test.setCurrentPage(pageRef);
        Account acc = [SELECT Id, PersonContactId FROM Account WHERE LastName = 'Test'];
        ApexPages.currentPage().getParameters().put('Email', 'test@ryobi.com.au');
        ApexPages.currentPage().getParameters().put('Brand', 'Ryobi');
        ApexPages.currentPage().getParameters().put('Id', acc.PersonContactId);
        MarketingPreferenceSiteController controller = new MarketingPreferenceSiteController();
        controller.save();
        controller.cancel();    
    }

    private static testMethod void testMethod2() {
        PageReference pageRef = Page.MarketingPreferenceSite;
        Test.setCurrentPage(pageRef);
        Account acc = [SELECT Id, PersonContactId FROM Account WHERE LastName = 'Test2'];
        ApexPages.currentPage().getParameters().put('Email', 'test@aegpowertools.com.au');
        ApexPages.currentPage().getParameters().put('Brand', 'AEG');
        ApexPages.currentPage().getParameters().put('Id', acc.PersonContactId);
        MarketingPreferenceSiteController controller = new MarketingPreferenceSiteController();

        controller.save();
        controller.cancel(); 
        Test.setCurrentPage(pageRef);
    }
    
    private static testMethod void testMethod3() {
        PageReference pageRef = Page.MarketingPreferenceSite;
        Test.setCurrentPage(pageRef);
        //Contact cont = [SELECT Id FROM Contact WHERE LastName = 'Rolle'];
        Account acc = [SELECT Id, PersonContactId FROM Account WHERE LastName = 'Rolle'];
        ApexPages.currentPage().getParameters().put('Email', 'venus.rolle@bbc.com');
        ApexPages.currentPage().getParameters().put('Brand', 'Milwaukee');
        ApexPages.currentPage().getParameters().put('Id', acc.PersonContactId);
        MarketingPreferenceSiteController controller = new MarketingPreferenceSiteController();

        controller.save();
        controller.cancel(); 
        Test.setCurrentPage(pageRef);
    }

    private static testMethod void testMethod4() {
        PageReference pageRef = Page.MarketingPreferenceSite;
        Test.setCurrentPage(pageRef);
        Account acc = [SELECT Id, PersonContactId FROM Account WHERE LastName = 'Test4'];
        ApexPages.currentPage().getParameters().put('Email', 'test4@aegpowertools.com.au');
        ApexPages.currentPage().getParameters().put('Brand', 'AEG');
        ApexPages.currentPage().getParameters().put('Id', acc.PersonContactId);
        MarketingPreferenceSiteController controller = new MarketingPreferenceSiteController();

        controller.save();
        controller.cancel(); 
        Test.setCurrentPage(pageRef);
    }

    private static testMethod void testMethod5() {
        PageReference pageRef = Page.MarketingPreferenceSite;
        Test.setCurrentPage(pageRef);
        Account acc = [SELECT Id, PersonContactId FROM Account WHERE LastName = 'Test5'];
        ApexPages.currentPage().getParameters().put('Email', 'test5@vax.com.au');
        ApexPages.currentPage().getParameters().put('Brand', 'VAX');
        ApexPages.currentPage().getParameters().put('Id', acc.PersonContactId);
        MarketingPreferenceSiteController controller = new MarketingPreferenceSiteController();

        controller.save();
        Test.setCurrentPage(pageRef);
    }
    
    private static testMethod void testMethod6() {
        PageReference pageRef = Page.MarketingPreferenceSite;
        Test.setCurrentPage(pageRef);
        Account acc = [SELECT Id, PersonContactId FROM Account WHERE LastName = 'Test'];
        Preference__c pref = [SELECT Id, Name FROM Preference__c WHERE Name = 'Research'];
        PersonAccountPreference__c ryPref = createPersonAccountPreference(acc.Id, pref.Id);
        insert ryPref;
        
        ApexPages.currentPage().getParameters().put('Email', 'test@ryobi.com.au');
        ApexPages.currentPage().getParameters().put('Brand', 'Ryobi');
        ApexPages.currentPage().getParameters().put('Id', acc.PersonContactId);
        MarketingPreferenceSiteController controller = new MarketingPreferenceSiteController();
        controller.save();
        controller.cancel();    
    }
    
    private static testMethod void testMethod7() {
        PageReference pageRef = Page.MarketingPreferenceSite;
        Test.setCurrentPage(pageRef);
        Account acc = [SELECT Id, PersonContactId FROM Account WHERE LastName = 'Rolle'];
        Preference__c pref = [SELECT Id, Name FROM Preference__c WHERE Name = 'MarketResearch'];
        PersonAccountPreference__c accPref = createPersonAccountPreference(acc.Id, pref.Id);
        insert accPref;
        
        ApexPages.currentPage().getParameters().put('Email', 'venus.rolle@bbc.com');
        ApexPages.currentPage().getParameters().put('Brand', 'Milwaukee');
        ApexPages.currentPage().getParameters().put('Id', acc.PersonContactId);
        ApexPages.currentPage().getParameters().put('Mobile', '0212345678');
        MarketingPreferenceSiteController controller = new MarketingPreferenceSiteController();
        controller.save();
        controller.cancel();    
    }

    /**********************************************************************
     * @description                 Create new preferences
     * @param  counter              Suffix of the preference name
     * @param  preferenceTopicId    Parent topic of preference
     * @return                      Preference raw record
     */
    private static Preference__c createPreference(String name, String preferenceTopicId, String brand) {
        Preference__c newPreference = new Preference__c();
        newPreference.Name = name;
        newPreference.PreferenceTopic__c = preferenceTopicId;
        newPreference.Brand__c = brand;
        newPreference.CountryCode__c = 'AU';
        return newPreference;
    }

    /**********************************************************************
     * @description             Create new preference topic
     * @param  counter          Suffix of preference topic name
     * @return                  Preference topic raw record
     */
    private static PreferenceTopic__c createPreferenceTopic(String name) {
        PreferenceTopic__c newPrefTopic = new PreferenceTopic__c();
        newPrefTopic.Name = name == 'Research' ? 'Communication Subscriptions' : name;
        newPrefTopic.Description__c = 'Preference Topic Description - ' + name;
        return newPrefTopic;
    }
    
    /**********************************************************************
     * @description             Create new person account preference
     * @param  accountId        Parent account of person account preference
     * @param  preferenceId     Parent preference of person account preference
     * @return                  Preference topic raw record
     */
    private static PersonAccountPreference__c createPersonAccountPreference(Id accountId, Id preferenceId) {
        PersonAccountPreference__c newPAPref = new PersonAccountPreference__c();
        newPAPref.PreferenceId__c = preferenceId;
        newPAPref.PersonAccountId__c = accountId;
        return newPAPref;
    }

}