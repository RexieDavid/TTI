@isTest(SeeAllData=false)
public class AssignReferralCodeToUserBatchTest {

    @TestSetup
    static void setupData() {
        UserRole userrole = [Select Id, DeveloperName From UserRole WHERE DeveloperName = 'CEO' Limit 1];
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = '~ CX System Admin' Limit 1];

        User admUser = new User(
            Alias = 'adminu',
            Email = 'adminuser@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = adminProfile.Id,
            UserRoleId = userrole.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testadmin@testing.com'
        );
        insert admUser;

        System.runAs(admUser) {
            Profile custAEGProfile = [
                SELECT Id
                FROM Profile
                WHERE Name = '~Customer Community AEG'
            ];

            Contact con = new Contact(LastName='Testing',FirstName='RAF');
            insert con;

            User custAEGUser = new User(
                Alias = 'raft',
                Email = 'raftest@testorg.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'Testing',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = custAEGProfile.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = 'raftest@testorg.com',
                Referral_Code__c = '',
                ContactId = con.Id
            );
            insert custAEGUser;
        }
    }

    private static testMethod void testExecuteBatch() {

        List<String> profileList = new List<String>{'~Customer Community AEG','~Customer Community AEG NZ'};
        String profileNameInSOQL='';
        for(String profile: profileList){
            profileNameInSOQL += 'Profile.Name =\'' +  profile + '\' or ';
        }
        profileNameInSOQL = profileNameInSOQL.substringBeforeLast(' or ');
        String soql = 'SELECT Id,name,Referral_Code__c FROM User WHERE ('+profileNameInSOQL+') and Referral_Code__c =\'\' LIMIT 1';
        
        Test.StartTest();
            AssignReferralCodeToUserBatch batch = new AssignReferralCodeToUserBatch(soql);
            Database.executebatch(batch, 1);
        Test.stopTest(); 

        User custAEGUserWithRef = [SELECT Id, Name, Email, Referral_Code__c FROM User WHERE Referral_Code__c != '' LIMIT 1];
        System.assertNotEquals(custAEGUserWithRef,null, 'Blank referral code'); 
        
    }
    
}