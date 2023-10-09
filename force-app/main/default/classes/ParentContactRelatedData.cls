public class ParentContactRelatedData {
    private List<Asset> assets;
    private List<Case> cases;
    private Parent_Contact__c parentcntact; 
    List<Account> allaccounts = new List<Account>();
    
   
    public ParentContactRelatedData(ApexPages.StandardController controller) {
        this.parentcntact= (Parent_Contact__c)controller.getRecord();
         allaccounts = [SELECT ID from Account WHERE ParentContact__c = : parentcntact.id];
    }
    
    
    public List<Asset> getAssets() {
        if (assets == null){
            assets = loadAssets();
        }
        system.debug('-----getAssets: Complete');
        return assets;
    }
    public List<Case> getCases() {
        if (cases == null){
            cases = loadCases();
        }
        system.debug('-----getCases: Complete');
        return cases;
    }
    public Parent_Contact__c getParentContact() {
        
        return parentcntact;
    }
 	public integer getAssetSize() {
        
        return getAssets().size();
    }
    
    private list<Asset> loadAssets()
    {
        
        //List<Account> allaccounts = [SELECT ID from Account WHERE ParentContact__c = : parentcntact.id];
        system.debug('----SOQL [SELECT ID from Account WHERE Parent_Contact = ' +  parentcntact.id);
        system.debug('-----allaccounts.size:' +  allaccounts.size());
        List<Asset> allassets = [SELECT ID, Name, sap_Material_Number__c, Product2Id, Product2.Brand__c, IdentifiedBy__c, PurchaseDate, Standard_Warranty_Months__c, Extended_Warranty_Months__c, CreatedDate from Asset WHERE AccountID IN : allaccounts];
        
        system.debug('----SOQL [SELECT ID from Account WHERE Parent_Contact = ' +  parentcntact.id);
        system.debug('-----allaccounts.size:' +  allaccounts.size());
        
        return allassets;
    }
    
     private list<Case> loadCases()
    {
      
        system.debug('-----allaccounts.size:' +  allaccounts.size());
        List<Case> allcases = [SELECT ID, CaseNumber, Type, Status, Brand__c, Nature__c, Resolution__c, ClosedDate, CreatedDate from Case WHERE AccountId IN : allaccounts];
        
        system.debug('----SOQL [SELECT ID from Account WHERE Parent_Contact = ' +  parentcntact.id);
        system.debug('-----allaccounts.size:' +  allaccounts.size());
        
        return allcases;
    }
}