/**
 * @File Name          : TTI_JobSummaryReceiptController.cls
 * @Description        : 
 * @Author             : Francis Nasalita
 * @Group              : 
 * @Last Modified By   : Rex Joseph Egoc
 * @Last Modified On   : 29/10/2020, 10:32 am
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    06/08/2019, 2:01:51 pm   Francis Nasalita     Initial Version
 * 1.1    29/10/2020, 10:32: 00 am Rex Joseph Egoc      added field in the query
**/
public class TTI_JobSummaryReceiptController {
    public Case objCase {get;set;}
    public List<Case> lstCase {get;set;}
    public String StrCaseId {get;set;}
    public List<Service_Request_Line_Item__c > lstProdLineItem {get;set;}
    public String strConvertCompletionDate {get;set;}

    public TTI_JobSummaryReceiptController() {
        lstCase = new List<Case>();
        StrCaseId= ApexPages.currentPage().getparameters().get('caseId');
        
        lstCase = [SELECT id , CaseNumber, Status, Retailer_Account__c, Retailer_Account__r.Name, TTI_Customer_Account__r.Name, TTI_Customer_Contact__c, Service_Agent__r.Name,
                SuppliedEmail, Brand__c, Product_Name__c, Purchase_Date__c, Fault_Description__c,TTI_Service_Agent_Comments__c,Asset.Name, TTI_Freight_In_Required__c,Retailer_Account__r.Phone,CreatedDate,TTI_Customer_Account__r.PersonMobilePhone, 
                //INC0027645 - Change to Job summary sheet - 03/05/2023 - JAC
                TTI_Customer_Account__r.Phone, Asset.SerialNumber, Fault_Codes__c, 
                // INC0027645 - End
                TTI_Freight_Out_Required__c, Retailer_Account__r.Delivery_Street__c, Retailer_Account__r.Delivery_Suburb__c, Retailer_Account__r.Delivery_Postcode__c,Claim_Type__c ,Repair_Type__c ,
                TTI_Freight_Out_Delivery_Address__c, TTI_Freight_Out_Delivery_Suburb__c , TTI_Freight_Out_Delivery_Postcode__c,Service_Agent__r.Phone, TTI_Freight_Out_Delivery_State__c, TTI_Freight_Out_Delivery_Country__c, 
                TTI_Freight_In_PickUp_Address__c, TTI_Freight_In_Pickup_Suburb__c, TTI_Freight_In_Pickup_Postcode__c, TTI_Freight_In_Pickup_State__c, TTI_Freight_In_Pickup_Country__c,Completion_Date__c ,
                Retailer_Account__r.Delivery_State__c, Retailer_Account__r.Delivery_Country__c, Service_Agent__r.Delivery_State__c, Service_Agent__r.Delivery_Country__c , Service_Agent__r.Delivery_Street__c, 
                Service_Agent__r.Delivery_Suburb__c, Service_Agent__r.Delivery_Postcode__c,TTI_Customer_Account__r.Delivery_State__c, TTI_Customer_Account__r.Delivery_Country__c , TTI_Customer_Account__r.Delivery_Street__c, 
                TTI_Customer_Account__r.Delivery_Suburb__c, TTI_Customer_Account__r.Delivery_Postcode__c, Serial_Number__c,Product_Name__r.Name, TTI_Brand_Logo_URL__c, Service_Agent__r.Internal_Service_Agent__c FROM Case WHERE Id =: StrCaseId];
        
        if (lstCase != null && !lstCase.isEmpty()) {

            if (lstCase[0].Repair_Type__c == 'Declined Warranty - Inspection fee') {
                lstCase[0].Repair_Type__c = 'Declined Warranty';
            }

            objCase = lstCase[0];
            strConvertCompletionDate = lstCase[0].Completion_Date__c.format('dd/MM/yyyy', UserInfo.getTimeZone().toString());
        }
        lstProdLineItem = [SELECT Quantity__c,Line_Item_Description__c, SKU_Number__c,Unit_Cost__c,Total_Value__c,Service_Request_Number__c 
                             FROM Service_Request_Line_Item__c 
                            WHERE Service_Request_Number__c =:StrCaseId 
                              AND Order_Line_Type__c='Part'];
    }
}