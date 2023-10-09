@isTest
public class TTI_CaseTriggerHandlerTest {

    /**
    * @author: Shivam Singh
    * @date: Jan 2018
    * @description: Test class for TTI_CaseTriggerHandler.
    */    
    public static Case loadTestData() {
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
    
    public static Case loadTestData2() {
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

    public static Case loadTestData3() {
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
        try {
            update caseObjUpdate3;
        } catch (Exception ex) {
        
        }
        Test.stopTest();
    }
    
    static testmethod void sendEmailtoCustomerWhenClaimMarkedAsCompletetest2() {
        
        Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        
        Contact objCon = TTI_CommonUtilityClass.createContact();
        insert objCon;
        
        TTI_CommonUtilityClass.insertTemplates();
        
        Case caseObj = loadTestData();        
        caseObj.Status = 'In Progress';
        caseObj.Service_Request_Milestone__c = 'In Progress';
        caseObj.TTI_Email_Notification_Opt_In__c = true;
        caseObj.Claim_Type__c = 'Warranty';
        caseObj.RecordTypeId = RecordTypeIdCase;
        update caseObj;
        
        Test.startTest();
        caseObj.Status = 'In Progress';
        caseObj.Service_Request_Milestone__c = 'Completed';
        caseObj.TTI_Email_Notification_Opt_In__c = true;
        
        try {
            update caseObj;
        } catch (Exception ex) {
        
        }

        Test.stopTest();
    }
    
    static testmethod void sendEmailtoCustomerWhenClaimMarkedAsCompletetest3() {
        
        Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        Contact objCon = TTI_CommonUtilityClass.createContact();
        insert objCon;
        
        TTI_CommonUtilityClass.insertTemplates();

        Case caseObj = loadTestData();
        caseObj.Status = 'In Progress';
        caseObj.Service_Request_Milestone__c = 'In Progress';
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
        
        try {
            update caseObj;
        } catch (Exception ex) {
        
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

        TTI_CommonUtilityClass.insertTemplates();

        Case caseObj = loadTestData();
        caseObj.Status = 'In Progress';
        caseObj.Service_Request_Milestone__c = 'In Progress';
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
        
        try {
            update caseObj;
        } catch (Exception ex) {
        
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
        
        TTI_CommonUtilityClass.insertTemplates();
        Case caseObj = loadTestData();
        caseObj.Status = 'In Progress';
        caseObj.Service_Request_Milestone__c = 'In Progress';        
        caseObj.TTI_Email_Notification_Opt_In__c = true;       
        caseObj.Claim_Type__c = 'Warranty';
        caseObj.Retailer_Account__c = serviceAgent.Id;       
        caseObj.RecordTypeId = RecordTypeIdCase;
        update caseObj;
        
        Test.startTest();
          
        caseObj.Status = 'In Progress';
        caseObj.Service_Request_Milestone__c = 'Completed';
        caseObj.TTI_Email_Notification_Opt_In__c = true;
        
        try {
            update caseObj;
        } catch (Exception ex) {
        
        }

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
    

    
    static testmethod void sendEmailtoCustomerWhenClaimRejectedtest() {
        
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
                developerName = 'TTI_RejectedWarrantyClaimTemplate',
                FolderId = UserInfo.getUserId(),
                TemplateType= 'Text',
                Name = 'TTI_RejectedWarrantyClaimTemplate',
                isActive = true
            ); 
            insert emlThreshold;
        }
        List<Case> newCases = new List<Case>();
        Map<Id, Case> oldCases = new Map<Id, Case>();
        
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
        caseObj.Service_Request_Milestone__c = 'New';
        caseObj.Closed_Reason__c = '';
        caseObj.Diagnosed_User__c = thisUser.Id;
        update caseObj;
        oldCases.put(caseObj.Id,caseObj);
        
        GST_Rates__c gnz = new GST_Rates__c();
        gnz.Name = 'New Zealand';
        gnz.Country__c = 'New Zealand';
        gnz.GST_Rate__c = 15;
        insert gnz;
        
        Test.startTest();
        
            caseObj.Service_Request_Milestone__c = 'Closed';
            caseObj.Closed_Reason__c = 'Rejected by Warranty Team';
            update caseObj;
            newCases.add(caseObj);
            
            TTI_CaseTriggerHandler.sendEmailtoCustomerWhenClaimRejected(newCases, oldCases);
            
        Test.stopTest();
        
    }
    

    static testmethod void sendEmailtoCustomerWhenClaimApprovedtest() {
        
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
                developerName = 'TTI_RejectedWarrantyClaimTemplate',
                FolderId = UserInfo.getUserId(),
                TemplateType= 'Text',
                Name = 'TTI_RejectedWarrantyClaimTemplate',
                isActive = true
            ); 
            insert emlThreshold;
        }
        List<Case> newCases = new List<Case>();
        Map<Id, Case> oldCases = new Map<Id, Case>();
        
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
        caseObj.Service_Request_Milestone__c = 'New';
        caseObj.Approved_Flag__c = false;
        update caseObj;
        oldCases.put(caseObj.Id,caseObj);
        
        GST_Rates__c gnz = new GST_Rates__c();
        gnz.Name = 'New Zealand';
        gnz.Country__c = 'New Zealand';
        gnz.GST_Rate__c = 15;
        insert gnz;
        
        Test.startTest();
        
            caseObj.Approved_Flag__c = true;
            caseObj.Service_Request_Milestone__c = 'In Progress';
            caseObj.TTI_Customer_Contact__c = objCon.Id;
            update caseObj;
            newCases.add(caseObj);
            
            TTI_CaseTriggerHandler.sendEmailtoCustomerWhenClaimApproved(newCases, oldCases);
            
        Test.stopTest();
        
    }

    static testmethod void deleteReceiptAndQuotePdftest() {
        
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
                developerName = 'TTI_RejectedWarrantyClaimTemplate',
                FolderId = UserInfo.getUserId(),
                TemplateType= 'Text',
                Name = 'TTI_RejectedWarrantyClaimTemplate',
                isActive = true
            ); 
            insert emlThreshold;
        }
        List<Case> newCases = new List<Case>();
        Map<Id, Case> oldCases = new Map<Id, Case>();
        
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
        caseObj.Invoice_Number_PC__c = null;
        update caseObj;
        oldCases.put(caseObj.Id,caseObj);
        
        GST_Rates__c gnz = new GST_Rates__c();
        gnz.Name = 'New Zealand';
        gnz.Country__c = 'New Zealand';
        gnz.GST_Rate__c = 15;
        insert gnz;
        
        Test.startTest();
        
            caseObj.Invoice_Number_PC__c = '1234567890';
            caseObj.SAP_Error_Text__c = '';
            caseObj.Freight_Error_Text__c = '';
            caseObj.TTI_Freight_Out_Required__c = false;
            update caseObj;
            newCases.add(caseObj);
            
            TTI_CaseTriggerHandler.deleteReceiptAndQuotePdf(newCases, oldCases);
            
        Test.stopTest();
        
    }

    static testmethod void sendEmailtoTrackTheStatusOfDeliverytest() {
        
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
                developerName = 'TTI_RejectedWarrantyClaimTemplate',
                FolderId = UserInfo.getUserId(),
                TemplateType= 'Text',
                Name = 'TTI_RejectedWarrantyClaimTemplate',
                isActive = true
            ); 
            insert emlThreshold;
        }
        List<Case> newCases = new List<Case>();
        Map<Id, Case> oldCases = new Map<Id, Case>();
        
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
        caseObj.TTI_Freight_in_tracking_url__c = 'www.test.com';
        caseObj.TTI_Freight_out_tracking_url__c = 'www.test.com';
        caseObj.Brand__c = 'AEG';
        caseObj.Freight_in_consignment_number__c = null;
        caseObj.Freight_out_consignment_number__c = null;
        update caseObj;
        oldCases.put(caseObj.Id,caseObj);
        
        GST_Rates__c gnz = new GST_Rates__c();
        gnz.Name = 'New Zealand';
        gnz.Country__c = 'New Zealand';
        gnz.GST_Rate__c = 15;
        insert gnz;
        
        Test.startTest();
        
            caseObj.TTI_Customer_Contact__c = objCon.Id;
            caseObj.TTI_Email_Notification_Opt_In__c = true;
            caseObj.Freight_in_consignment_number__c = '124321643';
            caseObj.Freight_out_consignment_number__c = '125436436';
            update caseObj;
            newCases.add(caseObj);
            
            TTI_CaseTriggerHandler.sendEmailtoTrackTheStatusOfDelivery(newCases, oldCases);
            
        Test.stopTest();
        
    }

    static testmethod void sendEmailtoCustomerWhenNonWarrantyClaimRejectedtest() {
        
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
                developerName = 'TTI_RejectedNonWarrantyClaimToCustomer',
                FolderId = UserInfo.getUserId(),
                TemplateType= 'Text',
                Name = 'TTI_RejectedNonWarrantyClaimToCustomer',
                isActive = true
            ); 
            insert emlThreshold;
        }
        List<Case> newCases = new List<Case>();
        Map<Id, Case> oldCases = new Map<Id, Case>();
        
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
        caseObj.Service_Request_Milestone__c = 'New';
        caseObj.Closed_Reason__c = '';
        caseObj.ContactId = objCon.Id;
        update caseObj;
        oldCases.put(caseObj.Id,caseObj);
        
        GST_Rates__c gnz = new GST_Rates__c();
        gnz.Name = 'New Zealand';
        gnz.Country__c = 'New Zealand';
        gnz.GST_Rate__c = 15;
        insert gnz;
        
        Test.startTest();
        
            caseObj.Service_Request_Milestone__c = 'Closed';
            caseObj.Closed_Reason__c = 'Rejected by Customer';
            caseObj.TTI_Email_Notification_Opt_In__c = true;
            caseObj.SuppliedEmail = 'test@test.com';
            update caseObj;
            newCases.add(caseObj);
            
            TTI_CaseTriggerHandler.sendEmailtoCustomerWhenNonWarrantyClaimRejected(newCases, oldCases);
            
        Test.stopTest();
        
    }

    
}