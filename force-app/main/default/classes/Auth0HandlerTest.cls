/**
 * Auth0Handler TEST class
 * 
 **/
@isTest
public class Auth0HandlerTest {
    
    /**
   	 * This method is used to set up the test data
   	 * 
   	 **/
    @testSetup static void setUpTestData() { 
    User testNewUser = new User();
    Account testNewAccount= new Account();
    String auth0Namespace= 'https://Salesforce_Custom_Claim/';
    String guidStr = Auth0HandlerCommunityUtility.generateGUID();
    Map<String,String> testattributeMap = setAuthData('testusercheck@test.com','testcheckFirstName','testcheckLastName').attributeMap;
    Map<String,String> testMap = Auth0HandlerCommunityUtility.getExternalUserMap(testattributeMap,auth0Namespace);
    testNewUser = Auth0HandlerCommunityUtility.instantiateUser('Milwaukee',testMap,'~Customer Community Milwaukee');
    testNewAccount = Auth0HandlerCommunityUtility.createAccount('Milwaukee',testMap,guidStr);
    if(testNewAccount!= null){
       testNewUser.ContactId = testNewAccount.personcontactid;
       testNewUser =  Auth0HandlerCommunityUtility.createUserNew(testNewUser);
     }
    }

     
   	/**
   	 * This method is used to test canCreateUser method in handler class
   	 * 
   	 **/ 
    testmethod public static void testCanCreateUser() {
    Auth0Handler auth0handler = new Auth0Handler ();
	Auth.UserData sampleAuthData = setAuthData('testuser1@test.com','test1FirstName','test1LastName');
    System.Assert(auth0handler.canCreateUser(sampleAuthData),'Handler should be able to create this user');
   	}
    
    /**
   	 * This method is used to test cannot create user scenario in handler class
   	 * 
   	 **/ 
    testmethod public static void testCannotCreateUser() {
    Auth0Handler auth0handler = new Auth0Handler ();
	Auth.UserData sampleAuthData = setAuthData('testusercheck@test.com','testcheckFirstName','testcheckLastName');
    System.Assert(!auth0handler.canCreateUser(sampleAuthData),'Handler should not be able to create this user');
   	}
    
    /**
   	 * This method is used to check if the user if from different community network
   	 * 
   	 **/ 
    testmethod public static void testDifferentCommunityNetworkId() {
    Auth0Handler auth0handler = new Auth0Handler ();
    String auth0Namespace= 'https://Salesforce_Custom_Claim/';
    Auth.UserData sampleAuthData = setAuthData('testuser3@test.com','test3FirstName','test3LastName');
    sampleAuthData.attributeMap.put(auth0Namespace + 'sfdc_networkid', '0DB90000000TP4wGAG');
    Test.startTest();
    User createdUser = auth0handler.createUser(null, sampleAuthData);
    Test.stopTest();
    System.Assert(createdUser==null,'User must be null');
    }
    
   /**
   	 * This method is used to test createUser method in handler class
   	 * 
   	 **/ 
    testmethod public static void testCreateUser() {
    Auth0Handler auth0handler = new Auth0Handler ();
    Auth.UserData sampleAuthData = setAuthData('testuser3@test.com','test3FirstName','test3LastName');
    Test.startTest();
    User createdUser = auth0handler.createUser(null, sampleAuthData);
    Test.stopTest();
    validateUser(createdUser,sampleAuthData); 
    }
    
    /**
   	 * This method is used to test the updateUser method in handler class
   	 * 
   	 **/ 
    testMethod public static void testUpdateUser() {
    Auth0Handler auth0handler = new Auth0Handler ();
    Auth.UserData sampleAuthData = setAuthData('testusercheck@test.com','testcheckFirstName','testcheckLastName');
    User createdUser = auth0handler.createUser(null, sampleAuthData);
    Test.startTest(); 
    Auth.UserData updatedAuthData = setAuthData('testusercheck@test.com','UpdatedcheckFirstName','testcheckLastName');
    auth0handler.updateUser(createdUser.id, null, updatedAuthData);
    User theUpdatedUser = [SELECT Id,firstName,Email,LastName from User Where Id = :createdUser.id];
    validateUser(theUpdatedUser,updatedAuthData);
    Test.stopTest();
    }
    
    /**
     * Validate the the User we've created
     * 
     **/ 
    private static void validateUser(User createdUser, Auth.UserData data) {
        System.Assert(createdUser!=null,'User must not be null');
        System.AssertEquals(createdUser.email,data.email,'Email address must be the same');
        System.AssertEquals(createdUser.FirstName,data.FirstName,'First name must match');
        System.AssertEquals(createdUser.LastName,data.LastName,'Last name must match');
    }
    
    /**
     * Set the sample Auth data values for testing
     * 
     * 
     * @param               Email, First name and Last name
	 * @return              Auth.Userdata setup 
     * 
     **/ 
    private static Auth.UserData setAuthData(String email,String firstName, String lastName) {
    Map<String,String> attributeMap = new Map<String,String>();
    String auth0Namespace= 'https://Salesforce_Custom_Claim/';
    attributeMap.put(auth0Namespace +'email', email);
    attributeMap.put(auth0Namespace + 'first_name', firstName);
    attributeMap.put(auth0Namespace + 'last_name', lastName);
    attributeMap.put(auth0Namespace + 'mobile', '9874587455');
    attributeMap.put(auth0Namespace + 'security_question', 'Question?');
    attributeMap.put(auth0Namespace + 'security_answer', 'Answer');
    attributeMap.put(auth0Namespace + 'street', 'Station Street');
    attributeMap.put(auth0Namespace + 'postal_code', '3000');
    attributeMap.put(auth0Namespace + 'state','Victoria');
    attributeMap.put(auth0Namespace + 'country', 'Australia');
    attributeMap.put(auth0Namespace + 'sfdc_networkid', '0DB2e000000005pGAA');
    return new Auth.UserData(lastName+System.currentTimeMillis(), firstName , lastName,
                                                     '' , email, '' , firstName + 'username' , 'en_US' , '' ,'' , attributeMap);
    }
}