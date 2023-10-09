@isTest
public class TTI_Invoice_Auto_Approval_ProcessTracker {
	
    public static string setupdata(){
        Id sRRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        Account accObj = TTI_CommonUtilityClass.createAccount();

        Contact objCon = TTI_CommonUtilityClass.createContact();
        insert objCon;

        TTI_CommonUtilityClass.insertTemplates();

        Product2 prod = new Product2(Name = 'Laptop X200', Family = 'Hardware',SAP_Material_Group__c='RD-TL');
        insert prod;

        Asset objAsset = new Asset(Name = 'Test', 
                               AccountId = accObj.Id, 
                               ContactId = objCon.id, 
                               Product2Id = prod.Id, 
                               Allow_Numbers_Only__c = true, 
                               Display_Week__c = true, 
                               Display_Year__c = true,
                               HelpText__c = 'Test Helper Text',
                               Regexpression_Validator__c = 'Exp',
                               Serial_Number_Length__c = 20,
                               SerialNumber='1123454');
        insert objAsset;

        Id b2cRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Agent').getRecordTypeId();
        Account objAc1 = new Account();
        objAc1.RecordTypeId = b2cRecTypeId;
        objAc1.Name = 'Saas1 Test1';
        objAc1.Type = 'Service Agent';
        objAc1.Max_Claimable_Sundry_Expenses__c = 10;
        objAc1.Brands__c = 'Ryobi'+';';
        objAc1.Record_Status__c = 'Active';
        objAc1.Service_Agent_Status__c = 'Bronze';
        insert objAc1;

        Contact objConTNotIn = new Contact();
        objConTNotIn.Email = 'test@rest.com';
        objConTNotIn.FirstName = 'Test';
        objConTNotIn.LastName = 'Saas';  
        insert objConTNotIn;

        Case caseObj = TTI_CommonUtilityClass.createCase();        
        caseObj.AccountId = objAc1.Id;
        caseObj.Diagnosed_Date__c = System.today().addDays(-3);
        caseObj.Product_Name__c = prod.id;
        caseObj.RecordTypeId = sRRecTypeId; 
        caseObj.Product_Payment_Category__c = 'Generators';
        caseObj.Product_Size_Category__c = 'Small';
        caseObj.Repair_Type__c = 'Declined Warranty - Inspection fee';
        caseObj.Claim_Type__c = 'Non-Warranty';
        caseObj.Purchase_Date__c = System.today().addDays(-10);
        caseObj.Service_Request_Milestone__c = 'New';
        caseObj.Closed_Reason__c = 'Service Request Completed';
        caseObj.TTI_Email_Notification_Opt_In__c = true;
        caseObj.TTI_Customer_Contact__c = objCon.Id;
        caseObj.Total_Sundry_Expenses__c = 500;
        caseObj.Invoiced_Approved__c = false;
        caseObj.SuppliedEmail = 'test123@test.com';
        caseObj.Repair_Type__c = 'Engine Repair';
        caseObj.Service_Agent__c = objAc1.id;
        caseObj.Invoice_Manually_Approved__c = false;
        Insert caseObj;
        return caseObj.Id;
    } 
	
    private static Testmethod void Nonwarranty(){
        Test.startTest();

        Id caseobjid = setupdata();
        Case caseobj = [Select Id,Total_Sundry_Expenses__c ,Claim_Type__c,Invoice_Manually_Approved__c,Product_Size_Category__c,Invoice_Auto_Approved__c,Invoice_Approved_Date__c,Product_Payment_Category__c,Number_of_Interactions__c,Manual_Invoice_Approval_Reason__c,Service_Request_Milestone__c,Service_Agent__r.Max_Claimable_Sundry_Expenses__c,Product_Name__r.SAP_Material_Group__c,Repair_Type__c From Case where id = :caseobjid limit 1];


        List<id> lstid = new List<id>();
        lstid.add(caseobj.Id);
        TTI_Invoice_Auto_Approval_Process.restartapprovalprocess(lstid);

        Test.stopTest();
    }
    
    private static Testmethod void warrantywithoutservicelines(){
        Test.startTest();
        
        Id caseobjid = setupdata();
        Case caseobj = [Select Id,Total_Sundry_Expenses__c ,Claim_Type__c,Invoice_Manually_Approved__c,Product_Size_Category__c,Invoice_Auto_Approved__c,Invoice_Approved_Date__c,Product_Payment_Category__c,Number_of_Interactions__c,Manual_Invoice_Approval_Reason__c,Service_Request_Milestone__c,Service_Agent__r.Max_Claimable_Sundry_Expenses__c,Product_Name__r.SAP_Material_Group__c,Repair_Type__c From Case where id = :caseobjid limit 1];
        caseobj.Claim_Type__c = 'Warranty';
        update caseobj;

        //try{

        //List<id> lstid = new List<id>();
        //lstid.add(caseobj.Id);
        //TTI_Invoice_Auto_Approval_Process.autoapprove(lstid);
        TTI_ServiceRequestController.submitInvoiceForApprovalMethod(caseobj.Id);
        //}catch(exception e){
        //system.debug('Exception--'+e.getMessage());
        //}

        Test.stopTest();
    }
		
    private static Testmethod void criteria1(){
        Test.startTest();
        Id caseobjid = setupdata();
        Case caseobj = [Select Id,Total_Sundry_Expenses__c ,Claim_Type__c,Invoice_Manually_Approved__c,Product_Size_Category__c,Invoice_Auto_Approved__c,Invoice_Approved_Date__c,Product_Payment_Category__c,Number_of_Interactions__c,Manual_Invoice_Approval_Reason__c,Service_Request_Milestone__c,Service_Agent__r.Max_Claimable_Sundry_Expenses__c,Product_Name__r.SAP_Material_Group__c,Repair_Type__c From Case where id = :caseobjid limit 1];
        caseobj.Claim_Type__c = 'Warranty';
        caseobj.Total_Sundry_Expenses__c = 9;
        update caseobj;



            //try{
                
                List<id> lstid = new List<id>();
                lstid.add(caseobj.Id);
                TTI_Invoice_Auto_Approval_Process.autoapprove(lstid);
            
            //}catch(exception e){
                //system.debug('Exception--'+e.getMessage());
            //}

        Test.stopTest();
    }
		
    private static Testmethod void criteria2(){
        Test.startTest();
        Id caseobjid = setupdata();
        Case caseobj = [Select Id,Total_Sundry_Expenses__c ,Claim_Type__c,Invoice_Manually_Approved__c,Product_Size_Category__c,Invoice_Auto_Approved__c,Invoice_Approved_Date__c,Product_Payment_Category__c,Number_of_Interactions__c,Manual_Invoice_Approval_Reason__c,Service_Request_Milestone__c,Service_Agent__r.Max_Claimable_Sundry_Expenses__c,Product_Name__r.SAP_Material_Group__c,Repair_Type__c From Case where id = :caseobjid limit 1];
        caseobj.Claim_Type__c = 'Warranty';
        caseobj.Total_Sundry_Expenses__c = 11;
        update caseobj;

        ServiceAgentBonus__c SAbonus = new ServiceAgentBonus__c();
        SAbonus.Name = 'Test';
        SAbonus.Grading__c = 'Bronze';
        SAbonus.Bonus_Amount_AUD__c = 10;
        SAbonus.Bonus_Amount_NZD__c = 20;
        SAbonus.RepairType__c = caseobj.Repair_Type__c;
        SAbonus.PaymentCategory__c = caseobj.Product_Payment_Category__c;
        Insert SAbonus;

        //try{

        List<id> lstid = new List<id>();
        lstid.add(caseobj.Id);
        TTI_Invoice_Auto_Approval_Process.autoapprove(lstid);

        //}catch(exception e){
        //system.debug('Exception--'+e.getMessage());
        //}

        Test.stopTest();
    }

    private static Testmethod void criteria3(){
        Test.startTest();
        Id caseobjid = setupdata();
        Case caseobj = [Select Id,Total_Sundry_Expenses__c ,Claim_Type__c,Invoice_Manually_Approved__c,Product_Size_Category__c,Invoice_Auto_Approved__c,Invoice_Approved_Date__c,Product_Payment_Category__c,Number_of_Interactions__c,Manual_Invoice_Approval_Reason__c,Service_Request_Milestone__c,Service_Agent__r.Max_Claimable_Sundry_Expenses__c,Product_Name__r.SAP_Material_Group__c,Repair_Type__c From Case where id = :caseobjid limit 1];
        caseobj.Claim_Type__c = 'Warranty';
        caseobj.Total_Sundry_Expenses__c = 11;
        caseobj.Product_Payment_Category__c = 'Forcelogic';
        caseobj.Repair_Type__c = 'Repair';
        update caseobj;

        Product2 prod1 = new Product2(Name = 'Laptop X200', Family = 'Hardware',SAP_Material_Group__c='RD-TL');
        insert prod1;

        Service_Request_Line_Item__c sli1 = new Service_Request_Line_Item__c();
        sli1.Service_Request_Number__c = caseobj.id;
        sli1.Part_Number__c = prod1.Id;
        sli1.Order_Line_Type__c = 'Part';
        sli1.Order_Line_Category__c = 'Bill of Materials';
        insert sli1;

        ServiceAgentBonus__c SAbonus = new ServiceAgentBonus__c();
        SAbonus.Name = 'Test';
        SAbonus.Grading__c = 'Bronze';
        SAbonus.Bonus_Amount_AUD__c = 10;
        SAbonus.Bonus_Amount_NZD__c = 20;
        SAbonus.RepairType__c = caseobj.Repair_Type__c;
        SAbonus.PaymentCategory__c = caseobj.Product_Payment_Category__c;
        Insert SAbonus;

        //try{

        List<id> lstid = new List<id>();
        lstid.add(caseobj.Id);
        TTI_Invoice_Auto_Approval_Process.autoapprove(lstid);

        //}catch(exception e){
        //system.debug('Exception--'+e.getMessage());
        //}

        Test.stopTest();
    }

    private static Testmethod void criteria4(){
        Test.startTest();
        Id caseobjid = setupdata();
        Case caseobj = [Select Id,Total_Sundry_Expenses__c ,Claim_Type__c,Invoice_Manually_Approved__c,Product_Size_Category__c,Invoice_Auto_Approved__c,Invoice_Approved_Date__c,Product_Payment_Category__c,Number_of_Interactions__c,Manual_Invoice_Approval_Reason__c,Service_Request_Milestone__c,Service_Agent__r.Max_Claimable_Sundry_Expenses__c,Product_Name__r.SAP_Material_Group__c,Repair_Type__c From Case where id = :caseobjid limit 1];
        caseobj.Claim_Type__c = 'Warranty';
        caseobj.Total_Sundry_Expenses__c = 9;
        update caseobj;

        Product2 prod1 = new Product2(Name = 'Laptop X200', Family = 'Hardware',SAP_Material_Group__c='RD-TL');
        insert prod1;

        Service_Request_Line_Item__c sli1 = new Service_Request_Line_Item__c();
        sli1.Service_Request_Number__c = caseobj.id;
        sli1.Part_Number__c = prod1.Id;
        sli1.Order_Line_Type__c = 'Part';
        sli1.Order_Line_Category__c = 'Bill of Materials';
        insert sli1;

        /*ServiceAgentBonus__c SAbonus = new ServiceAgentBonus__c();
        SAbonus.Name = 'Test';
        SAbonus.Grading__c = 'Bronze';
        SAbonus.Bonus_Amount_AUD__c = 10;
        SAbonus.Bonus_Amount_NZD__c = 20;
        SAbonus.RepairType__c = caseobj.Repair_Type__c;
        SAbonus.PaymentCategory__c = caseobj.Product_Payment_Category__c;
        Insert SAbonus; */

        PricingStructure__c ps = new PricingStructure__c();
        ps.Pricing_Type__c = caseobj.Repair_Type__c;
        ps.Name = 'Test';
        ps.Pricing_Amount_AUD__c = 10;
        ps.Pricing_Amount_NZD__c = 20;
        ps.Product_Category__c = caseobj.Product_Payment_Category__c;
        ps.Size__c = caseobj.Product_Size_Category__c;
        ps.Service_Agent_Status__c = 'Bronze';
        insert ps;
        //try{

        List<id> lstid = new List<id>();
        lstid.add(caseobj.Id);
        TTI_Invoice_Auto_Approval_Process.autoapprove(lstid);

        //}catch(exception e){
        //system.debug('Exception--'+e.getMessage());
        //}

    Test.stopTest();
    }
        
    /**
    * @author: Ericka Cajucom
    * @date: 2020-06-18
    * @description: Send case for approval when sundry exceeds max threshold
    */
    private static Testmethod void sundryExpensesExceedsMaximumThresholdTest(){
        
        List<id> lstid = new List<id>();
        
        Id serviceAgentId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Agent').getRecordTypeId();
        
        Account serviceAgent = TTI_CommonUtilityClass.createAccount();
        serviceAgent.RecordTypeId = serviceAgentId;
        serviceAgent.Allow_Delivery_to_Customers__c = false;
        serviceAgent.Name = 'TEST_SERVICE_AGENT';
        serviceAgent.Phone = '+6112313131';
        serviceAgent.Freight_Company__c = 'Courier Post';
        serviceAgent.Freight_Company_Account_Number__c = '21946011';
        insert serviceAgent;
        
        Contact objCon = TTI_CommonUtilityClass.createContact();
        objCon.AccountId = serviceAgent.Id;
		insert objCon;
        
        User thisUser = TTI_CommonUtilityClass.createUser();
        thisUser.Email = 'test@rest.com';
        thisUser.ContactId = objCon.Id;
        insert thisUser;
        
        System.runAs (thisUser) {
            Id caseobjid = setupdata();
            Case caseobj = [SELECT Id,
                            Total_Sundry_Expenses__c, 
                            Claim_Type__c,
                            Invoice_Manually_Approved__c,
                            Product_Size_Category__c, 
                            Invoice_Auto_Approved__c,
                            Invoice_Approved_Date__c,
                            Product_Payment_Category__c,
                            Number_of_Interactions__c,
                            Manual_Invoice_Approval_Reason__c,
                            Service_Request_Milestone__c,
                            Service_Agent__r.Max_Claimable_Sundry_Expenses__c,
                            Product_Name__r.SAP_Material_Group__c,
                            Repair_Type__c 
                            FROM Case 
                            WHERE Id = :caseobjid LIMIT 1];

            caseobj.Claim_Type__c = 'Warranty';
            caseobj.Total_Sundry_Expenses__c = 9;
            caseobj.Completion_Date__c = Date.newInstance(System.today().Year(), System.today().month(), 1);
            caseobj.OwnerId = thisUser.Id;
            update caseobj;
            
            Product2 prod1 = new Product2(
                Name = 'Laptop X200', 
                Family = 'Hardware',
                SAP_Material_Group__c = 'RD-TL');
            insert prod1;
            
            Service_Request_Line_Item__c sli = new Service_Request_Line_Item__c();
            sli.Service_Request_Number__c = caseobj.id;
            sli.Part_Number__c = prod1.Id;
            sli.Order_Line_Type__c = 'Part';
            sli.Order_Line_Category__c = 'Bill of Materials';
            insert sli;
            
            /*ServiceAgentBonus__c SAbonus = new ServiceAgentBonus__c();
            SAbonus.Name = 'Test';
            SAbonus.Grading__c = 'Bronze';
            SAbonus.Bonus_Amount_AUD__c = 10;
            SAbonus.Bonus_Amount_NZD__c = 20;
            SAbonus.RepairType__c = caseobj.Repair_Type__c;
            SAbonus.PaymentCategory__c = caseobj.Product_Payment_Category__c;
            Insert SAbonus;*/
            
            PricingStructure__c ps = new PricingStructure__c();
            ps.Pricing_Type__c = caseobj.Repair_Type__c;
            ps.Name = 'Test';
            ps.Pricing_Amount_AUD__c = 10;
            ps.Pricing_Amount_NZD__c = 20;
            ps.Product_Category__c = caseobj.Product_Payment_Category__c;
            ps.Size__c = caseobj.Product_Size_Category__c;
            ps.Service_Agent_Status__c = 'Bronze';
            insert ps;
                
            
            lstid.add(caseobj.Id);
        }
        
        Test.startTest();
		System.runAs (thisUser) {
			TTI_Invoice_Auto_Approval_Process.autoapprove(lstid);
		}
        Test.stopTest();
        
        List<ProcessInstance> objProcessInstance = [SELECT Id, TargetObjectId, CreatedDate FROM ProcessInstance WHERE TargetObjectId IN :lstid];
        
        System.assertNotEquals(null, objProcessInstance, 'No Approval Process');
    }
}