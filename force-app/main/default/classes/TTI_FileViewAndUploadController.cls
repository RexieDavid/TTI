/*
*  Name :- Upendra Kumar
*  Created Date:- 13/09/2018
*  Purpose:- Methods of this class will return list of files after upload or delete in claim page in portal
*  Modified By :-
*  Purpose :-
*  Modidired Date :-
*/ 

public class TTI_FileViewAndUploadController {

    /**********************************************************************
    * @description             Retrieves content version data
    *
    * @param   recordI         Content Version Id
    * @return                  String(Blob)
    * 
    * @example
    * getFileData('068*******')
    */
    @AuraEnabled
    public static String getFileData(Id recordId) {
        ContentVersion cv = [SELECT VersionData
                               FROM ContentVersion
                              WHERE Id = :recordId
                              LIMIT 1];
        
        return EncodingUtil.base64Encode((Blob) cv.VersionData);
    }

    /*
    *  Name :- Upendra Kumar
    *  Created Date:- 13/09/2018
    *  Purpose:- This method is used to get uploaded reciepts
    *  Modified By :-
    *  Purpose :-
    *  Modidired Date :-
    */
    @auraEnabled
    public static list<ContentDocumentLink> handleOnuploadfinished(Id recordId) {
        try {
            list<ContentDocumentLink> listOfAllFiles = new list<ContentDocumentLink>();
            for (ContentDocumentLink ObjLink : [SELECT ContentDocumentId, 
                                                       ContentDocument.Title, 
                                                       ContentDocument.FileExtension, 
                                                       ContentDocument.FileType, 
                                                       ContentDocument.LatestPublishedVersionId
                                                  FROM ContentDocumentLink 
                                                 WHERE LinkedEntityId = :recordId]) {

                if (!ObjLink.ContentDocument.Title.contains('Label')) {
                    listOfAllFiles.add(ObjLink); 
                }
            }
            return listOfAllFiles;
        } catch (Exception objException) {
            TTI_LogError.createExceptionLog(objException, recordId);
            String errorMessage = 'An error was encountered, Please contact your administrator';
            AuraHandledException execp = new AuraHandledException(errorMessage);
            execp.setMessage(errorMessage);
            throw execp;
        }
    }
        
    /*
    *  Name :- Upendra Kumar
    *  Created Date:- 13/09/2018
    *  Purpose:- This method is used remove/delete selected reciepts
    *  Modified By :-
    *  Purpose :-
    *  Modidired Date :-
    */
    @auraEnabled
    public static list<ContentDocumentLink> handleRemoveDocument(Id recordId, Id documentId) {
        try {
            ContentDocument objDocumentToDelete = new ContentDocument(Id=documentId);
            delete objDocumentToDelete;
            list<ContentDocumentLink> listOfAllFiles = new list<ContentDocumentLink>();
            for (ContentDocumentLink ObjLink : [SELECT ContentDocumentId, 
                                                       ContentDocument.Title, 
                                                       ContentDocument.FileExtension, 
                                                       ContentDocument.FileType
                                                  FROM ContentDocumentLink 
                                                 WHERE LinkedEntityId = :recordId]) {

                if (!ObjLink.ContentDocument.Title.contains('Label')) {
                    listOfAllFiles.add(ObjLink);
                }
            }
            return listOfAllFiles;
        } catch (Exception objException) {
            string inputParam = '"recordId":"' + recordId + '", "documentId":"' + documentId + '"';
            TTI_LogError.createExceptionLog(objException, inputParam);
            String errorMessage = 'An error was encountered, Please contact your administrator';
            AuraHandledException execp = new AuraHandledException(errorMessage);
            execp.setMessage(errorMessage);
            throw execp;
        }
    }
}