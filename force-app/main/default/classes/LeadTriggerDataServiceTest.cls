/**
 * @author:                         Kristopher Veraces
 * @date:                           2020-08-13
 */
@isTest
private class LeadTriggerDataServiceTest {
    private static final LeadTriggerDataService SERVICE = new LeadTriggerDataService();
    private static final String BCI_LEADS_MOCK_GROUP = 'BCI Leads Mock Group';
    private static final String QUEUE_GROUP_NOT_FOUND = 'BCI leads queue group not found.';
    private static final String REQUIRED_PROJECT_IDS = 'Must provide project Ids.';

    /**********************************************************************
     * @description:                Create BCI Lead Mock Group
    */
    @TestSetup
    static void makeData(){
        Group mockGroup = new Group();
        mockGroup.Name = BCI_LEADS_MOCK_GROUP;
        mockGroup.Type = 'Queue';
        insert mockGroup;
    }

    /**********************************************************************
     * @description:                Fetch BCI Mock Group
    */
    @isTest
    private static void fetchBCILeadGroupTest() {
        Group queueGroup;
        Test.startTest();
            SERVICE.BCILeadQueueGroup = BCI_LEADS_MOCK_GROUP;
            queueGroup = SERVICE.fetchBCILeadGroup();
        Test.stopTest();
        System.assert(queueGroup != null, 'Failed to fetch queue group');
    }

    /**********************************************************************
     * @description:                Fetch non existent BCI Mock Group
     * 
     *                              Will throw an error 
     *                              BCI leads queue group not found
    */
    @isTest
    private static void fetchBCILeadGroupNegativeTest() {
        String error;
        Test.startTest();
            try {
                SERVICE.BCILeadQueueGroup = 'Mock Group' + Datetime.now().getTime();
                SERVICE.fetchBCILeadGroup();
            } catch (Exception ex) {
                error = ex.getMessage();
            }
        Test.stopTest();
        System.assertEquals(QUEUE_GROUP_NOT_FOUND, error, 'Succesfully fetch queue group');
    }

    /**********************************************************************
     * @description:                Fetch project records with given project Ids
    */
    @isTest
    private static void fetchProjectsTest() {
        Set<String> projectIds = new Set<String>{'000001', '00002'};
        List<Project__c> projects;
        Test.startTest();
            projects = SERVICE.fetchProjects(projectIds);
        Test.stopTest();
        System.assert(projects != null, 'Failed to fetch project records');
    }

    /**********************************************************************
     * @description:                Fetch project records without giving 
     *                              project Ids
    */
    @isTest
    private static void fetchProjectsNegativeTest() {
        String error;
        Test.startTest();
            try {
                SERVICE.fetchProjects(null);
            } catch (Exception ex) {
                error = ex.getMessage();
            }
        Test.stopTest();
        System.assertEquals(REQUIRED_PROJECT_IDS, error, 'Succesfully fetch project records');
    }


}