@IsTest
public class ParentContactRelatedData_Test {
    
    
    static testMethod void getParentContactRelatedData_Test() {
        
        // Create Parent Contact
        Parent_Contact__c pc = new Parent_Contact__c();
        pc.Name = 'Test';
        Insert pc;
         //create Person Account
        Account a = TestUtilityClass.createPersonAccount(1)[0];
        a.ParentContact__c = pc.Id;
        insert a;
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(pc);
        ParentContactRelatedData  testPC = new ParentContactRelatedData (sc);
    }
     static testMethod void getAssets_Test() {
         // Create Parent Contact
        Parent_Contact__c pc = new Parent_Contact__c();
        pc.Name = 'Test';
        Insert pc;
         //create Person Account
        Account a = TestUtilityClass.createPersonAccount(1)[0];
        a.ParentContact__c = pc.Id;
     	insert a;
         
         SerialNumberDisplayType__c snType = new SerialNumberDisplayType__c();
         snType.Name = 'test';
         snType.Serial_Number_Length__c = 10;
         snType.HelperImageURL__c = 'https://www.google.com.au/images/branding/googlelogo/2x/googlelogo_color_120x44dp.png';
         snType.IsDefault__c = true;
         snType.HelpText__c = 'Please enter the ten digit serial number located on your tool.';
         insert snType;
        //create Product
        Product2 prod = TestUtilityClass.createProduct(1)[0];
         prod.SerialNumberDisplayType__c = snType.Id;
        Insert prod;
        //get contact
        Contact c =  [Select Id FROM Contact Where AccountID =:a.Id];
        //create Asset
        List<Asset> assetList = TestUtilityClass.createAsset(3, a.id, c.Id, prod.Id);
        insert assetList;
        //Parent_Contact__c pc = [Select Id, Name FROM Parent_Contact__c Where Id=: a.ParentContact__c];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(pc);
        ParentContactRelatedData  testPC = new ParentContactRelatedData (sc);
         
        testPC.getAssets();
        testPC.getAssetSize();
        testPC.getParentContact();
     }
    static testMethod void getCases_Test() {
        Parent_Contact__c pc = new Parent_Contact__c();
        pc.Name = 'Test';
        Insert pc;
        //create Person Account
        Account a = TestUtilityClass.createPersonAccount(1)[0];
        a.ParentContact__c = pc.Id;
        insert a;
        //get contact
        Contact con=  [Select Id FROM Contact Where AccountID =:a.Id];
        
        Case c = new Case();
        c.AccountId = a.Id;
        c.ContactId = con.Id;
        c.Type = 'New Redemption';
        c.Nature__c = 'Valid';
        c.Status = 'New';
        insert c;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(pc);
        ParentContactRelatedData  testPC = new ParentContactRelatedData (sc);
        testPC.getCases();
    }

}