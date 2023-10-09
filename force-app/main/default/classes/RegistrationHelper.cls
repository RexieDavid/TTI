/**
 * @author                          Unknown
 * @description                     Registration helper for community
 */
public without sharing class RegistrationHelper {

    private static final String COMMUNITY_PROFILE_COMPLETION_PACKAGE = 'community_profile_completion';

    /**
     * @author                      Unknown
     * @description                 Update account data linked to user
     *                              Note: This will happen in future tense and will
     *                              have a delay for the updated data to apply
     * 
     * @param userId                Id of registered user
     * @param street                User street
     * @param city                  User city
     * @param state                 User state
     * @param country               User country
     * @param postcode              User postcode
     * @param brand                 Community brand where the user registered
     * @param leadsource            Lead of the source
     * @param parentaccount         Parent account of account record
     * @param customerType          User customer type
     * @param profession            User profession
     * @param employeeSize          User employee size
     * @param subscribed            Subscription status
     * @param title                 User title
     */
    @future
    public static void updatePersonAccount(Id userId, 
                                           String street, 
                                           String city, 
                                           String state, 
                                           String country, 
                                           String postcode, 
                                           String brand, 
                                           String leadsource, 
                                           String parentaccount, 
                                           String customerType, 
                                           String profession, 
                                           String employeeSize, 
                                           Boolean subscribed,
                                           String title) {    
        List<Account> acctoUpdate = new List<Account>();
        Account acctWithParent = new Account();
        Map<String, Id> parentContactIdMap = new Map<String, Id>();
        User usr = [SELECT Id, 
                           Title, 
                           FirstName, 
                           LastName, 
                           ContactId, 
                           MobilePhone, 
                           Phone, 
                           Email 
                    FROM User WHERE Id = :userId];
        Contact cont = [SELECT Id, AccountId FROM Contact WHERE Id = :usr.ContactId];
        Account acct = [SELECT Id, 
                               FirstName, 
                               LastName, 
                               PersonEmail, 
                               Brand__pc, 
                               PersonMobilePhone, 
                               PersonHomePhone, 
                               ParentContact__c, 
                               PersonHasOptedOutOfEmail, 
                               Type, Profession__c, 
                               Employee_Size__c, 
                               PersonMailingStreet, 
                               PersonMailingCity, 
                               PersonMailingState, 
                               PersonMailingCountry, 
                               PersonMailingPostalCode, 
                               RecordTypeId,
                               Salutation
                        FROM Account 
                        WHERE Id = :cont.AccountId];
        
        if (parentaccount == null) {
            acct.ParentContact__c = createParentContact(acct.FirstName, acct.LastName).Id;
        }
        
        acct.et4ae5__HasOptedOutOfMobile__pc = !subscribed;
        acct.PersonHasOptedOutOfEmail = !subscribed;
        acct.PersonMailingStreet = street;
        acct.PersonMailingCity = city;
        acct.PersonMailingState = state;
        acct.PersonMailingCountry = country;
        acct.PersonMailingPostalCode = postcode;
        acct.Country__pc = country;
        acct.Brand__pc = brand;
        acct.PersonLeadSource = leadsource;
        acct.Type = customerType;
        acct.Profession__c = profession;
        acct.Employee_Size__c = employeeSize;
        acct.PersonMobilePhone = usr.MobilePhone;
        acct.PersonHomePhone = usr.Phone;
        acct.PersonEmail = usr.Email;
        acct.Salutation = title;
        String defaultAccOwner = Community_Settings__c.getValues('CommonSettings').Default_Account_OwnerId__c;
        if (defaultAccOwner != null) {
            List<User> uList = [SELECT Id FROM User Where Id = :defaultAccOwner AND isActive = TRUE];
            if (!uList.isEmpty()) {
                acct.OwnerId = defaultAccOwner;
            }
        }
        
        update acct;
    }
    
    
    /**
     * @author                      Unknown
     * @description                 Update account data linked to user
     *                              Note: This will happen in future tense and will
     *                              have a delay for the updated data to apply
     * 
     * @param userId                Id of registered user
     * @param street                User street
     * @param city                  User city
     * @param state                 User state
     * @param country               User country
     * @param postcode              User postcode
     * @param fName                 User firstname
     * @param lName                 User lastname
     * @param mobile                User mobile number
     * @param phone                 User phone number
     * @param email                 User email
     * @param cusType               User customer type
     * @param empSize               User employee size if type is business
     * @param title                 User title
     * @param profession            User profession
     */
    @future
    public static void updatePersonAccount(String userId, 
                                           String street, 
                                           String city, 
                                           String state, 
                                           String country, 
                                           String postcode, 
                                           String fName, 
                                           String lName, 
                                           String mobile, 
                                           String phone, 
                                           String email, 
                                           String cusType, 
                                           String empSize, 
                                           String title, 
                                           String profession) {
        
        User currUser = [SELECT Id, Contact.AccountId FROM User WHERE Id =: userId];
        Account acct = [SELECT Id FROM Account WHERE Id = :currUser.Contact.AccountId LIMIT 1];
        if (acct != null) {
            acct.PersonMailingStreet = street;
            acct.PersonMailingCity = city;
            acct.PersonMailingState = state;
            acct.PersonMailingCountry = country;
            acct.PersonMailingPostalCode = postcode;
            acct.Country__pc = country;
            acct.FirstName = fName;
            acct.LastName = lName;
            acct.PersonMobilePhone = mobile;
            acct.PersonHomePhone = phone;
            acct.PersonEmail = email;
            acct.Type = cusType;
            acct.Profession__c = profession;
            acct.Employee_Size__c = empSize;
            acct.PersonTitle = title;
            update acct;
        }
    }
   
    /**
     * @author                      Unknown
     * @description                 Create parent contact record
     * 
     * @param firstName             Parent contact firstname
     * @param lastName              Parent contact lastname
     */
    public static Parent_Contact__c createParentContact(String firstName, String lastName) {
        Parent_Contact__c parentContact = new Parent_Contact__c();
        parentContact.Name = firstName + ' ' + lastName;
        insert parentContact;
        return parentContact;
    }
}