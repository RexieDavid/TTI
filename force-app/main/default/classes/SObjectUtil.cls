/**
 * author:      Francis Nasalita
 * date:        2021-05-18
 * 
 */
public class SObjectUtil {

    private static final List<String> RECORD_TYPE_FIELDS = new List<String>{ 'RecordType.Id', 'RecordType.Name', 'RecordType.DeveloperName' };

    private static Map<String, Map<String, Schema.SObjectField>> cachedObjectFields = new Map<String, Map<String, Schema.SObjectField>>();

    /**********************************************************************
    * @description validates if an object exist
    * @param objectType SObject API name
    * @return boolean
    * @example
    * Boolean isObjectExist = isObjectExist('Account');
    */
    public static boolean isObjectExist(String objectType) {
        for (Schema.SObjectType sObjectType : Schema.getGlobalDescribe().values()) {
            String sobjName = String.valueOf(sObjectType);
            if (sobjName.contains(objectType)) {
                return true;
            }
        }
        return false;
    }

    /**********************************************************************
    * @description validates if a field exist in an object
    * @param objName SObject API name
    * @param fieldName field API name
    * @return boolean
    * @example
    * Boolean isFieldExist = isFieldExist('Account', 'FirstName');
    */
    public static Boolean isFieldExist(String objName, String fieldName) {
        Boolean isRecordTypeField = containsIgnoreCase(RECORD_TYPE_FIELDS, fieldName);
        if (isRecordTypeField) {
            return true;
        }

        Map<String, Schema.SObjectField> mapObjFields;
        if (cachedObjectFields.containsKey(objName)) {
            mapObjFields = cachedObjectFields.get(objName);
        } else {
            mapObjFields = Schema.getGlobalDescribe().get(objName).newSObject().getSObjectType().getDescribe().fields.getMap();

            cachedObjectFields.put(objName, mapObjFields);
        }
        
        return mapObjFields.containsKey(fieldName);
    }

    private static Boolean containsIgnoreCase(List<String> arrToCheck, String text) {
        Boolean exist = false;
        Pattern pattern = Pattern.compile('(?i)' + text);

        for (Integer counter = 0; counter < arrToCheck.size(); counter++) {
            Matcher matcher = pattern.matcher(arrToCheck[counter]);
            if (matcher.matches()) {
                exist = true;
                break;
            }
        }

        return exist;
    }

    public class SObjectUtilException extends Exception {}

}