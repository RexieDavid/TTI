public class TTIBrandsHelperClass {

    @AuraEnabled
    public static String getNewReplenishmentButton() {
        TTIBrandsSiteSettings__c settings = TTIBrandsSiteSettings__c.getInstance();
        if(settings.NewReplenishmentButtonURL__c != null && settings.NewReplenishmentButtonURL__c != '') {
            return settings.NewReplenishmentButtonURL__c;
        }
        return null;
    }

    @AuraEnabled
    public static String getTableMaxRecords() {
        TTIBrandsSiteSettings__c settings = TTIBrandsSiteSettings__c.getInstance();
        if(settings.Case_Lists_No_Records_to_Display__c != null && settings.Case_Lists_No_Records_to_Display__c != '') {
            return String.valueOf(settings.Case_Lists_No_Records_to_Display__c);
        }
        return null;    	
    }
}