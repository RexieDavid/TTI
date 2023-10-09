/* @description:    Controller for Tool Box Page
 * @author:         Arnie Ug (Accenture)
 * @createdDate:    29 March 2017 
 */
public without sharing class ToolBoxListCC {
    
    @AuraEnabled
    public static List<Asset> getAssets (Id contactId) {
        
        DateTime t0 = DateTime.now();
        
        String[] statuses = CommunitySettingsHelperClass.getToolboxStatuses(); //Community_Settings__c.getValues('CommonSettings').ToolboxDisplayStatus__c.Split(',');

        List<Asset> assetList = [  SELECT  Id, Name,AssetSource__c ,Asset_Source_Other__c, PurchaseDate, 
                                    CreatedDate, Registered_Date_Formula__c, SerialNumber, Status, Quantity, Total_Warranty_Years__c, 
                                    Standard_Warranty_Months__c,Extended_Warranty_Months__c,Receipt__c,
                                    Receipt__r.Receipt_Name__c,  Product2Id, Product2.ProductCode, Receipt__r.ReceiptSource__c , Product2.Customer_Facing_Name__c,
                                    Product2.Image_URL__c, KitProduct__r.Customer_Facing_Name__c, 
                                    SerialNumberWeek__c, SerialNumberYear__c, Display_Week__c, Display_Year__c,Allow_Numbers_Only__c,
                                    Regexpression_Validator__c, Serial_Number_Length__c, HelpText__c, Helper_Image_URL__c, FullSerialNumber__c, EnforceLength__c,
                                    Is_Serial_Number_Optional__c
                                    FROM Asset
                                    WHERE ContactId = :contactId                                    
                                    AND Status IN :statuses
                                    ORDER BY CreatedDate DESC];
        
        DateTime t1 = DateTime.now();
        
        System.debug('ToolBoxListCC.getAssets() time taken = ' + (t1.getTime()-t0.getTime()) + ' ms');
        return assetList;
    } 
    
    @AuraEnabled
    public static Integer getAssetCount () {
        
        String[] statuses = CommunitySettingsHelperClass.getToolboxStatuses(); //Community_Settings__c.getValues('CommonSettings').ToolboxDisplayStatus__c.Split(',');
        String contactID = getRunningContactId();
            
        return  [  SELECT  Count()
                                    FROM Asset
                                    WHERE ContactId = :contactId
                                    AND Status IN :statuses
                                    ];
        
    }
    
    @AuraEnabled
    public static Id getRunningContactId() {
        
        Id contactId = [SELECT Id, ContactId FROM User WHERE id = :UserInfo.getUserId()][0].ContactId;
        
        System.debug('Running User: ' + contactId);
        return contactId;
    }
    
    @AuraEnabled
    public static String getRunningContactName() {
        
        String fName = [SELECT Id, ContactId, FirstName FROM User WHERE id = :UserInfo.getUserId()][0].FirstName;
        
        System.debug('Running fName: ' + fName);
        return fName;
    }
    
    @AuraEnabled
    public static List<String> getRemoveReason() {
        /* can be removed
           List<String> options = new List<String>();
    
           Schema.DescribeFieldResult fieldResult = Asset.Inactive_Reason__c.getDescribe();
    
           List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    
           for (Schema.PicklistEntry f: ple) {
                options.add(f.getLabel());
            }       
           return options;
         */
        return CommunitySettingsHelperClass.getRemoveAssetReasons();
    } 
    
    
    @AuraEnabled
    public static String removeUpdate(Asset assets, String reason, String comment) {
        try{
            Asset oldAsset = [SELECT Id, Status, Inactive_Reason__c,Inactive_Comments__c FROM Asset WHERE Id =: assets.Id];
            oldAsset.Status = CommunitySettingsHelperClass.getAssetRemoveStatus() ;
            oldAsset.Inactive_Reason__c = CommunitySettingsHelperClass.mapRemoveAssetReasons(reason) ;
            oldAsset.Inactive_Comments__c = comment;
            
            update oldAsset;
        }catch(Exception e){
            return e.getMessage();
        }
       
        return '';
    } 
    
    @AuraEnabled
    public static Community_Settings__c  getCommunitySettings(){
        return CommunitySettingsHelperClass.getSiteSettings(site.getMasterLabel());
    }
    
    @AuraEnabled
    public static String getFileId(Id receiptId){
        
        System.debug('--------receiptId: ' + receiptId);
        
        Attachment attach = [SELECT Id,Name,OwnerId,ParentId FROM Attachment WHERE ParentId =: receiptId Order by CreatedDate desc Limit 1];
        string baseURl = site.getBaseUrl();
        String fileLink = baseURl +'/servlet/servlet.FileDownload?file='+ attach.Id;
        
        return fileLink;
        
    }
   
}