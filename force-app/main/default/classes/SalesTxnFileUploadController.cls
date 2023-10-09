public class SalesTxnFileUploadController {

    @AuraEnabled
    public static void linkFileToSalesTxn(String salesTxnId, String contentVersionId) {
        
        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionId].ContentDocumentId;

        ContentDocumentLink cdl = new ContentDOcumentLink(
            ContentDocumentId = contentDocumentId,
            LinkedEntityId = salesTxnId,
            Visibility = 'AllUsers'
        );

        insert cdl;
    }
}