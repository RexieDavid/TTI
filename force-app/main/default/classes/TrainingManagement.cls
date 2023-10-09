public class TrainingManagement {

    //temp var to compile
    public static string Course_Title;
    public static string Class_Location;
    public static string ClassName;
    public static string Region;
    public static string TMNumber;
    public static string Learner;
    public static Datetime Class_Start;
    public static Datetime Class_End;
    public static string TM_Current_Location;
    //end temp var

    // public static String docId;
    public static List<Course__c> courses;
    public static List<TrainingSession__c> trainings;
    public static List<TrainingAttendance__c> attendances;
    public static List<Account> locationAccs;
    public static List<Account> accounts;
    public static List<Contact> contacts;

    public static Course__c course;
    public static TrainingSession__c training;
    public static Contact con;
    public static TrainingAttendance__c attendance;
    
    @InvocableMethod
    public static void executeUpdate(List<String> documentIds) {
        //Logic for parsing the file and its contents
        //The first line is necessary as you cannot get the contents of a file unless it is attached to a document record
        // Document doc = [SELECT Id, body FROM ContentDocument WHERE id =: documentIds[0]];
        ContentVersion file = [SELECT Title, VersionData FROM ContentVersion WHERE IsLatest = TRUE and ContentDocumentId IN: documentIds];
        //Fetch the contents of the file into a string
        String stringBody = file.VersionData.toString();
        // String stringBody = doc.body.tostring();
        //Split each line at the end into a string
        List<String> fileLines = stringBody.split('\n');
        //remove header
        fileLines.remove(0);

        //List to hold the list of records after split
        List<List<String>> splitRecordsList = new List<List<String>>();
        //Set to hold the set of courese code + Store No
        Set<String> courseCodeStoreNoSet = new Set<String>();
        //Set of store code - to identify accounts
        Set<String> storeCodeSet = new Set<String>();
        //Set of TMNumber - to identify contacts
        Map<String, String> tmNumberSet = new Map<String, String>();
        //Map to hold course code and relevant list of training at each store
        Map<String, List<String>> courseCodeToListOfTrainingsAtStore = new Map<String, List<String>>();

        //Iterate thorugh each line in the fileLines list
        for (String singleRecord : fileLines) {
            // String singleRecordFromFileLInes = 'TTI - AEG Elite - Force & Fusion,PT0077,TTI - AEG Elite - Force & Fusion,Cockburn Central Warehouse,422161,Cockburn Central Warehouse,WA,2160,Elena Baker,2/01/2023 14:00,2/01/2023 15:30,In-Person,Enrolled,Learning Support,TTI - AEG Elite - Force & Fusion,,,,PT0077';
            //Split the string at ,
            // List<String> splitString = singleRecordFromFileLInes.split(',');
            List<String> splitString = singleRecord.split(',');
            System.debug('Split String array ==> ' + splitString);
            System.debug('Split String array ==> ' + splitString.size());
            if(splitString[0] != '') {
                //Add the store code to storeCodeSet
                storeCodeSet.add(splitString[7]);
                //Add TM Number to tmNumberSet along with the name of the contact, store code and course code
                tmNumberSet.put(splitString[4], splitString[4] + '-' + splitString[8] + '-' + splitString[7] + '-' + splitString[1]);
                //Combination of course code and store number can bbe used to identify unique training session
                //Form and string with the values of course code and store no with - in between and store it in a set
                //coursecode-storeno
                String courseCodeStorNoString = splitString[1] + '-' + splitString[7];
                System.debug(courseCodeStorNoString);
                courseCodeStoreNoSet.add(courseCodeStorNoString);
                splitRecordsList.add(splitString);
                System.debug(splitRecordsList);
            }
        }

        //Get the account information along with the associated contacts
        List<Account> accountListBasedOnStoreCode =  [SELECT Id, Name, AccountNumber, (SELECT Id, Name, AccountId, Team_Member_Id__c FROM Contacts) FROM Account WHERE AccountNumber IN :storeCodeSet];

        Map<String, List<String>> courseMap = new Map<String, List<String>>();
        //Iterate through the set of courseCodeStoreNoSet to get unique trainings at each store
        for (String st : courseCodeStoreNoSet) {
            //split the string at -
            List<String> storeCodeStoreNoList = st.split('-');
            // Set<String> uniqueTrainingsPerCourse = new Set<String>();
            //Iterate thorugh splitRecordsList and check if the records have same course code and store no
            //Add the matched records to the map of couserCodeToListOfTrainingsAtStore
            for (List<String> strList : splitRecordsList) {
                String courseStore = strList[1] + '-' + strList[7];
                if (
                    storeCodeStoreNoList[0] == strList[1] &&
                    storeCodeStoreNoList[1] == strList[7]&&
                    !courseCodeToListOfTrainingsAtStore.containsKey(courseStore)
                ) {
                    //Add the list of training records at each store per course into map of coursecode-storenum a nd list of trainings
                    courseCodeToListOfTrainingsAtStore.put(st, strList);
                    if(!courseMap.containsKey(strList[1])) {
                        courseMap.put(strList[1], strList);
                    }
                }
            }
        }
        
        List<Course__c> courses = new List<Course__c>();
        Map<String, String> courseCodeToCourseIdMap = new Map<String, String>();

        //Course Data
        //Fetch all the courses where the deactivate date field is not blank
        courses = [SELECT Id, Course_Code__c FROM Course__c WHERE Course_Status__c = 'Active'];
        //Map course id based on course code
        for(Course__c cor : courses) {
            courseCodeToCourseIdMap.put(cor.Course_Code__c, cor.Id);
        }

        List<Course__c> coursesToBeCreated = new List<Course__c>();
        //Iterate through courseMap keySet
        for(String courseCode : courseMap.keySet()) {
            //Check if course is existing 
            Boolean containsCourse = courseCodeToCourseIdMap.containsKey(courseCode);
            if(!containsCourse) {
                //Else create course
                Course__c newCor = new Course__c();
                newCor.Course_Code__c = courseCode;
                newCor.Course_Status__c = 'Active';
                newCor.CourseTitle__c = courseMap.get(courseCode)[0];
                coursesToBeCreated.add(newCor);
            }
        }
        try {
            System.debug('coursesToBeCreated: ' + coursesToBeCreated.size());
            insert coursesToBeCreated;
        } catch(Exception e) {
            System.debug('Insert operation on new courses failed: ' + e);
        }

        //Iterate though created courses and add to course map
        for(Course__c cor : coursesToBeCreated) {
            courseCodeToCourseIdMap.put(cor.Course_Code__c, cor.Id);
        }

        //Separate the Contact Information
        Map<String, Contact> contactsMapFromAccount = new Map<String, Contact>();
        List<Contact> contactsToBeCreated = new List<Contact>();
        Map<String, String> storeCodeToAccountIdMap = new Map<String, String>();

        //Iterate thorugh the account records and contacts list and fecth the contacts into the contactsListFromAccount list
        for(Account acc : accountListBasedOnStoreCode) {
            storeCodeToAccountIdMap.put(acc.AccountNumber,acc.Id);
            for(Contact cont : acc.Contacts) {
                contactsMapFromAccount.put(cont.Team_Member_Id__c, cont);
            }
        }

        //Iterate thorugh the contact information in tmNumberSet
        //Check if the TM Number exits in the  contactsMapFromAccount keyset
        //if a contact with tm number doesnt exist put the contact information in contactsToBeCreated
        for(String tmNum : tmNumberSet.keyset()) {
            //Check if the TMNumber is present in the contacts from the account query
            Boolean containsTMNumber = contactsMapFromAccount.containsKey(tmNum);
            //If not present then get map value for the key
            if(!containsTMNumber) {
                String tmMapValue = tmNumberSet.get(tmNum);
                List<String> conDetails = tmMapValue.split('-');
                //Iterater thorugh the account record
                for(Account accRec : accountListBasedOnStoreCode) {
                    //Check if the store number from tm map value matches the account number
                    if(conDetails[2] == accRec.AccountNumber) {
                        //Create a new contact record and add it to the list
                        Contact conTobCreated = new Contact();
                        String name = conDetails[1];
                        conTobCreated.FirstName = name.split(' ')[0];
                        conTobCreated.LastName = name.split(' ')[1];
                        conTobCreated.Team_Member_Id__c = conDetails[0];
                        conTobCreated.AccountId = accRec.Id;
                        contactsToBeCreated.add(conTobCreated);
                    }
                }
            }
        }

        //Insert the contacts that doesn't exist
        Set<String> createdContactIdSet = new Set<String>();
        try {
            insert contactsToBeCreated;
        } catch(Exception e) {
            System.debug('Insert operation on new contacts failed: ' + e);
        }

        //Iterate thorugh the created contacts and add it to the map so that we have combined contact list
        for(Contact newCon : contactsToBeCreated) {
            contactsMapFromAccount.put(newCon.Team_Member_Id__c, newCon);
        }

        //Training Data
        //Fetch the 'Consumer Training Session' record type
        RecordType consumerTrainingRecordType = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'Consumer_Training_Session' AND SObjectType = 'TrainingSession__c'];
        //storeCodeToAccountIdMap
        //contactsMapFromAccount
        //couserCodeToListOfTrainingsAtStore
        //courseCodeToCourseIdMap
        //Fields needed for Training Creation - CourseID__c, Training_Location_Account__c, Training_Session_Name__c, State__c, Start_Date_Time__c, End_Date_Time__c

        //List of trainings to be inserted
        List<TrainingSession__c> trainingsToBeInserted = new List<TrainingSession__c>();
        //Iterate though the map couserCodeToListOfTrainingsAtStore
        for(List<String> singleTrainingArray : courseCodeToListOfTrainingsAtStore.values()) {
            //Construct the training object
            System.debug('singleTrainingArray: ' + singleTrainingArray);
            TrainingSession__c session = new TrainingSession__c();
            System.debug('courseId: ' + courseCodeToCourseIdMap.get(singleTrainingArray[1]));
            session.CourseID__c = courseCodeToCourseIdMap.get(singleTrainingArray[1]);
            session.Training_Location_Account__c = storeCodeToAccountIdMap.get(singleTrainingArray[7]);
            session.Training_Session_Name__c = singleTrainingArray[2];
            session.State__c = singleTrainingArray[6];
            session.Start_Date_Time__c = parseDateTime(singleTrainingArray[9]);
            session.End_Date_Time__c = parseDateTime(singleTrainingArray[10]);
            session.RecordTypeId = consumerTrainingRecordType.Id;
            trainingsToBeInserted.add(session);
        }

        //Insert the training
        Set<String> createdSessionIdSet = new Set<String>();
        try {
            insert trainingsToBeInserted;
            //Fetch the id of sessions created into a set
            for(TrainingSession__c sInserted : trainingsToBeInserted) {
                createdSessionIdSet.add(sInserted.Id);
            }
        } catch(Exception e) {
            System.debug('Insert operation on new training sessions failed: ' + e);
        }

        //Query the trainings
        List<TrainingSession__c> newlyCreatedTrainingsList = [SELECT Id, CourseID__c, CourseID__r.Course_Code__c, Training_Location_Account__c, Training_Location_Account__r.AccountNumber, Training_Session_Name__c, State__c, Start_Date_Time__c, End_Date_Time__c FROM TrainingSession__c WHERE Id IN :createdSessionIdSet];

        List<TrainingAttendance__c> attendList = new List<TrainingAttendance__c>();

        //Fetch the 'Consumer Attendance' record type
        RecordType consumerAttendanceRecordType = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'Consumer_Attendance' AND SObjectType = 'TrainingAttendance__c'];

        //Iterate through the tmNumberSet
        for(String tmNum : tmNumberSet.keyset()) {
            
            //split the value of the tmNumberSet map, which will return an array of TMNumber, Course Code, Store Code
            List<String> tmNumDetails = tmNumberSet.get(tmNum).split('-');
            System.debug('tmNumDetails: ' + tmNumDetails);
            System.debug('tmNumDetails[3]: ' + tmNumDetails[3]);
            System.debug('tmNumDetails[2]: ' + tmNumDetails[2]);
            
            //Iterate through the trainings
            for(TrainingSession__c newSes : newlyCreatedTrainingsList) {
                System.debug('newSes: ' + newSes);
                //Whenever the training course code and store matches the above line course code and store code
                //Use the store for identifying the account
                //use the TM number for identifying the contact
                System.debug('newSes.CourseID__r.Course_Code__c: ' + newSes.CourseID__r.Course_Code__c);
                System.debug('newSes.Training_Location_Account__r.AccountNumber: ' + newSes.Training_Location_Account__r.AccountNumber);
                if(tmNumDetails[3] == newSes.CourseID__r.Course_Code__c &&
                tmNumDetails[2] == newSes.Training_Location_Account__r.AccountNumber) {
                    System.debug('if true');
                    //get the contact record from the contactsMapFromAccount mpa by passing the tmnumber is in the get method
                    Contact con = contactsMapFromAccount.get(tmNumDetails[0]);
                    System.debug('con: ' + con);

                    //using that contact create training member record
                    TrainingAttendance__c attend = new TrainingAttendance__c();
                    attend.TrainingAttendent__c = con.Id;
                    attend.TrainingSessionID__c = newSes.Id;
                    attend.Enrolled__c = TRUE;
                    attend.RecordTypeId = consumerAttendanceRecordType.Id;
                    attendList.add(attend);
                    System.debug('attend: ' + attend);
                    break;
                }
            }
        }

        try {
            System.debug('attendList.size(): ' + attendList.size());
            insert attendList;
        } catch(Exception e) {
            System.debug('Insert operation on new training sessions failed: ' + e);
        }
    }


    public static void updateTrainingDetails() {
        //find course
        courses = new List<Course__c>();
        courses = [SELECT Id FROM Course__c WHERE CourseTitle__c =: Course_Title];

        //create course if non-existent
        if(courses.isEmpty()) {
            course = new Course__c();
            course.CourseTitle__c = Course_Title;
            insert course;
        } else {
            course = courses[0];
        }

        // find account
        locationAccs = new List<Account>();
        locationAccs = [SELECT Id FROM Account WHERE Name =: Class_Location];
        trainings = new List<TrainingSession__c>();

        // find training session
        if(!locationAccs.isEmpty()) {
            trainings = [SELECT Id FROM TrainingSession__c WHERE Training_Session_Name__c =: ClassName OR Training_Location_Account__c =: accounts[0].Id];
        } else {
            trainings = [SELECT Id FROM TrainingSession__c WHERE Training_Session_Name__c =: ClassName];
        }

        // create training session if non-existent
        if(trainings.isEmpty()) {
            training = new TrainingSession__c();
            training.CourseID__c = course.Id;
            training.Training_Session_Name__c = ClassName;
            training.Training_Location_Account__c = accounts[0].Id;
            training.Region__c = Region;
            training.Start_Date_Time__c = Class_Start;
            training.End_Date_Time__c = Class_End;
            insert training;
        } else {
            training = trainings[0];
        }

        accounts = [SELECT Id FROM Account WHERE Name =: TM_Current_Location];

        // find contact
        contacts = new List<Contact>();
        contacts = [SELECT Id FROM Contact WHERE Team_Member_Id__c =: TMNumber OR Name =: Learner];

        if(contacts.isEmpty()) {
            con = new Contact();
            con.FirstName = Learner;
            con.Team_Member_Id__c = TMNumber;
            con.Local_Bunnings_Store__c =  accounts[0].Id;
            insert con;
        } else {
            con = contacts[0];
        }

        //find training attendance
        attendances = [SELECT Id FROM TrainingAttendance__c WHERE TrainingAttendent__c =: con.Id];

        if(attendances.isEmpty()) {
            attendance = new TrainingAttendance__c();
            attendance.TrainingAttendent__c = con.Id;
            insert attendance;
        }
    }

    public static DateTime parseDateTime(String stringDateTime) {
        List<String> listDate = stringDateTime.split(' ');
        system.debug(listDate);
        List<String> listTime = listDate[1].split(':');
        System.debug(listTime);
        Date toDate = Date.parse(listDate[0]);
        Time toTime = Time.newInstance(integer.valueOf(listTime[0]), integer.valueOf(listTime[1]), 0, 0);
        DateTime parsed = DateTime.newInstanceGmt(todate, totime);
        return parsed;
    }
}