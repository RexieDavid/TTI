/**
 * @author                          XXXXXXXXXX
 * @date                            XXXX-XX-XX
 *
 * @group                           Training Attendance Management
 *
 * @description                     Controller for Training Attenance lightning
 *                                  component bundle
*/
public with sharing class TrainingAttendeeMassUpdateController {

    private static final String ERR_GENERIC_MESSAGE = 'Something went wrong. Please contact your administrator.';
    private static final String ERR_INSUFFICIENT_ACCESS = 'You have no access. Please contact your administrator.';
    private static final String ERR_INVALID_ID = 'Invalid training session id.';
    private static final String PERMSET_MANAGE_ATTENDANCES = 'Manage_Attendances';
    private static final String TRAINING_ATTENDANCE_API = 'TrainingAttendance__c';
    
    /**********************************************************************
     * @description                 Fetch attendee list via training session Id
     *
     *                              If current user is not assigned to Manage_Attendance
     *                              permission set, will throw an error
     *                              
     * @param  sessionId            Training session record Id
     * @return                      List of Training Attendees
     */
    @AuraEnabled
    public static List<TrainingAttendance__c> getAttendeesList(String sessionId) {  
        AuraHandledException customException;
        Integer hasAccess = isAccessibleByUser();
        if (hasAccess == 1) {
            try {
                if (String.isNotBlank(sessionId)) {
                    return [SELECT Id, 
                                   Enrolled__c,
                                   Interested__c,
                                   Name, 
                                   Not_on_Enrolment_List__c, 
                                   Attendance_Status__c, 
                                   Position__c, 
                                   TrainingAttendent__r.Account.Name, 
                                   TrainingAttendent__r.Team_Member_Id__c, 
                                   TrainingAttendent__r.FirstName, 
                                   TrainingAttendent__r.LastName
                            FROM TrainingAttendance__c
                            WHERE TrainingSessionID__c = :sessionId
                            AND TrainingAttendent__c != NULL];
                } else {
                    customException = new AuraHandledException(ERR_INVALID_ID);
                    customException.setMessage(ERR_INVALID_ID);
                    throw customException;
                }
            } catch(Exception ex) {
                String errMessage = ex.getMessage().indexOf(ERR_INVALID_ID) != -1 ? ERR_INVALID_ID : ERR_GENERIC_MESSAGE;
                customException = new AuraHandledException(errMessage);
                customException.setMessage(errMessage);
                throw customException;
            }
        } else {
            AuraHandledException e = new AuraHandledException(ERR_INSUFFICIENT_ACCESS);
            e.setMessage(ERR_INSUFFICIENT_ACCESS);
            throw e;
        }
    }

    /**********************************************************************
     * @description                 Upsert new/old training attenance records
     * 
     * @param recordsList           List of attendance in JSON format
     */
    @AuraEnabled
    public static void updateRecords(String recordsList) {
        try {
            upsert (List<TrainingAttendance__c>) JSON.deserialize(recordsList, List<TrainingAttendance__c>.class);
        } catch (Exception ex) {
            AuraHandledException e = new AuraHandledException(ERR_GENERIC_MESSAGE);
            e.setMessage(ERR_GENERIC_MESSAGE);
            throw e;
        }
    }

    /**********************************************************************
     * @description                 Will fetch existing contacts that
     *                              have the same pattern with searchkey
     *                              
     * @param  searchKey            Search pattern
     * @param  contactIds           Contact Ids to be excluded in the query
     * @param  lookupFilters        Addition SOQL filter based on the lookup field
     * 
     * @return                      List of contacts
     * 
     * @example
     * TrainingAttendeeMassUpdateController.findContacts('John Doe', new List<String>{XXX,XXX}, 'xx__c = 4 AND xx__c = 'Name'');
     */
    @AuraEnabled(cacheable=true)
    public static List<Contact> findContacts(String searchKey, List<String> contactIds, String lookupFilters) {
        List<Contact> eContactsList = new List<Contact>();
        List<String> fields = new List<String>{ 'Id',
                                                'Name',
                                                'FirstName',
                                                'LastName',
                                                'Team_Member_Id__c',
                                                'AccountId',
                                                'Account.Name',
                                                'Title_Position__c'};

        if (String.isNotBlank(searchKey.trim())) {
            String key = '\'%' + String.escapeSingleQuotes(searchKey.trim()) + '%\'';
            String query = 'SELECT ' + String.join(fields, ', ') + ' FROM Contact WHERE ' 
                            + ' (Name LIKE ' + key + ' OR Team_Member_Id__c LIKE ' + key + ' )'
                            + ' AND Id NOT IN :contactIds';

            if (String.isNotBlank(lookupFilters)) {
                query += ' AND (' + lookupFilters + ')';
            }

            query += ' LIMIT 10';

            eContactsList = Database.query(query);
        }
        return eContactsList;
    }

    /**********************************************************************
     * @description                 Check if current user was assigned to
     *                              Manage_Attendance permission set
     *                              
     * @return                      Return SOQL count
     * 
     * @example
     * isAccessibleByUser();
     */
    private static Integer isAccessibleByUser() {
        return [SELECT Count() 
                FROM PermissionSetAssignment 
                WHERE AssigneeId = :Userinfo.getUserId() 
                AND PermissionSet.Name = :PERMSET_MANAGE_ATTENDANCES];
    }

    /**********************************************************************
     * @description                 Fetch lookup filter of specific lookup
     *                              field
     * 
     * @param fieldAPIName          Lookup field API Name
     * 
     * @return                      SOQL Filter
     * 
     * @example
     * TrainingAttendeeMassUpdateController.fetchLookupFilter('TrainingAttendent__c');
    */
    @AuraEnabled(cacheable=true)
    public static String fetchLookupFilter(String fieldAPIName) {
        String soqlFilter = '';
        if (String.isNotBlank(fieldAPIName)) {
            fieldAPIName = fieldAPIName.replace('__c', '').trim();
            List<String> lookupCriteria = new List<String>();
            List<ToolingAPI.Records> result = fetchFieldDefinition(fieldAPIName);
            if (!result.isEmpty()) {
                ToolingAPI.Metadata metadata = result[0].metadata;
                ToolingAPI.LookupFilter lookupFilter = metadata.lookupFilter;
                if (lookupFilter.active && !lookupFilter.filterItems.isEmpty()) {
                    for (ToolingAPI.FilterItems filter : metadata.lookupFilter.filterItems) {
                        lookupCriteria.add(filter.soqlFilter); 
                    }
                    soqlFilter = combineSOQLFilters(lookupCriteria, lookupFilter.booleanFilter);
                }
            }
            
        }
        return soqlFilter;
    }

    /**********************************************************************
     * @description                 Fetch field definition of specific field
     * 
     * @param fieldAPIName          Field API Name
     * 
     * @return                      List of records return by ToolingAPI HTTP 
     *                              Request
     * 
     * @example
     * fetchFieldDefinition('TrainingAttendent__c');
    */
    private static List<ToolingAPI.Records> fetchFieldDefinition(String fieldAPIName) {
        String query = 'SELECT Id, Metadata FROM CustomField WHERE DeveloperName = \'' + fieldAPIName + '\'';
        ToolingAPI toolingAPI = new ToolingAPI(true);
        if (Test.isRunningTest()) {
            toolingAPI = new ToolingAPI();
        } 

        toolingAPI.objectAPIName = TRAINING_ATTENDANCE_API;
        toolingAPI.query = query;
        toolingAPI.methodType = 'GET';
        return toolingAPI.initializeHttpRequest();
    }

    /**********************************************************************
     * @description                 Combine SOQL filters via booleanLogic
     * 
     * @param criteria              List of SOQL filters
     * @param booleanLogic          Boolean logic 
     * 
     * @return                      Combined SOQL filters
     * 
     * @example
     * combineSOQLFilters(new List<String>, '(1 OR 2) AND 3');
    */
    private static String combineSOQLFilters(List<String> criteria, String booleanLogic) {
        String soqlFilter;
        if (String.isNotBlank(booleanLogic)) {
            if (booleanLogic.containsIgnoreCase('OR') && booleanLogic.containsIgnoreCase('AND')) {
                // This will only work up to 9 lookup filters
                for (Integer ctr = 0; ctr < criteria.size(); ctr++) {
                    booleanLogic = booleanLogic.replace(String.valueOf(ctr+1), criteria[ctr]);
                }
                soqlFilter = booleanLogic;
            } else if (booleanLogic.containsIgnoreCase('AND')) {
                soqlFilter = String.join(criteria, ' AND ');
            } else {
                soqlFilter = String.join(criteria, ' OR ');
            }
        } else {
            soqlFilter = String.join(criteria, ' AND ');
        }
        return soqlFilter;
    }
}