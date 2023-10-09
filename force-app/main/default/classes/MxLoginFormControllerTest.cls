/**********************************************************************
 * @author                  Francis Nasalita
 * @date                    2020-07-08
 *
 * @description             Test class for MX Login Form Controller
 */
@isTest
public class MxLoginFormControllerTest {
    
    private static final MxSiteService service = (MxSiteService) Test.createStub(MxSiteService.class, new MxSiteServiceMocker());

    @IsTest
    static void positiveLoginTest() {
        MxLoginFormController.service = service;
        Test.startTest();
            String url = MxLoginFormController.login('milwaukee.agentplus', 'Thinkas1!', '/');
        Test.stopTest();
        // assert
        System.assertEquals('https://testurl.com', url, 'Invalid url.');
    }

    @IsTest
    static void negativeLoginTest() {
        String error_message = '';
        MxLoginFormController.service = service;
        
        Test.startTest();
            try {
                MxSiteService.hasMockError = True;
                MxLoginFormController.login('milwaukee.agentplus', 'Thinkas1!', '/');
            } catch(Exception ex) {
                 error_message = ex.getMessage();
            }
        Test.stopTest();
     	
        // assert
        System.assertEquals('Script-thrown exception', error_message, 'Resulting error message must match the default.');
    }
}