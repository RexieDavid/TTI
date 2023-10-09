@isTest
public class TTI_CaseTriggerHandlerTest2 {
    /**
* @author: Shivam Singh
* @date: Jan 2018
* @description: Test class for TTI_CaseTriggerHandler.
*/
    
    public static Case loadTestData()
    {
        Contact conObj = TTI_CommonUtilityClass.createContact();
        conObj.Email = null;
        conObj.Phone = '+6112313131';
        insert conObj;
        
        TTI_CommonUtilityClass.insertTemplates();
        
        Product2 prod = new Product2(Name = 'Laptop X200', Family = 'Hardware');
        insert prod;
        
        Id serviceAgentId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Agent').getRecordTypeId();
        
        Account serviceAgent = TTI_CommonUtilityClass.createAccount();
        serviceAgent.RecordTypeId = serviceAgentId;
        serviceAgent.Allow_Delivery_to_Customers__c = false;
        serviceAgent.Name = 'TEST_SERVICE_AGENT';
        serviceAgent.Phone = '+6112313131';
        serviceAgent.Freight_Company__c = 'Courier Post';
        serviceAgent.Freight_Company_Account_Number__c = '21946011';
        insert serviceAgent;
        
        Case caseObj = TTI_CommonUtilityClass.createCase();
        caseObj.AccountId = serviceAgent.Id;
        caseObj.Service_Agent__c = serviceAgent.Id;
        caseObj.Product_Payment_Category__c = 'Generators';
        caseObj.Repair_Type__c = 'Declined Warranty - Inspection fee';
        caseObj.Claim_Type__c = 'Warranty';
        caseObj.Service_Request_Milestone__c = 'New';
        caseObj.Approved_Flag__c = false;
        caseObj.TTI_Email_Notification_Opt_In__c = false;
        caseObj.TTI_Customer_Contact__c = conObj.Id;
        caseObj.Invoiced_Approved__c = false;
        caseObj.Freight_out_consignment_number__c = null;
        caseObj.Product_Name__c = prod.Id;
        caseObj.TTI_Customer_Delivery_Method__c = 'Pickup from Service Agent';
        insert caseObj;
        
        Attachment attach = new Attachment();     
        attach.Name = 'Case PDF - ' + caseObj.CaseNumber + '.pdf';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.body = bodyBlob;
        attach.parentId = caseObj.id;
        insert attach;
        
        return caseObj;
    }
    
    public static Case loadTestData2()
    {
        Contact conObj = TTI_CommonUtilityClass.createContact();
        TTI_CommonUtilityClass.insertTemplates();
        
        Product2 prod = new Product2(Name = 'Laptop X200', Family = 'Hardware');
        insert prod;
        
        Id serviceAgentId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Agent').getRecordTypeId();
        
        Account serviceAgent = TTI_CommonUtilityClass.createAccount();
        serviceAgent.Delivery_Country__c ='New Zealand';
        serviceAgent.RecordTypeId = serviceAgentId;
        serviceAgent.Allow_Delivery_to_Customers__c = false;
        serviceAgent.Name = 'TEST_SERVICE_AGENT';
        serviceAgent.Phone = '+6112313131';
        serviceAgent.Freight_Company__c = 'Courier Post';
        serviceAgent.Freight_Company_Account_Number__c = '21946011';
        serviceAgent.Service_Agent_Status__c = 'Bronze';
        serviceAgent.Max_Claimable_Sundry_Expenses__c = 80;
        insert serviceAgent;
        
        Case caseObj = TTI_CommonUtilityClass.createCase();
        caseObj.AccountId = serviceAgent.Id;
        caseObj.Service_Agent__c = serviceAgent.Id;
        caseObj.Product_Payment_Category__c = 'Generators';
        caseObj.Repair_Type__c = 'Declined Warranty - Inspection fee';
        caseObj.Claim_Type__c = 'Warranty';
        caseObj.Service_Request_Milestone__c = 'New';
        caseObj.Approved_Flag__c = false;
        caseObj.TTI_Email_Notification_Opt_In__c = false;
        caseObj.TTI_Customer_Contact__c = conObj.Id;
        caseObj.Invoiced_Approved__c = false;
        caseObj.Freight_out_consignment_number__c = null;
        caseObj.Product_Name__c = prod.Id;
        insert caseObj;
        
        Attachment attach = new Attachment();     
        attach.Name = 'Case PDF - ' + caseObj.CaseNumber + '.pdf';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.body = bodyBlob;
        attach.parentId = caseObj.id;
        insert attach;
        
        return caseObj;
    }

    public static Case loadTestData3()
    {
        Contact conObj = TTI_CommonUtilityClass.createContact();
        TTI_CommonUtilityClass.insertTemplates();
        
        Product2 prod = new Product2(Name = 'Laptop X200', Family = 'Hardware');
        insert prod;
        
        Id serviceAgentId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Agent').getRecordTypeId();
        
        Account serviceAgent = TTI_CommonUtilityClass.createAccount();
        serviceAgent.Delivery_Country__c ='Australia';
        serviceAgent.RecordTypeId = serviceAgentId;
        serviceAgent.Allow_Delivery_to_Customers__c = false;
        serviceAgent.Name = 'TEST_SERVICE_AGENT';
        serviceAgent.Phone = '+6112313131';
        serviceAgent.Freight_Company__c = 'Courier Post';
        serviceAgent.Freight_Company_Account_Number__c = '21946011';
        serviceAgent.Service_Agent_Status__c = 'Bronze';
        serviceAgent.Max_Claimable_Sundry_Expenses__c = 80;
        insert serviceAgent;
        
        Case caseObj = TTI_CommonUtilityClass.createCase();
        caseObj.AccountId = serviceAgent.Id;
        caseObj.Service_Agent__c = serviceAgent.Id;
        caseObj.Product_Payment_Category__c = 'Generators';
        caseObj.Repair_Type__c = 'Declined Warranty - Inspection fee';
        caseObj.Claim_Type__c = 'Warranty';
        caseObj.Service_Request_Milestone__c = 'New';
        caseObj.Approved_Flag__c = false;
        caseObj.TTI_Email_Notification_Opt_In__c = false;
        caseObj.TTI_Customer_Contact__c = conObj.Id;
        caseObj.Invoiced_Approved__c = false;
        caseObj.Freight_out_consignment_number__c = null;
        caseObj.Product_Name__c = prod.Id;
        insert caseObj;
        
        Attachment attach = new Attachment();     
        attach.Name = 'Case PDF - ' + caseObj.CaseNumber + '.pdf';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.body = bodyBlob;
        attach.parentId = caseObj.id;
        insert attach;
        
        return caseObj;
    }
    
    static testmethod void InProgress2() {
        Test.startTest();
        Case caseObjUpdate3 = loadTestData();
        caseObjUpdate3.TTI_Email_Notification_Opt_In__c = true;
        update caseObjUpdate3;
        caseObjUpdate3.Approved_Flag__c = true;       
        caseObjUpdate3.Service_Request_Milestone__c = 'In Progress';
        try{
            update caseObjUpdate3;
        }catch(Exception ex){
        
        }
        Test.stopTest();
    }
    
    static testmethod void sendEmailtoCustomerWhenClaimMarkedAsCompletetest2() {
        
        Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        
        Contact objCon = TTI_CommonUtilityClass.createContact();
        insert objCon;
        
        //User u = TTI_CommonUtilityClass.createUser();
        //u.ContactId = objCon.Id;
        //u.Email = 'test@rest.com';
        //insert u;
        TTI_CommonUtilityClass.insertTemplates();
        Case caseObj = loadTestData();
        //Case caseObj = TTI_CommonUtilityClass.createCase();
        caseObj.Status = 'In Progress';
        caseObj.Service_Request_Milestone__c = 'In Progress';
        //caseObj.Diagnosed_User__c =  u.Id;
        caseObj.TTI_Email_Notification_Opt_In__c = true;
       
        caseObj.Claim_Type__c = 'Warranty';
        
        caseObj.RecordTypeId = RecordTypeIdCase;
        update caseObj;
        
        Test.startTest();
        caseObj.Status = 'In Progress';
        caseObj.Service_Request_Milestone__c = 'Completed';
        caseObj.TTI_Email_Notification_Opt_In__c = true;
        
        try{
            update caseObj;
        }catch(Exception ex){
        
        }
        Test.stopTest();
        
    }
    
    static testmethod void sendEmailtoCustomerWhenClaimMarkedAsCompletetest3() {
        
        Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        Contact objCon = TTI_CommonUtilityClass.createContact();
        insert objCon;
        //User u = TTI_CommonUtilityClass.createUser();
        //u.ContactId = objCon.Id;
        //u.Email = 'test@rest.com';
        //insert u;
        TTI_CommonUtilityClass.insertTemplates();
        Case caseObj = loadTestData();
        //Case caseObj = TTI_CommonUtilityClass.createCase();
        caseObj.Status = 'In Progress';
        caseObj.Service_Request_Milestone__c = 'In Progress';
        //caseObj.Diagnosed_User__c =  u.Id;
        caseObj.TTI_Email_Notification_Opt_In__c = true;
       
        caseObj.Claim_Type__c = 'Warranty';
        caseObj.Retailer_Account__c = null;
       
        caseObj.RecordTypeId = RecordTypeIdCase;
        update caseObj;
        
        Test.startTest();
        caseObj.TTI_Freight_Out_Required__c = true;
        caseObj.TTI_Customer_Delivery_Method__c = 'Deliver';
        caseObj.Status = 'In Progress';
        caseObj.Service_Request_Milestone__c = 'Completed';
        caseObj.TTI_Email_Notification_Opt_In__c = true;
        
        try{
            update caseObj;
        }catch(Exception ex){
        
        }
        Test.stopTest();
        
    }
    
    static testmethod void sendEmailtoCustomerWhenClaimMarkedAsCompletetest4() {
        
        Id serviceAgentId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Agent').getRecordTypeId();
        
        Account serviceAgent = TTI_CommonUtilityClass.createAccount();
        serviceAgent.RecordTypeId = serviceAgentId;
        serviceAgent.Allow_Delivery_to_Customers__c = false;
        serviceAgent.Name = 'TEST_SERVICE_AGENT';
        serviceAgent.Phone = '+6112313131';
        serviceAgent.Freight_Company__c = 'Courier Post';
        serviceAgent.Type = 'Retailer';
        insert serviceAgent;
        
        Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        Contact objCon = TTI_CommonUtilityClass.createContact();
        insert objCon;
        //User u = TTI_CommonUtilityClass.createUser();
        //u.ContactId = objCon.Id;
        //u.Email = 'test@rest.com';
        //insert u;
        TTI_CommonUtilityClass.insertTemplates();
        Case caseObj = loadTestData();
        //Case caseObj = TTI_CommonUtilityClass.createCase();
        caseObj.Status = 'In Progress';
        caseObj.Service_Request_Milestone__c = 'In Progress';
        //caseObj.Diagnosed_User__c =  u.Id;
        caseObj.TTI_Email_Notification_Opt_In__c = true;
       
        caseObj.Claim_Type__c = 'Warranty';
        caseObj.Retailer_Account__c = serviceAgent.Id;
       
        caseObj.RecordTypeId = RecordTypeIdCase;
        update caseObj;
        
        Test.startTest();
        caseObj.TTI_Freight_Out_Required__c = true;
        caseObj.Status = 'In Progress';
        caseObj.Service_Request_Milestone__c = 'Completed';
        caseObj.TTI_Email_Notification_Opt_In__c = true;
        
        try{
            update caseObj;
        }catch(Exception ex){
        
        }
        Test.stopTest();
        
    }
    static testmethod void sendEmailtoCustomerWhenClaimMarkedAsCompletetest5() {
        
        Id serviceAgentId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Agent').getRecordTypeId();
        Account serviceAgent = TTI_CommonUtilityClass.createAccount();
        serviceAgent.RecordTypeId = serviceAgentId;
        serviceAgent.Allow_Delivery_to_Customers__c = false;
        serviceAgent.Name = 'TEST_SERVICE_AGENT';
        serviceAgent.Phone = '+6112313131';
        serviceAgent.Freight_Company__c = 'Courier Post';
        serviceAgent.Type = 'Retailer';
        insert serviceAgent;
        
        Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        Contact objCon = TTI_CommonUtilityClass.createContact();
        insert objCon;
        //User u = TTI_CommonUtilityClass.createUser();
        //u.ContactId = objCon.Id;
        //u.Email = 'test@rest.com';
        //insert u;
        TTI_CommonUtilityClass.insertTemplates();
        Case caseObj = loadTestData();
        //Case caseObj = TTI_CommonUtilityClass.createCase();
        caseObj.Status = 'In Progress';
        caseObj.Service_Request_Milestone__c = 'In Progress';
        //caseObj.Diagnosed_User__c =  u.Id;
        caseObj.TTI_Email_Notification_Opt_In__c = true;
       
        caseObj.Claim_Type__c = 'Warranty';
        caseObj.Retailer_Account__c = serviceAgent.Id;
       
        caseObj.RecordTypeId = RecordTypeIdCase;
        update caseObj;
        
        Test.startTest();
          
        caseObj.Status = 'In Progress';
        caseObj.Service_Request_Milestone__c = 'Completed';
        caseObj.TTI_Email_Notification_Opt_In__c = true;
        
        try{
            update caseObj;
        }catch(Exception ex){
        
        }
        Test.stopTest();
        
    }
    
    static testmethod void paymentevaluationtest2() {
        
        Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        
        Contact objCon = TTI_CommonUtilityClass.createContact();
        insert objCon;
        //User u = TTI_CommonUtilityClass.createUser();
        //u.ContactId = objCon.Id;
        //u.Email = 'test@rest.com';
        //insert u;
        
        TTI_CommonUtilityClass.insertTemplates();
        
        Case caseObj =loadTestData2();
        //Case caseObj = TTI_CommonUtilityClass.createCase();
        caseObj.Status = 'In Progress';
        caseObj.Service_Request_Milestone__c = 'Completed';
        //caseObj.Diagnosed_User__c =  u.Id;
        caseObj.TTI_Email_Notification_Opt_In__c = true;
        caseObj.Claim_Type__c = 'Non-Warranty';
        caseObj.TTI_Customer_Contact__c =objCon.Id;
        caseObj.RecordTypeId = RecordTypeIdCase;
        caseObj.TTI_Freight_in_tracking_url__c = 'www.test.com';
        caseObj.Freight_in_consignment_number__c = null;
        caseObj.SuppliedEmail = 'Test@test.com';
        caseObj.Closed_Reason__c = '';
        //caseObj.ownerid=u.id;
        caseObj.Invoiced_Approved__c = false;
        update caseObj;
        caseObj.Invoiced_Approved__c = true;
        
        update caseObj;
        
        caseObj.Claim_Type__c = 'Warranty';
        caseObj.Goodwill_parts_only__c = true;
        caseObj.Invoiced_Approved__c = false;
        update caseObj;
        caseObj.Invoiced_Approved__c = true;
        update caseObj;
        
        caseObj.Claim_Type__c = 'Warranty';
        caseObj.Goodwill_parts_only__c = false;
        caseObj.Invoiced_Approved__c = false;
        update caseObj;
        caseObj.Invoiced_Approved__c = true;
        caseObj.Repair_Type__c = 'Declined Warranty - Inspection fee';
        update caseObj;
        
        caseObj.Claim_Type__c = 'Warranty';
        caseObj.Repair_Type__c = 'Repair';
        caseObj.Goodwill_parts_only__c = false;
        caseObj.Invoiced_Approved__c = false;
        caseObj.Product_Payment_Category__c = 'Generators';
        caseObj.Product_Size_Category__c = 'Small';
        caseObj.Repair_Type__c='Engine Repair';
        caseObj.TTI_In_Progress_Datetime__c = date.today();
        caseObj.TTI_Completed_Datetime__c = date.today();
        caseObj.Total_Sundry_Expenses__c = 100.00;
        caseObj.TTI_Awaiting_Approval_Datetime__c = date.today();
        update caseObj;
        
        serviceAgentBonus__c SAbonus = new serviceAgentBonus__c();
        SAbonus.Name = 'Test';
        SAbonus.Grading__c = 'Bronze';
        SAbonus.Bonus_Amount_AUD__c = 10;
        SAbonus.Bonus_Amount_NZD__c = 20;
        SAbonus.RepairType__c = caseobj.Repair_Type__c;
        SAbonus.PaymentCategory__c = caseobj.Product_Payment_Category__c;
        SAbonus.Job_Duration__c = '24HR';
        insert SAbonus;
            
        PricingStructure__c ps = new PricingStructure__c();
        ps.Pricing_Type__c = caseobj.Repair_Type__c;
        ps.Name = 'Test';
        ps.Pricing_Amount_AUD__c = 10;
        ps.Pricing_Amount_NZD__c = 20;
        ps.Product_Category__c = caseobj.Product_Payment_Category__c;
        ps.Size__c = caseobj.Product_Size_Category__c;
        ps.Service_Agent_Status__c = 'Bronze';
        insert ps;
        
        GST_Rates__c ga = new GST_Rates__c();
        ga.Name = 'Australia';
        ga.Country__c = 'Australia';
        ga.GST_Rate__c = 15;
        insert ga;
        
        GST_Rates__c ga1 = new GST_Rates__c();
        ga1.Name = 'New Zealand';
        ga1.Country__c = 'New Zealand';
        ga1.GST_Rate__c = 15;
        insert ga1;
        Test.startTest();
        
        
        caseObj.Invoiced_Approved__c = true;
        update caseObj;
        
        
        caseObj.Invoiced_Approved__c = false;
        caseObj.TTI_In_Progress_Datetime__c = date.today();
        caseObj.TTI_Completed_Datetime__c = date.today().adddays(2);
        update caseObj;
        
        caseObj.Invoiced_Approved__c = true;
        update caseObj;
        
        caseObj.Invoiced_Approved__c = false;
        caseObj.TTI_In_Progress_Datetime__c = date.today();
        caseObj.TTI_Completed_Datetime__c = date.today().adddays(3);
        update caseObj;
        
        caseObj.Invoiced_Approved__c = true;
        update caseObj;
        
        Test.stopTest();
    }

    static testmethod void paymentevaluationtest3() {
        
        Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        
        Contact objCon = TTI_CommonUtilityClass.createContact();
        insert objCon;
        //User u = TTI_CommonUtilityClass.createUser();
        //u.ContactId = objCon.Id;
        //u.Email = 'test@rest.com';
        //insert u;
        
        TTI_CommonUtilityClass.insertTemplates();
        
        Case caseObj =loadTestData3();
        //Case caseObj = TTI_CommonUtilityClass.createCase();
        caseObj.Status = 'In Progress';
        caseObj.Service_Request_Milestone__c = 'Completed';
        //caseObj.Diagnosed_User__c =  u.Id;
        caseObj.TTI_Email_Notification_Opt_In__c = true;
        caseObj.Claim_Type__c = 'Non-Warranty';
        caseObj.TTI_Customer_Contact__c =objCon.Id;
        caseObj.RecordTypeId = RecordTypeIdCase;
        caseObj.TTI_Freight_in_tracking_url__c = 'www.test.com';
        caseObj.Freight_in_consignment_number__c = null;
        caseObj.SuppliedEmail = 'Test@test.com';
        caseObj.Closed_Reason__c = '';
        //caseObj.ownerid=u.id;
        caseObj.Invoiced_Approved__c = false;
        update caseObj;
        caseObj.Invoiced_Approved__c = true;
        
        update caseObj;
        
        caseObj.Claim_Type__c = 'Warranty';
        caseObj.Goodwill_parts_only__c = true;
        caseObj.Invoiced_Approved__c = false;
        update caseObj;
        caseObj.Invoiced_Approved__c = true;
        update caseObj;
        
        caseObj.Claim_Type__c = 'Warranty';
        caseObj.Goodwill_parts_only__c = false;
        caseObj.Invoiced_Approved__c = false;
        update caseObj;
        caseObj.Invoiced_Approved__c = true;
        caseObj.Repair_Type__c = 'Declined Warranty - Inspection fee';
        update caseObj;
        
        caseObj.Claim_Type__c = 'Warranty';
        caseObj.Repair_Type__c = 'Repair';
        caseObj.Goodwill_parts_only__c = false;
        caseObj.Invoiced_Approved__c = false;
        caseObj.Product_Payment_Category__c = 'Generators';
        caseObj.Product_Size_Category__c = 'Small';
        caseObj.Repair_Type__c='Engine Repair';
        caseObj.TTI_In_Progress_Datetime__c = date.today();
        caseObj.TTI_Completed_Datetime__c = date.today();
        caseObj.Total_Sundry_Expenses__c = 100.00;
        caseObj.TTI_Awaiting_Approval_Datetime__c = date.today();
        update caseObj;
        
        serviceAgentBonus__c SAbonus = new serviceAgentBonus__c();
        SAbonus.Name = 'Test';
        SAbonus.Grading__c = 'Bronze';
        SAbonus.Bonus_Amount_AUD__c = 10;
        SAbonus.Bonus_Amount_NZD__c = 20;
        SAbonus.RepairType__c = caseobj.Repair_Type__c;
        SAbonus.PaymentCategory__c = caseobj.Product_Payment_Category__c;
        SAbonus.Job_Duration__c = '24HR';
        insert SAbonus;
            
        PricingStructure__c ps = new PricingStructure__c();
        ps.Pricing_Type__c = caseobj.Repair_Type__c;
        ps.Name = 'Test';
        ps.Pricing_Amount_AUD__c = 10;
        ps.Pricing_Amount_NZD__c = 20;
        ps.Product_Category__c = caseobj.Product_Payment_Category__c;
        ps.Size__c = caseobj.Product_Size_Category__c;
        ps.Service_Agent_Status__c = 'Bronze';
        insert ps;
        
        GST_Rates__c ga = new GST_Rates__c();
        ga.Name = 'Australia';
        ga.Country__c = 'Australia';
        ga.GST_Rate__c = 15;
        insert ga;
        
        GST_Rates__c ga1 = new GST_Rates__c();
        ga1.Name = 'New Zealand';
        ga1.Country__c = 'New Zealand';
        ga1.GST_Rate__c = 15;
        insert ga1;
        Test.startTest();
        
        
        caseObj.Invoiced_Approved__c = true;
        update caseObj;
        
        
        caseObj.Invoiced_Approved__c = false;
        caseObj.TTI_In_Progress_Datetime__c = date.today();
        caseObj.TTI_Completed_Datetime__c = date.today().adddays(2);
        update caseObj;
        
        caseObj.Invoiced_Approved__c = true;
        update caseObj;
        
        caseObj.Invoiced_Approved__c = false;
        caseObj.TTI_In_Progress_Datetime__c = date.today();
        caseObj.TTI_Completed_Datetime__c = date.today().adddays(3);
        update caseObj;
        
        caseObj.Invoiced_Approved__c = true;
        update caseObj;
        
        Test.stopTest();
    }
    
    /**
    * @author: Ericka Cajucom
    * @date: 2020-06-18
    * @description: test Method sets Case Base Price from Null to 0 when no PricingStructure Matches
    */
    static testmethod void paymentevaluationtestZeroPay() {
        
        Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        
        Contact objCon = TTI_CommonUtilityClass.createContact();
        insert objCon;
        
        TTI_CommonUtilityClass.insertTemplates();
        
        Case caseObj = loadTestData2();
        caseObj.Status = 'In Progress';
        caseObj.Service_Request_Milestone__c = 'Completed';
        caseObj.TTI_Email_Notification_Opt_In__c = true;
        caseObj.TTI_Customer_Contact__c =objCon.Id;
        caseObj.RecordTypeId = RecordTypeIdCase;
        caseObj.TTI_Freight_in_tracking_url__c = 'www.test.com';
        caseObj.Freight_in_consignment_number__c = null;
        caseObj.SuppliedEmail = 'Test@test.com';
        caseObj.Closed_Reason__c = '';
        caseObj.Invoiced_Approved__c = false;
        caseObj.Claim_Type__c = 'Warranty';
        caseObj.Product_Payment_Category__c = 'Generators';
        caseObj.Product_Size_Category__c = 'Small';
        caseobj.Repair_Type__c = 'Replacement';
        caseObj.TTI_In_Progress_Datetime__c = date.today();
        caseObj.TTI_Completed_Datetime__c = date.today().adddays(3);
        caseObj.Brand__c = 'AEG';
        update caseObj;
        
        PricingStructure__c ps = new PricingStructure__c();
        ps.Pricing_Type__c = caseobj.Repair_Type__c;
        ps.Name = 'Test';
        ps.Pricing_Amount_AUD__c = 10;
        ps.Pricing_Amount_NZD__c = 20;
        ps.Product_Category__c = caseobj.Product_Payment_Category__c;
        ps.Size__c = caseobj.Product_Size_Category__c;
        ps.Service_Agent_Status__c = 'Platinum';
        insert ps;
        
        GST_Rates__c ga = new GST_Rates__c();
        ga.Name = 'Australia';
        ga.Country__c = 'Australia';
        ga.GST_Rate__c = 15;
        insert ga;
        
        GST_Rates__c gnz = new GST_Rates__c();
        gnz.Name = 'New Zealand';
        gnz.Country__c = 'New Zealand';
        gnz.GST_Rate__c = 15;
        insert gnz;
        
        Test.startTest();
        
        caseObj.Invoiced_Approved__c = true;
        update caseObj;
        
        Test.stopTest();
        
        List<Case> casePayment = [SELECT Id, 
                                Base_Amount_Payable_AUD__c, 
                                Base_GST_Payable_AUD__c, 
                                Base_Amount_Payable_NZD__c, 
                                Base_GST_Payable_NZD__c 
                                FROM Case 
                                WHERE Id = :caseObj.Id];

        String errorMsg = 'Base Amount was not updated!';
        System.assert(casePayment[0].Base_Amount_Payable_AUD__c != null && casePayment[0].Base_Amount_Payable_AUD__c == 0, errorMsg);
        System.assert(casePayment[0].Base_Amount_Payable_AUD__c != null && casePayment[0].Base_Amount_Payable_AUD__c == 0, errorMsg);
        System.assert(casePayment[0].Base_GST_Payable_AUD__c != null && casePayment[0].Base_GST_Payable_AUD__c == 0, errorMsg);
        System.assert(casePayment[0].Base_GST_Payable_NZD__c != null && casePayment[0].Base_GST_Payable_NZD__c == 0, errorMsg);
    }
    
    /**
    * @author: Ericka Cajucom
    * @date: 2020-06-18
    * @description: negative scenario, when no email is sent to customer
    */
    static testmethod void noEmailSenttoCustomerWhenClaimApprovedtest() {
        
        Id retailerAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Agent').getRecordTypeId();
        
        Account retailerAccount = TTI_CommonUtilityClass.createAccount();
        retailerAccount.RecordTypeId = retailerAccountId;
        retailerAccount.Allow_Delivery_to_Customers__c = false;
        retailerAccount.Name = 'TEST_SERVICE_AGENT';
        retailerAccount.Phone = '+6112313131';
        retailerAccount.Freight_Company__c = 'Courier Post';
        retailerAccount.Type = 'Retailer';
        insert retailerAccount;
        
        Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        
        Contact objCon = TTI_CommonUtilityClass.createContact();
        insert objCon;
        Case caseObj = loadTestData2();
        caseObj.Closed_Reason__c = '';
        caseObj.RecordTypeId = RecordTypeIdCase;
        caseObj.Retailer_Account__c = retailerAccount.Id;
        caseObj.TTI_Freight_Out_Required__c = true;
        caseObj.Brand__c = 'AEG';
        update caseObj;
        
        Test.startTest();
        
        caseObj.Approved_Flag__c = true;
        caseObj.TTI_Email_Notification_Opt_In__c = true;
        
        update caseObj;
        
        Integer actualLimits = Limits.getEmailInvocations();
        
        Test.stopTest();
        actualLimits = Limits.getEmailInvocations();
        System.assertEquals(0, actualLimits, 'Wrong Email Sent.');
    }
    
    static testmethod void sendNotificationAfterLimittest() {
        
        Id retailerAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Agent').getRecordTypeId();
        
        Account retailerAccount = TTI_CommonUtilityClass.createAccount();
        retailerAccount.RecordTypeId = retailerAccountId;
        retailerAccount.Allow_Delivery_to_Customers__c = false;
        retailerAccount.Name = 'TEST_SERVICE_AGENT';
        retailerAccount.Phone = '+6112313131';
        retailerAccount.Freight_Company__c = 'Courier Post';
        retailerAccount.Type = 'Retailer';
        insert retailerAccount;
        
        Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        Contact objCon = TTI_CommonUtilityClass.createContact();
        insert objCon;
        
        User thisUser = TTI_CommonUtilityClass.createUser();
        thisUser.Email = 'test@rest.com';
        thisUser.ContactId = objCon.Id;
        insert thisUser;
        System.runAs (thisUser) {
            EmailTemplate emlThreshold = new EmailTemplate (
                developerName = 'TTI_Threshold_Email_Notification',
                FolderId = UserInfo.getUserId(),
                TemplateType= 'Text',
                Name = 'TTI_Threshold_Email_Notification',
                isActive = true
            ); 
            insert emlThreshold;
        }
        List<Case> newCases = new List<Case>();
        
        Case caseObj = loadTestData2();
        
        objCon.AccountId = caseObj.AccountId;
        update objCon;
        
        caseObj.Closed_Reason__c = '';
        caseObj.RecordTypeId = RecordTypeIdCase;
        caseObj.Retailer_Account__c = retailerAccount.Id;
        caseObj.TTI_Freight_Out_Required__c = true;
        caseObj.Brand__c = 'AEG';
        caseObj.Completion_Date__c = Date.newInstance(System.today().Year(), System.today().month(), 1);
        caseObj.Total_Sundry_Expenses__c = 80;
        caseObj.ContactId = objCon.Id;
        update caseObj;
        
        GST_Rates__c gnz = new GST_Rates__c();
        gnz.Name = 'New Zealand';
        gnz.Country__c = 'New Zealand';
        gnz.GST_Rate__c = 15;
        insert gnz;
        
        Test.startTest();
        
        caseObj.Approved_Flag__c = true;
        caseObj.Invoiced_Approved__c = true;
        caseObj.TTI_Email_Notification_Opt_In__c = true;
        update caseObj;
        newCases.add(caseObj);
        
        TTI_CaseTriggerHandler.sendNotificationAfterLimit(newCases, null);
        Integer actualLimits = Limits.getEmailInvocations();
        
        Test.stopTest();
        
        System.assertEquals(1, actualLimits, 'No Email Sent to Service Agent.');
    }
}