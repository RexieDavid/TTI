/**********************************************************************
 * @author                  Francis Nasalita
 * @date                    2020-07-13
 *
 * @description             Test class for MX Site Service Class
 */
@isTest
public class MxSiteServiceTest {
    
    @IsTest
    static void testLogin() {
        
        Test.startTest();
        MxSiteService siteService = new MxSiteService();
        siteService.username = 'milwaukee.agentplus';
        siteService.password = 'Thinkas1!';
        siteService.startUrl = '/';

        Pagereference pageRef = siteService.login();
        Test.stopTest();

        // assert
        System.assertEquals('/', pageRef.getUrl(), 'Invalid url.');
    }
    
    @IsTest
    static void testForgotPassword() {
        
        Test.startTest();
        MxSiteService siteService = new MxSiteService();
        siteService.username = 'milwaukee.agentplus';
        
        MxSiteService.hasMockError = true;
        Boolean isResetSuccessful = siteService.forgotPassword();
        Test.stopTest();
        
        System.assert(isResetSuccessful, 'The password should be successfully reset.');
    }

}