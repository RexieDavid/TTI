public without sharing class TTI_OrderPartsFromBillController {
    private static final String ERR_GENERIC_MESSAGE = 'Something went wrong. Please contact your administrator.';

    @AuraEnabled
    public static List<sObject> getProductParts(string productTool) {
        try {

            String fieldAPIName = '';
            List<Object> arguments = new List<Object>();
            String soql = 'SELECT {0}, {1} FROM ProductParts__c {2}';
            String whereClause = 'WHERE ProductTool__c = :productTool ';
    
            Map<String, Schema.SObjectField> mapObjNamewithField =  Schema.getGlobalDescribe().get('ProductParts__c').getDescribe().fields.getMap();            
            for (Schema.SObjectField productField : mapObjNamewithField.values()) {
                fieldAPIName += productField + ', ';
            }
            fieldAPIName = fieldAPIName.trim().removeEnd(',');
    
            Set<String> fieldNames = new Set<String>{
                'ProductPart__r.AU_Landed_Cost__c',
                'ProductPart__r.AU_ListPrice__c',
                'ProductPart__r.AU_MRPty__c',
                'ProductPart__r.BP05_Bin__c',
                'ProductPart__r.BP06_Bin__c',
                'ProductPart__r.Description',
                'ProductPart__r.Name',
                'ProductPart__r.NZ02_Bin__c',
                'ProductPart__r.NZ_Landed_Cost__c',
                'ProductPart__r.NZ_ListPrice__c',
                'ProductPart__r.NZ_MRPty__c',
                'ProductPart__r.ProductCode',
                'ProductPart__r.SOH_BP01__c',
                'ProductPart__r.SOH_BP05__c',
                'ProductPart__r.SOH_BP06__c',
                'ProductPart__r.SOH_SP01__c',
                // INC0032321 - Stock level traffic lights NZ service centre - 02/17/2023 - JAC
                'ProductPart__r.SOH_NZ01__c',
                'ProductPart__r.SAP_Material_Group__c'    
                // INC0032321 - End           
            };
    
            arguments.add(String.join(new List<String>(fieldNames), ','));
            arguments.add(fieldAPIName);
            arguments.add(whereClause);
            
            List<sObject> lstSObject = Database.query(String.format(soql, arguments));
            if (!lstSObject.isEmpty()) {
                return lstSObject;
            } else {
                AuraHandledException customException = new AuraHandledException(ERR_GENERIC_MESSAGE);
                customException.setMessage(ERR_GENERIC_MESSAGE);
                throw customException;
            }        
        } catch (Exception e) {
            AuraHandledException customException = new AuraHandledException(e.getMessage());
            customException.setMessage(e.getMessage());
            throw customException;
        }
    }
    
    @AuraEnabled
    public static Service_Request_Line_Item__c getDummyObj()
    {
        Service_Request_Line_Item__c ObjServiceReqLineItem=new Service_Request_Line_Item__c();
        return ObjServiceReqLineItem;
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, List<String>> getFieldDependencies(String objectName, String controllingField, String dependentField)
    {
        return TTI_ServiceRequestController.getFieldDependencies(objectName, controllingField, dependentField);
    }
}