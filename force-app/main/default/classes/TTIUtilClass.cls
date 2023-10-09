/**
* @author       Haider Raza
* @date         06/04/2016
* @description  Utility class
**/
public with sharing class TTIUtilClass {

    /**
    * @author       Haider Raza
    * @date         06/04/2016
    * @description  Get the Quarter start and end dates
    **/
    public static Map<String, Period> periods {
        get{
            if (periods == null) {
                periods = new Map<String, Period>();
                for (Period p : [SELECT StartDate, EndDate, Number
                FROM Period
                WHERE Type = 'Quarter'
                ORDER BY StartDate]) {
                    if (System.Date.Today() >= p.StartDate && System.Date.Today() <= p.EndDate)
                        periods.put('Current', p);
                    else
                        periods.put('Y: ' + p.StartDate.Year() + ' Q: ' + p.Number, p);
                }
            }
            return periods;
        }
        private set;
    }

    /**
    * @author    HR
    * @date      15/02/2016
    * @description  Retrieve the record type id for the provided object. <br/>
    *     Sample success {RecordTypeName=xxxxxxxxxxxxxxxxxx}. <br/>
    *     Sample fail {Exception=Invalid object name}
    * @param    API Name of the object
    * @param    Record type name not the Developer name
    * @return    Map of RecordTypeName and Id e.g. {RecordTypeName=xxxxxxxxxxxxxxxxxx}
    **/
    public static Map<String, String> getRecordTypeId(String sobjectname, String recordtypename) {
        if (!Schema.getGlobalDescribe().containsKey(sobjectname)) {
            return new Map<String, String> {'Exception' => 'Invalid object name'};
        }

        if (!Schema.getGlobalDescribe().get(sobjectname).getDescribe().getRecordTypeInfosByName().containsKey(recordtypename)) {
            return new Map<String, String> {'Exception' => 'Invalid record type name'};
        }

        return new Map<String, String> {recordtypename => Schema.getGlobalDescribe().get(sobjectname).getDescribe().getRecordTypeInfosByName().get(recordtypename).getRecordTypeId()};
    }

    /**
    * @author    HR
    * @date      08/03/2016
    * @description  Retrieve the record type name and id map. <br/>
    *      Sample success BusinessAccount=012900000008Cg4AAE. <br/>
    *      Sample fail {Exception=Invalid object name}
    * @param    API Name of the object
    * @return    Map of RecordTypeName and Id if exist else return null
    **/
    public static Map<String, String> getRecordTypeId(String sobjectname) {
        if (!Schema.getGlobalDescribe().containsKey(sobjectname)) {
            return new Map<String, String> {'Exception' => 'Invalid object name'};
        }

        Map<String, String> rtMap = new Map<String, String>();

        for (String rtInfo : Schema.getGlobalDescribe().get(sobjectname).getDescribe().getRecordTypeInfosByName().keySet()) {
            if (Schema.getGlobalDescribe().get(sobjectname).getDescribe().getRecordTypeInfosByName().get(rtInfo).isAvailable()) {
                rtMap.put(rtInfo, Schema.getGlobalDescribe().get(sobjectname).getDescribe().getRecordTypeInfosByName().get(rtInfo).getRecordTypeId());
            }
        }

        return rtMap.isEmpty() ? null : rtMap;
    }

    /**
    * @author: Stephen James Laylo
    * @date: December 2017
    * @description: This method handles the formatting of phone number based on country
    */
    public static String formatPhoneNumberByCountry(String unformattedPhoneNumber, String country) {
        String phoneNumber = unformattedPhoneNumber;

        if (phoneNumber != null && phoneNumber != '') {
            phoneNumber = phoneNumber.trim();

            Map<String, Country_Codes__c> countryCodesSettings = Country_Codes__c.getAll();
            Map<String, Country_Codes__c> countryCodesMap = new Map<String, Country_Codes__c>();

            for (Country_Codes__c cc : countryCodesSettings.values()) {
                countryCodesMap.put(cc.Country_ABV__c, cc);
            }

            Map<String, Country_Codes__c> tempCountryCodesMap = new Map<String, Country_Codes__c>();

            if (countryCodesMap.containsKey(country)) {
                tempCountryCodesMap.putAll(countryCodesMap);
            } else if (countryCodesSettings.containsKey(country)) {
                tempCountryCodesMap.putAll(countryCodesSettings);
            }

            if (tempCountryCodesMap.containsKey(country)) {
                for (Country_Codes__c cc : tempCountryCodesMap.values()) {
                    if (phoneNumber.length() >= 3 && phoneNumber.left(3) == cc.Country_Code__c) {
                        phoneNumber = '0' + phoneNumber.substring(3, phoneNumber.length());
                    }
                    if (phoneNumber.length() >= 1 && phoneNumber.left(1) == '0') {
                        phoneNumber = tempCountryCodesMap.get(country).Country_Code__c + phoneNumber.substring(1, phoneNumber.length()).deleteWhitespace();
                    }
                }
            }
        }

        return phoneNumber;
    }

    /**
    * @author: Francis Nasalita
    * @date: February 2018
    * @description: This method handles the retrieval of picklist values
    */
    public static List<String> getPicklistValuesToList(String objName, String fieldName) {
        List<String> pickListValuesList = new List<String>();

        if ((objName != null && objName != '') && (fieldName != null && fieldName != '')) {
            for ( Schema.PicklistEntry pickListVal : Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get(fieldName).getDescribe().getPicklistValues()) {
                pickListValuesList.add(pickListVal.getLabel());
            }
        }

        return pickListValuesList;
    }

    /**
    * @author: Francis Nasalita
    * @date: April 2018
    * @description: This method handles the retrieval of brand of the current portal user logged in
    */
    public static String getBrandCurrentUser() {
        Id currentUserId = UserInfo.getUserId();

        User u = [SELECT ContactId FROM User WHERE Id = :currentUserId];

        if (u.ContactId != null) {
            try {
                Contact con = [SELECT Brand__c FROM Contact WHERE Id = :u.ContactId];
                return con.Brand__c;
            } catch (Exception err) {
                return err.getMessage();
            }
        } else {
            return null;
        }
    }

    /**
    * @author: Francis Nasalita
    * @date: March 2018
    * @description: This method handles the retrieval of fields info from fieldsets
    *               by fieldset API name and object Api name and put the values to List
    */
    public static List<Schema.FieldSetMember> readFieldSetToList(String fieldSetName, String objectName) {
        Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType SObjectTypeObj = globalDescribeMap.get(objectName);
        Schema.DescribeSObjectResult describeSObjectResultObj = SObjectTypeObj.getDescribe();

        Schema.FieldSet fieldSetObj = describeSObjectResultObj.FieldSets.getMap().get(fieldSetName);

        return fieldSetObj.getFields();
    }

    /**
    * @author: Francis Nasalita
    * @date: March 2018
    * @description: This method constructs the fields section for soql query using fieldsets
    */
    public static String constructFieldsFromFieldSet(String fieldSetApiName, String objectName) {
        List<Schema.FieldSetMember> listFields = TTIUtilClass.readFieldSetToList(fieldSetApiName, objectName);

        if (!listFields.isEmpty()) {
            String fields = '';
            Boolean flag = true;

            for (Schema.FieldSetMember field : listFields) {
                String fieldApiName = String.valueOf(field.getFieldPath());
                String fieldType = String.valueOf(field.getType());
                System.debug('### fieldType: ' + fieldType);
                if (flag) {
                    fields += (fieldType == 'REFERENCE') ? fieldApiName + ', ' + fieldApiName.replace('__c', '__r.Name') : (fieldType == 'ID') ? fieldApiName + ', Name' : fieldApiName;
                    flag = false;
                } else {
                    fields += (fieldType == 'REFERENCE') ? ', ' + fieldApiName + ', ' + fieldApiName.replace('__c', '__r.Name') : (fieldType == 'ID') ? ', ' + fieldApiName + ', Name' : ', ' + fieldApiName;
                }
            }

            return fields;
        } else {
            return null;
        }
    }

    /**
    * @author: Francis Nasalita
    * @date: March 2018
    * @description: This method constructs the SOQL querys with fieldset
    * @param:
    *        fieldSetApiName - FieldSet Api Name (Required)
    *        objectName      - Object Api Name (Required)
    *        condition       - Where Clause in one String e.g. 'Id = 00000000 AND Count__c = 23 OR Weight__c = 11'
    *                        *** USE String.escapeSingleQuotes to add string values on where clause e.g. 'Id = 000000000 AND Type = ' + String.escapeSingleQuotes('Active')
    *        lim             - this will add LIMIT to the query
    *        orderBy         - 'ORDER By' field should exist in the FieldSet
    *        isAscending     - this will add ASC or DESC to order by (Default: DESC)
    *        nullFirst       - this will NULL FIRST or LAST to query
    */
    public static String constructSOQLQuery(String fieldSetApiName, String objectName, String condition, Integer lim, String orderBy, Boolean isAscending, Boolean nullFirst) {
        // fieldSet and object api names should have value
        if (String.isBlank(fieldSetApiName) || String.isBlank(objectName)) {
            return null;
        }
        // one of the parameters should have value (condition or limit)
        if (String.isBlank(condition) && (lim == 0 || lim == null)) {
            return null;
        }

        String fields = constructFieldsFromFieldSet(fieldSetApiName, objectName);
        if (String.isNotBlank(fields)) {

            // validate orderBy if not null
            // check 'order by' field if exists in fields sets
            if (String.isNotBlank(orderBy) || orderBy != null) {
                if (!fields.contains(orderBy.trim())) {
                    return null;
                }
            }

            isAscending = (isAscending == null) ? false : isAscending;
            nullFirst = (nullFirst == null) ? false : nullFirst;

            String query = 'SELECT ' + fields;

            query += ' FROM ' + objectName;
            query += (String.isNotBlank(condition) && condition != null) ? ' WHERE ' + condition : '';
            if (String.isNotBlank(orderBy) && orderBy != null) {
                query += ' ORDER BY ' + orderBy;
                query += (isAscending) ? ' ASC ' : ' DESC ';
            }
            query += (nullFirst) ? ' NULLS FIRST' : '';
            query += (lim != 0 && lim != null) ? ' LIMIT ' + String.valueOf(lim) : '';

            System.debug('### constructSOQLQuery query: ' + query);
            return query;
        } else {
            return null;
        }
    }

    /**
    * @author: Stephen James Laylo
    * @date: May 2018
    * @description: This method returns the Object Type from record ID
    * @param:
    *        recordIdOrPrefix - Record ID or Prefix (Required)
    */
    public static String findObjectNameFromRecordIdPrefix(String recordIdOrPrefix) {
        try {
            String myIdPrefix = String.valueOf(recordIdOrPrefix).substring(0, 3);

            Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe();

            for (Schema.SObjectType stype : gd.values()) {
                Schema.DescribeSObjectResult r = stype.getDescribe();
                String prefix = r.getKeyPrefix();

                if (prefix != null && prefix.equals(myIdPrefix)) {
                    return r.getName();
                }
            }
        } catch (Exception e) {
            System.debug(e);
        }

        return '';
    }
}