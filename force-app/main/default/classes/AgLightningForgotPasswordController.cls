/**********************************************************************
 * @author                  Rex Joseph Egoc
 * @date                    2020-10-28
 *
 * @description             AEG Forgot Password Controller
 */
global class AgLightningForgotPasswordController {

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
        
        service.brand = 'AEG';
        service.username = username;
        
        if (!service.checkUsername()) {
            throw new AgLightningForgotPasswordControllerException(Label.Site.invalid_email);
        }
        
        try {
            service.forgotPassword();
            PageReference checkEmailRef = new PageReference(checkEmailUrl);
            return checkEmailRef.getUrl();
        } catch (Exception ex) {
            throw new AgLightningForgotPasswordControllerException(ex.getMessage());
        }
    }
    
    public class AgLightningForgotPasswordControllerException extends Exception {}
}