/**
 * @author:                         Kristopher Veraces
 * @date:                           2020-08-13
 * @description:                    Will house data mocking for test class
 */
@isTest
public class LeadTriggerDataServiceMock implements System.StubProvider {
    private final String LEAD_QUEUE_GROUP_NOT_FOUND = 'BCI leads queue group not found.';
    private final String MOCK_PROJECT_ID = 'a0c0o000000SUCCESS';
    private final String MOCK_GROUP_ID = '00G0o000002SUCCESS';
    public static Boolean hasError = false;

    public Object handleMethodCall(
        Object stubbedObject, 
        String stubbedMethodName, 
        Type returnType, 
        List<Type> listOfParamTypes, 
        List<String> listOfParamNames, 
        List<Object> listOfArgs) { 

        switch on stubbedMethodName { 
            when 'fetchBCILeadGroup' {
                return this.createGroup();
            }
            when 'fetchProjects' {
                if (hasError) {
                    throw new LeadTriggerDataServiceMockException(this.LEAD_QUEUE_GROUP_NOT_FOUND);
                }
                return this.createProjects();
            }
            when else {
                NoSuchElementException nsee = new NoSuchElementException();
                nsee.setMessage('The method called currently isn\'t set up and cannot be mocked.');
                throw nsee;
            }
        }
    }

    /**********************************************************************
     * @description:                Create mock group record
    */
    private Group createGroup() {
        return new Group(
            Id = this.MOCK_GROUP_ID,
            Name = 'Dummy Group'
        );
    }

    /**********************************************************************
     * @description:                Create mock project records
    */
    private List<Project__c> createProjects() {
        List<Project__c> projects = new List<Project__c>();
        for (Integer i = 0; i < 100; i++) {
            Project__c project = new Project__c();
            project.Id = this.MOCK_PROJECT_ID;
            project.BCI_Project_ID__c = 'Dummy_BCI_Project_Id';
            projects.add(project);
        }
        return projects;
    }

    /**********************************************************************
     * @description:                Custom Exception
    */
    public class LeadTriggerDataServiceMockException extends Exception {}
}