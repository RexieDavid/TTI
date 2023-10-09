/**********************************************************************
 * @author                  Francis Nasalita
 * @date                    2020-07-10
 *
 * @description             Controller for MX Forgot Password
 */
public class MxForgotPasswordController {

    @TestVisible
    private static MxSiteService service = new MxSiteService();
    /**********************************************************************
    * @description             Will reset the user's password 
    * 
    * @param  username
    * @param  checkEmailUrl    Confirmation page
    * @return                  String url from the Site.login Pagereference
    * 
    * @example
    * login('milwaukee.agentplus', './')
    */
    @AuraEnabled
    public static String forgotPassword(String username, String checkEmailUrl) {
        try {
            service.username = username;
            service.forgotPassword();

            return new PageReference(checkEmailUrl).getUrl();
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    public class MxForgotPasswordControllerException extends Exception {}
}