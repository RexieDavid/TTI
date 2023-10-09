@isTest
public class TTI_ServiceRequest_Auto_Approval_ProTest {
/**
* @author: Shivam Singh
* @date: Jan 2018
* @description: Test class for TTI_ServiceRequest_Auto_Approval_Process.
*/
  
    static testmethod void testTTI_ServiceRequest_Auto_Approval_Process() {
        Group g1 = new Group(Name='group name', type='Queue');
        insert g1;
        QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
        insert q1;
        
        User u = new User(Id=userinfo.getuserid());
        system.runAs(u){
            TTI_CommonUtilityClass.insertTemplates();
        
            Product2 prod = new Product2(Name = 'Laptop X200', Family = 'Hardware', AU_Landed_Cost__c=null, NZ_Landed_Cost__c = null, Maximum_Number_of_Parts__c=0, SOH_BP01__c=1, Standard_Warranty_Months__c = -10.00);
            insert prod;
            
            Case caseObj = TTI_CommonUtilityClass.createCase();
            caseObj.Goodwill__c = true;
            caseObj.Goodwill_parts_only__c = false;
            caseObj.Claim_Type__c = 'Warranty';
            caseObj.Purchase_Date__c = system.today();
            caseObj.Product_Name__c = prod.Id;
            insert caseObj; 
            
            AutoApproval_Percentage__c autoApprovalPercentage = new AutoApproval_Percentage__c();
            autoApprovalPercentage.Name = 'SOH_Percentage';
            autoApprovalPercentage.AutoApproval_Percentage__c =1;
            insert autoApprovalPercentage;
            
            Service_Request_Line_Item__c serviceRequestLineItemObj = new Service_Request_Line_Item__c();
            serviceRequestLineItemObj.Order_Line_Type__c = 'Part';
            serviceRequestLineItemObj.Order_Line_Category__c = 'Manual entry';
            serviceRequestLineItemObj.Service_Request_Number__c = caseObj.Id;
            serviceRequestLineItemObj.Part_Number__c = prod.Id;
            serviceRequestLineItemObj.Quantity__c = 2;
            insert serviceRequestLineItemObj;
            AutoApproval_Percentage__c autoApprovalPerObj = new AutoApproval_Percentage__c();
            autoApprovalPerObj.Name = 'Cost_Percentage';
            autoApprovalPerObj.AutoApproval_Percentage__c = 80.00;
            insert autoApprovalPerObj;
            
             TTI_ServiceRequest_Auto_Approval_Process.autoapprove(caseObj.Id);
            
            ProductParts__c productPartObj = new ProductParts__c();
            productPartObj.ProductPart__c = prod.Id;
            productPartObj.ProductTool__c = prod.Id;
            productPartObj.Quantity__c = 1;
            productPartObj.External_ID__c = '123456';
            insert productPartObj;
            
            serviceRequestLineItemObj.Order_Line_Category__c = 'Bill of Materials';
            update serviceRequestLineItemObj;
            TTI_ServiceRequest_Auto_Approval_Process.autoapprove(caseObj.Id);
        }
       
    }

}