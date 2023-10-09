/**
* @author: Stephen James Laylo
* @date: February 2018
* @description: This class handles all CRUD operations for the
* Direct Marketing Contact Trigger. All logic should be placed here and not in the
* trigger itself
*/ 
public class DirectMarketingContactTriggerHandler {
    public static Boolean runTrigger = true;
	private static Id industrialRetailPreferencesDirectMarketingContactRecTypeId = Schema.SObjectType.Marketing_Preference__c.getRecordTypeInfosByName().get('Industrial Retail Preferences').getRecordTypeId();
	
	/**
    * @author: Stephen James Laylo
    * @date: February 2018
    * @description: This method handles all on Before Insert
    * functionalities of the Direct Marketing Contact
    */ 
    public static void onBeforeInsert(List<Direct_Marketing_Contact__c> newDirectMarketingContacts) {
        if (runTrigger) {
            populateAccountContactIdUnique(newDirectMarketingContacts);
            createMarketingPreferenceForNewDirectMarketingContact(newDirectMarketingContacts);
        }  
    }
    
    /**
    * @author: Stephen James Laylo
    * @date: February 2018
    * @description: This method handles all on After Insert
    * functionalities of the Direct Marketing Contact
    */ 
    public static void onAfterInsert(List<Direct_Marketing_Contact__c> newDirectMarketingContacts) {
        
    }
    
    /**
    * @author: Stephen James Laylo
    * @date: February 2018
    * @description: This method handles all on Before Update
    * functionalities of the Direct Marketing Contact
    */ 
    public static void onBeforeUpdate(List<Direct_Marketing_Contact__c> newDirectMarketingContacts, Map<Id, Direct_Marketing_Contact__c> oldDirectMarketingContactsMap) {
        if (runTrigger) {
            populateAccountContactIdUnique(newDirectMarketingContacts);
            createMarketingPreferenceForNewDirectMarketingContact(newDirectMarketingContacts);
        }   
    }
    
    /**
    * @author: Stephen James Laylo
    * @date: February 2018
    * @description: This method handles all on After Update
    * functionalities of the Direct Marketing Contact
    */ 
    public static void onAfterUpdate(List<Direct_Marketing_Contact__c> newDirectMarketingContacts, Map<Id, Direct_Marketing_Contact__c> oldDirectMarketingContactsMap) {
        
    }

    /**
    * @author: Stephen James Laylo
    * @date: March 2018
    * @description: This method handles the update of Marketing Preference Subscriptions
    */ 
    public static void populateAccountContactIdUnique(List<Direct_Marketing_Contact__c> newDirectMarketingContacts) {
        for (Direct_Marketing_Contact__c newDirectMarketingContact : newDirectMarketingContacts) {
            newDirectMarketingContact.Account_Id_and_Contact_Id_Unique__c = newDirectMarketingContact.Account__c + '_' + newDirectMarketingContact.Contact__c;
        }
    }

    /**
    * @author: Stephen James Laylo
    * @date: February 2018
    * @description: This method handles the update of Marketing Preference Subscriptions
    */ 
    public static void createMarketingPreferenceForNewDirectMarketingContact(List<Direct_Marketing_Contact__c> newDirectMarketingContacts) {
    	Set<String> accContIds = new Set<String>();
        Set<Id> contIds = new Set<Id>();

    	Savepoint sp = Database.setSavepoint();

    	for (Direct_Marketing_Contact__c newDirectMarketingContact : newDirectMarketingContacts) {
    		if (newDirectMarketingContact.Account_Id_and_Contact_Id_Unique__c != null) {
    			contIds.add(newDirectMarketingContact.Contact__c);
                accContIds.add(newDirectMarketingContact.Account_Id_and_Contact_Id_Unique__c);
    		}
    	}

        if (Trigger.isInsert) {
            Map<String, Direct_Marketing_Contact__c> existingDirectMarketingContactsMap = new Map<String, Direct_Marketing_Contact__c>();

            for (Direct_Marketing_Contact__c existingDirectMarketingContact : [SELECT Id, Account__c, Contact__c, Account_Id_and_Contact_Id_Unique__c FROM Direct_Marketing_Contact__c WHERE Account_Id_and_Contact_Id_Unique__c IN :accContIds]) {
                if (existingDirectMarketingContact.Account_Id_and_Contact_Id_Unique__c != null) {
                    existingDirectMarketingContactsMap.put(existingDirectMarketingContact.Account_Id_and_Contact_Id_Unique__c, existingDirectMarketingContact);
                }
            }
            for (Direct_Marketing_Contact__c newDirectMarketingContact : newDirectMarketingContacts) {
                if (existingDirectMarketingContactsMap.containsKey(newDirectMarketingContact.Account_Id_and_Contact_Id_Unique__c)) {
                    newDirectMarketingContact.Id = existingDirectMarketingContactsMap.get(newDirectMarketingContact.Account_Id_and_Contact_Id_Unique__c).Id;
                }
            }
        }

    	List<Contact> contacts = [SELECT Id, (SELECT Id FROM Marketing_Preferences__r) FROM Contact WHERE Id IN :contIds];
    	List<Contact> contactsToCreateMarketingPreferences = new List<Contact>();
    	List<Contact> contactsToUpdateMarketingPreferences = new List<Contact>();

    	for (Contact c : contacts) {
    		if (c.Marketing_Preferences__r.isEmpty()) {
    			contactsToCreateMarketingPreferences.add(c);
    		} else {
    			contactsToUpdateMarketingPreferences.add(c);
    		}
    	}

    	List<Marketing_Preference__c> marketingPreferencesToUpsert = new List<Marketing_Preference__c>();

    	for (Contact c : contactsToCreateMarketingPreferences) {
    		Marketing_Preference__c marketingPreferenceToAdd = new Marketing_Preference__c();
    		marketingPreferenceToAdd.RecordTypeId = industrialRetailPreferencesDirectMarketingContactRecTypeId;
    		marketingPreferenceToAdd.General_Communication__c = true;
    		marketingPreferenceToAdd.Monthly_Communication__c = true;
    		marketingPreferenceToAdd.Contact__c = c.Id;

            marketingPreferencesToUpsert.add(marketingPreferenceToAdd);
    	}

    	for (Contact c : contactsToUpdateMarketingPreferences) {
    		for (Marketing_Preference__c marketingPreferenceToUpdate : c.Marketing_Preferences__r) {
	    		marketingPreferenceToUpdate.General_Communication__c = true;
	    		marketingPreferenceToUpdate.Monthly_Communication__c = true;
	    		marketingPreferenceToUpdate.Image_Relay__c = false;
	    		marketingPreferenceToUpdate.Press_Release__c = false;
	    		marketingPreferenceToUpdate.Product_Launch_2_WEEK__c = false;
	    		marketingPreferenceToUpdate.Product_Launch_4_WEEK__c = false;

	    		marketingPreferencesToUpsert.add(marketingPreferenceToUpdate);
    		}	
    	}

    	try {
    		upsert marketingPreferencesToUpsert;
    	} catch (Exception err) {
    		System.debug(err);
            Database.rollback(sp);
    	}
    }

}