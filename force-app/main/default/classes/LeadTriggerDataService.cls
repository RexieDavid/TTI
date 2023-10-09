/**
 * @author:                         Kristopher Veraces
 * @date:                           2020-08-13
 * @description:                    Will house all the functionality for
 *                                  Data service layer (e.g. SOQL, DMLs)
 */
public class LeadTriggerDataService {
    private final String QUEUE_GROUP_NOT_FOUND = 'BCI leads queue group not found.';
    private final String REQUIRED_PROJECT_IDS = 'Must provide project Ids.';
    @TestVisible
    private String BCILeadQueueGroup = 'BCI Leads';

    /**********************************************************************
     * @description:                Fetch BCI Leads Queue Group
     * 
     *                              Will throw an error if Group not found
    */
    public Group fetchBCILeadGroup() {
        try {
            return [SELECT Id,
                            Name,
                            DeveloperName,
                            Email,
                            Type
                    FROM Group
                    WHERE Type = 'Queue'
                    AND Name = :this.BCILeadQueueGroup 
                    LIMIT 1];
        } catch (Exception ex) {
            // Possible error - List has no rows for assignment to SObject
            throw new LeadTriggerDataServiceException(this.QUEUE_GROUP_NOT_FOUND);
        }
    }

    /**********************************************************************
     * @description:                Fetch Project Records
     * 
     * @param projectIds            List of project Ids | Required
    */
    public List<Project__c> fetchProjects(Set<String> projectIds) {
        if (projectIds == null) {
            throw new LeadTriggerDataServiceException(this.REQUIRED_PROJECT_IDS);
        }

        return [SELECT Id, 
                       BCI_Project_ID__c 
                FROM Project__c 
                WHERE BCI_Project_ID__c IN :projectIds];
    }

    /**********************************************************************
     * @description:                Custom Exception
    */
    public class LeadTriggerDataServiceException extends Exception {}
}