/**
* @author           Francis Nasalita
* @date             2021-03-09
* @description      Sales transaction file upload controller Test
*/
@isTest
public class SalesTxnFileUploadControllerTest {

    @IsTest
    static void testLinkFileToSalesTxn() {
        ContentVersion cv = new ContentVersion(
            Title = 'salesTxn',
            PathOnClient = 'salesTxn.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert cv;

        Sales_Transactions__c salesTxn = new Sales_Transactions__c();
        insert salesTxn;

        Test.startTest();
            SalesTxnFileUploadController.linkFileToSalesTxn(salesTxn.Id, cv.Id);
        Test.stopTest();
        
    }
}