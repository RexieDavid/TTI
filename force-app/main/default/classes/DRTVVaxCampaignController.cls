/**
* @author: Francis Nasalita
* @date: February 2018
* @description: This class handles logic for DRTV_Vax_Campaign_Page page
*/ 
public class DRTVVaxCampaignController {

	private Id b2cConsumerContactAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(GlobalConstantUtility.RECORD_TYPE_ACCOUNT_B2C_CONSUMER_CONTACT).getRecordTypeId();

	public Marketing_Campaign__c marketingCampaign;

	public Account newAccount {get;set;}
	public Boolean newsletter {get;set;}
	public Boolean noError {get;set;}
	public String email {get;set;}
	public String firstName {get;set;}
	public String lastName {get;set;}
	public String mobile {get;set;}
	public String selectedFloorSurface {get;set;}
	public String selectedHasPets {get;set;}
	public String selectedPropertySize {get;set;}

	// Constants
	public String consAccRecStatusActive = GlobalConstantUtility.ACCOUNT_RECORD_STATUS_ACTIVE; // Active
	public String consFloorSurface = GlobalConstantUtility.MARKETING_CAMPAIGN_FLOOR_SURFACE; // Floor_Surface__c
	public String consFloorSurfaceNA = GlobalConstantUtility.MARKETING_CAMPAIGN_FLOOR_SURFACE_NA; // N/A
	public String consHasPets = GlobalConstantUtility.MARKETING_CAMPAIGN_HAS_PETS; // Has_Pets__c
	public String consHasPetsNA = GlobalConstantUtility.MARKETING_CAMPAIGN_HAS_PETS_NA; // N/A
	public String consLeadSourceWeb = GlobalConstantUtility.ACCOUNT_LEAD_SOURCE_WEB; // Web
	public String consMarketingCampaign = GlobalConstantUtility.SOBJECT_MARKETING_CAMPAIGN; // Marketing_Campaign__c
	public String consPicklistNone = GlobalConstantUtility.PICKLIST_NONE; // --None--
	public String consPropertySize = GlobalConstantUtility.MARKETING_CAMPAIGN_PROPERTY_SIZE; // Property_Size__c
	public String consPropertySizeNA = GlobalConstantUtility.MARKETING_CAMPAIGN_PROPERTY_SIZE_NA; // N/A
	public String consRTIdVaxDRTVMarch2018 = GlobalConstantUtility.RECORD_TYPE_MARKETING_CAMPAIGN_VAX_DRTV_MARCH_2018; // Vax DRTV March 2018
	public String consUserConnectedAppAdmin = GlobalConstantUtility.USER_CONNECTED_APP_ADMINISTRATOR; // Connected App Administrator
	public String consVax = GlobalConstantUtility.BRAND_VAX; // Vax

	public List<SelectOption> floorSurfaceItems {
		get {
			List<SelectOption> options = new List<SelectOption>();
			options.add(new SelectOption(consFloorSurfaceNA, consPicklistNone));
			for(String s : TTIUtilClass.getPicklistValuesToList(consMarketingCampaign, consFloorSurface)) {
				options.add(new SelectOption(s,s));
			}
			return options;
		}
		set;
	}

	public List<SelectOption> hasPetsItems {
		get {
			List<SelectOption> options = new List<SelectOption>();
			options.add(new SelectOption(consHasPetsNA, consPicklistNone));
			for(String s : TTIUtilClass.getPicklistValuesToList(consMarketingCampaign, consHasPets)) {
				options.add(new SelectOption(s,s));
			}
			return options;
		}
		set;
	}

	public List<SelectOption> propertySizeItems {
		get {
			List<SelectOption> options = new List<SelectOption>();
			options.add(new SelectOption(consPropertySizeNA, consPicklistNone));
			for(String s : TTIUtilClass.getPicklistValuesToList(consMarketingCampaign, consPropertySize)) {
				options.add(new SelectOption(s,s));
			}
			return options;
		}
		set;
	}

	public DRTVVaxCampaignController() {
		newAccount = new Account();
		marketingCampaign = new Marketing_Campaign__c();
		newsletter = false;
		noError = true;
	}

	/**
	* @author: Francis Nasalita
	* @date: February 2018
	* @description: This method hanldes submit button. Creates Person Account, Marketing Preference, and Marketing campaign record.
	*/ 
	public void createVaxPersonAccount() {
        Savepoint sp = Database.setSavepoint();

        String debug = '';
        Marketing_Preference__c marketingPreference = new Marketing_Preference__c();
        Id vaxDRTVrtId = Schema.SObjectType.Marketing_Campaign__c.getRecordTypeInfosByName().get(consRTIdVaxDRTVMarch2018).getRecordTypeId();
        List<Account> existingAccounts = [SELECT Id, Name FROM Account WHERE PersonEmail = :email AND Brand__pc = :consVax AND RecordTypeId = :b2cConsumerContactAccRecTypeId];
        List<Marketing_Preference__c> marketingPreferences = [SELECT Id, Newsletter__c, Person_Account__c FROM Marketing_Preference__c WHERE Person_Account__c = :newAccount.Id LIMIT 1];
        List<Marketing_Campaign__c> marketingCampaigns = [Select Id from Marketing_Campaign__c WHERE Person_Account__c = :newAccount.Id AND RecordTypeId = :vaxDRTVrtId LIMIT 1];

        newAccount.FirstName = firstName;
        newAccount.LastName = lastName;
        newAccount.PersonEmail = email;
        newAccount.PersonMobilePhone = mobile;
        newAccount.Brand__pc = consVax;
        newAccount.PersonLeadSource = consLeadSourceWeb;
        newAccount.RecordTypeId = b2cConsumerContactAccRecTypeId;
        newAccount.Record_Status__c = consAccRecStatusActive;

        List<User> connectedAppAdmins = [SELECT Id FROM User WHERE Name = :consUserConnectedAppAdmin LIMIT 1];
        if (!connectedAppAdmins.isEmpty()) {
            newAccount.OwnerId = connectedAppAdmins[0].Id;
        }
        
        if (!existingAccounts.isEmpty()) {
            newAccount.Id = existingAccounts[0].Id;
        }

        try {
        	upsert newAccount;
        } catch (Exception err) {
            System.debug(err);
            Database.rollback(sp);
            noError = false;
        }   
        
        

        if (!marketingPreferences.isEmpty()) {
            marketingPreference.Id = marketingPreferences[0].Id;
        } else {
            marketingPreference.Person_Account__c = newAccount.Id;
        }

        marketingCampaign.RecordTypeId = vaxDRTVrtId;
        marketingCampaign.Floor_Surface__c = selectedFloorSurface;
        marketingCampaign.Property_Size__c = selectedPropertySize;
        marketingCampaign.Has_Pets__c = selectedHasPets;

        if(!marketingCampaigns.isEmpty()) {
        	marketingCampaign.Id = marketingCampaigns[0].Id;
        } else {
        	marketingCampaign.Person_Account__c = newAccount.Id;
        }

        if(newsletter == true) {
        	marketingPreference.Newsletter__c = true;
	        marketingPreference.DIY_Inspiration__c = true;
	        marketingPreference.New_Product_Updates__c = true;
	        marketingPreference.SMS__c = true;

        	marketingCampaign.Interested__c = true;
        } else {
        	newAccount.PersonHasOptedOutOfEmail = true;
        	newAccount.et4ae5__HasOptedOutOfMobile__pc = true;
        }

        try {           
            upsert marketingPreference;
            upsert marketingCampaign;
        } catch (Exception err) {
            System.debug(err);
            Database.rollback(sp);
            noError = false;
        }    

        if(noError == true) {
        	clearVariables();
        }        
    }
	
	public void clearVariables() {
		newAccount = new Account();
		marketingCampaign = new Marketing_Campaign__c();
		newsletter = false;
		noError = true;
		firstName = '';
		lastName = '';
		email = '';
		mobile = '';
		selectedFloorSurface = '';
		selectedPropertySize = '';
		selectedHasPets = '';
	}
}