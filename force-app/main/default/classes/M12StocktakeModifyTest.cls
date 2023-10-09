/**
 * @author                          Kristopher Veraces
 * @date                            March 13, 2022
 */
@isTest
private class M12StocktakeModifyTest {
    @TestSetup
    private static void makeData() {
        Account account =  TestData.createAccounts(1)[0];
        insert account;
        Contact contact = TestData.create1Contact(account.Id);
        insert contact;
        Product2 product = TestData.create1Product();
        insert product;
        M12_Stocktake__c stockTake = createStocktake(account.Id);
        insert stockTake;
        M12_Inventory__c inventory = TestData.createM12Inventory(product.Id);
        insert inventory;
        M12_Stocktake_Inventory__c stockTakeInventory = createStocktakeInventory(stockTake.Id, inventory.Id);
        insert stockTakeInventory;
    }

    @isTest
    private static void getStockTakesTest() {
        M12_Stocktake__c stockTake = [SELECT Id, Account__c FROM M12_Stocktake__c LIMIT 1];
        M12StocktakeModify stockModify;
        Test.startTest();
            navigateToStockTakeModifyPage(stockTake, false);
            stockModify = createInstanceClass(stockTake);
        Test.stopTest();
        List<M12_Stocktake__c> m12StockTakes = stockModify.m12StockTakes;
        System.assertEquals(stockTake.Id, m12StockTakes[0].Id, 'Fail to get stocktake Id');
    }

    @isTest
    private static void navigateToAccountPageWithoutRetURLTest() {
        Pagereference currPage;
        M12_Stocktake__c stockTake = [SELECT Id, Account__c FROM M12_Stocktake__c LIMIT 1];
        M12StocktakeModify stockModify;
        String baseURL = URL.getSalesforceBaseUrl().toExternalForm();
        PageReference accountPage = new PageReference(baseURL + '/' + stockTake.Account__c);
        Test.startTest();
            navigateToStockTakeModifyPage(stockTake, false);
            stockModify = createInstanceClass(stockTake);
            currPage = stockModify.backToAccount();
        Test.stopTest();
        System.assertEquals(accountPage.getUrl(), currPage.getUrl(), 'Failed to navigate back to account record page');
    }

    @isTest
    private static void navigateToAccountPageWithRetURLTest() {
        Pagereference currPage;
        M12_Stocktake__c stockTake = [SELECT Id, Account__c FROM M12_Stocktake__c LIMIT 1];
        M12StocktakeModify stockModify;
        String baseURL = URL.getSalesforceBaseUrl().toExternalForm();
        PageReference accountPage = new PageReference(baseURL + '/' + stockTake.Account__c);
        Test.startTest();
            navigateToStockTakeModifyPage(stockTake, true);
            stockModify = createInstanceClass(stockTake);
            currPage = stockModify.backToAccount();
        Test.stopTest();
        System.assertEquals(accountPage.getUrl(), currPage.getUrl(), 'Failed to navigate back to account record page');
    }

    @isTest
    private static void navigateToShareM12StockPageTest() {
        Pagereference currPage;
        M12_Stocktake__c stockTake = [SELECT Id, Account__c FROM M12_Stocktake__c LIMIT 1];
        M12StocktakeModify stockModify;
        Test.startTest();
            navigateToStockTakeModifyPage(stockTake, true);
            stockModify = createInstanceClass(stockTake);
            currPage = stockModify.shareM12Stock();
        Test.stopTest();
        Map<String, String> pageParams = currPage.getParameters();
        System.assertEquals(stockTake.Id, pageParams.get('Id'), 'Failed to navigate to ShareM12Stocktake page');
        System.assertEquals(stockTake.Account__c, pageParams.get('accId'), 'Failed to navigate to ShareM12Stocktake page');
    }

    @isTest
    private static void updateM12QuantityWithQuantityTest() {
        M12StocktakeModify stockModify;
        M12_Stocktake__c stockTake = [SELECT Id, Account__c FROM M12_Stocktake__c LIMIT 1];
        M12_Stocktake_Inventory__c inventory = [SELECT Id, Stocktake_Quantity__c FROM M12_Stocktake_Inventory__c WHERE M12_Stocktake__c = :stockTake.Id];
        inventory.Stocktake_Quantity__c = 6;
        update inventory;
        Test.startTest();
            navigateToStockTakeModifyPage(stockTake, true);
            stockModify = createInstanceClass(stockTake);
            stockModify.siIdToUpdate = inventory.Id;
            stockModify.updateM12Quantity();
        Test.stopTest();
        M12_Stocktake_Inventory__c updatedInventory = [SELECT Id, Total_Price__c FROM M12_Stocktake_Inventory__c WHERE M12_Stocktake__c = :stockTake.Id];
        System.assertEquals(0, updatedInventory.Total_Price__c, 'Failed to update M12 Stocktake Inventory');
    }

    @isTest
    private static void updateM12QuantityWithoutQuantityTest() {
        M12StocktakeModify stockModify;
        M12_Stocktake__c stockTake = [SELECT Id, Account__c FROM M12_Stocktake__c LIMIT 1];
        M12_Stocktake_Inventory__c inventory = [SELECT Id, Stocktake_Quantity__c FROM M12_Stocktake_Inventory__c WHERE M12_Stocktake__c = :stockTake.Id];
        inventory.Stocktake_Quantity__c = null;
        update inventory;
        Test.startTest();
            navigateToStockTakeModifyPage(stockTake, true);
            stockModify = createInstanceClass(stockTake);
            stockModify.siIdToUpdate = inventory.Id;
            stockModify.updateM12Quantity();
        Test.stopTest();
        M12_Stocktake_Inventory__c updatedInventory = [SELECT Id, Total_Price__c FROM M12_Stocktake_Inventory__c WHERE M12_Stocktake__c = :stockTake.Id];
        System.assertEquals(500, updatedInventory.Total_Price__c, 'Failed to update M12 Stocktake Inventory');
    }

    @isTest
    private static void getApexPageStandardControllerTest() {
        ApexPages.StandardSetController con;
        M12_Stocktake__c stockTake = [SELECT Id, Account__c FROM M12_Stocktake__c LIMIT 1];
        M12StocktakeModify stockModify;
        Test.startTest();
            navigateToStockTakeModifyPage(stockTake, false);
            stockModify = createInstanceClass(stockTake);
            con = stockModify.con;
        Test.stopTest();
        System.assert(con != null, 'Failed to fetch apex page standard controller');
    }

    @isTest
    private static void paginationTest() {
        Boolean hasNext;
        Boolean hasPrevious;
        Integer pageNumber;
        M12_Stocktake__c stockTake = [SELECT Id, Account__c FROM M12_Stocktake__c LIMIT 1];
        M12StocktakeModify stockModify;
        Test.startTest();
            navigateToStockTakeModifyPage(stockTake, false);
            stockModify = createInstanceClass(stockTake);
            hasNext = stockModify.hasNext;
            hasPrevious = stockModify.hasPrevious;
            stockModify.first();
            stockModify.next();
            stockModify.previous();
            stockModify.last();
        Test.stopTest();
        System.assert(!hasNext, 'Failed to fetch records');
        System.assert(!hasPrevious, 'Failed to fetch records');
    }

    @isTest
    private static void getPageDetailsTest() {
        Integer pageNumber;
        String pageDetails;
        M12_Stocktake__c stockTake = [SELECT Id, Account__c FROM M12_Stocktake__c LIMIT 1];
        M12StocktakeModify stockModify;
        Test.startTest();
            navigateToStockTakeModifyPage(stockTake, false);
            stockModify = createInstanceClass(stockTake);
            pageNumber = stockModify.pageNumber;
            pageDetails = stockModify.pageDetail;
        Test.stopTest();
        System.assertEquals(1, pageNumber, 'Did not set page number to 1');
        System.assertEquals('Page 1 of 1', pageDetails, 'Failed setting up page details');
    }

    @isTest
    private static void cancelTest() {
        M12_Stocktake__c stockTake = [SELECT Id, Account__c FROM M12_Stocktake__c LIMIT 1];
        M12StocktakeModify stockModify;
        Test.startTest();
            navigateToStockTakeModifyPage(stockTake, false);
            stockModify = createInstanceClass(stockTake);
            stockModify.cancel();
        Test.stopTest();
        // Nothing to assert
    }

    /**
     * @description                 Navigate to Page.M12StocktakeModify page
     *                              with the Id and RetURL as page parameters
     * 
     * @param stockTake             M12 Stocktake Record
     * @param hasAccountId          Determine if the page have retURL
     */
    private static void navigateToStockTakeModifyPage(M12_Stocktake__c stockTake, Boolean hasAccountId) {
        Pagereference currPage = Page.M12StocktakeModify;
        currPage.getParameters().put('Id', stockTake.Id);
        if (hasAccountId) {
            currPage.getParameters().put('retURL', stockTake.Account__c);
        }
        Test.setCurrentPage(currPage);
    }

    /**
     * @description                 Create M12StocktakeModify class 
     *                              with its corresponding apexpages.standardcontroller
     * 
     * @param stockTake             M12 Stocktake Record
     */
    private static M12StocktakeModify createInstanceClass(M12_Stocktake__c stockTake) {
        ApexPages.StandardController sc = new ApexPages.StandardController(stockTake);
        M12StocktakeModify m12StockStakeModify = new M12StocktakeModify(sc);
        return m12StockStakeModify;
    }

    /**
     * @description                 Create stocktake record
     * 
     * @param accountId             Account to link to new stocktake record
     */
    private static M12_Stocktake__c createStocktake(String accountId) {
        DateTime currDateTime = System.now();
        return new M12_Stocktake__c(
            Account__c = accountId,
            Emailed__c = true,
            Emailed_Date__c = currDateTime.addMonths(-1),
            Submitted__c = true,
            Submitted_Date__c = currDateTime
        );
    }

    /**
     * @description                 Create stocktake inventory
     * 
     * @param stocktakeId           Stocktake to link to new stocktake inventory record
     * @param inventoryId           Stocktake Inventory to link to new stocktake inventory record
     */
    private static M12_Stocktake_Inventory__c createStocktakeInventory(String stocktakeId, String inventoryId) {
        return new M12_Stocktake_Inventory__c(
            Display__c = true,
            Is_Mandatory_Display__c = true,
            M12_Inventory__c = inventoryId,
            M12_Stocktake__c = stocktakeId,
            Stocktake_Quantity__c = 0,
            Variation__c = 10
        );
    }
}