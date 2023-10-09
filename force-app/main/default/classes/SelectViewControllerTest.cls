/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class SelectViewControllerTest {

    static testMethod void myUnitTest() {
        SelectViewController s = new SelectViewController();
        
        System.RunAs(getNewUser('System Administrator', 'INDAM - NAT - MGR', 'testAut@gmail.com')){
            s.selectViewPageRef();          
        }
        
        System.RunAs(getNewUser('System Administrator', 'CEO', 'testAut6@gmail.com')){
            s.selectViewPageRef();          
        }
        
    }
    
     public static User getNewUser(String profileName, String roleName, String userName) {  

         /* Get any profile for the given type.*/ 

         Profile p = [select id   

                       from Profile   

                      where Name = :profileName  

                      limit 1]; 
                      
           System.assert(p!=null);    
                      
          UserRole ur = [select id   

                       from UserRole   

                      where Name = :roleName  

                      limit 1];   
                      
          System.assert(ur!=null);

        //String testemail = 'puser000@amamama.com';  

         User pu = new User(profileId = p.id, username = userName, email = userName,   

                            emailencodingkey = 'UTF-8', localesidkey = 'en_US',   

                           languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles',   

                            alias='cspu', lastname='lastname', UserRoleId = ur.id);  

         insert(pu); 
         
          System.assert(pu!=null);

         return pu;  

     }  
    
}