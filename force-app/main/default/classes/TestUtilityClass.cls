/**
* @author Original: Arjen Nayal
* @date Original: 29 May 2017 
* @description Test Utility Class
*/
@isTest
public class TestUtilityClass {
    
    /**
    * @author Original: Arjen Nayal
    * @date Original: 29 May 2017 
    * @description Method for creating test account
    */
    public static List<Account> createAccount(Integer sizeVar) {
        
        List<Account>accList = new List<Account>();
        for (Integer flag = 0; flag < sizeVar; flag ++) {
            Account accVar = new Account();
            accVar.Name = 'test' + string.valueOf(flag);
            accList.add(accVar);
        }
        return accList;
    }
    
    /**
    * @author Original: Arjen Nayal
    * @date Original:  29 May 2017 
    * @description Method for creating test contact
    */
    public static List<Contact> createContact(integer sizeVar,String accId) {
        List<Contact> conList = new List<Contact>();
  
        for (Integer i = 0; i < sizeVar; i ++) {
            Contact conVar = new Contact(
                FirstName = 'Test',
                LastName = 'Contact',
                AccountId = accId
            );
            conList.add(conVar);
        }
        return conList;
    }
    
    /**
    * @author Original: Arjen Nayal
    * @date Original: 29 May 2017 
    * @description Method for creating test Person Account
    */
    public static List<Account> createPersonAccount(Integer sizeVar) {
        RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Account' AND isActive = TRUE AND DeveloperName = 'PersonAccount' LIMIT 1];
        List<Account>accList = new List<Account>();
        for (Integer flag = 0; flag < sizeVar; flag ++) {
            Account accVar = new Account();
            accVar.RecordTypeID = rt.Id;
            accVar.FirstName = 'test' + string.valueOf(flag);
            accVar.LastName = 'test' + string.valueOf(flag);
            accVar.PersonMailingStreet = 'test@yahoo.com';
            accVar.PersonMailingPostalCode = '12345';
            accVar.PersonMailingCity = 'SFO';
            accVar.PersonMailingCountry = 'Australia';
            accVar.PersonHomePhone = '1234567';
            accVar.PersonMobilePhone = '12345678';
            accVar.Brands__c = 'Ryobi';
            accVar.Country__pc = 'Australia';
            accList.add(accVar);
        }
        return accList;
    }
    
    /**
    * @author Original: Arjen Nayal
    * @date Original: 29 May 2017
    * @description Method for creating test Asset
    */
    public static List<Asset> createAsset(integer sizeVar,String accId, String conId, String prodId) {
        List<Asset> assetList = new List<Asset>();
  
        for (Integer i = 0; i < sizeVar; i ++) {
            Asset assetVar = new Asset(
                Name = 'Airwave Air Reciprocating Saw',
                AccountId = accId,
                ContactId = conId,
                Product2Id = prodId
                
            );
            assetList.add(assetVar);
        }
        return assetList;
    }

    /**
    * @author Original: Arjen Nayal
    * @date Original:  29 May 2017 
    * @description Method for creating test Product
    */
    public static List<Product2> createProduct(integer sizeVar) {
        List<Product2> prodList = new List<Product2>();
        for (Integer i = 0; i < sizeVar; i ++) {
            Product2 prod = new Product2(
                Name = 'Ryobi Airwave Air Reciprocating Saw',
                Image_URL__c = 'https://739a9e17fab0c4e729e1-5436bcca90dbfab4540ef3f0f1183096.ssl.cf4.rackcdn.com/products/photos/large_eef8457e-22af-4425-857d-69c1202e77fa.jpeg',
                Small_Image_URL__c = 'https://739a9e17fab0c4e729e1-5436bcca90dbfab4540ef3f0f1183096.ssl.cf4.rackcdn.com/products/photos/tiny_eef8457e-22af-4425-857d-69c1202e77fa.jpeg',
                Published__c = true,
                IsActive = true,
                Available_AU__c = true,
                Available_NZ__c = true,
                Category_Customer_Level1__c = 'Power Tools',
                Category_Customer_Level2__c = 'Cutting;Pneumatics', 
                Category_Customer_Level3__c = 'Pneumatic',
                Customer_Facing_Name__c = 'Airwave Air Reciprocating Saw',
                ProductCode = 'RA-RS6300-B'
            );

            prodList.add(prod);
        }
        
        return prodList;
    }
    
    /*
     * @author: Ronald Pascual
     * @date Original:  11 NOV 2018
     * @description Method for creating user
     */
     public static List<User> createUser(String sapNumber, Integer noOfUser) {
        //String rand = generateRandomString(6);
        List<User> userList = new List<User>();
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        
        for(Integer i = 0; i < noOfUser; i ++){
            User u = new User(Alias = uniqueName.substring(18, 23), Email= uniqueName + i + '@testorg.com', 
                              EmailEncodingKey='UTF-8', LastName= 'Testing' + i, LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p.Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName= uniqueName + i + '@testorg.com', TTI_SAP_Cust_No__c = sapNumber + i);
            userList.add(u);
        }

        return userList;
    }
    
    public static List<Inventory__c> createInventories(String sapNumber, Integer noOfInventory){
        List<Inventory__c> invList = new List<Inventory__c>();
        
        for (integer i = 0; i < noOfInventory; i ++) {
            invList.add(new Inventory__c(SAP_Account__c = sapNumber + i));
        }
        
        return invList;
    }
    /*
    private static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
    */

}