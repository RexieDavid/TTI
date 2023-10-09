@isTest(seeAllData=true)
public class ToolBoxListCC_Test {
    
    static testMethod void getAssets_Test() {
        
        
        Parent_Contact__c pc = new Parent_Contact__c();
        pc.Name = 'Test';
        Insert pc;
        //create Person Account
        Account a = TestUtilityClass.createPersonAccount(1)[0];
        a.ParentContact__c = pc.Id;
        insert a;
        //get contact
        Contact c=  [Select Id, country__c FROM Contact Where AccountID =:a.Id];
        
        SerialNumberDisplayType__c snType = new SerialNumberDisplayType__c();
         snType.Name = 'test';
         snType.Serial_Number_Length__c = 10;
         snType.HelperImageURL__c = 'https://www.google.com.au/images/branding/googlelogo/2x/googlelogo_color_120x44dp.png';
         snType.IsDefault__c = true;
         snType.HelpText__c = 'Please enter the ten digit serial number located on your tool.';
         insert snType;
        //create Product
        List<Product2> prods = TestUtilityClass.createProduct(2);
        prods[0].SerialNumberDisplayType__c = snType.Id;
        prods[0].brand__c = 'RY';
        prods[0].category_customer_level1__c =  'Power Tools';
        prods[1].SerialNumberDisplayType__c = snType.Id;
        prods[1].Brand__c = 'RY';
        Insert prods;
        
        //create receipt
        Receipts__c r = new Receipts__c(ReceiptSource__c = 'Bunnings',
                                        Account__c = a.Id
        								);
        insert r;
        
        Attachment attach=new Attachment();   	
    	attach.Name='TestFile';
    	Blob bodyBlob=Blob.valueOf('base64Data');
    	attach.body=bodyBlob;
        attach.parentId=r.id;
        insert attach;
        
        List<Asset> assetList = TestUtilityClass.createAsset(1, a.Id, c.Id, prods[0].Id);
        assetList[0].Standard_Warranty_Months__c = 48;
        assetList[0].Extended_Warranty_Months__c = 24;
        assetList[0].AssetSource__c = 'Retailer - Bunnings';
        assetList[0].Status = 'Confirmed';
        assetList[0].Receipt__c = r.Id;
        Insert assetList;
        
        Profile profile1 = [Select Id from Profile where UserType  = 'CspLitePortal' Limit 1];
        User portalUser = new User(
            //UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = 'test3@yahoo.com.Ryobi',
            Alias = 'batman',
            Email='test@yahoo.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago',
            ContactId = c.Id
            );
        Database.insert(portalUser);
        system.runAs(portalUser){
            ToolBoxListCC.getRunningContactName();
        }
        

        ToolBoxListCC.getAssets(c.Id);
        ToolBoxListCC.getAssetCount();
        ToolBoxListCC.getRemoveReason();
        ToolBoxListCC.getCommunitySettings();
        ToolBoxListCC.getFileId(r.Id);
     	ToolBoxListCC.removeUpdate(assetList[0], 'I sold the tool', 'Test');
    }

}