@isTest
public class SAPQASOrderDetailsControllerTest {
    
    @TestSetup
    static void makeData() {
        Order__c order = new Order__c(
            Name = 'test1234'
        );
        insert order;
    }

    @IsTest
    static void testStandardController() {
        Order__c order = [SELECT Id, Name FROM Order__c WHERE Name = 'test1234'][0];
        ApexPages.StandardController sc = new ApexPages.StandardController(order);

        Test.startTest();
            SAPQASOrderDetailsController controller = new SAPQASOrderDetailsController(sc);
            PageReference pageRef = Page.SAPQASOrderDetails;
            Test.setCurrentPage(pageRef);
            System.assertEquals(false, controller.orderdet.isEmpty(), 'Order list should not be empty.');
        Test.stopTest();        
    }

    @isTest
    static void testShowListHappyPath() {
        Test.startTest();
            SAPQASOrderDetailsController controller = new SAPQASOrderDetailsController();
            controller.inputSalesOrd = '1';
            controller.showList();
            
            System.assertEquals(true, controller.orderdet.isEmpty(), 'Order list should be empty.');
        Test.stopTest();
    }

    @isTest
    static void testShowListNoInput() {
        Test.startTest();
            SAPQASOrderDetailsController controller = new SAPQASOrderDetailsController();
            controller.inputSalesOrd = '1234567891011';
            controller.showList();

            System.assertEquals(true, controller.hasMessages, 'Should have error message.');
            System.assertEquals('You have entered invalid Sales Order Number', controller.errorMessage, 'Invalid error message.');
            System.assertEquals('warning', controller.alertType, 'Invalid alert type.');
        Test.stopTest();
    }

    @isTest
    static void testShowListExceedingCharInput() {
        Test.startTest();
            SAPQASOrderDetailsController controller = new SAPQASOrderDetailsController();
            controller.inputSalesOrd = '';
            controller.showList();

            System.assertEquals(true, controller.hasMessages, 'Should have error message.');
            System.assertEquals('Please enter Sales Order Number', controller.errorMessage, 'Invalid error message.');
            System.assertEquals('warning', controller.alertType, 'Invalid alert type.');
        Test.stopTest();
    }

    @isTest
    static void testShowListNotExist() {
        Test.startTest();
            SAPQASOrderDetailsController controller = new SAPQASOrderDetailsController();
            controller.inputSalesOrd = 'xxxxxxx';
            controller.showList();

            System.assertEquals(true, controller.hasMessages, 'Should have error message.');
            System.assertEquals('Sales Order Number not exist', controller.errorMessage, 'Invalid error message.');
            System.assertEquals('offline', controller.alertType, 'Invalid alert type.');
        Test.stopTest();
    }

    public static SF_Order_DetailsSet__x createOrderDetailSetRecord() {
        return new SF_Order_DetailsSet__x(
            IVbeln__c = 'test1234',
            Posnr__c = '000010',
            Matnr__c = 'C18PCG600A-201B',
            Carrier__c = 'PBT',
            Bstnk__c = '1438448',
            Maktx__c = 'M18 Milw 600ml Caulking Gun - kit',
            Bmeng__c = 2.000,
            DateText__c = '26/10/2018',
            ConNote__c = 'TEI0046959',
            OrderStatus__c = 'Invoiced',
            WadatIst__c = Date.today(),
            Kwmeng__c = 2.000
        );
    }
}