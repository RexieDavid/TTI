/**
 * @author:                         Stephen James Laylo
 * @date:                           2017-04
 * @description:                    Handles all CRUD operations for the
 *                                  Lead Trigger. All logic should be placed here and not in the
 *                                  trigger itself
 */
public class LeadTriggerHandler {
    private static final String END_CONSUMER_IND_TYPE = 'End_Consumer_IND';
    @TestVisible
    private static LeadTriggerDataService service = new LeadTriggerDataService();

    /**********************************************************************
     * @author:                     Stephen James Laylo
     * @date:                       2017-04
     * @param newLeads              List of new leads
     * 
     * @description:                Handles all on Before Insert
     *                              functionalities of the Lead
     */ 
    public static void onBeforeInsert(List<Lead> newLeads) {
        setLeadBrand(newLeads);
        assignToQueueAndUpdateRecordType(newLeads);
        updateProject(newLeads);
    }

    /**********************************************************************
     * @author:                     Rexie Aaron David
     * @date:                       6/1/2023
     * @param newLeads              List of new leads
     * 
     * @description:                Handles all on Before Update
     *                              functionalities of the Lead
     */ 
    public static void onBeforeUpdate(List<Lead> newLeads) {
        setLeadBrand(newLeads);
    }

    /**********************************************************************
     * @author:                     Stephen James Laylo
     * @date:                       2017-04
     * @param leads                 List of new leads
     * 
     * @description:                Updates Project value if 
     *                              BCI Project Id was populated
    */ 
    private static void updateProject(List<Lead> leads) {
        Map<String, Id> projects = fetchProjects(leads);
        for (Lead lead : leads) {
            if (projects.containsKey(lead.BCI_ProjectID__c)) {
                lead.Project__c = projects.get(lead.BCI_ProjectID__c);
            }
        }
    }

    /**********************************************************************
     * @param leads                 List of new leads
     * 
     * @description:                Updates Owner and recordtype if 
     *                              BCI Contact Id was populated
    */ 
    private static void assignToQueueAndUpdateRecordType(List<Lead> leads) {
        Group queueGroup = service.fetchBCILeadGroup();
        String leadEndConsumerIndRecordtypeId = Schema.SObjectType.Lead
                                                    .getRecordTypeInfosByDeveloperName()
                                                    .get(END_CONSUMER_IND_TYPE)
                                                    .getRecordTypeId();
        for (Lead lead : leads) {
            if (lead.BCI_ContactID__c != null) {
                lead.OwnerId = queueGroup.Id;
                lead.RecordTypeId =  leadEndConsumerIndRecordtypeId;
            }
        }
    }

    /**********************************************************************
     * @param leads                 List of new leads
     * 
     * @description:                Fetch project records
    */ 
    private static Map<String, Id> fetchProjects(List<Lead> leads) {
        Set<String> projectIds = fetchLeadProjectIds(leads);
        Map<String, Id> projects = new Map<String, Id>();
        for (Project__c project : service.fetchProjects(projectIds)) {
            projects.put(project.BCI_Project_ID__c, project.Id);
        }
        return projects;
    }

    /**********************************************************************
     * @param leads                 List of new leads
     * 
     * @description:                Consolidate lead project Ids
    */
    private static Set<String> fetchLeadProjectIds(List<Lead> leads) {
        Set<String> projectIds = new Set<String>();
        for (Lead lead : leads) {
            if (String.isNotBlank(lead.BCI_ProjectID__c)) {
                projectIds.add(lead.BCI_ProjectID__c);
            }
        }
        return projectIds;
    }

    /**********************************************************************
     * @author:                     Rexie Aaron David
     * @date:                       6/1/2023
     * @param leads                 List of new leads
     * 
     * @description:                [SD-2201] Set Lead_Brand__c value as placeholder for Lead Conversion Mapping,
     *                              Reason: Lead Brand__c field is a multiselect picklist, referencing it using a formula is not possible.
    */ 
    private static void setLeadBrand(List<Lead> leads) {
        for (Lead lead : leads) {
            if (lead.Brand__c != NULL) {
                lead.Lead_Brand__c = lead.Brand__c;
            }
        }
    }

}