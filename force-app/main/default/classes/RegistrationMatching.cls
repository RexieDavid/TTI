public class RegistrationMatching {
    public static RegistrationMatchResult getPersonAccounts(Id accId, string email, string accFirstName, string accLastName, string accMobile, string accPhone, string brand, string recType){
        Map<String, Account> accMap = new Map<String, Account>();
        Map<String, Account> accMapEmails = new Map<String, Account>();
        Map<String, Account> accMapLPMPhones = new Map<String, Account>();
        Map<String, Account> accMapFPLPPhones = new Map<String, Account>();
        
        RegistrationMatchResult returnValues;
        if(accPhone != null){
            accPhone = accPhone.replaceAll('\\s+', '');
        }
        if(accMobile!= null ){
            accMobile = accMobile.replaceAll('\\s+', '');
        }
        String accName = accFirstName + ' ' + accLastName;
        for(Account a : [SELECT Id, FirstName, LastName, PersonEmail, PersonMobilePhone, PersonHomePhone, Phone, Brand__pc, ParentContact__c FROM Account WHERE 
                     ((Firstname != null AND Firstname =: accFirstName) OR 
                      (Lastname != null AND Lastname =: accLastName) OR 
                      (PersonMobilePhone != null AND PersonMobilePhone =: accMobile) OR 
                      (PersonHomePhone != null AND PersonHomePhone =: accPhone) OR
                      (Phone !=null AND Phone =: accPhone)) AND
                     RecordTypeId =: recType AND ParentContact__r.Name = :accName ]){
            accMap.put((a.FirstName != null ? a.FirstName + '_' : '' ) + a.LastName + '_' + (a.PersonMobilePhone != null ? a.PersonMobilePhone + '_' : '') + (a.PersonHomePhone != null ? a.PersonHomePhone + '_' : '') + a.PersonEmail, a);
        }
        
        if(accMap.size() > 0){
            for(String key : accMap.keySet()){
                if(accMap.containsKey(key) && accMap.get(key).Id != accId){
                    if(accMap.get(key).PersonEmail == email){
                        accMapEmails.put(key, accMap.get(key));
                    } else if(accMap.get(key).Lastname == accLastName && accMap.get(key).PersonMobilePhone == accMobile){
                        accMapLPMPhones.put(key, accMap.get(key));
                    } else if(accMap.get(key).FirstName == accFirstName && accMap.get(key).Lastname == accLastName && (accMap.get(key).PersonHomePhone == accPhone || accMap.get(key).Phone == accPhone)){
                        accMapFPLPPhones.put(key, accMap.get(key));
                    }
                }
            }   
        }
        returnValues = getMatchedRecords(accMapEmails, brand);
        if (returnvalues.parentAccountMatchID ==null && returnvalues.personAccountMatch == null) {
            returnValues = getMatchedRecords(accMapLPMPhones, brand);
        }
        if (returnvalues.parentAccountMatchID ==null && returnvalues.personAccountMatch == null) {
            returnValues = getMatchedRecords(accMapFPLPPhones, brand);
        }
        return returnValues;
    }
    
    private static RegistrationMatchResult getMatchedRecords(Map<String, Account> items, String brand){
        RegistrationMatchResult returnValues = new RegistrationMatchResult();
        if (!items.isEmpty()) {
            Id parentContactId = items.values()[0].ParentContact__c;
            for (Account a : items.values()){
                //there should always be a parent account but check for null anyway.
                if (a.ParentContact__c != null){
                    returnValues.parentAccountMatchID = parentContactId;
                }
                if (brand == a.Brand__pc){
                    returnValues.personAccountMatch = a;
                    return returnValues;
                }
            }
            if (returnValues.personAccountMatch == null && returnvalues.parentAccountMatchID != null){
                List<Account> allforparent = [SELECT Id FROM Account WHERE ParentContact__c =: returnvalues.parentAccountMatchID AND Brand__pc =: brand ORDER BY createddate DESC LIMIT 1];
                List<User> u  = [SELECT id FROM User WHERE contact.accountid IN: allforparent];
                
                if (allforparent.size() > 0 && u.size() == 0) {
                    returnValues.personAccountMatch = allforparent[0];
                }                   
            }
        }
        return returnValues;
    }
    
    public static void updatePersonAccount(List<Account> newAccList){
        List<Account> accList= new List<Account>();
        Set<Id> accIdset = new set<id>();
        for(Account acc : newAccList){
            accIdset.add(acc.Id);
        }
        for(Account a : [SELECT Id, RecordTypeId, PersonEmail, CreatedDate, Brand__pc, PersonHomePhone, PersonMobilePhone, FirstName, LastName, ParentContact__c FROM Account WHERE Id IN: accIdset]){
            RegistrationMatching.RegistrationMatchResult matchresult = RegistrationMatching.getPersonAccounts(a.Id, a.PersonEmail, a.FirstName, a.LastName, a.PersonMobilePhone, a.PersonHomePhone, null, a.RecordTypeId);
            
            if(matchresult.parentAccountMatchID == null){
                a.ParentContact__c = RegistrationHelper.createParentContact(a.FirstName, a.LastName).Id;
            }else{
                a.ParentContact__c = matchresult.parentAccountMatchID;
            }
            accList.add(a);
        }
        update accList;
    }
    
    public class RegistrationMatchResult{
        @AuraEnabled
        public Account personAccountMatch {get; set;}
        
        @AuraEnabled
        public String  parentAccountMatchID {get; set;}
    }
       
}