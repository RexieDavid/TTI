/**
 * Created by Haider Raza on 7/02/2017.
 */

@isTest
public with sharing class M12HubCodeCoverage {
    static Account testAccount;
    static Contact testContact;
    static Product2 testProduct;
    static M12_Inventory__c m12Inventory;


    static void prepareData(){
        testAccount = TestData.createAccounts(1)[0];
        insert testAccount;
        testContact = TestData.create1Contact(testAccount.Id);
        insert testContact;
        testProduct = TestData.create1Product();
        insert testProduct;
        m12Inventory = TestData.createM12Inventory(testProduct.Id);
        insert m12Inventory;
    }

    static testmethod void testM12InventoryTriggers() {
        prepareData();

        M12_Inventory__c m12Inventory2 = TestData.createM12Inventory(testProduct.Id);
        Test.startTest();
        insert m12Inventory2;
        Test.stopTest();
    }

    static testMethod void testM12StocktakeAndShare(){
        prepareData();
        
        PageReference m12stocktakeNav = Page.NavigateM12Stocktake;
        m12stocktakeNav.getParameters().put('Id', testAccount.Id);
    
        Test.setCurrentPage(m12stocktakeNav);
        NavigateM12Stocktake clsNavigateM12Stocktake = new NavigateM12Stocktake();
	    clsNavigateM12Stocktake.accId = testAccount.Id;
        System.debug('xx:'+clsNavigateM12Stocktake.controlNavigation());

        PageReference m12stocktakepage = Page.M12Stocktake;
        m12stocktakepage.getParameters().put('Id', testAccount.Id);

        ApexPages.StandardController controller = new ApexPages.StandardController(testAccount);

        Test.setCurrentPage(m12stocktakepage);
        M12Stocktake clsM12Stocktake = new M12Stocktake(controller);

        List<M12Stocktake.cProducts> cprods = clsM12Stocktake.getProducts();
        System.assert(cprods.size() == 1);
        System.assert(cprods[0].TotalPrice == 500);

        cprods[0].Quantity = 1;
        clsM12Stocktake.updateM12Quantity();
        System.assert(cprods[0].TotalPrice == 400);
        System.assert(cprods[0].Variance == -4);

        PageReference sharePageReference = clsM12Stocktake.SubmitM12Stocktake();

        List<M12_Stocktake_Inventory__c> m12StocktakeInventory = [SELECT Id, Display__c, M12_Inventory__c, M12_Stocktake__c, Stocktake_Quantity__c, Variation__c, Total_Price__c FROM M12_Stocktake_Inventory__c];
        System.assert(m12StocktakeInventory[0].Stocktake_Quantity__c == 1);
        System.assert(m12StocktakeInventory[0].Variation__c == -4);
        System.assert(m12StocktakeInventory[0].Total_Price__c == 400);

        List<M12_Stocktake__c> m12Stocktakes = [SELECT Submitted__c, Submitted_Date__c FROM M12_Stocktake__c];
        System.assert(m12Stocktakes[0].Submitted__c == TRUE);

        clsM12Stocktake.first();
        clsM12Stocktake.last();
        clsM12Stocktake.next();
        clsM12Stocktake.previous();
        String pgDetail = clsM12Stocktake.pageDetail;


        Test.setCurrentPage(sharePageReference);
        ShareM12Stocktake shareStocks = new ShareM12Stocktake();

        List<M12_Stocktake_Inventory__c> m12StocktakeInventories = shareStocks.getstocktakes();

        List<ShareM12Stocktake.cContact> contacts = shareStocks.getContacts();

        for(ShareM12Stocktake.cContact c : contacts){
            c.selected = TRUE;
        }

        Test.startTest();
            shareStocks.M12SharePDF();
        Test.stopTest();

        PageReference modifyM12PageReference = Page.M12StocktakeModify;
        modifyM12PageReference.getParameters().put('Id', m12Stocktakes[0].Id);

        ApexPages.StandardController ctrl = new ApexPages.StandardController(m12Stocktakes[0]);
        Test.setCurrentPage(modifyM12PageReference);
        M12StocktakeModify clsModify = new M12StocktakeModify(ctrl);

        List<M12_Stocktake__c> m12Stocks = clsModify.m12Stocktakes;

        System.debug('shareM12Stock:'+ clsModify.shareM12Stock());
        clsModify.updateM12Quantity();
        System.assert('Page 1 of 1' == clsModify.pageDetail);
        clsModify.first();
        clsModify.last();
        clsModify.next();
        clsModify.last();
        System.debug(''+clsModify.hasNext);
        System.debug(''+clsModify.hasPrevious);
        System.debug(''+clsModify.pageNumber);

        clsModify.backToAccount();
    }
}