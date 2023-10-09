/**
* @author           Samuel Oberes
* @date             2021-02-23
* @description      Serves as exclusive backend controller for the spRctiReprocessing LWC component
*/
public with sharing class SpRctiReprocessingController {

    /**********************************************************************
     * @description           Returns the file name of all the casenumber-bearing CSV files needed for the migration
     * @return                List of file names
     */
    @AuraEnabled(cacheable=true)
    public static List<String> getFilesToLoad() {
        List<String> filesToLoad = new List<String>();
        for (ContentVersion cv : [SELECT Title FROM ContentVersion WHERE Title LIKE '%rcti-migration-%' AND CreatedById = :UserInfo.getUserId()]) {
            filesToLoad.add(cv.Title);
        }
        return filesToLoad;
    }

    /**********************************************************************
     * @description               Returns all the pertinent claim details needed in the migration and monitoring
     * @param migrationFileTitle  Filename of the casenumber-bearing CSV file that needs to be loaded for migration
     * @return                    List of claims and their details based on the contents of the CSV migration file
     */
    @AuraEnabled(cacheable=true)
    public static List<Claim> getClaimsForReprocessing(String migrationFileTitle) {
        ContentVersion cv = [SELECT Id, VersionData FROM ContentVersion WHERE Title = :migrationFileTitle AND CreatedById = :UserInfo.getUserId()];

        List<Claim> claimsToReturn = new List<Claim>();
        List<String> csvLines = cv.VersionData.toString().split('\n');
        List<String> caseNumbers = new List<String>();
        for (Integer i = 1; i < csvLines.size(); i++) {
            List<String> csvRowData = csvLines[i].split(',');
            caseNumbers.add(csvRowData[0]);
        }

        for (Case c : [SELECT Casenumber, 
                              Status, 
                              Invoice_Number_PC__c, 
                              AWS_Invoice_File_Key__c 
                         FROM Case
                        WHERE Casenumber IN :caseNumbers]) {
            Claim claim = new Claim();
            claim.id = c.Id;
            claim.caseNumber = c.Casenumber;
            claim.invoiceNumber = c.Invoice_Number_PC__c;
            claim.status = c.Status;
            claim.invoiceFileKey = c.AWS_Invoice_File_Key__c;
            claimsToReturn.add(claim);
        }
        return claimsToReturn;
    }

    /**********************************************************************
     * @description           Calls the RCTI generation service to start the PDF generation and e2e AWS process
     * @param caseIds         List of case ids where the PDF generation should run for
     */
    @AuraEnabled
    public static void startReprocessing(List<Id> caseIds) {
        System.debug('DBG: startReprocessing caseIds --- ' + caseIds);
        SpRctiGenerationService.start(new Set<Id>(caseIds));
    }

    public class Claim {

        @AuraEnabled
        public String id { get; set; }

        @AuraEnabled
        public String caseNumber { get; set; }

        @AuraEnabled
        public String invoiceNumber { get; set; }

        @AuraEnabled
        public String status { get; set; }

        @AuraEnabled
        public String invoiceFileKey { get; set; }

    }

}