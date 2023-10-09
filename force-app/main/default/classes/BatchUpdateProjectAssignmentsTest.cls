/**
* @author      : Ericka Cajucom
* @date        : 2020-05-15
*/
@isTest
private class BatchUpdateProjectAssignmentsTest {

    private static final String NO_RECORD_UPDATED = 'No Records Were Updated';
   
    @testSetup
    static void testDataSetup() {
        
        Profile stdUsrProfile = [SELECT Id FROM Profile WHERE Name='Standard User'];
        
        User stdUser = new User(Alias = 'standt',
                Email = 'standarduser@testorg.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'Testing',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = stdUsrProfile.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = 'teststandard@testing.com',
                TTI_SAP_Cust_No__c = '12345',
                Division = 'Industrial');
        insert stdUser;
        
        RecordType iMogRegionRecType = [SELECT Name, Id FROM RecordType WHERE Name = 'Industrial MOG Region'];
        Region__c nRegion = new Region__c(Region_Name__c ='testRegion',
                                        Assigned_to__c = stdUser.id,
                                        Region_State__c = 'VIC',
                                        RecordTypeId = iMogRegionRecType.Id);
        insert nRegion ;
        
        Postcode__c nPCode = new Postcode__c(Suburb__c = 'test Suburb',
                                        Postcode__c   = '9999',
                                        JSS_Region__c = nRegion.id);
        insert nPCode;
           
        List<Project__c> projectList = new List<Project__c>();
        for(integer i = 0; i < 10; i++){
            Project__c nProject = new Project__c(Project_Long_Name__c = 'test' + i,
                                        Postcode__c = nPCode.Postcode__c,
                                        Lock_Record_Owner__c = false,
                                        OwnerId = stdUser.Id,
                                        State__c = 'VIC');
            projectList.add(nProject);
        }
        insert projectList;
        
        projectList[0].Project_Category__c = 'Oil and Gas';
        update projectList[0];
    }
    
    /**********************************************************************
    * @description Update project owner id to the region assigned to
    */
    private static testmethod void testBatchUpdateProjectAssignments() {
   
        Test.startTest();
        Batch_UpdateProjectAssignments obj = new Batch_UpdateProjectAssignments();
        DataBase.executeBatch(obj);
        Test.stopTest();
        
        List<Project__c> projectList = [SELECT OwnerId FROM Project__c];
        Region__c region = [SELECT Assigned_to__c FROM Region__c];
        
        System.assertEquals(projectList[0].OwnerId, region.Assigned_to__c, NO_RECORD_UPDATED);
        
    }
}