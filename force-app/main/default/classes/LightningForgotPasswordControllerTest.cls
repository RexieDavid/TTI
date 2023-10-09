/**********************************************************************
 * @author                  Rex Joseph Egoc
 * @date                    2020-08-21
 *
 * @description             Test Class LightningForgotPasswordController
 */
@IsTest
public class LightningForgotPasswordControllerTest {
    
    private static final SiteService service = (SiteService) Test.createStub(SiteService.class, new SiteServiceMocker());
    
    /*
     * @description        forgot password positive test
     */
    @IsTest
    static void positiveForgotPasswordTest() {
        Test.startTest();
            LightningForgotPasswordController.service = service;
            String result = LightningForgotPasswordController.forgotPassword('test@yahoo.com', '/');
        Test.stopTest();
        System.assertEquals('/', result, 'Must match redirect page');
    }
    
    /*
     * @description        forgot password negative test invalid username
     */
    @IsTest
    static void negativeForgotPasswordTestInvalidUserName() {
        String err_message;
        Test.startTest();
            try {
                SiteServiceMocker.hasMockError = true;
                LightningForgotPasswordController.service = service;
                LightningForgotPasswordController.forgotPassword('test', '/');
            } catch (Exception ex) {
                err_message = ex.getMessage();
            }
        Test.stopTest();
        System.assertEquals('Script-thrown exception', err_message, 'Error Message must match');
    }
    
    /*
     * description        forgot password negative test null checkEmailRef
     */
    @IsTest
    static void negativeForgotPasswordTestNullCheckEmailRef() {
        String err_message;
        Test.startTest();
            try {
                LightningForgotPasswordController.service = service;
                LightningForgotPasswordController.forgotPassword('test@yahoo.com', null);
            } catch (Exception e) {
                err_message = e.getMessage();
            }
        Test.stopTest();
        System.assertEquals('Script-thrown exception', err_message, 'Error Message must match');
    }
}