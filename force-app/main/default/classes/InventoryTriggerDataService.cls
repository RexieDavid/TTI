/**
 * @author                          Kristopher Veraces
 * 
 * @date                            2020-08-11
 * 
 * @description                     Store SOQL queries or DMLs in 
 *                                  Inventory Trigger Handler class
 */ 
public class InventoryTriggerDataService {

    private final String CUSTOMER_NUMBERS_REQUIRED = 'Missing SAP Customer Numbers';

    /**********************************************************************
     * @description                     Fetch SAP user owners
     * 
     * @param sapCustomerNumbers        Collection of SAP customer numbers
     */
    public List<User> fetchSAPUsers(Set<String> sapCustomerNumbers) {
        if (sapCustomerNumbers == null) {
            throw new InventoryTriggerDataServiceException(this.CUSTOMER_NUMBERS_REQUIRED);
        }

        return [SELECT Id,
                       TTI_SAP_Cust_No__c
                FROM User
                WHERE TTI_SAP_Cust_No__c IN :sapCustomerNumbers];
    }

    public class InventoryTriggerDataServiceException extends Exception {}
}