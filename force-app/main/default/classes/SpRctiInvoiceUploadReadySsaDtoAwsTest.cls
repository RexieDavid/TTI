/**********************************************************************
 * @author                  Francis Nasalita
 * @date                    2020-09-24
 *
 * @description             Test class for SpRctiInvoiceUploadReadySsaDtoAws
 */
@IsTest
public class SpRctiInvoiceUploadReadySsaDtoAwsTest {
    
    // This test method should give 100% coverage
    static testMethod void testParse() {
        String json = '{\"aws\": {'+
        '  \"accountId\": \"\",'+
        '  \"invoiceNumber\": \"\",'+
        '  \"caseNumber\": \"\"'+
        '}}';
        SpRctiInvoiceUploadReadySsaDtoAws r = SpRctiInvoiceUploadReadySsaDtoAws.parse(json);
        System.assert(r != null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SpRctiInvoiceUploadReadySsaDtoAws.Aws objAws = new SpRctiInvoiceUploadReadySsaDtoAws.Aws(System.JSON.createParser(json));
        System.assert(objAws != null);
        System.assert(objAws.accountId == null);
        System.assert(objAws.invoiceNumber == null);
        System.assert(objAws.caseNumber == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SpRctiInvoiceUploadReadySsaDtoAws objSpRctiInvoiceUploadReadySsaDtoAw = new SpRctiInvoiceUploadReadySsaDtoAws(System.JSON.createParser(json));
        System.assert(objSpRctiInvoiceUploadReadySsaDtoAw != null);
        System.assert(objSpRctiInvoiceUploadReadySsaDtoAw.aws == null);
    }
}