public without sharing class CommunityFooter {
   
    /*
    @AuraEnabled
    public static Community_Settings__c  getCommunitySettings(){
   
		return CommunitySettingsHelper.getSiteSettings(site.getMasterLabel());
		
    }
    */
    
	@AuraEnabled
    public static CommunitySettingsHelperClass.SiteSettingsResult  getSiteSettings(){
  	
        return CommunitySettingsHelperClass.getSiteAndUserSettings(site.getMasterLabel());      
      
    }
}