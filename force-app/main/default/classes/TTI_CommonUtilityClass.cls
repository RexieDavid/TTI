/**
* @author Unknown
* @date 2019-07-18
*
* @group Service Portal
* @group-content ../../ApexDocContent/service-portal.html
*
* @description Test data factory
*/
@isTest
public class TTI_CommonUtilityClass {

    /**********************************************************************
    * @description             Creates an instance of Case object
    * 
    * @return                  Service Request type Case record
    * 
    * @example
    * createCase()
    */
    public Static case createCase() {
        Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        Case caseObj = new Case();
        caseObj.Brand__c='AEG';
        caseObj.Status = 'New';
        caseObj.Service_Request_Milestone__c = 'New';
        caseObj.RecordTypeId = RecordTypeIdCase; 
        return caseObj;
    }

    /**********************************************************************
    * @description             Creates an instance of a Case object by Brand
    * 
    * @param  brand            brand
    * @return                  Service Request type Case record
    * 
    * @example
    * createCase('AEG')
    */
    public Static case createCase(String brand) {
        Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        Case caseObj = new Case();
        caseObj.Brand__c = brand;
        caseObj.Status = 'New';
        caseObj.Service_Request_Milestone__c = 'New';
        caseObj.RecordTypeId = RecordTypeIdCase; 
        return caseObj;
    }

    /**********************************************************************
    * @description             Creates an instance of an Account object
    * 
    * @param  fName            First name
    * @param  lName            Last name
    * @param  brand            brand
    * @param  country          country
    * @return                  Person Account record
    * 
    * @example
    * createB2CAccount('Tom', 'Nook', 'AEG', 'Australia')
    */
    public static Account createB2CAccount(String fName, String lName, String brand, String country) {
        String recordTypeIdPA = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('B2C Consumer Contact').getRecordTypeId();

        Account accObj = new Account();
        accObj.RecordTypeId = recordTypeIdPA;
        accObj.FirstName = fName;
        accObj.LastName = lName;
        accObj.Brand__pc = brand;
        accObj.Country__pc = country;
        accObj.Record_Status__c = 'Active';
        accObj.Type = 'Individual';
        return accObj;
    }
    
    /**********************************************************************
    * @description             Creates an instance of an Account object
    *
    * @return                  Account record
    * 
    * @example
    * createAccount()
    */
    public static Account createAccount() {
        Account accObj = new Account();
        accObj.Freight_Company__c='TNT'; 
        accObj.Allow_Delivery_to_Customers__c =True;
        accObj.Delivery_Country__c ='Australia';
        accObj.ShippingStreet ='tez';
        accObj.ShippingCity='noida';
        accObj.ShippingCountry='New Zealand';
        accObj.ShippingState='NSW';
        accObj.ShippingPostalCode ='201301';
        accObj.Delivery_Street__c='qwer';
        accObj.Delivery_Suburb__c='uytr'; 
        accObj.Delivery_State__c='wert';
        accObj.Delivery_Postcode__c ='234511';
        return accObj;
    }
    
    /**********************************************************************
    * @description             Creates an instance of a Contact object
    *
    * @return                  Contact record
    * 
    * @example
    * createContact()
    */
    public static Contact createContact() {
        Contact conObj = new Contact();
        conObj.FirstName = 'Test';
        conObj.LastName = 'Contact';
        conObj.Email = 'shivamkr.92@gmail.com';
        return conObj;
    }
    
    /**********************************************************************
    * @description             Creates an instance of a User object
    *
    * @return                  User record
    * 
    * @example
    * createUser()
    */
    public Static User createUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = '~Customer Community Warranty'];
        User u = new User(
            Alias = 'standt', 
            Email = 'standarduser@testorg.com',
            EmailEncodingKey = 'UTF-8', 
            LastName = 'Testing', 
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', 
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles', 
            UserName = 'teststandard@testing.com', 
            TTI_SAP_Cust_No__c = '12345', 
            Division = 'Industrial'
            );
        return u;
    }
    
    /**********************************************************************
    * @description             Creates an instance of a Task object
    *
    * @return                  Service request type task record
    * 
    * @example
    * createTask()
    */
    public Static Task createTask() {
        Id RecordTypeIdTask = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        Task taskList = new Task();
        taskList = new Task(
            Type = 'Call', 
            Status = 'Not Started', 
            Priority = 'Normal', 
            subject = 'Service Request Approval More Information Required'
        );
        return taskList;
        
    }

    /**********************************************************************
    * @description             Creates Freight Account Details and 
                               Freight Company API details records
                               (TO BE DEPRECATED... this is used from initial
                               freight design which is no longer used but 
                               the classes are still active)
    */
    public static void createFreightAPICustomSettings() {
        List<Freight_Account_Details__c> lst = new List<Freight_Account_Details__c>();
        Freight_Account_Details__c objFreightAccDetails = new Freight_Account_Details__c();
        objFreightAccDetails.Name = '21946011';
        objFreightAccDetails.City__c = 'EASTERN CREEK';
        objFreightAccDetails.Company_Name__c = 'TECHTRONIC - SYDNEY SERVICE DE PARTMENT';
        objFreightAccDetails.Contact_Email__c = 'phillip.crotty@ttibrands.com.au';
        objFreightAccDetails.Contact_Name__c = 'Phillip Crotty';
        objFreightAccDetails.Contact_Phone__c = '+61397307754';
        objFreightAccDetails.Country__c = 'Australia';
        objFreightAccDetails.Postcode__c = '2766';
        objFreightAccDetails.Province__c = 'NSW';
        objFreightAccDetails.Street_Address__c = '21 KANGAROO AVE';
        
        Freight_Account_Details__c objFreightAccDetails1 = new Freight_Account_Details__c();
        objFreightAccDetails1.Name = '91903017';
        objFreightAccDetails1.City__c = 'Rowville';
        objFreightAccDetails1.Company_Name__c = 'Techtronic Industries Group';
        objFreightAccDetails1.Contact_Email__c = 'phillip.crotty@ttibrands.com.au';
        objFreightAccDetails1.Contact_Name__c = 'Phillip Crotty';
        objFreightAccDetails1.Contact_Phone__c = '+61397307754';
        objFreightAccDetails1.Country__c = 'Australia';
        objFreightAccDetails1.Postcode__c = '3178';
        objFreightAccDetails1.Province__c = 'Victoria';
        objFreightAccDetails1.Street_Address__c = '21 Kellets Road';
        lst.add(objFreightAccDetails);
        lst.add(objFreightAccDetails1);
        insert lst;
        
        List<TTI_Frieght_Company_API_Details__c> lstCompanyAPI = new List<TTI_Frieght_Company_API_Details__c>();
        TTI_Frieght_Company_API_Details__c TNT = new TTI_Frieght_Company_API_Details__c();
        TNT.Name = 'TNT';
        TNT.Prefix__c = 'TTB';
        TNT.Sender_Code__c = 'TTIBV';
        TNT.TTI_Access_Token_Generation_URL__c = '';
        TNT.TTI_Client_Id__c = '';
        TNT.TTI_Client_Secret__c = '';
        TNT.TTI_EndpointURL__c = 'http://www.tntexpress.com.au/webservices/Booking.svc';
        TNT.TTI_Grant_Type__c = '';
        TNT.TTI_Password__c = 'letmeinnow1';
        TNT.TTI_SOAP_Action_URL__c = 'http://tempuri.org/IBooking/SubmitBookingRequest';
        TNT.TTI_Username__c = 'cit00000000000103780';
        lstCompanyAPI.add(TNT);
        
        TTI_Frieght_Company_API_Details__c CP = new TTI_Frieght_Company_API_Details__c();
        CP.Name = 'Courier Post';
        CP.Prefix__c = 'TTB';
        CP.Sender_Code__c = 'TTIBV';
        CP.TTI_Access_Token_Generation_URL__c = '    https://oauth.nzpost.co.nz/as/token.oauth2';
        CP.TTI_Client_Id__c = 'e0805dffbd4f421a9033d36ffdd00622';
        CP.TTI_Client_Secret__c = '8BAA97831FD64D14ABD6DE33039bD780';
        CP.TTI_EndpointURL__c = 'https://api.uat.nzpost.co.nz/parcelpickup/v3/bookings';
        CP.TTI_Grant_Type__c = 'client_credentials';
        CP.TTI_Password__c = 'letmeinnow1';
        CP.TTI_SOAP_Action_URL__c = 'http://tempuri.org/IBooking/SubmitBookingRequest';
        CP.TTI_Username__c = 'cit00000000000103780';
        lstCompanyAPI.add(CP);
        
        insert lstCompanyAPI;
    }
    
    /**********************************************************************
    * @description             Creates template records for custom setting
    *
    * @return                  void
    * 
    * @example
    * insertTemplates()
    */
    public static void insertTemplates() {
        
        list<TTI_Template__c> template = new list<TTI_Template__c>();
        TTI_Template__c consignmentNoteTemplate = new TTI_Template__c();
        consignmentNoteTemplate.Name = 'ConsignmentNoteTemplate';
        consignmentNoteTemplate.Approved_Claim_Notification_Template__c = 'NotificationContainingFreightCompanyConsignmentNoteTemplate';
        template.add(consignmentNoteTemplate);
        
        TTI_Template__c consignmentOutNoteTemplate = new TTI_Template__c();
        consignmentOutNoteTemplate.Name = 'ConsignmentNoteTemplateFreightOut';
        consignmentOutNoteTemplate.Approved_Claim_Notification_Template__c = 'NotificationContainingFreightOutCompanyConsignmentNoteTemplate';
        template.add(consignmentOutNoteTemplate);
        
        TTI_Template__c rejectedWarrantyClaimTemplate = new TTI_Template__c();
        rejectedWarrantyClaimTemplate.Name = 'TTI_RejectedWarrantyClaimTemplate';
        rejectedWarrantyClaimTemplate.Approved_Claim_Notification_Template__c = 'TTI_RejectedWarrantyClaimTemplate';
        template.add(rejectedWarrantyClaimTemplate);
        
        TTI_Template__c warrantyClaimApprovedNotification = new TTI_Template__c();
        warrantyClaimApprovedNotification.Name = 'TTI_WarrantyClaimApprovedNotification';
        warrantyClaimApprovedNotification.Approved_Claim_Notification_Template__c = 'TTI_WarrantyClaimApprovedNotification';
        template.add(warrantyClaimApprovedNotification);
        
        TTI_Template__c emailsentToTheServiceAgentTemplate = new TTI_Template__c();
        emailsentToTheServiceAgentTemplate.Name = 'TTI_EmailsentToTheServiceAgentTemplate';
        emailsentToTheServiceAgentTemplate.Approved_Claim_Notification_Template__c = '';
        template.add(emailsentToTheServiceAgentTemplate);
        
        TTI_Template__c rejectedNonWarrantyClaimToCustomer = new TTI_Template__c();
        rejectedNonWarrantyClaimToCustomer.Name = 'TTI_RejectedNonWarrantyClaimToCustomer';
        rejectedNonWarrantyClaimToCustomer.Approved_Claim_Notification_Template__c = 'TTI_RejectedNonWarrantyClaimToCustomer';
        template.add(rejectedNonWarrantyClaimToCustomer);
        
        TTI_Template__c MarkedAsComplete = new TTI_Template__c();
        MarkedAsComplete.Name = 'TTI_MarkedAsCompleteNotification';
        MarkedAsComplete.Approved_Claim_Notification_Template__c = 'TTI_MarkedAsCompleteNotification';
        template.add(MarkedAsComplete);
        
        TTI_Template__c CaseReceiptTemplate = new TTI_Template__c();
        CaseReceiptTemplate.Name = 'CaseReceiptTemplate';
        CaseReceiptTemplate.Approved_Claim_Notification_Template__c = 'Case Receipt Template';
        template.add(CaseReceiptTemplate);
        
        TTI_Template__c QuoteTemplate = new TTI_Template__c();
        QuoteTemplate.Name = 'QuoteTemplate';
        QuoteTemplate.Approved_Claim_Notification_Template__c = 'TTI Quote Template';
        template.add(QuoteTemplate);
        
        insert template;
    }

    /**********************************************************************
    * @description             Creates system admin user
    *
    */
    public static User getSystemAdmin() {
        User systemAdminUser = new User(
            UserRoleId = [SELECT Id FROM UserRole WHERE PortalType = 'None' LIMIT 1].Id,
            ProfileId = [SELECT Id FROM PROFILE WHERE Name = 'System Administrator' LIMIT 1].Id,
            Username = 'sysadmin@tti.com.hk',
            Alias = 'sysad',
            Email = 'sysadmin@tti.com.hk',
            EmailEncodingKey = 'UTF-8',
            Firstname = 'System',
            Lastname = 'Admin',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Chicago'
        );

        insert systemAdminUser;

        return systemAdminUser;
    }

    /**********************************************************************
    * @description             Creates service agent account with contacts
    *
    */
    public static List<User> createSAAcctsWithCntctsAndUsers(Integer numAccts, Integer numCntctsPerAcct) {        
        List<Account> accts = new List<Account>();
        List<Contact> cntcts = new List<Contact>();
        List<User> users = new List<User>();

        for (Integer ctr = 0; ctr < numAccts; ctr++) {
            Account acct = new Account(
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Agent').getRecordTypeId(),
                Name = 'Service Center ' + ctr,
                TTI_SAP_Cust_No__c = '40000000' + ctr,
                Service_Agent_Status__c = 'Platinum',
                Trading_Hours_Time_Days__c = 'Please check with store',
                Internal_Service_Agent__c = true,
                Allow_Inspection_Fee__c = true,
                Allow_Delivery_to_Customers__c = true,
                Display_on_GEO_Locator__c = true,
                Max_Claimable_Sundry_Expenses__c = 0,
                Freight_Company__c = 'StarTrack',
                Freight_Company_Account_Number__c = '0000000' + ctr,
                Company_Code__c = 'BP01',
                ShippingStreet = '21 KELLETTS ROAD',
                ShippingCity = 'ROWVILLE',
                ShippingState = 'VIC',
                ShippingPostalCode = '3178',
                ShippingCountry = 'AU',
                ShippingLatitude = -37.9111571,
                ShippingLongitude = 145.2414325,
                Delivery_Street__c = '21 KELLETTS ROAD',
                Delivery_Suburb__c = 'ROWVILLE',
                Delivery_State__c = 'VIC',
                Delivery_Postcode__c = '3178',
                Delivery_Country__c = 'Australia'
            );
        }
        insert accts;
        
        Integer ctr = 0;
        for (Integer acctCtr = 0; acctCtr < numAccts; acctCtr++) {
            Account acct = accts[acctCtr];

            for (Integer cntctCtr = 0; cntctCtr < numCntctsPerAcct; cntctCtr++) {
                cntcts.add(new Contact(
                    RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Commercial (Trade or Employee)').getRecordTypeId(),
                    AccountId = acct.Id,
                    FirstName = 'Service' + ctr,
                    LastName = 'Agent' + ctr,
                    Phone = '+614' + String.valueOf(ctr).leftpad(9, '0'),
                    MobilePhone = '+614' + String.valueOf(ctr).leftpad(9, '0'),
                    Email = 'serviceagent' + ctr + '@yopmail.com',
                    MailingStreet = acct.Delivery_Street__c,
                    MailingCity = acct.Delivery_Suburb__c,
                    MailingState = acct.Delivery_State__c,
                    MailingPostalCode = acct.Delivery_Postcode__c,
                    MailingCountry = acct.Delivery_Country__c,
                    MailingLatitude = -37.9111571, 
                    MailingLongitude = 145.2414325
                ));

                ctr++;
            }
        }
        insert cntcts;

        for (Integer cntctCtr = 0; cntctCtr < numCntctsPerAcct; cntctCtr++) {
            users.add(new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = '~Customer Community Warranty' LIMIT 1].Id,
                ContactId = cntcts[cntctCtr].Id,
                LastName = 'Agent' + cntctCtr,
                Alias = 'ag' + cntctCtr,
                EmailEncodingKey = 'UTF-8', 
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', 
                TimeZoneSidKey = 'America/Los_Angeles', 
                Email = 'serviceagent' + cntctCtr + '@yopmail.com',
                UserName = 'teststandard@testing.com',
                TTI_SAP_Cust_No__c = String.valueOf(cntctCtr).leftpad(5, '0'),
                Division = 'Industrial'                
            ));
        }
        insert users;

        return users;
    }

    /**********************************************************************
    * @description             Creates b2c account
    *
    */
    public static List<Account> createB2CAccounts(String brand, String country, String type, Integer numAccts) {
        List<Account> accts = new List<Account>();

        for (Integer ctr = 0; ctr < numAccts; ctr++) {
            Account acct = new Account(
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Consumer Contact').getRecordTypeId(),
                FirstName = 'firstName' + ctr,
                LastName = 'lastName' + ctr,
                Brand__pc = brand, // ex. Milwaukee
                Country__pc = country, // Australia or New Zealand
                Record_Status__c = 'Active',
                Type = type // Individual or Business
            );
        }
        
        insert accts;

        return accts;
    }

    /**********************************************************************
    * @description             Initializes SOH RAG Status custom settings
    *
    */
    public static void initSOHRAGStatus() {
        List<SOHRAGStatus__c> lstSOHRAGStatus = new List<SOHRAGStatus__c>();

        lstSOHRAGStatus.add(new SOHRAGStatus__c(
            Name = 'RED',
            MaxSOHRange__c = 0,
            MinSOHRange__c = -99999999
        ));

        lstSOHRAGStatus.add(new SOHRAGStatus__c(
            Name = 'AMBER',
            MaxSOHRange__c = 10,
            MinSOHRange__c = 1
        ));

        lstSOHRAGStatus.add(new SOHRAGStatus__c(
            Name = 'GREEN',
            MaxSOHRange__c = 999999999,
            MinSOHRange__c = 11
        ));

        insert lstSOHRAGStatus;
    }

    /**********************************************************************
    * @description             Initializes Auto Approval Percentage custom settings
    *
    */
    public static void initAutoApprovalPerc() {
        List<AutoApproval_Percentage__c> autoApprovalPercList = new List<AutoApproval_Percentage__c>();

        autoApprovalPercList.add(new AutoApproval_Percentage__c(
            Name = 'Cost_Percentage',
            AutoApproval_Percentage__c = 80
        ));

        autoApprovalPercList.add(new AutoApproval_Percentage__c(
            Name = 'SOH_Percentage',
            AutoApproval_Percentage__c = 60
        ));

        insert autoApprovalPercList;
    }

    /**********************************************************************
    * @description             Initializes GST rates custom settings
    *
    */
    public static void initGSTRates() {
        List<GST_Rates__c> gstRates = new List<GST_Rates__c>();

        gstRates.add(new GST_Rates__c(
            Name = 'Australia',
            GST_Rate__c = 10,
            Country__c = 'Australia'
        ));

        gstRates.add(new GST_Rates__c(
            Name = 'New Zealand',
            GST_Rate__c = 15,
            Country__c = 'New Zealand'
        ));

        insert gstRates;
    }

    public enum ProductType { ACCESSORY, HAND_TOOL, SPARE_PART, TOOL_MACHINE }
    /**********************************************************************
    * @description             Initializes GST rates custom settings
    *
    */
    public static List<Product2> createProducts(ProductType productType, Integer numProducts) {
        List<Product2> products = new List<Product2>();

        for (Integer ctr = 0; ctr < numProducts; ctr++) {
            Product2 product = new Product2(
                Name = 'Product ' + ctr,
                SAP_Material_Type__c = 'HAWA',
                Family = 'Hardware',
                AU_Landed_Cost__c = null,
                NZ_Landed_Cost__c = null,
                Maximum_Number_of_Parts__c = Integer.valueof((Math.random() * 10)),
                SOH_BP01__c = Integer.valueof((Math.random() * 10)),
                Standard_Warranty_Months__c = Integer.valueof((Math.random() * 24)),
                Height__c = Integer.valueof((Math.random() * 25)),
                Length__c = Integer.valueof((Math.random() * 25)),
                Width__c = Integer.valueof((Math.random() * 25)),
                Weight__c = Integer.valueof((Math.random() * 150)),
                Dangerous_Goods_Text__c = 'CLASS9',
                SAP_MaterialNumber__c = String.valueOf(ctr).leftpad(5, '0')
            );
            
            switch on productType {
                when ACCESSORY {
                    product.recordTypeId = getProductRecordTypeId('Accessory');
                }
                when HAND_TOOL {
                    product.recordTypeId = getProductRecordTypeId('Hand Tool');
                }
                when SPARE_PART {
                    product.recordTypeId = getProductRecordTypeId('Spare Part');
                }
                when TOOL_MACHINE {
                    product.recordTypeId = getProductRecordTypeId('Tool/Machine');
                }
                when else {
                    // product record type will be set to default
                }
            }

            products.add(product);
        }
        insert products;

        return products;
    }

    private static Id getProductRecordTypeId(String productType) {
        return Schema.SObjectType.Product2.getRecordTypeInfosByName().get(productType).getRecordTypeId();
    } 
}