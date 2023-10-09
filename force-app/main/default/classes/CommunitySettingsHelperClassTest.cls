@IsTest
public class CommunitySettingsHelperClassTest {    
    @testSetup
    private static void testSetup() {
        Community_Settings__c cs = new Community_Settings__c();
        cs.Name = 'CommonSettings';
        cs.ToolboxDisplayStatus__c = 'Confirmed';
        cs.RecieptSourceMapping__c  = 'Bunnings;Bunnings;Other;Other';
        cs.PurchasedFromMapping__c  = 'Bunnings;Retailer - Bunnings;Others;Retailer - Other';
        cs.RemoveReasonMapping__c = 'I sold the tool;Sold;My tool was replaced;Replaced;My tool was refunded;Refunded;MyTool was stolen;Stolen;My tool broke;Faulty;I gave my tool away as a gift;Gifted;Incorrect product selected;Incorrect;Other reason;Other';
        insert cs;

        Community_Settings__c csRb = new Community_Settings__c();
        csRb.Brand__c = 'Ryobi';
        csRb.ProductBrand__c = 'RY';
        csRb.Australia_Country__c ='Australia';
        csRb.Name = 'myRyobi';
        csRb.ProductSelectionIntialCategories__c = 'Outdoor,Power Tools,Accessories';
        insert csRb;
    }
    
    private static testMethod void getToolboxStatuses_Test() {
        CommunitySettingsHelperClass.getToolboxStatuses();
    }

    private static testMethod void getAssetCreateStatus_Test() {
        CommunitySettingsHelperClass.getAssetCreateStatus();
    }

    private static testMethod void getAssetRemoveStatus_Test() {
        CommunitySettingsHelperClass.getAssetRemoveStatus();
    }

    private static testMethod void getAssetDefaultIdentifiedBy_Test() {
        CommunitySettingsHelperClass.getAssetDefaultIdentifiedBy();
    }

    private static testMethod void getAssetDefaultWarrantyStatus_Test() {
        CommunitySettingsHelperClass.getAssetDefaultWarrantyStatus();
    }

    private static testMethod void getRemoveAssetReasons_Test() {
        CommunitySettingsHelperClass.getRemoveAssetReasons();
    }

    private static testMethod void mapRemoveAssetReasons_Test() {
        CommunitySettingsHelperClass.mapRemoveAssetReasons('Sold');
    }
    
    private static testMethod void mapPurchasedFROM_Test() {
        CommunitySettingsHelperClass.mapPurchasedFROM('Promotion');
    }

    private static testMethod void mapReceiptSource_Test() {
        CommunitySettingsHelperClass.mapReceiptSource('Other');
    }

    private static testMethod void getSiteSettings_Test() {
        CommunitySettingsHelperClass.getSiteSettings('myRyobi');
    }

    private static testMethod void getValuesByNames_Test() {
        List<string> n = new List<string>{'Brand__c', 'ProductBrand__c', 'Lead_Source__c'};
        CommunitySettingsHelperClass.getValuesByName('myRyobi', n);
    }
    
    private static testMethod void getSiteAndUserSettings_Test() {
        UserRole role = [Select Id From UserRole WHERE DeveloperName = 'CEO' LIMIT 1];
        Profile sysAd = [Select Id from Profile where Name  = '~System Administrator' Limit 1];
        User sysAdUser = new User(
            UserRoleId = role.Id,
            ProfileId = sysAd.Id,
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            FirstName = 'systemadd321',
            LastName = 'systemadd321',
            Username = 'systemadd321@appirio.com.ryobi',
            CommunityNickname = 'systemadd321',
            Alias = 'syst321',
            Email = 'systemadd321@email.com',
            IsActive = true
        );

        insert sysAdUser;

        System.runAs(sysAdUser) {
            RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND isActive = TRUE AND DeveloperName = 'PersonAccount' LIMIT 1];
            Account acc = TestUtilityClass.createPersonAccount(1)[0];
            acc.Registration_complete__c = false;
            insert acc;
            
            Contact c = [SELECT Id FROM Contact WHERE AccountID =:acc.Id];
            
            Profile profile1 = [SELECT Id FROM Profile WHERE UserType  = 'CspLitePortal' LIMIT 1];
            User portalUser = new User(
                ProfileId = profile1.Id,
                Username = 'tes543t@yahoo.com.Ryobi',
                Alias = 'bat543',
                Email='test543@yahoo.com',
                EmailEncodingKey='UTF-8',
                Firstname='Bruce345',
                Lastname='Wayne543',
                LanguageLocaleKey='en_US',
                LocaleSidKey='en_US',
                TimeZoneSidKey='America/Chicago',
                ContactId = c.Id
            );
            Database.insert(portalUser);
        }            

        CommunitySettingsHelperClass.getSiteAndUserSettings('myRyobi');
    }
}