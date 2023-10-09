/**
* @author Rexie David
* @date 2023-01-16
*
* @description Product Recall Controller
*/

public with sharing class ProductRecallController {

    /**
    * @author: Rexie David
    * @date: 2023-01-16
    * @description: This method retrieves Product Recall record
    * @return: String
    */
    @AuraEnabled
    public static String validateProductRecall(String validationType, String key){
        System.debug('validationType >>> '+validationType);
        System.debug('key >>> '+key);
        String resultStr = ''; 
        // key = key+'x';
        try {
            resultStr = validationType == 'Enquiry' ? processEnquiry(key) : validationType == 'Receipt' ? processReceipt(key) : null;
            if(resultStr == 'No Result Found.') throw new ProductRecallControllerException(resultStr);
        } catch (Exception e) {
            String errorMsg = e.getMessage();
            throw new AuraHandledException(ErrorMsg);
        }
        return resultStr;
    }

    /**
    * @author: Rexie David
    * @date: 2023-01-16
    * @description: This method handles logic for Enquiry feature
    * @return: String
    */
    public static String processEnquiry(String key){
        
        String result = '';
        List<Product_Recall__c> productRecall = retrieveProductRecall(key);
        if(productRecall.size() > 0){
            // Enquiry Match - Return Result
            result = JSON.serializePretty(productRecall);
        } 
        // else result = 'No Result Found.';
        else {
            key = (key.length() == 10) ? key.right(5) : key.length() > 10 && key.length() < 15 ? key.right(6) : key;
            List<Batch_ID_Validation__mdt> batchIdValidation = retrieveBatchIdValidation(key, 'AEG 58v');
            if(batchIdValidation.size() > 0){
                // Enquiry Match - Return Result
                result =  JSON.serializePretty(batchIdValidation);
            } 
            else result = 'No Result Found.';
        }
        return result;
    }

    /**
    * @author: Rexie David
    * @date: 2023-01-16
    * @description: This method handles logic for Receipt feature
    * @return: String
    */
    public static String processReceipt(String key){

        String result = '';
        // if(key.length() > 10){
        List<Product_Recall__c> productRecall = retrieveProductRecall(key);
        if(productRecall.size() > 0){
            // Enquiry Match - Return Result and Update Product Recall
            result = JSON.serializePretty(productRecall);//JSON.serializePretty(updateProductRecall(productRecall[0]));
        } 
        else{
            key = (key.length() == 10) ? key.right(5) : key.length() == 11 ? key.right(6) : key;
            System.debug('processReceipt >>> '+key);
            List<Batch_ID_Validation__mdt> batchIdValidation = retrieveBatchIdValidation(key, 'AEG 58v');
            if(batchIdValidation.size() > 0){
                // Enquiry Match - Return Result and Insert Product Recall
                result =  JSON.serializePretty(batchIdValidation);//JSON.serializePretty(insertProductRecall(key, batchIdValidation[0].Status__c));
            } 
            else result = 'No Result Found.';
        }
        return result;
    }

    /**
    * @author: Rexie David
    * @date: 2023-01-16
    * @description: This method retrieves List of Product Recall record that matches the key
    * @return: List<Product_Recall__c>
    */
    public static List<Product_Recall__c> retrieveProductRecall(String key){

        return [    SELECT Id, Name, QR_Code_Scan__c, Status__c, Serial_Number__c
                    FROM Product_Recall__c 
                    WHERE RecordType.Name = 'AEG 58v Recall' AND (QR_Code_Scan__c =: key OR Serial_Number__c =: key)];

    }
    
    /**
    * @author: Rexie David
    * @date: 2023-01-16
    * @description: This method retrieves Batch_ID_Validation__mdt record
    * @return: List<Batch_ID_Validation__mdt>
    */
    public static List<Batch_ID_Validation__mdt> retrieveBatchIdValidation(String batchId, String product){

        return [    SELECT Id, DeveloperName, Batch_Id__c, Product__c, Status__c
                    FROM Batch_ID_Validation__mdt 
                    WHERE Product__c =: product AND Batch_Id__c =: batchId];

    }

    /**
    * @author: Rexie David
    * @date: 2023-01-16
    * @description: This method performs and INSERT DML to the Product_Recall__c object
    * @return: String
    */
    @AuraEnabled
    public static string insertProductRecall(String serialNumber, String status){
        try {
            Id aegRT = Schema.SObjectType.Product_Recall__c.getRecordTypeInfosByName().get('AEG 58v Recall').getRecordTypeId();
            Product_Recall__c prodRecall = new Product_Recall__c();
            prodRecall.Receipt_Date_Time_Stamp__c = System.now();
            prodRecall.User_Name__c = UserInfo.getUserId();
            prodRecall.Status__c = status;
            prodRecall.Serial_Number__c = serialNumber.toUpperCase();
            prodRecall.RecordTypeId = aegRT;
            Database.insert(prodRecall);
        return JSON.serializePretty(prodRecall);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**
    * @author: Rexie David
    * @date: 2023-01-16
    * @description: This method performs and INSERT DML to the Product_Recall__c object
    * @return: String
    */
    @AuraEnabled
    public static String updateProductRecall (Product_Recall__c prodRecallToUpdate){
        try {
            Product_Recall__c prodRecall = new Product_Recall__c();
            prodRecall.Id = prodRecallToUpdate.Id;
            prodRecall.Serial_Number__c = prodRecallToUpdate.Serial_Number__c;
            prodRecall.Receipt_Date_Time_Stamp__c = System.now();
            prodRecall.User_Name__c = UserInfo.getUserId();
            Database.update(prodRecall);
            return JSON.serializePretty(prodRecall);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class ProductRecallControllerException extends Exception {}

}