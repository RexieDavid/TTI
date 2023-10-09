@isTest
public class RYTestDataFactory {

    /**********************************************************************
     * @description                 Build Person Account List
     * 
     * @param  sizeVar              number of Person Accounts to be built
     * @return                      List of Person Accounts
     */
    public static List<Account> buildPersonAccountList(Integer sizeVar) {
        RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Account' AND isActive = TRUE AND DeveloperName = 'PersonAccount' LIMIT 1];
        List<Account> accList = new List<Account>();
        for (Integer flag = 0; flag < sizeVar; flag ++) {
            Account accVar = new Account();
            accVar.RecordTypeID = rt.Id;
            accVar.FirstName = 'test' + string.valueOf(flag);
            accVar.LastName = 'test' + string.valueOf(flag);
            accVar.PersonMailingStreet = 'test@yahoo.com';
            accVar.PersonMailingPostalCode = '12345';
            accVar.PersonMailingCity = 'SFO';
            accVar.PersonMailingCountry = 'Australia';
            accVar.PersonHomePhone = '1234567';
            accVar.PersonMobilePhone = '12345678';
            accVar.Brands__c = 'Ryobi';
            accVar.Country__pc = 'Australia';
            accList.add(accVar);
        }
        return accList;
    }

    /**********************************************************************
     * @description                 Build Bunnings Business Account
     * 
     * @param  sizeVar              number of Business Account to be built
     * @return                      List of Business Account
     */
    public static List<Account> buildBussinessAccount(Integer sizeVar) {
        RecordType rt = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' AND isActive = TRUE AND DeveloperName = 'Commercial' LIMIT 1];
        List<Account> accList = new List<Account>();
        for (Integer flag = 0; flag < sizeVar; flag ++) {
            Account accVar = new Account();
            accVar.RecordTypeID = rt.Id;
            accVar.Record_Status__c = 'Active';
            accVar.Name = 'Bunnings';
            accVar.Type = 'Retailer';
            accVar.Customer_Group_1_Code__c = 'BU';
            accVar.Customer_Group_1__c = 'Bunnings';
            accVar.Company_Code__c = 'BP01';
            accList.add(accVar);
        }
        return accList;
    }
    /**********************************************************************
     * @description                 Build User
     * 
     * @param  sizeVar              number of Users to be built
     * @param  profileId            Profile to be used of Users
     * @param  contactId            ContactId for Users
     * @return                      User Built
     */
    public static User buildUser(Id profileId, Id contactId, String userName) {
        User newUser = new User();
        newUser.ProfileId = profileId;
        newUser.Username = userName;
        newUser.Alias = 'subpref';
        newUser.Email = 'subpref@test.com';
        newUser.EmailEncodingKey = 'UTF-8';
        newUser.FirstName = 'sub';
        newUser.Lastname = 'pref';
        newUser.LanguageLocaleKey = 'en_US';
        newUser.LocaleSidKey = 'en_US';
        newUser.TimeZoneSidKey = 'America/Chicago';
        newUser.Country = 'Australia';
        newUser.ContactId = contactId;
        return newUser;
    }

    /**********************************************************************
     * @description                 Build new preferences
     * 
     * @param  counter              Name of the preference
     * @param  preferenceTopicId    Parent topic of preference
     * @return                      Preference raw record
     */
    public static Preference__c buildPreference(Integer counter, String preferenceTopicId){
        Preference__c newPreference = new Preference__c();
        newPreference.Name = 'Preference - ' + counter;
        newPreference.PreferenceTopic__c = preferenceTopicId;
        newPreference.Brand__c = 'RY';
        newPreference.CountryCode__c = 'AU';
        return newPreference;
    }

    /**********************************************************************
     * @description             Build new preference topic
     * 
     * @param  counter          Suffix of preference topic name
     * @return                  Preference topic raw record
     */
    public static PreferenceTopic__c buildPreferenceTopic(Integer counter, String name) {
        PreferenceTopic__c newPrefTopic = new PreferenceTopic__c();
        newPrefTopic.Name = name;
        newPrefTopic.Description__c = 'Preference Topic Description - ' + counter;
        return newPrefTopic;
    }

    /**********************************************************************
     * @description             Build new person account preferences
     *
     * @param  personAccountId  Account Id where preference should be link
     * @param  preferenceId     Id of preference to be link
     * @return                  Person Account preference raw record
     */
    public static PersonAccountPreference__c buildPersonAccountPreference(String personAccountId, String preferenceId) {
        PersonAccountPreference__c newPersonAccountPref = new PersonAccountPreference__c();
        newPersonAccountPref.PreferenceId__c = preferenceId;
        newPersonAccountPref.PersonAccountId__c = personAccountId;
        return newPersonAccountPref;
    }
}