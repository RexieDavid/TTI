/**
 * @author:                         Kristopher Veraces
 * @date:                           2020-08-13
 */
@isTest
private class LeadTriggerHandlerTest {
    private static final LeadTriggerDataService SERVICE = 
        (LeadTriggerDataService) Test.createStub(LeadTriggerDataService.class, new LeadTriggerDataServiceMock());
    private static final String MOCK_PROJECT_ID = 'a0c0o000000SUCCESS';
    private static final String MOCK_GROUP_ID = '00G0o000002SUCCESS';

    /**********************************************************************
     * @description:                Update Project field if BCI Project Id
     *                              has a value
    */
    @isTest
    static void updateProjectTest() {
        List<Lead> leads = createLeads();
        for (Lead lead : leads) {
            lead.BCI_ProjectID__c = 'Dummy_BCI_Project_Id';
        }
        Test.startTest();
            LeadTriggerHandler.service = SERVICE;
            LeadTriggerHandler.onBeforeInsert(leads);
        Test.stopTest();
        System.assertEquals(MOCK_PROJECT_ID, leads[0].Project__c, 'Failed to update project');
    }

    /**********************************************************************
     * @description:                Update Lead record type and assign it
     *                              to queue if BCI ContactId has a value
    */
    @isTest
    static void assignOwnerAndUpdateRecordTypeTest() {
        List<Lead> leads = createLeads();
        for (Lead lead : leads) {
            lead.BCI_ContactID__c = 'Dummy_BCI_Contact_Id';
        }

        Test.startTest();
            LeadTriggerHandler.service = SERVICE;
            LeadTriggerHandler.onBeforeInsert(leads);
        Test.stopTest();
        System.assertEquals(MOCK_GROUP_ID, leads[0].OwnerId, 'Failed to update lead owner and recordtype');
    }

    /**********************************************************************
     * @description:                Update Lead record type and assign it
     *                              to queue if BCI ContactId has a value
     * 
     *                              Will throw an error if group queue not
     *                              found
    */
    @isTest
    static void assignOwnerAndUpdateRecordTypeNegativeTest() {
        String error;
        List<Lead> leads = createLeads();
        for (Lead lead : leads) {
            lead.BCI_ContactID__c = 'Dummy_BCI_Contact_Id';
        }

        Test.startTest();
            LeadTriggerHandler.service = SERVICE;
            LeadTriggerDataServiceMock.hasError = true;
            try {
                LeadTriggerHandler.onBeforeInsert(leads);
            } catch (Exception ex) {
                error = ex.getMessage();
            }
            
        Test.stopTest();
        System.assertEquals('BCI leads queue group not found.', error, 'Succesfully assigned to queue');
    }

    /**********************************************************************
     * @description:                Insert lead to run in trigger context.
     *                              Only to cover the trigger part
     * 
     * @note                        Type of integration testing, prone to
     *                              different types of error (e.g. validation, 
     *                              required fields, etc.)
    */
    @isTest
    static void insertTriggerTest() {
        Test.startTest();
            LeadTriggerHandler.service = SERVICE;
            insert createLeads();
        Test.stopTest();
        List<Lead> leads = [SELECT Id FROM Lead];
        System.assertEquals(100, leads.size(), 'Failed to insert lead records');
    }

    /**********************************************************************
     * @description:                Create lead records
    */
    private static List<Lead> createLeads() {
        String mockValue = 'Mock' + Datetime.now().getTime();
        List<Lead> leads = new List<Lead>();
        for (Integer i = 0; i < 100; i++) {
            Lead lead = new Lead();
            lead.LastName = mockValue + i;
            lead.Company = mockValue + i;
            leads.add(lead);
        }
        return leads;
    }
}