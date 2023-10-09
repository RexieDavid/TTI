/**
* @author: Jacob Peterson (Accenture)
* @date: March 2017
* @description: Helper functions for common community settings
*/ 
public class CommunitySettingsHelperClass {

    /**
    * @author: Jacob Peterson
    * @date: March 2017
    * @description: To be honest, I don't know what this method is doing
    */ 
    public static List<String> getToolboxStatuses() {
        return Community_Settings__c.getValues('CommonSettings').ToolboxDisplayStatus__c.split(',');
    }

    /**
    * @author: Jacob Peterson
    * @date: March 2017
    * @description: To be honest, I don't know what this method is doing
    */ 
    public static String getAssetCreateStatus() {
        return Community_Settings__c.getValues('CommonSettings').AssetCreateStatus__c  ;
    }

    /**
    * @author: Jacob Peterson
    * @date: March 2017
    * @description: To be honest, I don't know what this method is doing
    */ 
    public static String getAssetRemoveStatus() {
        return Community_Settings__c.getValues('CommonSettings').AssetRemoveStatus__c ;
    }

    /**
    * @author: Jacob Peterson
    * @date: March 2017
    * @description: To be honest, I don't know what this method is doing
    */ 
    public static String getAssetDefaultIdentifiedBy() {
        return Community_Settings__c.getValues('CommonSettings').DefaultIdentifiedBy__c ;
    }

    /**
    * @author: Jacob Peterson
    * @date: March 2017
    * @description: To be honest, I don't know what this method is doing
    */ 
    public static String getAssetDefaultWarrantyStatus() {
        return Community_Settings__c.getValues('CommonSettings').DefaultWarrantyStatus__c ;
    }

    /**
    * @author: Jacob Peterson
    * @date: March 2017
    * @description: To be honest, I don't know what this method is doing
    */ 
    public static List<String> getRemoveAssetReasons() {
        return getDisplayValues(Community_Settings__c.getValues('CommonSettings').RemoveReasonMapping__c);
    }

    /**
    * @author: Jacob Peterson
    * @date: March 2017
    * @description: To be honest, I don't know what this method is doing
    */ 
    public static String mapRemoveAssetReasons(String selectedValue) {
        return mapDisplayValue(selectedValue,Community_Settings__c.getValues('CommonSettings').RemoveReasonMapping__c);
    }

    /**
    * @author: Jacob Peterson
    * @date: March 2017
    * @description: To be honest, I don't know what this method is doing
    */ 
     public static String mapPurchasedFrom(String selectedValue) {
        return mapDisplayValue(selectedValue,Community_Settings__c.getValues('CommonSettings').PurchasedFromMapping__c);
    }

    /**
    * @author: Jacob Peterson
    * @date: March 2017
    * @description: To be honest, I don't know what this method is doing
    */ 
    public static String mapReceiptSource(String selectedValue) {
        return mapDisplayValue(selectedValue,Community_Settings__c.getValues('CommonSettings').RecieptSourceMapping__c  );
    }

    /**
    * @author: Jacob Peterson
    * @date: March 2017
    * @description: To be honest, I don't know what this method is doing
    */ 
    public static Community_Settings__c getSiteSettings(String siteName) {
        if(Test.isRunningTest()) {
            return Community_Settings__c.getValues('myAEG');
        } else {
            return Community_Settings__c.getValues(siteName);
        }
    }

    /**
    * @author: Jacob Peterson
    * @date: March 2017
    * @description: To be honest, I don't know what this method is doing
    */ 
    public static SiteSettingsResult getSiteAndUserSettings(String siteName) {
        SiteSettingsResult result = new SiteSettingsResult();
        result.communitySettings = CommunitySettingsHelperClass.getSiteSettings(Site.getMasterLabel());
        User currentUser = [SELECT Id, ContactId, Contact.AccountId, Contact.Country__c, Contact.account.Registration_complete__c FROM User WHERE Id = :UserInfo.getUserId()];

        if (currentUser.Contact.Country__c != null ) {
            result.userCountry = currentUser.Contact.Country__c;
        }

        return result;
    }

    /**
    * @author: Jacob Peterson
    * @date: March 2017
    * @description: To be honest, I don't know what this method is doing
    */ 
    public static Map<String,String> getValuesByName(String siteName, List<String> fieldnames) {
        Map<String, String> returnValues = new Map<String, String>();
        Community_Settings__c settings = Community_Settings__c.getValues(siteName);

        for (String n : fieldnames) {
            returnvalues.put(n, String.valueOf(settings.get(n)));
        }
        return returnValues;
    }

    /**
    * @author: Jacob Peterson
    * @date: March 2017
    * @description: To be honest, I don't know what this method is doing
    */ 
    private static List<String> getDisplayValues(String value) {
        List<String> values =  value.split(';') ;
        List<String> returnValues = new List<String>();

        for (Integer i = 0; i < values.size(); i ++) {
            if (Math.mod(i, 2) == 0) {
                returnValues.add(values[i]);
            }
        }
        return returnValues;
    }

    /**
    * @author: Jacob Peterson
    * @date: March 2017
    * @description: To be honest, I don't know what this method is doing
    */ 
    private static String mapDisplayValue(String matchvalue, String values) {
        List<String> v = values.split(';') ;
        String returnValue;

        for (Integer i = 0; i < v.size(); i ++) {
            if (matchvalue.equals(v[i])) {
                System.debug('JAC v: ' + v[i]);
                System.debug('JAC v1: ' + v[i + 1]);
                returnValue = v[i + 1];
                break;
            }
        }
        return returnValue;
    }

    /**
    * @author: Jacob Peterson
    * @date: March 2017
    * @description: Wrapper class for Site Settings
    */ 
    public class SiteSettingsResult {

        @AuraEnabled
        public Community_Settings__c communitySettings;

        @AuraEnabled
        public String userCountry;

        public SiteSettingsResult() {

        }
    }
}