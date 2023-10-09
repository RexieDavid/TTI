/**********************************************************************
 * @author                  Rex Joseph Egoc
 * @date                    2020-10-28
 *
 * @description             Test Class AEG Forgot Password Controller
 */
@IsTest
public class AgLightningForgotPasswordControllerTest {
    
    private static final SiteService service = (SiteService) Test.createStub(SiteService.class, new SiteServiceMocker());
    
    /*
     * @description        forgot password positive test
     */
    @IsTest
    static void positiveForgotPasswordTest() {
        Test.startTest();
            SiteServiceMocker.hasMockError = false;
            AgLightningForgotPasswordController.service = service;
            String result = AgLightningForgotPasswordController.forgotPassword('test@yahoo.com', '/');
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
                AgLightningForgotPasswordController.service = service;
                AgLightningForgotPasswordController.forgotPassword('test', '/');
            } catch (Exception ex) {
                err_message = ex.getMessage();
            }
        Test.stopTest();
        System.assertEquals('Invalid Email Address', err_message, 'Error Message must match');
    }
    
    /*
     * description        forgot password negative test null checkEmailRef
     */
    @IsTest
    static void negativeForgotPasswordTestNullCheckEmailRef() {
        String errMessage;
        Test.startTest();
            try {
                AgLightningForgotPasswordController.forgotPassword('test@yahoo.com', null);
            } catch (Exception e) {
                errMessage = e.getMessage();
            }
        Test.stopTest();
        System.assertEquals('Argument 1 cannot be null', errMessage, 'Error Message must match');
    }
}