/**********************************************************************
 * @author                  Rex Joseph Egoc
 * @date                    2020-10-28
 *
 * @description             Ryobi Forgot Password Controller
 */
global class RyLightningForgotPasswordController {
    
    @TestVisible
    private static SiteService service = new SiteService();
    
    /*
     * @description                       for password reset
     * 
     * @params        username            email for password reset
     *                checkEmailUrl       page to redirect after password reset
     */
    @AuraEnabled
    public static String forgotPassword(String username, String checkEmailUrl) {

        service.brand = 'Ryobi';
        service.username = username;
        
        if (!service.checkUsername()) {
            throw new RyLightningForgotPasswordControllerException(Label.Site.invalid_email);
        }
        
        try {
            service.forgotPassword();
            PageReference checkEmailRef = new PageReference(checkEmailUrl);
            return checkEmailRef.getUrl();
        } catch (Exception ex) {
            throw new RyLightningForgotPasswordControllerException(ex.getMessage());
        }
    }
    
    public class RyLightningForgotPasswordControllerException extends Exception {}
}