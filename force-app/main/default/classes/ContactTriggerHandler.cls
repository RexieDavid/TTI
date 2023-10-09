/**
 * @author:                         Jerome Liwanag
 * @date:                           Sep 2017  
 * @description:                    This class handles all CRUD operations for the
 *                                  Contact Trigger. All logic should be placed here and not in the
 *                                  trigger itself
*/ 
public class ContactTriggerHandler {
    /**
    * @author: Jerome Liwanag
    * @date: Sep 2017
    * @description: This method handles all on Before Insert
    * functionalities of the Contact
    */ 
    public static void onBeforeInsert(List<Contact> newContacts) {
        changePhoneNumberFormat(newContacts);
    }
    
    /**
    * @author: Jerome Liwanag
    * @date: Sep 2017
    * @description: This method handles all on Before Insert
    * functionalities of the Contact
    */ 
    public static void onBeforeUpdate(List<Contact> newContacts, Map<Id,Contact> oldContactsMap) {
        changePhoneNumberFormat(newContacts);
    }
    
    /**
    * @author: Jerome Liwanag
    * @date: Sep 2017
    * @description: This method handles all on After Insert
    * functionalities of the Contact
    */ 
    public static void onAfterInsert(List<Contact> newContacts) {
        // assignContactToCase(newContacts);
    }
    
    
    /**
    * @author: Jerome Liwanag
    * @date: Sep 2017
    * @description: This method handles the changing of
    * phone number format from '0' to international format
    */ 
    public static void changePhoneNumberFormat(List<Contact> conList) {
        Map<String, Country_Codes__c> countryCodesSettings = Country_Codes__c.getAll();
        Map<String, Country_Codes__c> countryCodesMap = new Map<String, Country_Codes__c>();
        String country = '';
        Set<Id> accIds = new Set<Id>();
        for (Contact conLoop : conList) {
            if(conLoop.accountId != null){
                accIds.add(conLoop.accountId);
            }
        }
        for (Country_Codes__c cc : countryCodesSettings.values()) {
            countryCodesMap.put(cc.Country_ABV__c, cc);
        }
        Map<Id,Account> accMap = new Map<Id,Account>([SELECT ID,BillingCountry FROM Account WHERE ID IN: accIds]);
        for (Contact conLoop : conList) {
            Map<String, Country_Codes__c> tempCountryCodesMap = new Map<String, Country_Codes__c>();
            if(conLoop.MailingCountry != null && conLoop.MailingCountry != ''){
                country = conLoop.MailingCountry;
            } else {
                country = accMap.get(conLoop.accountId).BillingCountry;
            }
            Country_Codes__c countryCodeToUse = countryCodesMap.get(country);

            if (countryCodesMap.containsKey(country)) {
                tempCountryCodesMap.putAll(countryCodesMap);
            } else if (countryCodesSettings.containsKey(country)) {
                tempCountryCodesMap.putAll(countryCodesSettings);
            }

            if (tempCountryCodesMap.containsKey(country)) {
                for (Country_Codes__c cc : tempCountryCodesMap.values()) {
                    if (conLoop.Phone != null && conLoop.Phone != '' && conLoop.Phone.left(3) == cc.Country_Code__c) {
                        conLoop.Phone = '0' + conLoop.Phone.substring(3, conLoop.Phone.length());
                    }
                    if (conLoop.npe01__WorkPhone__c != null && conLoop.npe01__WorkPhone__c != '' && conLoop.npe01__WorkPhone__c.left(3) == cc.Country_Code__c) {
                        conLoop.npe01__WorkPhone__c = '0' + conLoop.npe01__WorkPhone__c.substring(3, conLoop.npe01__WorkPhone__c.length());
                    }if (conLoop.npe01__PreferredPhone__c != null && conLoop.npe01__PreferredPhone__c != '' && conLoop.npe01__PreferredPhone__c.left(3) == cc.Country_Code__c) {
                        conLoop.npe01__PreferredPhone__c = '0' + conLoop.npe01__PreferredPhone__c.substring(3, conLoop.npe01__PreferredPhone__c.length());
                    }
                    if (conLoop.MobilePhone != null && conLoop.MobilePhone != '' && conLoop.MobilePhone.left(3) == cc.Country_Code__c) {
                        conLoop.MobilePhone = '0' + conLoop.MobilePhone.substring(3, conLoop.MobilePhone.length());
                    }
                    if (conLoop.OtherPhone != null && conLoop.OtherPhone != '' && conLoop.OtherPhone.left(3) == cc.Country_Code__c) {
                        conLoop.OtherPhone = '0' + conLoop.OtherPhone.substring(3, conLoop.OtherPhone.length());
                    }
                    if (conLoop.HomePhone != null && conLoop.HomePhone != '' && conLoop.HomePhone.left(3) == cc.Country_Code__c) {
                        conLoop.HomePhone = '0' + conLoop.HomePhone.substring(3, conLoop.HomePhone.length());
                    }
                }
                if (conLoop.Phone != null && conLoop.Phone != '' && conLoop.Phone.left(1) == '0') {
                    conLoop.Phone = tempCountryCodesMap.get(country).Country_Code__c + conLoop.Phone.substring(1, conLoop.Phone.length()).deleteWhitespace();
                }
                if (conLoop.npe01__WorkPhone__c != null && conLoop.npe01__WorkPhone__c != '' && conLoop.npe01__WorkPhone__c.left(1) == '0') {
                    conLoop.npe01__WorkPhone__c = tempCountryCodesMap.get(country).Country_Code__c + conLoop.npe01__WorkPhone__c.substring(1, conLoop.npe01__WorkPhone__c.length()).deleteWhitespace();
                }
                if (conLoop.npe01__PreferredPhone__c != null && conLoop.npe01__PreferredPhone__c != '' && conLoop.npe01__PreferredPhone__c.left(1) == '0') {
                    conLoop.npe01__PreferredPhone__c = tempCountryCodesMap.get(country).Country_Code__c + conLoop.npe01__PreferredPhone__c.substring(1, conLoop.npe01__PreferredPhone__c.length()).deleteWhitespace();
                }
                if (conLoop.MobilePhone != null && conLoop.MobilePhone != '' && conLoop.MobilePhone.left(1) == '0') {
                    conLoop.MobilePhone = tempCountryCodesMap.get(country).Country_Code__c + conLoop.MobilePhone.substring(1, conLoop.MobilePhone.length()).deleteWhitespace();
                }
                if (conLoop.OtherPhone != null && conLoop.OtherPhone != '' && conLoop.OtherPhone.left(1) == '0') {
                    conLoop.OtherPhone = tempCountryCodesMap.get(country).Country_Code__c + conLoop.OtherPhone.substring(1, conLoop.OtherPhone.length()).deleteWhitespace();
                }
                if (conLoop.HomePhone != null && conLoop.HomePhone != '' && conLoop.HomePhone.left(1) == '0') {
                    conLoop.HomePhone = tempCountryCodesMap.get(country).Country_Code__c + conLoop.HomePhone.substring(1, conLoop.HomePhone.length()).deleteWhitespace();
                }
            }
        }
    }
    
    /**
     * @author:                     Jerome Liwanag
     * @date:                       Sep 2017
     * @description:                This method handles the automatic
     *                              assignation of contact and account to a case based on
     *                              its email and the case' web email
     * 
     * @history                     Kristopher Veraces 05-08-2020
     *                              Commenting-out the code but not permanent
     *                              delete as it can be uncommented in 
     *                              different stream and for reference. .
    */ 
    /*
    public static void assignContactToCase(List<Contact> conList){
        Set<String> emailSet = new Set<String>();
        for(Contact conLoop : conList){
            if(conLoop.Email != null){
                emailSet.add(conLoop.Email);
            }
            else if(conLoop.npe01__WorkEmail__c != null){
                emailSet.add(conLoop.npe01__WorkEmail__c);
            }
            else if(conLoop.npe01__HomeEmail__c != null){
                emailSet.add(conLoop.npe01__HomeEmail__c);
            }
            else if(conLoop.npe01__AlternateEmail__c != null){
                emailSet.add(conLoop.npe01__AlternateEmail__c);
            }
        }
        
        if(emailSet.isEmpty()){
            return;
        }
        
        Map<String,List<Case>> caseMap = new Map<String,List<Case>>();
        for(Case caseLoop : [SELECT ID,SuppliedEmail,AccountId,ContactId FROM Case WHERE SuppliedEmail IN :emailSet AND ContactId = null]){
            if(!caseMap.containsKey(caseLoop.SuppliedEmail)){
                caseMap.put(caseLoop.SuppliedEmail, new List<Case> {caseLoop});
            }else{
                caseMap.get(caseLoop.SuppliedEmail).add(caseLoop);
            }
        }
        
        if(caseMap.isEmpty()){
            return;
        }
        
        List<Case> caseListToUpdate = new List<Case>();
        for(Contact conLoop : conList){
            if(conLoop.Email != null && caseMap.containsKey(conLoop.Email)){
                for(Case caseLoop : caseMap.get(conLoop.Email)){
                    caseLoop.accountId = conLoop.accountId;
                    caseLoop.contactId = conLoop.Id;
                    caseListToUpdate.add(caseLoop);
                }
            }
            else if(conLoop.npe01__WorkEmail__c != null && caseMap.containsKey(conLoop.npe01__WorkEmail__c)){
                for(Case caseLoop : caseMap.get(conLoop.npe01__WorkEmail__c)){
                    caseLoop.accountId = conLoop.accountId;
                    caseLoop.contactId = conLoop.Id;
                    caseListToUpdate.add(caseLoop);
                }
            }
            else if(conLoop.npe01__HomeEmail__c != null && caseMap.containsKey(conLoop.npe01__HomeEmail__c)){
                for(Case caseLoop : caseMap.get(conLoop.npe01__HomeEmail__c)){
                    caseLoop.accountId = conLoop.accountId;
                    caseLoop.contactId = conLoop.Id;
                    caseListToUpdate.add(caseLoop);
                }
            }
            else if(conLoop.npe01__AlternateEmail__c != null && caseMap.containsKey(conLoop.npe01__AlternateEmail__c)){
                for(Case caseLoop : caseMap.get(conLoop.npe01__AlternateEmail__c)){
                    caseLoop.accountId = conLoop.accountId;
                    caseLoop.contactId = conLoop.Id;
                    caseListToUpdate.add(caseLoop);
                }
            }
        }
        
        if(!caseListToUpdate.isEmpty()){
            try{
                update caseListToUpdate;
            } catch(DMLException e){
                for(Contact conLoop : conList){
                    conLoop.addError('Contact Creation Failed. Error: ' + e.getMessage());
                }
            }
        }
    }
    */
}