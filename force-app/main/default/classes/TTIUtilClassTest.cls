@isTest
private class TTIUtilClassTest {

    private static testMethod void testTTIFormRecTypes() {
        Country_Codes__c ccNz = new Country_Codes__c();
        ccNz.country_ABV__c = 'NZ';
        ccNz.country_code__c = '+64';
        ccNz.country_name__c = 'New Zealand';
        ccNz.Name = 'New Zealand';
        insert ccNz;

        Country_Codes__c ccAu = new Country_Codes__c();
        ccAu.country_ABV__c = 'AU';
        ccAu.country_code__c = '+61';
        ccAu.country_name__c = 'Australia';
        ccAu.Name = 'Australia';
        insert ccAu;
	
        TTIUtilClass.findObjectNameFromRecordIdPrefix('001');
        TTIUtilClass.periods.get('Current');
        TTIUtilClass.getRecordTypeId('Account', 'B2C Consumer Contact');
        TTIUtilClass.getRecordTypeId('Account');
        TTIUtilClass.formatPhoneNumberByCountry('09369576078', 'Australia');
        TTIUtilClass.formatPhoneNumberByCountry('+619369576078', 'NZ');
        TTIUtilClass.getPicklistValuesToList('Account', 'Brand__pc');
        TTIUtilClass.getBrandCurrentUser();
        TTIUtilClass.readFieldSetToList('Active_Redemptions', 'Redemptions__c');
        TTIUtilClass.constructFieldsFromFieldSet('Complete_Redemptions', 'Redemptions__c');
        TTIUtilClass.constructSOQLQuery('Active_Redemptions', 'Redemptions__c', 'Count__c > 0', 1000, 'Count__c', true, false);
        TTIUtilClass.constructSOQLQuery('Complete_Redemptions', 'Redemptions__c', 'Count__c > 0', 500, null, false, true);
        TTIUtilClass.constructSOQLQuery('Complete_Redemptions', 'Redemptions__c', 'Count__c > 0', 200, 'Count__c', false, true);
    }

}