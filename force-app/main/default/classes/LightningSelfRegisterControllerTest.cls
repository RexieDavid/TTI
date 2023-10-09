@isTest(seeAllData = true)
public with sharing class LightningSelfRegisterControllerTest {


    static testMethod void testLightningSelfRegister() {
        LightningSelfRegisterController.isValidPassword('ttibrands123', 'ttibrands123');
    }

    static testMethod void testLightningSelfRegister1(){
        String networkId = Network.getNetworkId();
        LightningSelfRegisterController.siteAsContainerEnabled(networkId);
    }

    static testMethod void testLightningSelfRegister2(){
        UserRole portalRole = [SELECT Id FROM UserRole WHERE PortalType = 'None' LIMIT 1];
        Profile profId = [SELECT Id FROM PROFILE WHERE Name = 'System Administrator' LIMIT 1];

        User user1 = new User(UserRoleId = portalRole.Id,
                                ProfileId = profId.Id,
                                Username = System.now().millisecond() + 'test23@test.com',
                                Alias = 'batman',
                                Email='bruce.wayne@ttibrands.com',
                                EmailEncodingKey='UTF-8',
                                Firstname='Bruce',
                                Lastname='Wayne',
                                LanguageLocaleKey='en_US',
                                LocaleSidKey='en_US',
                                TimeZoneSidKey='America/Chicago');
        insert user1;

        System.runAs (user1) {
            Id b2cPersonAccountRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Consumer Contact').getRecordTypeId();

            Account portalAccount1 = new Account(FirstName = 'Hayley', LastName = 'Williams', PersonEmail = 'hayley.williams@fueledbyramen.com', PersonMobilePhone = '09176578945', Brand__pc = 'Ryobi', RecordTypeId = b2cPersonAccountRecId, PersonMailingPostalCode = '4024', PersonMailingCountry = 'New Zealand');
            insert portalAccount1;

            Contact contact1 = new Contact(Id=[SELECT PersonContactId FROM Account WHERE Id = :portalAccount1.Id LIMIT 1].PersonContactId);

            Profile portalProfile = [SELECT Id FROM Profile WHERE Name = '~Customer Community Ryobi NZ' LIMIT 1];

            User user2 = new User(Username = System.now().millisecond() + 'test12345@test.com',
                                    ContactId = contact1.Id,
                                    ProfileId = portalProfile.Id,
                                    Title = 'Ms.',
                                    Alias = 'test123',
                                    Country = 'Australia',
                                    PostalCode = '4024',
                                    MobilePhone = '09176578945',
                                    Email = 'hayley.williams@fueledbyramen.com',
                                    EmailEncodingKey = 'UTF-8',
                                    FirstName = 'Hayley',
                                    LastName = 'Williams',
                                    CommunityNickname = 'test12345',
                                    TimeZoneSidKey = 'America/Los_Angeles',
                                    LocaleSidKey = 'en_US',
                                    LanguageLocaleKey = 'en_US');
            insert user2;

            List<Map<String, Object>> fieldlist = new List<Map<String, Object>> ();
            Map<String, Object> fieldMap = new Map<String, Object>();
            fieldMap.put('description', 'new field');
            fieldMap.put('fieldPath', 'dummyPath');
            fieldlist.add(fieldMap);
            String extraFields = JSON.serialize(fieldlist);

            LightningSelfRegisterController.validatePassword(user2, 'ttibrands123', 'ttibrands123');
            LightningSelfRegisterController.selfRegister(user2.FirstName, user2.LastName, user2.Email, 'ttibrands123', 'ttibrands123', portalAccount1.Id, 'http://registration-confirm.com', extraFields, 'http://my.company.salesforce.com', true, user2.Title, user2.Country, '', user2.MobilePhone, user2.Phone, true, true, 'Business', 'Dealer', '0-10', 'Who was your childhood hero?', 'You' , 'xdfTrg');
            LightningSelfRegisterController.testDummy();
        }
    }


    static testMethod void testLightningSelfRegister3(){
        LightningSelfRegisterController.getUserName();
        LightningSelfRegisterController.getSiteName();
    }

    static testMethod void testLightningSelfRegister4(){
        LightningSelfRegisterController.existingUser('dirkdsilva', 'ttibrands');
    }

    static testMethod void testLightningSelfRegister5(){
        Community_Settings__c cs = new Community_Settings__c();
        cs.Brand__c = 'Ryobi';
        cs.Name = 'test';
        insert cs;

        Account portalAccount1 = new Account(Name = 'TestAccount');
        insert portalAccount1;

        List<Map<String, Object>> fieldlist = new List<Map<String, Object>> ();
        Map<String, Object> fieldMap = new Map<String, Object>();
        fieldMap.put('description', 'new field');
        fieldMap.put('fieldPath', 'dummyPath');
        fieldlist.add(fieldMap);
        String extraFields = JSON.serialize(fieldlist);

        LightningSelfRegisterController.selfRegister('Dirk', 'Dsilva', 'dsilva@ttibrands.com', 'ttibrands123', 'ttibrands123', portalAccount1.Id, 'http://registration-confirm.com', extraFields, 'http://my.company.salesforce.com', false, 'Mr.', 'Australia', '12345', '123456789', '123456789', true, true, 'Business', '0-10', 'Who was your childhood hero?', 'You', 'Dealer', 'xBGdfG');

        LightningSelfRegisterController.getCommunitySettings();
        LightningSelfRegisterController.getExtraFields(extraFields);
    }

    static testMethod void testLightningSelfRegister6(){
        Community_Settings__c cs = new Community_Settings__c();
        cs.Brand__c = 'AEG';
        cs.Name = 'test';
        insert cs;

        Account portalAccount1 = new Account(Name = 'TestAccount');
        insert portalAccount1;

        List<Map<String, Object>> fieldlist = new List<Map<String, Object>> ();
        Map<String, Object> fieldMap = new Map<String, Object>();
        fieldMap.put('description', 'new field');
        fieldMap.put('fieldPath', 'dummyPath');
        fieldlist.add(fieldMap);
        String extraFields = JSON.serialize(fieldlist);

        LightningSelfRegisterController.selfRegister('Dirk', 'Dsilva', 'dsilva@ttibrands.com', 'ttibrands123', 'ttibrands123', portalAccount1.Id, 'http://registration-confirm.com', extraFields, 'http://my.company.salesforce.com', true, 'Mr.', 'Australia', '12345', '123456789', '123456789', true, true, 'Business', '0-10', 'Who was your childhood hero?', 'You', 'Dealer', 'xBGdfG');

        LightningSelfRegisterController.getCommunitySettings();
        LightningSelfRegisterController.getExtraFields(extraFields);
    }

    static testMethod void testLightningSelfRegister7(){
        Community_Settings__c cs = new Community_Settings__c();
        cs.Brand__c = 'AEG';
        cs.Name = 'test';
        insert cs;

        Account portalAccount1 = new Account(Name = 'TestAccount');
        insert portalAccount1;

        List<Map<String, Object>> fieldlist = new List<Map<String, Object>> ();
        Map<String, Object> fieldMap = new Map<String, Object>();
        fieldMap.put('description', 'new field');
        fieldMap.put('fieldPath', 'dummyPath');
        fieldlist.add(fieldMap);
        String extraFields = JSON.serialize(fieldlist);

        LightningSelfRegisterController.selfRegister('', 'Dsilva', 'dsilva@ttibrands.com', 'ttibrands123', 'ttibrands123', portalAccount1.Id, 'http://registration-confirm.com', extraFields, 'http://my.company.salesforce.com', true, 'Mr.', 'Australia', '12345', '123456789', '123456789', true, true, 'Business', '0-10', 'Who was your childhood hero?', 'You', 'Dealer', 'xBGdfG');

        LightningSelfRegisterController.getCommunitySettings();
        LightningSelfRegisterController.getExtraFields(extraFields);
    }

    static testMethod void testLightningSelfRegister8(){
        Community_Settings__c cs = new Community_Settings__c();
        cs.Brand__c = 'AEG';
        cs.Name = 'test';
        insert cs;

        Account portalAccount1 = new Account(Name = 'TestAccount');
        insert portalAccount1;

        List<Map<String, Object>> fieldlist = new List<Map<String, Object>> ();
        Map<String, Object> fieldMap = new Map<String, Object>();
        fieldMap.put('description', 'new field');
        fieldMap.put('fieldPath', 'dummyPath');
        fieldlist.add(fieldMap);
        String extraFields = JSON.serialize(fieldlist);

        LightningSelfRegisterController.selfRegister('Dsilva', '', 'dsilva@ttibrands.com', 'ttibrands123', 'ttibrands123', portalAccount1.Id, 'http://registration-confirm.com', extraFields, 'http://my.company.salesforce.com', true, 'Mr.', 'Australia', '12345', '123456789', '123456789', true, true, 'Business', '0-10', 'Who was your childhood hero?', 'You', 'Dealer', 'xBGdfG');

        LightningSelfRegisterController.getCommunitySettings();
        LightningSelfRegisterController.getExtraFields(extraFields);
    }

    static testMethod void testLightningSelfRegister9(){
        Community_Settings__c cs = new Community_Settings__c();
        cs.Brand__c = 'AEG';
        cs.Name = 'test';
        insert cs;

        Account portalAccount1 = new Account(Name = 'TestAccount');
        insert portalAccount1;

        List<Map<String, Object>> fieldlist = new List<Map<String, Object>> ();
        Map<String, Object> fieldMap = new Map<String, Object>();
        fieldMap.put('description', 'new field');
        fieldMap.put('fieldPath', 'dummyPath');
        fieldlist.add(fieldMap);
        String extraFields = JSON.serialize(fieldlist);

        LightningSelfRegisterController.selfRegister('Dsilva', 'Dsilva', '', 'ttibrands123', 'ttibrands123', portalAccount1.Id, 'http://registration-confirm.com', extraFields, 'http://my.company.salesforce.com', true, 'Mr.', 'Australia', '12345', '123456789', '123456789', true, true, 'Business', '0-10', 'Who was your childhood hero?', 'You', 'Dealer', 'xBGdfG');

        LightningSelfRegisterController.getCommunitySettings();
        LightningSelfRegisterController.getExtraFields(extraFields);
    }

    static testMethod void testLightningSelfRegister10(){
        Community_Settings__c cs = new Community_Settings__c();
        cs.Brand__c = 'AEG';
        cs.Name = 'test';
        insert cs;

        Account portalAccount1 = new Account(Name = 'TestAccount');
        insert portalAccount1;

        List<Map<String, Object>> fieldlist = new List<Map<String, Object>> ();
        Map<String, Object> fieldMap = new Map<String, Object>();
        fieldMap.put('description', 'new field');
        fieldMap.put('fieldPath', 'dummyPath');
        fieldlist.add(fieldMap);
        String extraFields = JSON.serialize(fieldlist);

        LightningSelfRegisterController.selfRegister('Dsilva', 'Dsilva', 'dsilva@ttibrands.com', 'ttibrands123', 'ttibrands123', portalAccount1.Id, 'http://registration-confirm.com', extraFields, 'http://my.company.salesforce.com', true, 'Mr.', '', '12345', '123456789', '123456789', true, true, 'Business', '0-10', 'Who was your childhood hero?', 'You', 'Dealer' , 'xBGdfG');

        LightningSelfRegisterController.getCommunitySettings();
        LightningSelfRegisterController.getExtraFields(extraFields);
    }

    static testMethod void testLightningSelfRegister11(){
        Community_Settings__c cs = new Community_Settings__c();
        cs.Brand__c = 'AEG';
        cs.Name = 'test';
        insert cs;

        Account portalAccount1 = new Account(Name = 'TestAccount');
        insert portalAccount1;

        List<Map<String, Object>> fieldlist = new List<Map<String, Object>> ();
        Map<String, Object> fieldMap = new Map<String, Object>();
        fieldMap.put('description', 'new field');
        fieldMap.put('fieldPath', 'dummyPath');
        fieldlist.add(fieldMap);
        String extraFields = JSON.serialize(fieldlist);

        LightningSelfRegisterController.selfRegister('Dsilva', 'Dsilva', 'dsilva@ttibrands.com', 'ttibrands123', 'ttibrands123', portalAccount1.Id, 'http://registration-confirm.com', extraFields, 'http://my.company.salesforce.com', true, 'Mr.', 'Australia', '', '123456789', '123456789', true, true, 'Business', '0-10', 'Who was your childhood hero?', 'You', 'Dealer' , 'xBGdfG');

        LightningSelfRegisterController.getCommunitySettings();
        LightningSelfRegisterController.getExtraFields(extraFields);
    }

    static testMethod void testLightningSelfRegister12(){
        Community_Settings__c cs = new Community_Settings__c();
        cs.Brand__c = 'Ryobi';
        cs.Name = 'test';
        insert cs;

        Account portalAccount1 = new Account(Name = 'TestAccount');
        insert portalAccount1;

        List<Map<String, Object>> fieldlist = new List<Map<String, Object>> ();
        Map<String, Object> fieldMap = new Map<String, Object>();
        fieldMap.put('description', 'new field');
        fieldMap.put('fieldPath', 'dummyPath');
        fieldlist.add(fieldMap);
        String extraFields = JSON.serialize(fieldlist);

        LightningSelfRegisterController.selfRegister('Dsilva', 'Dsilva', 'dsilva@ttibrands.com', 'ttibrands123', 'ttibrands123', portalAccount1.Id, 'http://registration-confirm.com', extraFields, 'http://my.company.salesforce.com', true, 'Mr.', 'Australia', '12345', '', '123456789', true, true, 'Business', '0-10', 'Who was your childhood hero?', 'You', 'Dealer', 'xBGdfG');

        LightningSelfRegisterController.getCommunitySettings();
        LightningSelfRegisterController.getExtraFields(extraFields);
    }

    static testMethod void testLightningSelfRegister13(){
        Community_Settings__c cs = new Community_Settings__c();
        cs.Brand__c = 'AEG';
        cs.Name = 'test';
        insert cs;

        Account portalAccount1 = new Account(Name = 'TestAccount');
        insert portalAccount1;

        List<Map<String, Object>> fieldlist = new List<Map<String, Object>> ();
        Map<String, Object> fieldMap = new Map<String, Object>();
        fieldMap.put('description', 'new field');
        fieldMap.put('fieldPath', 'dummyPath');
        fieldlist.add(fieldMap);
        String extraFields = JSON.serialize(fieldlist);

        LightningSelfRegisterController.selfRegister('Dsilva', 'Dsilva', 'dsilva@ttibrands.com', 'ttibrands123', 'ttibrands123', portalAccount1.Id, 'http://registration-confirm.com', extraFields, 'http://my.company.salesforce.com', true, 'Mr.', 'Australia', '12345', '123456789', '', true, true, 'Business', '0-10', 'Who was your childhood hero?', 'You', 'Dealer', 'xBGdfG');

        LightningSelfRegisterController.getCommunitySettings();
        LightningSelfRegisterController.getExtraFields(extraFields);
    }

    static testMethod void testLightningSelfRegister14(){
        Community_Settings__c cs = new Community_Settings__c();
        cs.Brand__c = 'AEG';
        cs.Name = 'test';
        insert cs;

        Account portalAccount1 = new Account(Name = 'TestAccount');
        insert portalAccount1;

        List<Map<String, Object>> fieldlist = new List<Map<String, Object>> ();
        Map<String, Object> fieldMap = new Map<String, Object>();
        fieldMap.put('description', 'new field');
        fieldMap.put('fieldPath', 'dummyPath');
        fieldlist.add(fieldMap);
        String extraFields = JSON.serialize(fieldlist);

        LightningSelfRegisterController.selfRegister('Dsilva', 'Dsilva', 'dsilva@ttibrands.com', 'ttibrands123', 'ttibrands123', portalAccount1.Id, 'http://registration-confirm.com', extraFields, 'http://my.company.salesforce.com', true, 'Mr.', 'Australia', '12345', '123456789', '123456789', true, true, '', '0-10', 'Who was your childhood hero?', 'You', 'Dealer', 'xBGdfG');

        LightningSelfRegisterController.getCommunitySettings();
        LightningSelfRegisterController.getExtraFields(extraFields);
    }

    static testMethod void testLightningSelfRegister15(){
        Community_Settings__c cs = new Community_Settings__c();
        cs.Brand__c = 'AEG';
        cs.Name = 'test';
        insert cs;

        Account portalAccount1 = new Account(Name = 'TestAccount');
        insert portalAccount1;

        List<Map<String, Object>> fieldlist = new List<Map<String, Object>> ();
        Map<String, Object> fieldMap = new Map<String, Object>();
        fieldMap.put('description', 'new field');
        fieldMap.put('fieldPath', 'dummyPath');
        fieldlist.add(fieldMap);
        String extraFields = JSON.serialize(fieldlist);

        LightningSelfRegisterController.selfRegister('Dsilva', 'Dsilva', 'dsilva@ttibrands.com', 'ttibrands123', 'ttibrands123', portalAccount1.Id, 'http://registration-confirm.com', extraFields, 'http://my.company.salesforce.com', true, 'Mr.', 'Australia', '12345', '123456789', '123456789', true, true, 'Business', '0-10', 'Who was your childhood hero?', 'You', 'Dealer', 'xBGdfG');

        LightningSelfRegisterController.getCommunitySettings();
        LightningSelfRegisterController.getExtraFields(extraFields);
    }

    static testMethod void testLightningSelfRegister16(){
        Community_Settings__c cs = new Community_Settings__c();
        cs.Brand__c = 'AEG';
        cs.Name = 'test';
        insert cs;

        Account portalAccount1 = new Account(Name = 'TestAccount');
        insert portalAccount1;

        List<Map<String, Object>> fieldlist = new List<Map<String, Object>> ();
        Map<String, Object> fieldMap = new Map<String, Object>();
        fieldMap.put('description', 'new field');
        fieldMap.put('fieldPath', 'dummyPath');
        fieldlist.add(fieldMap);
        String extraFields = JSON.serialize(fieldlist);

        LightningSelfRegisterController.selfRegister('Dsilva', 'Dsilva', 'dsilva@ttibrands.com', 'ttibrands123', 'ttibrands123', portalAccount1.Id, 'http://registration-confirm.com', extraFields, 'http://my.company.salesforce.com', true, 'Mr.', 'Australia', '12345', '123456789', '123456789', true, true, 'Business', '0-10', '', 'You', 'Dealer', 'xBGdfG');

        LightningSelfRegisterController.getCommunitySettings();
        LightningSelfRegisterController.getExtraFields(extraFields);
    }

    static testMethod void testLightningSelfRegister17(){
        Community_Settings__c cs = new Community_Settings__c();
        cs.Brand__c = 'AEG';
        cs.Name = 'test';
        insert cs;

        Account portalAccount1 = new Account(Name = 'TestAccount');
        insert portalAccount1;

        List<Map<String, Object>> fieldlist = new List<Map<String, Object>> ();
        Map<String, Object> fieldMap = new Map<String, Object>();
        fieldMap.put('description', 'new field');
        fieldMap.put('fieldPath', 'dummyPath');
        fieldlist.add(fieldMap);
        String extraFields = JSON.serialize(fieldlist);

        LightningSelfRegisterController.selfRegister('Dsilva', 'Dsilva', 'dsilva@ttibrands.com', 'ttibrands123', 'ttibrands123', portalAccount1.Id, 'http://registration-confirm.com', extraFields, 'http://my.company.salesforce.com', true, 'Mr.', 'Australia', '12345', '123456789', '123456789', true, true, 'Business', '0-10', 'Who was your childhood hero?', '', 'Dealer', 'xBGdfG');

        LightningSelfRegisterController.getCommunitySettings();
        LightningSelfRegisterController.getExtraFields(extraFields);
    }

    static testMethod void testLightningSelfRegister18(){
        Community_Settings__c cs = new Community_Settings__c();
        cs.Brand__c = 'AEG';
        cs.Name = 'test';
        insert cs;

        Account portalAccount1 = new Account(Name = 'TestAccount');
        insert portalAccount1;

        List<Map<String, Object>> fieldlist = new List<Map<String, Object>> ();
        Map<String, Object> fieldMap = new Map<String, Object>();
        fieldMap.put('description', 'new field');
        fieldMap.put('fieldPath', 'dummyPath');
        fieldlist.add(fieldMap);
        String extraFields = JSON.serialize(fieldlist);

        LightningSelfRegisterController.selfRegister('Dsilva', 'Dsilva', 'dsilva@ttibrands.com', 'ttibrands23', 'ttibrands123', portalAccount1.Id, 'http://registration-confirm.com', extraFields, 'http://my.company.salesforce.com', true, 'Mr.', 'Australia', '12345', '', '', true, true, 'Business', '0-10', 'Who was your childhood hero?', '', 'Dealer', 'xBGdfG');

        LightningSelfRegisterController.getCommunitySettings();
        LightningSelfRegisterController.getExtraFields(extraFields);
    }

    static testMethod void testLightningSelfRegister19(){
        Community_Settings__c cs = new Community_Settings__c();
        cs.Brand__c = 'AEG';
        cs.Name = 'test';
        insert cs;

        Account portalAccount1 = new Account(Name = 'TestAccount');
        insert portalAccount1;

        List<Map<String, Object>> fieldlist = new List<Map<String, Object>> ();
        Map<String, Object> fieldMap = new Map<String, Object>();
        fieldMap.put('description', 'new field');
        fieldMap.put('fieldPath', 'dummyPath');
        fieldlist.add(fieldMap);
        String extraFields = JSON.serialize(fieldlist);

        LightningSelfRegisterController.selfRegister('Dsilva', 'Dsilva', 'dsilva@ttibrands.com', 'ttibrands23', 'ttibrands123', portalAccount1.Id, 'http://registration-confirm.com', extraFields, 'http://my.company.salesforce.com', true, 'Mr.', 'Australia', '12345', '', '', true, false, 'Business', '0-10', 'Who was your childhood hero?', '', 'Dealer', 'xBGdfG');

        LightningSelfRegisterController.getCommunitySettings();
        LightningSelfRegisterController.getExtraFields(extraFields);
    }

    static testMethod void testLightningSelfRegister20(){
        LightningSelfRegisterController.picklistOptionWrapper wrap1 = new LightningSelfRegisterController.picklistOptionWrapper();
        wrap1.optionName = 'test';
        wrap1.optionSelected = false;
        LightningSelfRegisterController.referenceFieldWrapper wrap = new LightningSelfRegisterController.referenceFieldWrapper();
        wrap.label = 'test';
        wrap.type = 'PICKLIST';
        wrap.value = 'value1';
        wrap.fieldPath = 'test';

        LightningSelfRegisterController.getSiteName();
        LightningSelfRegisterController.getCommunitySettings();
        LightningSelfRegisterController.getUserName();
    }

    static testMethod void testLightningSelfRegister21() {
        String networkId = Network.getNetworkId();
        //System.assertEquals(true, LightningSelfRegisterController.siteAsContainerEnabled(networkId));
    }

    static testMethod void testIsValidPassword() {
        System.assert(LightningSelfRegisterController.isValidPassword('password?@12334', 'password?@12334') == true);
        System.assert(LightningSelfRegisterController.isValidPassword('password?@12334', 'dummyPassword') == false);
        System.assert(LightningSelfRegisterController.isValidPassword('password?@12334', null) == false);
        System.assert(LightningSelfRegisterController.isValidPassword(null, 'fakePwd') == false);
    }

    static testMethod void testSiteAsContainerEnabled() {
        String networkId = Network.getNetworkId();
        //System.assertEquals(true, LightningSelfRegisterController.siteAsContainerEnabled(networkId));
    }

    static testMethod void testSelfRegistration() {
        Map<String, String> paramsMap = initializeParams();
        System.assertNotEquals(null, paramsMap);
        System.assertEquals(Label.Site.lastname_is_required, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), '', paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true, paramsMap.get('title'),paramsMap.get('country'),paramsMap.get('postcode'),paramsMap.get('mobile'),paramsMap.get('phone'), true,true, paramsMap.get('customerType'),paramsMap.get('profession'),paramsMap.get('employeeSize'),paramsMap.get('securityQuestion'), paramsMap.get('answer'),paramsMap.get('referralCode')));
        System.assertEquals(Label.Site.email_is_required, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), '', paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true, paramsMap.get('title'),paramsMap.get('country'),paramsMap.get('postcode'),paramsMap.get('mobile'),paramsMap.get('phone'), true,true, paramsMap.get('customerType'),paramsMap.get('profession'),paramsMap.get('employeeSize'),paramsMap.get('securityQuestion'), paramsMap.get('answer'),paramsMap.get('referralCode')));
        System.assertEquals('First Name is required.', LightningSelfRegisterController.selfRegister(null, paramsMap.get('lastName'), '', null, paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true, paramsMap.get('title'),paramsMap.get('country'),paramsMap.get('postcode'),paramsMap.get('mobile'),paramsMap.get('phone'), true,true, paramsMap.get('customerType'),paramsMap.get('profession'),paramsMap.get('employeeSize'),paramsMap.get('securityQuestion'), paramsMap.get('answer'),paramsMap.get('referralCode')));
        System.assertEquals(Label.site.passwords_dont_match, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordWrong'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true, paramsMap.get('title'),paramsMap.get('country'),paramsMap.get('postcode'),paramsMap.get('mobile'),paramsMap.get('phone'), true,true, paramsMap.get('customerType'),paramsMap.get('profession'),paramsMap.get('employeeSize'),paramsMap.get('securityQuestion'), paramsMap.get('answer'),paramsMap.get('referralCode')));
        System.assertNotEquals(null, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), '', paramsMap.get('password'), paramsMap.get('confirmPasswordWrong'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), false, paramsMap.get('title'),paramsMap.get('country'),paramsMap.get('postcode'),paramsMap.get('mobile'),paramsMap.get('phone'), true,true, paramsMap.get('customerType'),paramsMap.get('profession'),paramsMap.get('employeeSize'),paramsMap.get('securityQuestion'), paramsMap.get('answer'),paramsMap.get('referralCode')));
        System.assertEquals('Title is required', LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), null, paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true, null,paramsMap.get('country'),paramsMap.get('postcode'),paramsMap.get('mobile'),paramsMap.get('phone'), true,true, paramsMap.get('customerType'),paramsMap.get('profession'),paramsMap.get('employeeSize'),paramsMap.get('securityQuestion'), paramsMap.get('answer'),paramsMap.get('referralCode')));
        System.assertEquals('Country is required.', LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), null, paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true, paramsMap.get('title'),null,paramsMap.get('postcode'),paramsMap.get('mobile'),paramsMap.get('phone'), true,true, paramsMap.get('customerType'),paramsMap.get('profession'),paramsMap.get('employeeSize'),paramsMap.get('securityQuestion'), paramsMap.get('answer'),paramsMap.get('referralCode')));
        System.assertEquals('Postcode is required.', LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), null, paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true, paramsMap.get('title'),paramsMap.get('country'),null,paramsMap.get('mobile'),paramsMap.get('phone'), true,true, paramsMap.get('customerType'),paramsMap.get('profession'),paramsMap.get('employeeSize'),paramsMap.get('securityQuestion'), paramsMap.get('answer'),paramsMap.get('referralCode'))); 
        System.assertEquals('Security question is required', LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), null, paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true, paramsMap.get('title'),paramsMap.get('country'),paramsMap.get('postcode'),paramsMap.get('mobile'),paramsMap.get('phone'), true,true, paramsMap.get('customerType'),paramsMap.get('profession'),paramsMap.get('employeeSize'),null, paramsMap.get('answer'),paramsMap.get('referralCode')));
        System.assertEquals('Answer is required.', LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), null, paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true, paramsMap.get('title'),paramsMap.get('country'),paramsMap.get('postcode'),paramsMap.get('mobile'),paramsMap.get('phone'), true,true, paramsMap.get('customerType'),paramsMap.get('profession'),paramsMap.get('employeeSize'),paramsMap.get('securityQuestion'),paramsMap.get('referralCode'),null));
        System.assertEquals('Please accept Terms and Conditions.', LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), null, paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true, paramsMap.get('title'),paramsMap.get('country'),paramsMap.get('postcode'),paramsMap.get('mobile'),paramsMap.get('phone'), true,false, paramsMap.get('customerType'),paramsMap.get('profession'),paramsMap.get('employeeSize'),paramsMap.get('securityQuestion'), paramsMap.get('answer'),paramsMap.get('referralCode')));
    }

    static testMethod void testSelfRegisterWithProperCredentials() {
        Map<String, String> paramsMap = initializeParams();
        //System.assertEquals(null, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true, paramsMap.get('title'),paramsMap.get('country'),paramsMap.get('postcode'),paramsMap.get('mobile'),paramsMap.get('phone'), true,true, paramsMap.get('customerType'),paramsMap.get('profession'),paramsMap.get('employeeSize'),paramsMap.get('securityQuestion'), paramsMap.get('answer')));
    }

    static testMethod void testSelfRegisterWithCreatedAccount() {
        Account acc = new Account(name = 'test acc');
        insert acc;
        List<Account> accounts = [SELECT Id FROM Account LIMIT 1];
        System.assert(!accounts.isEmpty(), 'There must be at least one account in this environment!');
        String accountId = accounts[0].Id;
        Map<String, String> paramsMap = initializeParams();
        //System.assertEquals(null, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), accountId, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), false, paramsMap.get('title'),paramsMap.get('country'),paramsMap.get('postcode'),paramsMap.get('mobile'),paramsMap.get('phone'), true,true, paramsMap.get('customerType'),paramsMap.get('profession'),paramsMap.get('employeeSize'),paramsMap.get('securityQuestion'), paramsMap.get('answer')));
    }

    static testMethod void testGetNullExtraFields() {
        //System.assertEquals(new List < Map < String, Object >> (), LightningSelfRegisterController.getExtraFields(null));
        System.assertEquals(new List<LightningSelfRegisterController.referenceFieldWrapper>(), LightningSelfRegisterController.getExtraFields(null));
    }

    static testMethod void testGetNonEmptyExtraFields() {
        //System.assertEquals(new List < Map < String, Object >> (), LightningSelfRegisterController.getExtraFields('field1'));
        System.assertEquals(new List<LightningSelfRegisterController.referenceFieldWrapper>(), LightningSelfRegisterController.getExtraFields('field1'));
    }

    static testMethod void testGetExtraFieldsInSelfRegistration() {
        List<Map<String, Object>> fieldlist = new List<Map<String, Object>> ();
        Map<String, String> paramsMap = initializeParams();
        Map<String, Object> fieldMap = new Map < String, Object > ();
        fieldMap.put('description', 'new field');
        fieldMap.put('fieldPath', 'dummyPath');
        fieldlist.add(fieldMap);
        String extraFields = JSON.serialize(fieldlist);
        System.assertNotEquals(null, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), extraFields, paramsMap.get('startUrl'), true, paramsMap.get('title'),paramsMap.get('country'),paramsMap.get('postcode'),paramsMap.get('mobile'),paramsMap.get('phone'), true,true, paramsMap.get('customerType'),paramsMap.get('profession'),paramsMap.get('employeeSize'),paramsMap.get('securityQuestion'), paramsMap.get('answer'),paramsMap.get('referralCode')));
    }

    static testMethod void LightningSelfRegisterController(){
        LightningSelfRegisterController.getSiteName();
        LightningSelfRegisterController.getCommunitySettings();
        LightningSelfRegisterController.getUserName();
        LightningSelfRegisterController.picklistOptionWrapper wrap1 = new LightningSelfRegisterController.picklistOptionWrapper();
        wrap1.optionName = 'test';
        wrap1.optionSelected = false;
        LightningSelfRegisterController.referenceFieldWrapper wrap = new LightningSelfRegisterController.referenceFieldWrapper();
        wrap.label = 'test';
        wrap.type = 'PICKLIST';
        wrap.value = 'value1';
        wrap.fieldPath = 'test';
    }

    private static Map<String, String> initializeParams() {
        Map<String, String> paramsMap = new Map<String, String>();
        String firstName = 'test';
        String lastName = 'User';
        String email = 'testUser@salesforce.com';
        String password = 'testuser123';
        String confirmPasswordCorrect = 'testuser123';
        String confirmPasswordWrong = 'wrongpassword';
        String accountId = 'testuser123';
        String regConfirmUrl = 'http://registration-confirm.com';
        String startUrl = 'http://my.company.salesforce.com';
        String title = 'Mr.';
        String country = 'Australia';
        String postcode = '12345';
        String mobile = '123456789';
        String phone = '123456789';
        String customerType = 'Business';   
        String employeeSize = '0-10';
        String securityQuestion = 'Who was your childhood hero?';
        String answer = 'You';
        String profession = 'Dealer';
        paramsMap.put('firstName', firstName);
        paramsMap.put('lastName', lastName);
        paramsMap.put('email', email);
        paramsMap.put('password', password);
        paramsMap.put('confirmPasswordCorrect', confirmPasswordCorrect);
        paramsMap.put('confirmPasswordWrong', confirmPasswordWrong);
        paramsMap.put('accountId', accountId);
        paramsMap.put('regConfirmUrl', regConfirmUrl);
        paramsMap.put('startUrl', startUrl);
        paramsMap.put('title', title);
        paramsMap.put('country', country);
        paramsMap.put('postcode', postcode);
        paramsMap.put('mobile', mobile);
        paramsMap.put('phone', phone);
        paramsMap.put('customerType', customerType);
        paramsMap.put('employeeSize', employeeSize);
        paramsMap.put('securityQuestion', securityQuestion);
        paramsMap.put('answer', answer);
        paramsMap.put('profession', profession);
        return paramsMap;
    }
}