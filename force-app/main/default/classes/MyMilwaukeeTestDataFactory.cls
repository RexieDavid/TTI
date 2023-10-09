/**
* @author      : Samuel Oberes
* @date        : 2019-02-13
* @description : Test data factory for the MyMilwaukee (Onekey) community
*/
@isTest
public class MyMilwaukeeTestDataFactory {

    private static final Id PROFILEID_CSP_LITE_PORTAL = [SELECT Id FROM Profile WHERE UserType = 'CspLitePortal' LIMIT 1].Id;
    private static final Id RECORDTYPEID_B2C_PERSON_ACCOUNT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Consumer Contact').getRecordTypeId();
    
    public static CommunityRegistrationResourcePostReqDto createCommunityRegistrationResourcePostReqDto() {

        CommunityRegistrationResourcePostReqDto request = new CommunityRegistrationResourcePostReqDto();
        request.firstName = 'Luka';
        request.lastName = 'Doncic';
        request.email = 'luka.doncic@samplemail.com';
        request.password = 'AaBbCc123';
        request.mobile = '12345678';
        request.brand = 'ML';
        request.industry = 'Construction';
        request.securityQuestion = 'Are you human?';
        request.securityAnswer = 'yes';
        request.country = 'AU';

        return request;
    }

    public static CommunityRegistrationResourcePatchReqDto createCommunityRegistrationResourcePatchReqDto() {
        
        CommunityRegistrationResourcePatchReqDto request = new CommunityRegistrationResourcePatchReqDto();
        request.op = CommunityRegistrationResourcePatchReqDto.Operation.REPLACE;
        request.path = '/email';
        request.value = 'test@samplemail.com';
        return request;
    }

    public static User createSystemAdminUser() {
        UserRole role = new UserRole(DeveloperName = 'ApexRole', Name = 'ApexRole');
        insert role;
        Profile sysAdProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User sysAdminUser = new User(
            ProfileId = sysAdProfile.Id,
            Username = System.now().millisecond() + 'commMilSysAdmin@test.com',
            Alias = 'batman',
            Email = 'bruce.wayne@wayneenterprises.com',
            EmailEncodingKey = 'UTF-8',
            Firstname = 'Bruce',
            Lastname = 'Wayne',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Chicago',
            UserRoleId = role.Id,
            Country = 'Australia'
        );
        return sysAdminUser;
    }

    public static Account createPersonAccount(String lastname) {
        Account portalAcct = new Account();
        portalAcct.RecordTypeId = RECORDTYPEID_B2C_PERSON_ACCOUNT;
        portalAcct.FirstName = 'John';
        portalAcct.LastName = lastname;
        portalAcct.PersonMailingStreet = 'Test';
        portalAcct.PersonMailingPostalCode = '1234';
        portalAcct.PersonMailingCity = 'SFO';
        portalAcct.PersonMailingCountry = 'Australia';
        portalAcct.PersonHomePhone = '1234567';
        portalAcct.PersonMobilePhone = '12345678';
        portalAcct.Brands__c = 'Milwaukee';
        portalAcct.Country__pc = 'Australia';

        return portalAcct;
    }

    public static User createCustomerCommunityMilwaukeeUser(Id contactId) {
        User portalUser = new User(
            ProfileId = PROFILEID_CSP_LITE_PORTAL,
            Username = System.now().millisecond() + 'commMilPortalUser@test.com',
            Alias = 'jdoe',
            Email = 'johndoe@mailinator.com',
            EmailEncodingKey = 'UTF-8',
            Firstname = 'John',
            Lastname = 'Doe',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Chicago',
            ContactId = contactId,
            Country = 'Australia'
        );

        return portalUser;
    }

    // Preferences
    public static List<PreferenceTopic__c> createPreferenceTopics(Integer recordCount) {
        List<PreferenceTopic__c> preferenceTopics = new List<PreferenceTopic__c>();
        for (Integer i = 0; i < recordCount; i++) {
            preferenceTopics.add(new PreferenceTopic__c(
                Name = 'Topic-' + i,
                Description__c = 'This is description.'
            ));
        }
        return preferenceTopics;
    }

    public static Preference__c createPreference(String brand, String country, Id topic) {
        Preference__c preference = new Preference__c(
            PreferenceTopic__c = topic,
            Brand__c = brand,
            CountryCode__c = country,
            IsStandard__c = true
        );
        return preference;
    }

    public static PersonAccountPreference__c createPersonAcctPreference(Id preferenceId, Id personAcctId) {
        PersonAccountPreference__c personAcctPreferences = new PersonAccountPreference__c(
            PreferenceId__c = preferenceId,
            PersonAccountId__c = personAcctId
        );
        return personAcctPreferences;
    }
}