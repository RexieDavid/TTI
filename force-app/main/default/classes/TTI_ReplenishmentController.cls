public without sharing class TTI_ReplenishmentController {

    @AuraEnabled 
    public static string getSOHRAGStatusCustomSetting() {
        List<SOHRAGStatus__c> lstSOHRAGStatus = SOHRAGStatus__c.getall().values();
        return JSON.serialize(lstSOHRAGStatus);
    }

    @AuraEnabled
    public static User getUserType(String userId) {
        return [SELECT Id, Account.RecordTypeId, Account.RecordType.Name, Account.Internal_Service_Agent__c, AccountId, UserRole.Name, Account.Delivery_Country__c ,
                       Account.Allow_Delivery_to_Customers__c, Account.BillingAddress, Account.ShippingStreet,Account.ShippingCity, Account.ShippingCountry, Account.ShippingState,
                       Account.ShippingPostalCode, Account.Delivery_Street__c, Account.Delivery_Suburb__c, Account.Delivery_State__c, Account.Delivery_Postcode__c, Account.Company_Code__c,
                       Account.Freight_Company__c, ContactId, Account.MX_Authorised__c, Contact.Last_Manifested_Date__c
                  FROM User 
                 WHERE id = :userId];
    }

    @AuraEnabled
    public static List<ProductParts__c> fetchBillOfMaterials(String productToolId) {
        return [SELECT Id, ProductPart__c, ProductPart__r.Description, ProductPart__r.SOH_BP01__c, ProductPart__r.SOH_BP05__c,
                       ProductPart__r.SOH_BP06__c, ProductPart__r.BP05_Bin__c, ProductPart__r.BP06_Bin__c, Quantity__c, 
                       ProductPart__r.AU_ListPrice__c, ProductPart__r.NZ_ListPrice__c, ProductPart__r.ProductCode, ProductPart__r.SOH_SP01__c 
                  FROM ProductParts__c 
                 WHERE ProductTool__c = :productToolId];
    }
    
    @AuraEnabled
    public static TTI_Replenishment_Header__c fetchReplenishmentRecord(String recordId) {
        return [SELECT Id, TTI_Purchase_Order_Reference__c, TTI_Status__c, TTI_Service_Agent__c, TTI_Service_Agent__r.Company_Code__c,
                           (SELECT Id, TTI_SKU_Number__c, TTI_Product_Number__r.SOH_BP01__c, TTI_Product_Number__r.SOH_BP05__c,
                                   TTI_Product_Number__r.SOH_BP06__c, TTI_Product_Number__r.BP05_Bin__c, TTI_Product_Number__r.BP06_Bin__c,
                                   TTI_Product_Number__r.Description, TTI_Consignment_Number__c, TTI_Quantity__c, TTI_Unit_Cost__c, TTI_Total_Cost__c, TTI_Product_Number__r.SOH_SP01__c 
                              FROM Replenishment_Line_Items__r) 
                  FROM TTI_Replenishment_Header__c 
                 WHERE Id = :recordId];
    }

    @AuraEnabled
    public static String saveReplishmentHeaderAndItsLineItem(String objReplenishmentHeaderStr, String lstReplenishmentLineItemStr, String lstRemoveReplenishmentLineItemStr) {
        TTI_Replenishment_Header__c objRepHeader = (TTI_Replenishment_Header__c) JSON.deserialize(objReplenishmentHeaderStr, TTI_Replenishment_Header__c.class);
        if (objRepHeader.TTI_Status__c == 'Submitted') {
            objRepHeader.TTI_Submitted_Date__c = date.today();
        }
        upsert objRepHeader;

        if (!String.isBlank(lstReplenishmentLineItemStr)) {
            List<TTI_Replenishment_Line_Item__c> lstRepHeaderLineItems = (List<TTI_Replenishment_Line_Item__c>) JSON.deserialize(lstReplenishmentLineItemStr, List<TTI_Replenishment_Line_Item__c>.class);
            for (TTI_Replenishment_Line_Item__c objRepHeaderLineItem :lstRepHeaderLineItems) {
                if (String.isBlank(objRepHeaderLineItem.id))
                    objRepHeaderLineItem.TTI_Replenishment_Header__c=objRepHeader.Id;
            }
            upsert lstRepHeaderLineItems;
        }

        if (!String.isBlank(lstRemoveReplenishmentLineItemStr)) {
            List<TTI_Replenishment_Line_Item__c> lstRepHeaderLineItemsRemove = (List<TTI_Replenishment_Line_Item__c>) JSON.deserialize(lstRemoveReplenishmentLineItemStr, List<TTI_Replenishment_Line_Item__c>.class);
            delete lstRepHeaderLineItemsRemove;
        }
        return objRepHeader.Id;        
    }

    
}