public without sharing class TTI_CaseReceiptController {
    public Case objCase{get;set;}
    public static List<Case> lstCase{get;set;}
    public static String StrCaseId{get;set;}
    
    public TTI_CaseReceiptController ()
    {
        lstCase = new List<Case>();
        StrCaseId= string.valueOf(ApexPages.currentPage().getparameters().get('caseId'));
        
        lstCase =[SELECT id , CaseNumber, Status, Retailer_Account__c, Retailer_Account__r.Name, TTI_Customer_Account__r.Name, TTI_Customer_Contact__c, Service_Agent__r.Name,
                  SuppliedEmail, Brand__c, Product_Name__c, Purchase_Date__c, Fault_Description__c, TTI_Freight_In_Required__c,CreatedDate,TTI_Customer_Account__r.PersonMobilePhone,  
                  TTI_Freight_Out_Required__c, Retailer_Account__r.Delivery_Street__c, Retailer_Account__r.Delivery_Suburb__c, Retailer_Account__r.Delivery_Postcode__c,
                  TTI_Freight_Out_Delivery_Address__c, TTI_Freight_Out_Delivery_Suburb__c , TTI_Freight_Out_Delivery_Postcode__c, TTI_Freight_Out_Delivery_State__c, TTI_Freight_Out_Delivery_Country__c, 
                  TTI_Freight_In_PickUp_Address__c, TTI_Freight_In_Pickup_Suburb__c, TTI_Freight_In_Pickup_Postcode__c, TTI_Freight_In_Pickup_State__c, TTI_Freight_In_Pickup_Country__c,
                  Retailer_Account__r.Delivery_State__c, Retailer_Account__r.Delivery_Country__c, Service_Agent__r.Delivery_State__c, Service_Agent__r.Delivery_Country__c , Service_Agent__r.Delivery_Street__c, 
                  Service_Agent__r.Delivery_Suburb__c,Service_Agent__r.Phone, Asset.Name, Service_Agent__r.Delivery_Postcode__c, Serial_Number__c,Product_Name__r.Name, TTI_Brand_Logo_URL__c FROM Case WHERE Id =:StrCaseId];
        system.debug('lstCase====='+lstCase);
        
        if(lstCase != null && !lstCase.isEmpty()){
            objCase = lstCase[0];
        }
    }
    
}