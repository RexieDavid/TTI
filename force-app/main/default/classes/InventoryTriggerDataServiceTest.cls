/**
 * @author:                          Kristopher Veraces
 * @date:                            2020-08-11
*/
@isTest
private class InventoryTriggerDataServiceTest {

    /**********************************************************************
     * @description                     Fetch SAP users with given
     *                                  account numbers
     */
    @isTest
    public static void fetchSAPUsers() {
        List<User> users;
        Set<String> sapAccountNumbers = new Set<String>{'000001', '000002'};
        InventoryTriggerDataService service = new InventoryTriggerDataService();
        Test.startTest();
            users = service.fetchSAPUsers(sapAccountNumbers);
        Test.stopTest();
        System.assert(users != null, 'Failed to fetch SAP user records');
    }

    /**********************************************************************
     * @description                     Fetch SAP users without providing
     *                                  SAP account numbers
     * 
     *                                  Will throw an exception
     */
    @isTest
    public static void fetchSAPUsersWithoutAccountNumbers() {
        String errorMessage;
        InventoryTriggerDataService service = new InventoryTriggerDataService();
        Test.startTest();
            try {
                service.fetchSAPUsers(null);
            } catch (Exception ex) {
                errorMessage = ex.getMessage();
            }
        Test.stopTest();
        System.assertEquals('Missing SAP Customer Numbers', errorMessage, 'Successfully fetch SAP user records');
    }
}