/**********************************************************************
 * @author                  Francis Nasalita
 * @date                    2020-07-13
 *
 * @description             Test class for MX Forgot Password Controller
 */
@isTest
public class MxForgotPasswordControllerTest {
    
    private static final MxSiteService service = (MxSiteService) Test.createStub(MxSiteService.class, new MxSiteServiceMocker());

    @IsTest
    static void positiveForgotPasswordTest() {
        MxForgotPasswordController.service = service;
        Test.startTest();
            String url = MxForgotPasswordController.forgotPassword('milwaukee.agentplust', '/');
        Test.stopTest();

        System.assertEquals('/', url, 'Invalid Url.');
    }

    @IsTest
    static void negativeForgotPasswordTest() {
        MxForgotPasswordController.service = service;
        String errorMessage = '';

        Test.startTest();
        try {
            MxSiteService.hasMockError = true;
            MxForgotPasswordController.forgotPassword('milwaukee.agentplust', '/');
        } catch (Exception e) {
            errorMessage = e.getMessage();
        }
        Test.stopTest();
        
        System.assertEquals('Script-thrown exception', errorMessage, 'Resulting error message must match the default.');
    }
}