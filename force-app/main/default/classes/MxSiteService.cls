/**********************************************************************
 * @author                  Francis Nasalita
 * @date                    2020-07-10
 *
 * @description             Site Service
 */
public class MxSiteService {

    private final String DOMAIN = '@mxagent.milwaukeetool.com.au';

    public static Boolean hasMockError;
    
    public String password { get; set; }
    public String startUrl { get; set; }
    public String username { 
        get {
            return username;
        }
        set {
            username = value + DOMAIN;
        }
    }

    public Pagereference login() {
        return Test.isRunningTest() ? new Pagereference('/') : Site.login(username, password, startUrl);
    }

    public Boolean forgotPassword() {
        return Test.isRunningTest() ? hasMockError : Site.forgotPassword(username);
    }

    public class MxSiteServiceException extends Exception {}
}