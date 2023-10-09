/*
* @author                           Rex Joseph Egoc
* @date                             2020-02-11
*
* group:                            AEG Community
* group-content:                    /../ApexDocContent/aeg-community.html
*
* @description                      Test data factory for AEG Community
*/
@isTest
public class AgTestDataFactory {

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
            accVar.Brands__c = 'AEG';
            accVar.Country__pc = 'Australia';
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
        newPreference.Brand__c = 'AG';
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

    /**********************************************************************
     * @description                 Create list of products
     * 
     * @return                      List of products
    */
    public static List<Product2> buildProducts(integer sizeVar) {
        List<Product2> prodList = new List<Product2>();
        for (Integer i = 0; i < sizeVar; i ++) {
            Product2 prod = new Product2(
                Name = 'AEG Product ' + i,
                Image_URL__c = 'https://test.jpeg',
                Small_Image_URL__c = 'https://test.jpeg',
                Published__c = true,
                IsActive = true,
                Available_AU__c = true,
                Available_NZ__c = true,
                Brand__c = 'AG',
                ProductCode = 'Product-' + i
            );
            prodList.add(prod);
        }
        return prodList;
    }

    /**********************************************************************
     * @description             Create Redemption Campaign
     * 
     * @param purchasedProdId   Purchase product Id
     * @param redeemedProdId    Redeemed Product Id
     * @return                  Redemption Campaign record
     */
    public static Redemption_Campaigns__c buildRedemptionCampaign(String purchasedProdId, String redeemedProdId) {
        Redemption_Campaigns__c newRedCamp = new Redemption_Campaigns__c();
        newRedCamp.Name = 'AEG_Redemption_Campaign';
        newRedCamp.Brand__c = 'AEG';
        newRedCamp.Country__c = 'anz';
        newRedCamp.Valid_From__c = System.today() - 31;
        newRedCamp.Redeemed_Item__c = redeemedProdId;
        newRedCamp.Purchased_Product__c = purchasedProdId;
        newRedCamp.Valid_To__c = System.today();
        newRedCamp.Redemption_Type__c = 'External';
        return newRedCamp;
    }
}