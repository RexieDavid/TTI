@isTest
private class RebateCalculationsExtensionTest {
    private static final String CONTRACT_ID = DataMock.Id.generate(Contract.SObjectType);
    private static final Pagereference CONTRACT_RECORD_PAGE = new Pagereference('/' + CONTRACT_ID);
    private static RebateCalculationsExtensionDataService service = 
        (RebateCalculationsExtensionDataService) Test.createStub(
            RebateCalculationsExtensionDataService.class, 
            new RebateCalculationsExtensionDataMock());

    private static RebateCalculationsDataService rebateCalculationService = 
        (RebateCalculationsDataService) Test.createStub(
            RebateCalculationsDataService.class, 
            new RebateCalculationsDataServiceMock());

    @isTest
    private static void initTest() {
        Contract contract = new Contract(Id = CONTRACT_ID);
        ApexPages.StandardController sc = new ApexPages.StandardController(contract);
        RebateCalculationsExtension extension;
        Test.startTest();
            extension = setMockServices(sc);
        Test.stopTest();
        System.assert(extension.rebates != null, 'Failed to show rebates');
    }

    @isTest
    private static void createRebateTest() {
        Pagereference pageRef;
        Contract contract = new Contract(Id = CONTRACT_ID);
        ApexPages.StandardController sc = new ApexPages.StandardController(contract);
        RebateCalculationsExtension extension = setMockServices(sc);
        extension.rebates = createRebates();
        Test.startTest();
            pageRef = extension.createRebate();
        Test.stopTest();
        System.assertEquals(CONTRACT_RECORD_PAGE.getUrl(), pageRef.getUrl(), 'Failed to upsert rebates');
    }

    @isTest
    private static void doCancelTest() {
        Pagereference pageRef;
        Contract contract = new Contract(Id = CONTRACT_ID);
        ApexPages.StandardController sc = new ApexPages.StandardController(contract);
        RebateCalculationsExtension extension = setMockServices(sc);
        Test.startTest();
            pageRef = extension.doCancel();
        Test.stopTest();
        System.assertEquals(sc.cancel().getUrl(), pageRef.getUrl(), 'Redirected to different page');
    }

    private static RebateCalculationsExtension setMockServices(ApexPages.StandardController sc) {
        RebateCalculations.service = rebateCalculationService;
        return new RebateCalculationsExtension(sc, service);
    }

    private static List<Rebate__c> createRebates() {
        List<Rebate__c> rebates = new List<Rebate__c>();
        for (Integer i = 0; i < 10; i++) {
            rebates.add(new Rebate__c(
                Name = 'MockRebate-' + i,
                Contract__c = CONTRACT_ID
            ));
        }
        return rebates;
    }

    
}