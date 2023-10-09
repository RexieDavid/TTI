/**
* @author Francis Nasalita
* @date 2020-06-18
*
* @description Test class for OrderDetailsController
*/
@isTest
public class OrderDetailsControllerTest {

    @isTest
    static void testGetOrderDetails() {        
        Test.startTest();
        OrderDetailsController.OrderDetailsResponseData response = OrderDetailsController.getOrderDetails(true, 'test-order');
        Test.stopTest();
        System.assertEquals(1, response.lstOrderDetails.size(), 'Did not return any order.');
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