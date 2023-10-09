@isTest
public class ProductRecallControllerTest {

    private final static string ENQUIRY = 'Enquiry';
    private final static string RECEIPT = 'Receipt';

    static testMethod void validateProductRecallviaSerial_Test() {
        
        Id aegRT = Schema.SObjectType.Product_Recall__c.getRecordTypeInfosByName().get('AEG 58v Recall').getRecordTypeId();

        Test.startTest();
            ProductRecallController.insertProductRecall('05182I2022','Recall');
            List<Product_Recall__c> prodRecallList = [  SELECT Id, Name, QR_Code_Scan__c, Status__c, Serial_Number__c 
                                                        FROM Product_Recall__c];

            System.assertNotEquals(prodRecallList.size(), 0);
            String validateStr = ProductRecallController.validateProductRecall(ENQUIRY, prodRecallList[0].Serial_Number__c);
            System.assertNotEquals(validateStr, NULL);
            
            //NO Result Found Exception
            try{
                validateStr = ProductRecallController.validateProductRecall(ENQUIRY, prodRecallList[0].Serial_Number__c+'xxx');
                System.assertNotEquals(validateStr, NULL);
            }
            catch(Exception e){
                System.assertEquals(e.getMessage().contains('Script-thrown exception'), true); 
            }
            
        Test.stopTest();

    }

    static testMethod void validateProductRecallReceipt_Test() {
        
        Id aegRT = Schema.SObjectType.Product_Recall__c.getRecordTypeInfosByName().get('AEG 58v Recall').getRecordTypeId();

        Test.startTest();
            ProductRecallController.insertProductRecall('05182I2022','Recall');
            List<Product_Recall__c> prodRecallList = [  SELECT Id, Name, QR_Code_Scan__c, Status__c, Serial_Number__c 
                                                        FROM Product_Recall__c];
            prodRecallList[0].QR_Code_Scan__c = '130604001DG9|EU22123D0700511|A58BAT14';
            update prodRecallList;

            System.assertNotEquals(prodRecallList.size(), 0);
            String validateStr = ProductRecallController.validateProductRecall(RECEIPT, prodRecallList[0].QR_Code_Scan__c);
            System.assertNotEquals(validateStr, NULL);

            String updateProductRecallStr = ProductRecallController.updateProductRecall(prodRecallList[0]);
            System.assertNotEquals(updateProductRecallStr, NULL);
        Test.stopTest();

    }

    static testMethod void validateProductRecallviaBatchId_Test() {
        
        Id aegRT = Schema.SObjectType.Product_Recall__c.getRecordTypeInfosByName().get('AEG 58v Recall').getRecordTypeId();

        Test.startTest();
            String validateStr = ProductRecallController.validateProductRecall(RECEIPT, '05182I2022');
            System.assertNotEquals(validateStr, NULL);
            String productRecallString = ProductRecallController.insertProductRecall('05182I2022','Recall');
        Test.stopTest();

    }

}