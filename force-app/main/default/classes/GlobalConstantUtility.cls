/**
* @author Jerome Liwanag
* @date 2017-05-08
*
* @description Utility class that contains constants, intended to be accessed globally
*
* @history
* <Date>         <Author>       <Description>
* 2018-11-14     S. Oberes      Changed the getVariablesForTest to make it dynamic, and also added new values
*/
global class GlobalConstantUtility {

	public GlobalConstantUtility() {
	
	}

	// Country
	public static final String ANZ = 'anz';
	public static final String AUSTRALIA_SHORT = 'au';
	public static final String NEW_ZEALAND_SHORT = 'nz';
	public static final String AUSTRALIA = 'Australia';
	public static final String AUSTRALIAN = 'Australian';
	public static final String NEW_ZEALAND = 'New Zealand';
    
    // Users
    public static final String USER_CONNECTED_APP_ADMINISTRATOR = 'Connected App Administrator';

    // Brands
    public static final String BRAND_VAX = 'Vax';

    // Account Types
    public static final String ACCOUNT_TYPE_CONSUMER_COMPANY = 'Consumer Company';
    public static final String ACCOUNT_TYPE_SERVICE_AGENT = 'Service Agent';
    public static final String ACCOUNT_TYPE_RETAILER = 'Retailer';
    public static final String ACCOUNT_TYPE_REP_ACCOUNT = 'Rep Account';
    public static final String ACCOUNT_TYPE_HEAD_OFFICE = 'Head Office';
    public static final String ACCOUNT_TYPE_HEAD_OFFICE_END_CONSUMER = 'Head Office - End Consumer';
    public static final String ACCOUNT_TYPE_HEAD_OFFICE_INTERNAL = 'Head Office - Internal';
    public static final String ACCOUNT_TYPE_INDUSTRY_ASSOCIATION = 'Industry Association';

    // Account Record Status Values
    public static final String ACCOUNT_RECORD_STATUS_ACTIVE = 'Active';
    public static final String ACCOUNT_RECORD_STATUS_INACTIVE = 'Inactive';
    public static final String ACCOUNT_RECORD_STATUS_PENDING = 'Pending';

    // Account Lead Source Values
    public static final String ACCOUNT_LEAD_SOURCE_WEB = 'Web';
    
    // Account Record Types
    public static final String RECORD_TYPE_ACCOUNT_SERVICE_AGENT = 'Service Agent';
    public static final String RECORD_TYPE_ACCOUNT_COMMERCIAL = 'Commercial';
    public static final String RECORD_TYPE_ACCOUNT_REP_ACCOUNT = 'Rep Account';
    public static final String RECORD_TYPE_ACCOUNT_HEAD_OFFICE_ACCOUNT = 'Head Office Account';
    public static final String RECORD_TYPE_ACCOUNT_HEAD_OFFICE_ACCOUNT_END_CONSUMER = 'Head Office Account - End-Consumer';
    public static final String RECORD_TYPE_ACCOUNT_END_CONSUMER = 'End Consumer';
    public static final String RECORD_TYPE_ACCOUNT_INTERNAL_TTI_DIVISION_HQ = 'Internal TTI Division HQ';
    public static final String RECORD_TYPE_ACCOUNT_INDUSTRY_ASSOCIATION = 'Industry Association';
    public static final String RECORD_TYPE_ACCOUNT_B2C_CONSUMER_CONTACT = 'B2C Consumer Contact';
    
    // Marketing Campaign Record Types
    public static final String RECORD_TYPE_MARKETING_CAMPAIGN_IN_PACK_PROMO = 'In Pack Promo';
    public static final String RECORD_TYPE_MARKETING_CAMPAIGN_VAX_DRTV_MARCH_2018 = 'Vax DRTV March 2018';
    
    // Marketing Campaign Next Project Tools
    public static final String MARKETING_CAMPAIGN_NEXT_PROJECT_TOOLS_DRILL = 'Drill';
    public static final String MARKETING_CAMPAIGN_NEXT_PROJECT_TOOLS_SAW = 'Saw';
    public static final String MARKETING_CAMPAIGN_NEXT_PROJECT_TOOLS_SANDER = 'Sander';
    public static final String MARKETING_CAMPAIGN_NEXT_PROJECT_TOOLS_LIFESTYLE_PRODUCT = 'Lifestyle Product';
    public static final String MARKETING_CAMPAIGN_NEXT_PROJECT_TOOLS_NAILER = 'Nailer';
    public static final String MARKETING_CAMPAIGN_NEXT_PROJECT_TOOLS_LINE_TRIMMER = 'Line Trimmer';
    public static final String MARKETING_CAMPAIGN_NEXT_PROJECT_TOOLS_LAWN_MOWER = 'Lawn Mower';
    public static final String MARKETING_CAMPAIGN_NEXT_PROJECT_TOOLS_BLOWER = 'Blower';

    // Marketing Campaign Custom Fields
    public static final String MARKETING_CAMPAIGN_FLOOR_SURFACE = 'Floor_Surface__c';
    public static final String MARKETING_CAMPAIGN_PROPERTY_SIZE = 'Property_Size__c';
    public static final String MARKETING_CAMPAIGN_HAS_PETS = 'Has_Pets__c';

    // Marketing Campaign Picklist Values
    public static final String MARKETING_CAMPAIGN_FLOOR_SURFACE_NA = 'N/A';
    public static final String MARKETING_CAMPAIGN_PROPERTY_SIZE_NA = 'N/A';
    public static final String MARKETING_CAMPAIGN_HAS_PETS_NA = 'N/A';  

    // Marketing Campaign To-Do List
    public static final String MARKETING_CAMPAIGN_TO_DO_LIST_HOME_MAINTENANCE = 'Home Maintenance';
    public static final String MARKETING_CAMPAIGN_TO_DO_LIST_HOME_IMPROVEMENT = 'Home Improvement';
    public static final String MARKETING_CAMPAIGN_TO_DO_LIST_WOODWORK_PROJECT = 'Woodwork Project';
    public static final String MARKETING_CAMPAIGN_TO_DO_LIST_GARDENING = 'Gardening';

    // Inventory Record Types
    public static final String RECORD_TYPE_INVENTORY_TTI_PRODUCT = 'TTI Product';

    // Opportunity Stage Name
    public static final String OPPORTUNITY_STAGENAME_STAGE = 'Stage';
    public static final String OPPORTUNITY_STAGENAME_CLOSED_WON = 'Closed Won';
    public static final String OPPORTUNITY_STAGENAME_PROSPECTING = 'Prospecting';

    // Contract Status
    public static final String CONTRACT_STATUS_IN_APPROVAL_PROCESS = 'In Approval Process';
    public static final String CONTRACT_STATUS_ACTIVATED = 'Activated';
    public static final String CONTRACT_STATUS_DRAFT = 'Draft';

    // Contract Record Types
    public static final String RECORD_TYPE_CONTRACT_APPROVED = 'Approved';

    // Group Types
    public static final String GROUP_TYPE_QUEUE = 'Queue';

    // Lead Record Types
    public static final String RECORD_TYPE_LEAD_END_CONSUMER_IND = 'End-Consumer IND';

    // TTI Form Record Types
    public static final String RECORD_TYPE_TTI_FORM_DEMO_SAMPLE_REQUEST = 'Demo Sample Request';
    public static final String RECORD_TYPE_TTI_FORM_SHOWROOM_STOCK_REQUEST = 'Showroom Stock Request';
    public static final String RECORD_TYPE_TTI_FORM_PROMO_STOCK_REQUEST = 'Promo Stock Request';
    public static final String RECORD_TYPE_TTI_FORM_ZJSS_INTERNAL_ORDER = 'ZJSS Internal Order';
    public static final String RECORD_TYPE_TTI_FORM_SHOWROOM_STOCK_RETURN = 'Showroom Stock Return';
    public static final String RECORD_TYPE_TTI_FORM_ZJSS_REBATE = 'ZJSS Rebate';
    public static final String RECORD_TYPE_TTI_FORM_SPONSORSHIPS = 'Sponsorships';
    
    public static final String RECORD_STATUS_PENDING = 'Pending';

    // sObject Types
    public static final String SOBJECT_TYPE_ACCOUNT = 'Account';
    public static final String SOBJECT_TYPE_LEAD = 'Lead';
    public static final String SOBJECT_TYPE_PRODUCT = 'Product2';
    public static final String SOBJECT_TYPE_TTI_FORM = 'TTI_Form__c';
    public static final String SOBJECT_MARKETING_CAMPAIGN = 'Marketing_Campaign__c';
    
    // Sales Organisations
    public static final String ACCOUNT_SALES_ORGANISATION_BP01 = 'BP01';
    public static final String ACCOUNT_SALES_ORGANISATION_BP02 = 'BP02';
    public static final String ACCOUNT_SALES_ORGANISATION_NZ01 = 'NZ01';

    // Symbols
    public static final String SEPARATOR_SEMI_COLON = ';';

    // 
    public static final String ACTIVE = 'Active';
    public static final String INACTIVE = 'Inactive';
    public static final String PICKLIST_NONE = '--None--';

    public static String getVariablesForTest() {
        String s = '';
        s += GlobalConstantUtility.USER_CONNECTED_APP_ADMINISTRATOR;
        s += GlobalConstantUtility.BRAND_VAX;
        s += GlobalConstantUtility.ACCOUNT_TYPE_CONSUMER_COMPANY;
        s += GlobalConstantUtility.ACCOUNT_TYPE_SERVICE_AGENT;
        s += GlobalConstantUtility.ACCOUNT_TYPE_RETAILER;
        s += GlobalConstantUtility.ACCOUNT_TYPE_REP_ACCOUNT;
        s += GlobalConstantUtility.ACCOUNT_TYPE_HEAD_OFFICE;
        s += GlobalConstantUtility.ACCOUNT_TYPE_HEAD_OFFICE_END_CONSUMER;
        s += GlobalConstantUtility.ACCOUNT_TYPE_HEAD_OFFICE_INTERNAL;
        s += GlobalConstantUtility.ACCOUNT_TYPE_INDUSTRY_ASSOCIATION;
        s += GlobalConstantUtility.ACCOUNT_RECORD_STATUS_ACTIVE;
        s += GlobalConstantUtility.ACCOUNT_RECORD_STATUS_INACTIVE;
        s += GlobalConstantUtility.ACCOUNT_RECORD_STATUS_PENDING;
        s += GlobalConstantUtility.ACCOUNT_LEAD_SOURCE_WEB;
        s += GlobalConstantUtility.RECORD_TYPE_ACCOUNT_SERVICE_AGENT;
        s += GlobalConstantUtility.RECORD_TYPE_ACCOUNT_COMMERCIAL;
        s += GlobalConstantUtility.RECORD_TYPE_ACCOUNT_REP_ACCOUNT;
        s += GlobalConstantUtility.RECORD_TYPE_ACCOUNT_HEAD_OFFICE_ACCOUNT;
        s += GlobalConstantUtility.RECORD_TYPE_ACCOUNT_HEAD_OFFICE_ACCOUNT_END_CONSUMER;
        s += GlobalConstantUtility.RECORD_TYPE_ACCOUNT_END_CONSUMER;
        s += GlobalConstantUtility.RECORD_TYPE_ACCOUNT_INTERNAL_TTI_DIVISION_HQ;
        s += GlobalConstantUtility.RECORD_TYPE_ACCOUNT_INDUSTRY_ASSOCIATION;
        s += GlobalConstantUtility.RECORD_TYPE_ACCOUNT_B2C_CONSUMER_CONTACT;
        s += GlobalConstantUtility.RECORD_TYPE_MARKETING_CAMPAIGN_IN_PACK_PROMO;
        s += GlobalConstantUtility.RECORD_TYPE_MARKETING_CAMPAIGN_VAX_DRTV_MARCH_2018;
        s += GlobalConstantUtility.MARKETING_CAMPAIGN_NEXT_PROJECT_TOOLS_DRILL;
        s += GlobalConstantUtility.MARKETING_CAMPAIGN_NEXT_PROJECT_TOOLS_SAW;
        s += GlobalConstantUtility.MARKETING_CAMPAIGN_NEXT_PROJECT_TOOLS_SANDER;
        s += GlobalConstantUtility.MARKETING_CAMPAIGN_NEXT_PROJECT_TOOLS_LIFESTYLE_PRODUCT;
        s += GlobalConstantUtility.MARKETING_CAMPAIGN_NEXT_PROJECT_TOOLS_NAILER;
        s += GlobalConstantUtility.MARKETING_CAMPAIGN_NEXT_PROJECT_TOOLS_LINE_TRIMMER;
        s += GlobalConstantUtility.MARKETING_CAMPAIGN_NEXT_PROJECT_TOOLS_LAWN_MOWER;
        s += GlobalConstantUtility.MARKETING_CAMPAIGN_NEXT_PROJECT_TOOLS_BLOWER;
        s += GlobalConstantUtility.MARKETING_CAMPAIGN_FLOOR_SURFACE;
        s += GlobalConstantUtility.MARKETING_CAMPAIGN_PROPERTY_SIZE;
        s += GlobalConstantUtility.MARKETING_CAMPAIGN_HAS_PETS;
        s += GlobalConstantUtility.MARKETING_CAMPAIGN_FLOOR_SURFACE_NA;
        s += GlobalConstantUtility.MARKETING_CAMPAIGN_PROPERTY_SIZE_NA;
        s += GlobalConstantUtility.MARKETING_CAMPAIGN_HAS_PETS_NA;
        s += GlobalConstantUtility.MARKETING_CAMPAIGN_TO_DO_LIST_HOME_MAINTENANCE;
        s += GlobalConstantUtility.MARKETING_CAMPAIGN_TO_DO_LIST_HOME_IMPROVEMENT;
        s += GlobalConstantUtility.MARKETING_CAMPAIGN_TO_DO_LIST_WOODWORK_PROJECT;
        s += GlobalConstantUtility.MARKETING_CAMPAIGN_TO_DO_LIST_GARDENING;
        s += GlobalConstantUtility.RECORD_TYPE_INVENTORY_TTI_PRODUCT;
        s += GlobalConstantUtility.OPPORTUNITY_STAGENAME_STAGE;
        s += GlobalConstantUtility.OPPORTUNITY_STAGENAME_CLOSED_WON;
        s += GlobalConstantUtility.OPPORTUNITY_STAGENAME_PROSPECTING;
        s += GlobalConstantUtility.CONTRACT_STATUS_IN_APPROVAL_PROCESS;
        s += GlobalConstantUtility.CONTRACT_STATUS_ACTIVATED;
        s += GlobalConstantUtility.CONTRACT_STATUS_DRAFT;
        s += GlobalConstantUtility.RECORD_TYPE_CONTRACT_APPROVED;
        s += GlobalConstantUtility.GROUP_TYPE_QUEUE;
        s += GlobalConstantUtility.RECORD_TYPE_LEAD_END_CONSUMER_IND;
        s += GlobalConstantUtility.RECORD_TYPE_TTI_FORM_DEMO_SAMPLE_REQUEST;
        s += GlobalConstantUtility.RECORD_TYPE_TTI_FORM_SHOWROOM_STOCK_REQUEST;
        s += GlobalConstantUtility.RECORD_TYPE_TTI_FORM_PROMO_STOCK_REQUEST;
        s += GlobalConstantUtility.RECORD_TYPE_TTI_FORM_ZJSS_INTERNAL_ORDER;
        s += GlobalConstantUtility.RECORD_TYPE_TTI_FORM_SHOWROOM_STOCK_RETURN;
        s += GlobalConstantUtility.RECORD_TYPE_TTI_FORM_ZJSS_REBATE;
        s += GlobalConstantUtility.RECORD_TYPE_TTI_FORM_SPONSORSHIPS;
        s += GlobalConstantUtility.RECORD_STATUS_PENDING;
        s += GlobalConstantUtility.SOBJECT_TYPE_ACCOUNT;
        s += GlobalConstantUtility.SOBJECT_TYPE_LEAD;
        s += GlobalConstantUtility.SOBJECT_TYPE_PRODUCT;
        s += GlobalConstantUtility.SOBJECT_TYPE_TTI_FORM;
        s += GlobalConstantUtility.SOBJECT_MARKETING_CAMPAIGN;
        s += GlobalConstantUtility.ACCOUNT_SALES_ORGANISATION_BP01;
        s += GlobalConstantUtility.ACCOUNT_SALES_ORGANISATION_BP02;
        s += GlobalConstantUtility.ACCOUNT_SALES_ORGANISATION_NZ01 ;
        s += GlobalConstantUtility.SEPARATOR_SEMI_COLON ;
        s += GlobalConstantUtility.ACTIVE;
        s += GlobalConstantUtility.INACTIVE ;
        s += GlobalConstantUtility.PICKLIST_NONE;
        return s;
    }
}