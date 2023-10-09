public without sharing class TTI_PredictiveSearchController {
    
    @AuraEnabled
    public static List<sObject> getListOfObjects(string searchString,String whereQuery,String objName,Boolean ignoreDefaultNameSearch,String ParentFieldsToQuery)
    {
        String sObjQuery = '';
        String fieldAPIName = '';
        Map<String, Schema.SObjectField> mapObjNamewithField =  Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();
        
        for(Schema.SObjectField s: mapObjNamewithField.values())
        { 
            Schema.DescribeFieldResult sfield = s.getDescribe();
            fieldAPIName += s+', '; 
        }
        fieldAPIName = fieldAPIName.trim().removeEnd(',');
        
        if(ParentFieldsToQuery!=null && ParentFieldsToQuery!=''){
            fieldAPIName= fieldAPIName +','+ParentFieldsToQuery;
        }
        
        searchString='%'+searchString+'%';
        if(ignoreDefaultNameSearch)
        {
            sObjQuery = 'SELECT '+fieldAPIName+' FROM '+objName+' WHERE '+whereQuery;
        }
        else
        {
            if(whereQuery != null && whereQuery != '')
            {
                
                sObjQuery = 'SELECT '+fieldAPIName+' FROM '+objName+' WHERE '+whereQuery+' AND Name LIKE:searchString';
            }
            if(whereQuery == null || whereQuery == '')
            {
                sObjQuery = 'SELECT '+fieldAPIName+' FROM '+objName+' WHERE  Name LIKE:searchString';
            }
        }
        List<sObject> lstSObject = Database.query(sObjQuery);
        
        if(lstSObject!=null && !lstSObject.isEmpty())
        {
            return lstSObject;
        }
        return null;
    }

    @AuraEnabled
    public static  List<sObject> getRecord(String whereQuery,String objName,String ParentFieldsToQuery) {
        String sObjQuery = '';
        String fieldAPIName = '';
        Map<String, Schema.SObjectField> mapObjNamewithField =  Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();
        
        for(Schema.SObjectField s: mapObjNamewithField.values())
        { 
            Schema.DescribeFieldResult sfield = s.getDescribe();
            fieldAPIName += s+', '; 
        }
        fieldAPIName = fieldAPIName.trim().removeEnd(',');
        
        if(ParentFieldsToQuery!=null && ParentFieldsToQuery!=''){
            fieldAPIName= fieldAPIName +','+ParentFieldsToQuery;
        }

        sObjQuery = 'SELECT '+fieldAPIName+' FROM '+objName+' WHERE '+whereQuery;
        
        List<sObject> record = Database.query(sObjQuery);
        if(record != null) {
            return record;
        }
        return null;
    }
    
    public String setObjectType(sObject newObj) {
        String objType = newObj.getSObjectType().getDescribe().getName();
        return objType;
    }
    
}