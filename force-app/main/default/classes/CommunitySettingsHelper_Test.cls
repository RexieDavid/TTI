@IsTest(SeeAllData = true)
public class CommunitySettingsHelper_Test {
    
    static testMethod void getToolboxStatuses_Test() {
     	
        CommunitySettingsHelperClass.getToolboxStatuses();
    }
    static testMethod void getAssetCreateStatus_Test() {
     	
        CommunitySettingsHelperClass.getAssetCreateStatus();
    }
    static testMethod void getAssetRemoveStatus_Test() {
     	
        CommunitySettingsHelperClass.getAssetRemoveStatus();
    }
    static testMethod void getAssetDefaultIdentifiedBy_Test() {
     	
        CommunitySettingsHelperClass.getAssetDefaultIdentifiedBy();
    }
    static testMethod void getAssetDefaultWarrantyStatus_Test() {
     	
        CommunitySettingsHelperClass.getAssetDefaultWarrantyStatus();
    }
    static testMethod void getRemoveAssetReasons_Test() {
     	
        CommunitySettingsHelperClass.getRemoveAssetReasons();
    }
    static testMethod void mapRemoveAssetReasons_Test() {
     	
        CommunitySettingsHelperClass.mapRemoveAssetReasons('Sold');
    }
    
    static testMethod void mapPurchasedFrom_Test() {
     	
        CommunitySettingsHelperClass.mapPurchasedFrom('Promotion');
    }
    static testMethod void mapReceiptSource_Test() {
     	
        CommunitySettingsHelperClass.mapReceiptSource('Other');
    }
    static testMethod void getSiteSettings_Test() {
     	
        CommunitySettingsHelperClass.getSiteSettings('myRyobi');
    }
    static testMethod void getValuesByNames_Test() {
     	 List<string> n = new List<string>{'Brand__c','ProductBrand__c','Lead_Source__c'};
        CommunitySettingsHelperClass.getValuesByName('myRyobi', n);
    }
    
    static testMethod void getSiteAndUserSettings_Test() {
        UserRole portalRole = [SELECT Id FROM UserRole WHERE PortalType = 'None' LIMIT 1];
        Profile profId = [SELECT Id FROM PROFILE WHERE Name = 'System Administrator' LIMIT 1];

        User user1 = new User(UserRoleId = portalRole.Id,
                                ProfileId = profId.Id,
                                Username = System.now().millisecond() + 'test23@test.com',
                                Alias = 'batman',
                                Email='bruce.wayne@ttibrands.com',
                                EmailEncodingKey='UTF-8',
                                Firstname='Bruce',
                                Lastname='Wayne',
                                LanguageLocaleKey='en_US',
                                LocaleSidKey='en_US',
                                TimeZoneSidKey='America/Chicago');
        insert user1;

        System.runAs (user1) {
            RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND isActive = TRUE AND DeveloperName = 'PersonAccount' LIMIT 1];
            Account acc = TestUtilityClass.createPersonAccount(1)[0];
            acc.Registration_complete__c = false;
            insert acc;
            
            contact c = [Select Id FROM Contact Where AccountID =:acc.Id];
            
            Profile profile1 = [Select Id from Profile where UserType  = 'CspLitePortal' Limit 1];
            User portalUser = new User(
                //UserRoleId = portalRole.Id,
                ProfileId = profile1.Id,
                Username = 'test@yahoo.com.Ryobi1',
                Alias = 'batman1',
                Email='test@yahoo.com1',
                EmailEncodingKey='UTF-8',
                Firstname='Bruce1',
                Lastname='Wayne1',
                LanguageLocaleKey='en_US',
                LocaleSidKey='en_US',
                TimeZoneSidKey='America/Chicago',
                ContactId = c.Id
            );

            Database.insert(portalUser);
        }
        
 	
        //system.runAs(portalUser){
       // userinfo.getUserId();
            CommunitySettingsHelperClass.getSiteAndUserSettings('myRyobi');
        //}
        
    }


}