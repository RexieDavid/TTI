@isTest
public class TTI_PredictiveSearchControllerTest {

    private static final String ERR_GENERIC_MESSAGE = 'Something went wrong. Please contact your administrator.';

    /*******************************************
    * Description          Initialize test data
    * 
    */
    @TestSetup
    static void makeData() {
        List<Account> b2cAccountLst = TTI_CommonUtilityClass.createB2CAccounts('AEG', 'Australia', 'Business', 1);
        
        ContentVersion contentVersion = new ContentVersion(
            title = 'Elephants',
            PathOnClient = 'Elephants.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        ContentDocumentLink newCDocLink = new ContentDocumentLink(
            LinkedEntityId = b2cAccountLst[0].Id,
            ContentDocumentId = documents[0].Id,
            shareType = 'V'
        );
        insert newCDocLink;
    }
    
    /**********************************************************
    * Description          Perform Database.query on Account record
    */
    @isTest
    static void testQueryListOfObjects() {
    
        Account acc = [SELECT Id, Name FROM Account LIMIT 1];
        String whereQuery = 'Record_Status__c = \'Active\'';
        String objName = 'Account';
        String parentFieldsToQuery = '(SELECT Id, LinkedEntityId FROM ContentDocumentLinks)';
        
        Test.startTest();
        
        List<sObject> listOfObjects =  
            TTI_PredictiveSearchController.getListOfObjects(acc.Name,
                                                            whereQuery,
                                                            objName,
                                                            false, 
                                                            parentFieldsToQuery);
        List<sObject> listOfObjects_IgnoreDefaultName =  
            TTI_PredictiveSearchController.getListOfObjects(acc.Name, 
                                                            whereQuery,
                                                            objName,
                                                            true, 
                                                            parentFieldsToQuery);
                                                            
        List<sObject> listOfObjects_NoWhereClause =  
            TTI_PredictiveSearchController.getListOfObjects(acc.Name, 
                                                            '',
                                                            objName,
                                                            false, 
                                                            parentFieldsToQuery);
                                                            
        List<sObject> getRecord = TTI_PredictiveSearchController.getRecord(whereQuery,
                                                                            objName,
                                                                            parentFieldsToQuery);
        
        TTI_PredictiveSearchController predictiveSearchCtrl = new TTI_PredictiveSearchController();                                                                    
        String checkObjectType = predictiveSearchCtrl.setObjectType(listOfObjects[0]);
        
        Test.stopTest();
        System.assert(!listOfObjects.isEmpty(), ERR_GENERIC_MESSAGE);
        System.assert(!listOfObjects_IgnoreDefaultName.isEmpty(), ERR_GENERIC_MESSAGE);
        System.assert(!listOfObjects_NoWhereClause.isEmpty(), ERR_GENERIC_MESSAGE);
        System.assert(!getRecord.isEmpty(), ERR_GENERIC_MESSAGE);
        System.assert(checkObjectType == 'Account', ERR_GENERIC_MESSAGE);
    }
}