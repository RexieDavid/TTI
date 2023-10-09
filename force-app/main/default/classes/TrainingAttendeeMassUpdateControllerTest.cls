/**********************************************************************
 * @date                            December 11, 2019
 */
@isTest
private class TrainingAttendeeMassUpdateControllerTest {

    private static final Id ACCOUNT_END_CONSUMER_RECORD_TYPE_ID = getRecordTypeIdByObjAndNAme('Account', 'End_Consumer');
    private static final Id CONSUMER_TRAINING_SESSION_RECORD_TYPE_ID = getRecordTypeIdByObjAndNAme('TrainingSession__c', 'Consumer_Training_Session');
    private static final Id CONTACT_CONSUMER_PUBLIC_RECORD_TYPE_ID = getRecordTypeIdByObjAndNAme('Contact', 'Consumer_Public');
    private static final String ERR_GENERIC_MESSAGE = 'Something went wrong. Please contact your administrator.';
    private static final String ERR_INSUFFICIENT_ACCESS = 'You have no access. Please contact your administrator.';
    private static final String ERR_INVALID_ID = 'Invalid training session id.';
    private static final Id MANAGE_ATTENDANCE_PERMISSION_SET_ID = [SELECT Id FROM PermissionSet WHERE Name = 'Manage_Attendances'].Id;
    private static final String PERMSET_MANAGE_ATTENDANCES = 'Manage_Attendances';
    
    /**********************************************************************
     * @description                 Create data before executing test methods
     *                              including account, contact, users, etc.
     */             
    @testSetup 
    static void initData() {
        Integer counter = 0;
        List<Account> nAccountsList = new List<Account>();
        List<Contact> nContactsList = new List<Contact>();
        List<Course__c> nCoursesList = new List<Course__c>();
        List<TrainingAttendance__c> nTrainingAttendancesList = new List<TrainingAttendance__c>();
        List<TrainingSession__c> nTrainingSessionsList = new List<TrainingSession__c>();
        List<User> nUsersList = new List<User>();

        Set<String> profilesSet = new Set<String>{'AEG onsite', 'Consumer Area Manager', 'Consumer Sales Management'};

        for (Profile eProfile : [SELECT Id FROM Profile WHERE Name IN :profilesSet]) {
            User nUser = new User();
            nUser.Alias = 'suser' + counter;
            nUser.Email = 'standard.user' + counter + '@yopmail.com';
            nUser.LastName = 'user' + counter;
            nUser.EmailEncodingKey = 'UTF-8';
            nUser.LanguageLocaleKey = 'en_US';
            nUser.LocaleSidKey = 'en_US';
            nUser.ProfileId = eProfile.Id;
            nUser.TimeZoneSidKey = 'America/Los_Angeles';
            nUser.UserName = 'standard.user' + counter + '@yopmail.com.aeg';
            nUsersList.add(nUser);
            counter++;
        }
        insert nUsersList;

        System.runAs(new User(Id = UserInfo.getUserId())) {
            for (counter = 0; counter < 10; counter++) {
                Account nAccount = createCustomerAccount(counter);
                nAccountsList.add(nAccount);
            }
            insert nAccountsList;

            for (counter = 0; counter < 10; counter++) {
                Contact nContact = createConsumerContact(counter, nAccountsList.get(counter).Id);
                nContactsList.add(nContact);
            }
            insert nContactsList;


            for (counter = 0; counter < 10; counter++) {
                Course__c nCourse = createCourse(counter);
                nCoursesList.add(nCourse);
            }
            insert nCoursesList;

            for (counter = 0; counter < 10; counter++) {
                TrainingSession__c nTrainingSession = createConsumerSession(counter, nCoursesList.get(counter).Id);
                nTrainingSessionsList.add(nTrainingSession);
            }
            insert nTrainingSessionsList;

            for (counter = 0; counter < 10; counter++) {
                List<TrainingAttendance__c> trainingAttendancesList = createAttendees(nTrainingSessionsList.get(counter).Id, nContactsList);
                nTrainingAttendancesList.addAll(trainingAttendancesList);
            }
            insert nTrainingAttendancesList;
        } 
       
    }

    /**********************************************************************
     * @description                 Perform positive test in fetching
     *                              Attendees per Training Session
     */
    @isTest
    static void getAttendeesListTest() {
        List<TrainingAttendance__c> attendees = new List<TrainingAttendance__c>();
        TrainingSession__c eTrainSession = [SELECT Id FROM TrainingSession__c LIMIT 1];
        List<PermissionSetAssignment> ePermSets = [SELECT Id 
                                            FROM PermissionSetAssignment 
                                            WHERE AssigneeId = :UserInfo.getUserId() 
                                            AND PermissionSetId = :MANAGE_ATTENDANCE_PERMISSION_SET_ID];
        if (ePermSets.isEmpty()) {
            PermissionSetAssignment permSetAssign = new PermissionSetAssignment();
            permSetAssign.AssigneeId = UserInfo.getUserId();
            permSetAssign.PermissionSetId = MANAGE_ATTENDANCE_PERMISSION_SET_ID;
            insert permSetAssign;
        }
        Test.startTest();
            System.runAs(new User(Id = UserInfo.getUserId())) {
                attendees = TrainingAttendeeMassUpdateController.getAttendeesList(eTrainSession.Id);
            }
        Test.stopTest();
        System.assert(!attendees.isEmpty(), 'Failed to retrieve training attendees');

    }

    /**********************************************************************
     * @description                 Perform negative test in fetching
     *                              Attendees per Training Session passing
     *                              empty session Id
     *
     *                              Will throw 'Invalid training session id' 
     *                              error
     */
    @isTest
    static void getAttendeesInvalidIdTest() {
        String result;
        TrainingSession__c eTrainSession = [SELECT Id FROM TrainingSession__c LIMIT 1];
        User aegOnsiteUser = [SELECT Id FROM User WHERE Alias = 'suser1'];
        PermissionSetAssignment permSetAssign = new PermissionSetAssignment();
        permSetAssign.AssigneeId = aegOnsiteUser.Id;
        permSetAssign.PermissionSetId = MANAGE_ATTENDANCE_PERMISSION_SET_ID;
        insert permSetAssign;
        Test.startTest();
            System.runAs(aegOnsiteUser) {
                try {
                    TrainingAttendeeMassUpdateController.getAttendeesList(null);
                } catch (Exception ex) {
                    result = ex.getMessage();
                }
            }
        Test.stopTest();
        System.assertEquals(ERR_INVALID_ID, result, 'Succesfully retrieved attendee list');
    }


    /**********************************************************************
     * @description                 Perform negative test in fetching
     *                              Attendees per Training Session without
     *                              assigning the appropriate permission
     *                              to the current user
     *
     *                              Will throw 'You have no access. Please 
     *                              contact your administrator.' error
     */
    @isTest 
    static void getAttendeesWithNoAccessTest() {
        String result;
        User aegOnsiteUser = [SELECT Id FROM User WHERE Alias = 'suser1'];
        Test.startTest();
            System.runAs(aegOnsiteUser) {
                try {
                    List<TrainingAttendance__c> attendees = TrainingAttendeeMassUpdateController.getAttendeesList('');
                } catch(Exception ex) {
                    result = ex.getMessage();
                }
            }
        Test.stopTest();
        System.assertEquals(ERR_INSUFFICIENT_ACCESS, result, 'Succesfully retrieved attendee list');
    }

    /**********************************************************************
     * @description                 Perform positive test in updating
     *                              training attendees
     */
    @isTest
    static void updateRecordsTest() {
        TrainingSession__c eTrainSession = [SELECT Id FROM TrainingSession__c LIMIT 1];
        List<Contact> eContactsList = [SELECT Id FROM Contact LIMIT 50];
        List<TrainingAttendance__c> eTrainingAttendees = [SELECT Id, 
                                                                 TrainingAttendent__c,
                                                                 TrainingSessionID__c,
                                                                 Not_on_Enrolment_List__c
                                                          FROM TrainingAttendance__c
                                                          WHERE TrainingSessionID__c = :eTrainSession.Id
                                                          LIMIT 50];

        for (TrainingAttendance__c eAttendee : eTrainingAttendees) {
            eAttendee.Not_on_Enrolment_List__c = true;
        }

        Test.startTest();
            TrainingAttendeeMassUpdateController.updateRecords(JSON.serialize(eTrainingAttendees));
        Test.stopTest();
        eTrainingAttendees = [SELECT Id FROM TrainingAttendance__c WHERE Not_on_Enrolment_List__c = true];
        System.assertEquals(eContactsList.size(), eTrainingAttendees.size(), 'Failed to upsert attendees');
    }

    /**********************************************************************
     * @description                 Perform negative test in inserting/updating
     *                              training attendees by passing new attendees
     *                              with insufficient details
     *
     *                              Will throw 'Something went wrong. Please 
     *                              contact your administrator.' error
     *                              
     */
    @isTest
    static void updateRecordsWithoutContactTest() {
        String result;
        TrainingSession__c eTrainSession = [SELECT Id FROM TrainingSession__c LIMIT 1];
        List<Contact> eContactsList = [SELECT Id FROM Contact LIMIT 50];
        List<TrainingAttendance__c> nTrainingAttendees = createAttendees(eTrainSession.Id, eContactsList);
        List<TrainingAttendance__c> eTrainingAttendees = [SELECT Id, 
                                                                 TrainingAttendent__c,
                                                                 TrainingSessionID__c,
                                                                 Not_on_Enrolment_List__c
                                                          FROM TrainingAttendance__c
                                                          WHERE TrainingSessionID__c = :eTrainSession.Id
                                                          LIMIT 50];

        for (TrainingAttendance__c nAttendee : nTrainingAttendees) {
            nAttendee.TrainingSessionID__c = null;
            nAttendee.TrainingAttendent__c = null;
        }

        eTrainingAttendees.addAll(nTrainingAttendees);

        Test.startTest();
            try {
                TrainingAttendeeMassUpdateController.updateRecords(JSON.serialize(eTrainingAttendees));
            } catch (Exception ex) {
                result = ex.getMessage();
            }
            
        Test.stopTest();
        System.assertEquals(ERR_GENERIC_MESSAGE, result, 'Succesfully added new attendees');    
    }

    /**********************************************************************
     * @description                 Perform positive test in fetching contacts
     *                              with name having the same pattern
     */
    @isTest
    static void findContactsTest() {
        List<Contact> eContacts = new List<Contact>();
        Test.startTest();
            eContacts = TrainingAttendeeMassUpdateController.findContacts('Contact Test', new List<String>(), '');
        Test.stopTest();
        System.assert(!eContacts.isEmpty(), 'Failed to fetch contact records');
    }

    /**********************************************************************
     * @description                 Perform positive test in fetching contacts
     *                              with name having the same pattern
     *
     *                              Will return empty list since there are no
     *                              contact that have 'Cool Contacts' name
     */
    @isTest
    static void findContactsWithEmptyResultTest() {
        List<Contact> eContacts = new List<Contact>();
        Test.startTest();
            eContacts = TrainingAttendeeMassUpdateController.findContacts('Cool Contact', new List<String>(), '');
        Test.stopTest();
        System.assert(eContacts.isEmpty(), 'Successfully fetched contacts');
    }

    /**********************************************************************
     * @description                 Perform positive test in fetching field 
     *                              lookup filter and convert it to SOQL filter
     */
    @isTest
    static void fetchLookupFilterTest() {
        String filter;
        Test.setMock(HttpCalloutMock.class, new ToolingAPICalloutMock('GET', 200));
        Test.startTest();
            filter = TrainingAttendeeMassUpdateController.fetchLookupFilter('TrainingAttendent__c');
        Test.stopTest();
        System.assert(String.isNotBlank(filter), 'Failed to fetch lookup filter');
    }

    /**********************************************************************
     * @description                 Perform negative test in fetching field 
     *                              lookup filter and convert it to SOQL filter
     *      
     *                              Will result to bad request
     */
    @isTest
    static void fetchLookupFilterNegativeTest() {
        String errMessage;
        Test.setMock(HttpCalloutMock.class, new ToolingAPICalloutMock('GET', 400));
        Test.startTest();
            try {
                TrainingAttendeeMassUpdateController.fetchLookupFilter('TrainingAttendent__c');
            } catch (Exception ex) {
                errMessage = ex.getMessage();
            }
        Test.stopTest();
        System.assertEquals('400 : Bad Request', errMessage, 'Succesfully fetch lookup filter');
    }
    

    /**********************************************************************
     * @description                 Fetch recordtype id via object and recordtype name
     * 
     * @param  objApiName           Object api name
     * @param  recordTypeDevName    Recordtype Developer name
     * @return                      Id of recordtype
     */
    private static Id getRecordTypeIdByObjAndNAme(String objApiName, String recordTypeDevName) {
        return Schema.describeSObjects(new List<String>{objApiName})[0].getRecordTypeInfosByDeveloperName().get(recordTypeDevName).getRecordTypeId();
    }

    /**********************************************************************
     * @description                 Create account record
     * 
     * @param  counter              Suffix of account name
     * @return                      Account record with details
     */
    private static Account createCustomerAccount(Integer counter) {
        Account nAccount = new Account();
        nAccount.RecordTypeId = ACCOUNT_END_CONSUMER_RECORD_TYPE_ID;
        nAccount.Name = 'Account Test Name ' + String.valueOf(counter + 1);
        nAccount.Customer_Group_4_Code__c = 'BU';
        return nAccount;
    }

    /**********************************************************************
     * @description                 Create contact record
     * 
     * @param  counter              Suffix of contact name
     * @param  accountId            Parent account Id
     * @return                      Contact record with details
     */
    private static Contact createConsumerContact(Integer counter, Id accountId) {
        Contact nContact = new Contact();
        nContact.RecordTypeId = CONTACT_CONSUMER_PUBLIC_RECORD_TYPE_ID;
        nContact.FirstName = 'Contact Test First Name ' + String.valueOf(counter + 1);
        nContact.LastName = 'Contact Test Last Name ' + String.valueOf(counter + 1);
        nContact.AccountId = accountId;
        nContact.Email = 'ContactTestEmail' + String.valueOf(counter + 1) + '@yopmail.com';
        return nContact;
    }

    /**********************************************************************
     * @description                 Create course record
     * 
     * @param  counter              Suffix of course title
     * @return                      Course record with details
     */
    private static Course__c createCourse(Integer counter) {
        String uniqueIdentifier = String.valueOf(counter + 1);
        Course__c nCourse = new Course__c();
        nCourse.CourseTitle__c = 'Course ' + uniqueIdentifier;
        nCourse.Customer_Course_Reference__c = 'TBA-' + uniqueIdentifier;
        return nCourse;
    }

    /**********************************************************************
     * @description                 Create Training Session record
     * 
     * @param  counter              Suffix of training session name
     * @param  courseId             Parent course Id
     * @return                      Training session record with details
     */
    private static TrainingSession__c createConsumerSession(Integer counter, Id courseId) {
        TrainingSession__c nTrainingSession = new TrainingSession__c();
        nTrainingSession.RecordTypeId = CONSUMER_TRAINING_SESSION_RECORD_TYPE_ID;
        nTrainingSession.Training_Session_Name__c = 'Training Session ' + String.valueOf(counter + 1);
        nTrainingSession.Bunnings_Course_Code__c = '1234' + String.valueOf(counter);
        nTrainingSession.Start_Date_Time__c = System.now();
        nTrainingSession.End_Date_Time__c = System.now() + 30;
        nTrainingSession.CourseID__c = courseId;
        return nTrainingSession;
    }

    /**********************************************************************
     * @description                 Create Training Attendance records
     * 
     * @param  sessionId            Parent Training Session Id
     * @param  consumerContacts     List of contacts to be linked
     * @return                      List of atendee records
     */
    private static List<TrainingAttendance__c> createAttendees(Id sessionId, List<Contact> consumerContacts) {
        List<TrainingAttendance__c> trainingAttendanceList = new List<TrainingAttendance__c>();
        for (Integer counter = 0; counter < consumerContacts.size(); counter++) {
            trainingAttendanceList.add(new TrainingAttendance__c(
                TrainingAttendent__c = consumerContacts[counter].Id,
                TrainingSessionID__c = sessionId
            ));
        }
        return trainingAttendanceList;
    }

}