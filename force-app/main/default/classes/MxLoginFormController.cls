/**********************************************************************
 * @author                  Francis Nasalita
 * @date                    2020-07-08
 *
 * @description             Controller for MX Login Form
 */
public class MxLoginFormController {
    
    @TestVisible
    private static MxSiteService service = new MxSiteService();

/**********************************************************************
    * @description             Will login the user with provided username
    *                          and password
    * 
    * @param  username         
    * @param  password         
    * @param  startUrl         Page where the customer will be redirected
    * @return                  String url from the Site.login Pagereference
    * 
    * @example
    * login('milwaukee.agentplus', 'Thinkas1!', '/')
    */
    @AuraEnabled
    public static String login(String username, String password, String startUrl) {
        try {
            service.username = username;
            service.password = password;
            service.startUrl = startUrl;

            return service.login().getUrl();
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        
    }
    
    public class MxLoginFormControllerException extends Exception {}
}