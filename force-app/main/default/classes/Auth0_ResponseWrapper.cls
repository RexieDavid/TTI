public class Auth0_ResponseWrapper {
    
    public String created_at;
    public String email;
    public Boolean email_verified;
    public List<Identities> identities;
    public String name;
    public String nickname;
    public String picture;
    public String updated_at;
    public String user_id;
    public User_metadata user_metadata;
    public String last_login;
    public String last_ip;
    public Integer logins_count;
    public App_metadata app_metadata;
    
    public class App_metadata {
        public String legacy_user_id;
        public String salesforce_accountId;
        public String salesforce_contactid;
        public String salesforce_guid;
        public String salesforce_user_id;
    }

    public class User_metadata {
        public String first_name;
        public String last_name;
        public String country;
        public String mobile;
        public String profession;
        public String industry;
        public String employmenttype;
        public String email_subscribe;
        public String sms_subscribe;
    }

    public class Identities {
        public String user_id;
        public String provider;
        public String connection;
        public Boolean isSocial;
    }
}