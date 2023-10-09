/**********************************************************************
 * @author                  Rex Joseph Egoc
 * @date                    2020-08-21
 *
 * @description             Test Class LightningForgotPasswordController
 */
global class LightningForgotPasswordController {

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

        try {
            service.username = username;
            if (!service.checkUsername()) {
                throw new LightningForgotPasswordControllerException(Label.Site.invalid_email);
            } else {
                service.forgotPassword();
            }

            PageReference checkEmailRef = new PageReference(checkEmailUrl);
            return checkEmailRef.getUrl();
      
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    public class LightningForgotPasswordControllerException extends Exception {}
}