/**
 * @description  Auth0HandlerCommunityUtility acts as a utility class for Auth0handler class
 **/

public class Auth0HandlerCommunityUtility {
    public enum FailureType { STANDARD, CUSTOM }
    
    /**
	 * @description         Check whether user exists
	 * 						 
	 *                          
	 * 
	 * @param               user email and brand name
	 * @return              Boolean value      
	 */	
    public static Boolean doesUserExist(String userEmail, String brand) {
        return [SELECT COUNT() FROM User WHERE Email = :userEmail AND UserName = :(userEmail + '.' + brand) LIMIT 1] > 0;
    }
    
	/**
	 * @description         gets the user from community 
	 * 						 
	 *                          
	 * 
	 * @param               user email and brand name
	 * @return              User profile from community      
	 */
    public static User getCommunityUser(String userEmail, String brand) {
        List<User> users = [SELECT Firstname, Lastname, Email, MobilePhone, ContactId, UserName FROM User WHERE Email = :userEmail AND UserName = :(userEmail + '.' + brand) LIMIT 1];
        return users.isEmpty() ? null : users.get(0);
    }

	/**
	 * @description         gets the person account
	 * 						 
	 *                          
	 * 
	 * @param               user email
	 * @return              Person account      
	 */
    public static Account getB2cAccountByEmail(String email) {
        Id b2cConsumerContactAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Consumer Contact').getRecordTypeId();
        List<Account> accounts = [SELECT Id, 
                                         PersonContactId, 
                                         Onekey_GUID__c 
                                    FROM Account 
                                   WHERE PersonEmail = :email 
                                     AND Brand__pc = 'Milwaukee' 
                                     AND RecordTypeId = :b2cConsumerContactAccRecTypeId];
        return accounts.isEmpty() ? null : accounts.get(0);
    }

	/**
	 * @description         generates the GUID
	 * 						 
	 *                          
	 * 
	 * @return              ID string    
	 */
    public static String generateGUID() {
    
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0, 8) + '-' + h.SubString(8, 12) + '-' + h.SubString(12, 16) + '-' + h.SubString(16, 20) + '-' + h.substring(20);
        return guid;
    
    }
    /**
	 * @description         generates the Community Network id
	 * 						 
	 *                          
	 * 
	 * @return              ID string    
	 */
    public static Network getCommunityNetworkid() {
    
        List<Network> communityNetwork  = [SELECT id,Name FROM Network WHERE name =: 'OneKey Portal' limit 1];
        return communityNetwork.isEmpty() ? null : communityNetwork.get(0);
    
    }
 
	/**
	 * @description         checks whether email is of valid format
	 * 						 
	 *                          
	 * 
	 * @param               user metadata map, brand name and community profile name
	 * @return              User profile
	 */    
    public static User instantiateUser(String brand, Map<String,String> userMap, String profileName) {
        User user = new User();
        DateTime dt = Date.today();
        user.Alias = dt.format('MMddyy');
        user.Email = userMap.get('email');
        user.Username = user.Email + '.' + brand.toLowerCase();
        user.FirstName = userMap.get('first_name');
        user.LastName = userMap.get('last_name');
        user.MobilePhone = userMap.get('mobile');
        user.TimezoneSidKey = 'Australia/Sydney';
        user.Answer__c = userMap.get('security_answer');
        user.Security_Question__c = userMap.get('security_question');
        user.EmailEncodingKey = 'UTF-8';
        user.LanguageLocaleKey = 'en_US';
        user.LocaleSidKey = 'en_US';
        user.ProfileId = !Test.isRunningTest() ? [SELECT Id FROM Profile WHERE Name = :profileName].Id 
                : [SELECT Id FROM Profile WHERE UserType = 'CspLitePortal' LIMIT 1].Id;
        user.Street = userMap.get('street');
        user.City = userMap.get('city');
        user.PostalCode = userMap.get('postal_code');
        user.State = userMap.get('state');
        user.Country = userMap.get('country');
        return user;
  }
    
	/**
	 * @description        create a b2c account
	 * 						 
	 *                          
	 * 
	 * @param               user metadata map, brand name and GUID string
	 * @return              Account      
	 */
    public static Account createAccount( String brand, Map<String,String> userMap, String guidStr){ 
                                            
           Id b2cConsumerContactAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Consumer Contact').getRecordTypeId();
			Boolean subscribetoEmail = Boolean.valueOf(userMap.get('subscribetoEmail'));
        	Boolean subscribetoSMS = Boolean.valueOf(userMap.get('subscribetoSMS'));
        	Boolean hasMarketingCloud = [SELECT COUNT() FROM PackageLicense WHERE NamespacePrefix = 'et4ae5'] > 0;	
        	Account personAccount = new Account();
            personAccount.RecordTypeId = b2cConsumerContactAccRecTypeId;
            personAccount.PersonEmail = userMap.get('email');
            personAccount.FirstName = userMap.get('first_name');
            personAccount.LastName = userMap.get('last_name');
            personAccount.PersonMobilePhone = userMap.get('mobile');
            personAccount.Brand__pc = brand;
            personAccount.Country__pc = userMap.get('country');
            personAccount.PersonMailingCountry = userMap.get('country');
            personAccount.PersonMailingStreet = userMap.get('street');
            personAccount.PersonMailingPostalCode = userMap.get('postal_code');
            personAccount.PersonMailingState = userMap.get('state');
          	personAccount.PersonHasOptedOutOfEmail = !subscribetoEmail;
            personAccount.et4ae5__HasOptedOutOfMobile__pc = !subscribetoSMS;
        	personAccount.Profession__c = userMap.get('profession');
        	personAccount.Onekey_GUID__c = guidStr;
        	if (hasMarketingCloud) {
            	personAccount.et4ae5__HasOptedOutOfMobile__pc = !subscribetoSMS;
        	}
       
            try {
                insert personAccount;   
                personAccount = [select id,name,personcontactid,RecordTypeId from account where id =: personAccount.id];
            } catch (DmlException e) {
                } catch (Exception e) {
         } 
  		return personAccount;
 	  }
    
   /**
	 * @description        Create new user
	 * 						 
	 *                          
	 * 
	 * @param               User profile
	 * @return              User
	 */
   public static User CreateUserNew( User milwaukeeNewUser){                                          
       User newmilwaukeeUser = new User();
       newmilwaukeeUser = milwaukeeNewUser;	
       try {
           insert newmilwaukeeUser;  
       } catch (DmlException e) {
       	} catch (Exception e) {
       } 
  		return newmilwaukeeUser;
 	  } 
    
    
    /**
	 * @description        Create Milwaukee User
	 * 						 
	 *                          
	 * 
	 * @param               auth data,boolean cancreate,brandname,communityprofile,namespace
	 * @return              User
	 */
   public static User createMilwaukeeUser(Auth.UserData data,
                                          Boolean canCreateUser,
                                          String MIL_BRAND,
                                          String MIL_COMMUNITY_PROFILE,String AUTH0_NAMESPACE){ 
         Map<String,String> userMap;                                     
         userMap = Auth0HandlerCommunityUtility.getExternalUserMap(data.attributeMap, AUTH0_NAMESPACE);                                        
          if(!canCreateUser) {
            return Auth0HandlerCommunityUtility.getCommunityUser(userMap.get('email'),MIL_BRAND);
        }else{
            User milwaukeeNewUser = new User();
            Account milwaukeeNewAccount= new Account();
            string guidStr = generateGUID();
            milwaukeeNewUser = getCommunityUser(userMap.get('email'),MIL_BRAND);
            Account existingPersonalAccount = getB2cAccountByEmail(userMap.get('email'));
            if(milwaukeeNewUser == null && existingPersonalAccount == null)
            {      
                milwaukeeNewUser = instantiateUser(MIL_BRAND,userMap,MIL_COMMUNITY_PROFILE);
                milwaukeeNewAccount =createAccount(MIL_BRAND,userMap,guidStr);
            	if(milwaukeeNewAccount!= null){
                    milwaukeeNewUser.ContactId = milwaukeeNewAccount.personcontactid;
                    milwaukeeNewUser =  createUserNew(milwaukeeNewUser);
                }
            }  
            return milwaukeeNewUser;
            }
 	  }    
	/**
	 * @description        Map the user meta data into a map
	 * 						 
	 *                          
	 * 
	 * @param               user metadata map
	 * @return              userMap
	 */
    public static Map<String,String> getExternalUserMap(Map<String,String> dataMap, String auth0Namespace){
    Map<String,String> userMap = new Map<String,String>();
    userMap.put('email', dataMap.containsKey(auth0Namespace+'email') ? dataMap.get(auth0Namespace+'email') : '');
    userMap.put('first_name', dataMap.containsKey(auth0Namespace+'first_name') ? dataMap.get(auth0Namespace+'first_name') : '');
    userMap.put('last_name', dataMap.containsKey(auth0Namespace+'last_name') ? dataMap.get(auth0Namespace+'last_name') : '');
    userMap.put('mobile', dataMap.containsKey(auth0Namespace+'mobile') ? dataMap.get(auth0Namespace+'mobile') : '');
    userMap.put('security_question', dataMap.containsKey(auth0Namespace+'securityQuestion') ? dataMap.get(auth0Namespace+'securityQuestion') : '');
    userMap.put('security_answer', dataMap.containsKey(auth0Namespace+'securityAnswer') ? dataMap.get(auth0Namespace+'securityAnswer') : '');
    userMap.put('locality', dataMap.containsKey(auth0Namespace+'locality') ? dataMap.get(auth0Namespace+'locality') : '');
    userMap.put('street', dataMap.containsKey(auth0Namespace+'street') ? dataMap.get(auth0Namespace+'street') : '');
    userMap.put('postal_code', dataMap.containsKey(auth0Namespace+'postal_code') ? dataMap.get(auth0Namespace+'postal_code') : '');
    userMap.put('state', dataMap.containsKey(auth0Namespace+'state') ? dataMap.get(auth0Namespace+'state') : '');
    userMap.put('city', dataMap.containsKey(auth0Namespace+'city') ? dataMap.get(auth0Namespace+'city') : '');
    userMap.put('country', dataMap.containsKey(auth0Namespace+'country') ? dataMap.get(auth0Namespace+'country') : '');
    userMap.put('subscribetoEmail', dataMap.containsKey(auth0Namespace+'subscribetoEmail') ? dataMap.get(auth0Namespace+'subscribetoEmail') : '');
    userMap.put('subscribetoSMS', dataMap.containsKey(auth0Namespace+'subscribetoSMS') ? dataMap.get(auth0Namespace+'subscribetoSMS') : '');  
    userMap.put('profession', dataMap.containsKey(auth0Namespace+'profession') ? dataMap.get(auth0Namespace+'profession') : '');  
    userMap.put('sfdc_networkid', dataMap.containsKey(auth0Namespace+'sfdc_networkid') ? dataMap.get(auth0Namespace+'sfdc_networkid') : '');
    return userMap;    
    }
	
}