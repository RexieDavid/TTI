public without sharing class TTI_PartsOrderedController {
    private static final String ERR_GENERIC_MESSAGE = 'Something went wrong. Please contact your administrator.';
    
    @AuraEnabled
    public static List<Service_Request_Line_Item__c> getServiceReqLineItem(string caseNumber) {
        try {
            String fieldAPIName = '';
            List<Object> arguments = new List<Object>();
            String soql = 'SELECT {0}, {1} FROM Service_Request_Line_Item__c {2}';
            String whereClause = 'WHERE Service_Request_Number__c = :caseNumber AND Order_Line_Type__c = \'Part\' ';
    
            Map<String, Schema.SObjectField> mapObjNamewithField =  Schema.getGlobalDescribe().get('Service_Request_Line_Item__c').getDescribe().fields.getMap();            
            for (Schema.SObjectField productField : mapObjNamewithField.values()) {
                fieldAPIName += productField + ', ';
            }
            fieldAPIName = fieldAPIName.trim().removeEnd(',');

            Set<String> fieldNames = new Set<String>{
                'Part_Number__r.BP05_Bin__c',
                'Part_Number__r.BP06_Bin__c',
                'Part_Number__r.Name',
                'Part_Number__r.NZ02_Bin__c',
                'Part_Number__r.SOH_BP01__c',
                'Part_Number__r.SOH_BP05__c',
                'Part_Number__r.SOH_BP06__c',
                'Part_Number__r.SOH_NZ01__c',
                'Part_Number__r.SOH_SP01__c',
                'Part_Number__r.SAP_Material_Group__c'
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
    public static string getNonWarrantyServiceReqLineItem(string caseNumber) {
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Service_Request_Line_Item__c.fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();
        
        String theQuery = 'SELECT ';
        for(Schema.SObjectField s : fldObjMapValues)
        {
            String theName = s.getDescribe().getName();
            
            // Continue building your dynamic query string
            theQuery += theName + ',';
        }
        
        // Trim last comma
        theQuery = theQuery.subString(0, theQuery.length() - 1);
        string strOrderType='Quote';
        // Finalize query string
        theQuery += ' FROM Service_Request_Line_Item__c WHERE Service_Request_Number__c=:caseNumber AND Order_Line_Type__c=:strOrderType';
        
        // Make your dynamic call
        Service_Request_Line_Item__c[] lstServReqLineItm = Database.query(theQuery);
        
        
        return JSON.serialize(lstServReqLineItm);
    }
    
    @AuraEnabled
    public static string getRetailChargesCustomSetting()
    {
        List<Retail_Charges_Rates__c> RetailChargesRates = Retail_Charges_Rates__c.getall().values();
        return JSON.serialize(RetailChargesRates);
    }

}