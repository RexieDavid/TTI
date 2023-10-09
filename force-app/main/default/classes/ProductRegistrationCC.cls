/* @description:    Controlled for the warranty product selection page
 * @author:         Andrew Manetakis (Accenture)
 * @createdDate:    16 March 2017 
 */
public class ProductRegistrationCC {
    
    @AuraEnabled
    public static Community_Settings__c getCommunitySettings() {
        return CommunitySettingsHelperClass.getSiteSettings(Site.getMasterLabel());
    }

    @AuraEnabled
    public static String getSiteBrand() {
        return getCommunitySettings().Brand__c;
    }
    
    // returns a list of available products for warranty registration
    @AuraEnabled
    public static List<Product2> getProducts () {
        List<Product2> productList = new List<Product2>();
        DateTime t0 = DateTime.now();

        //TODO: get the brand from the linked user contact record
        //TODO: remove the category_customer_level1__c hard coding
        //TODO: refernce the Published__c flag in both main & subquery
        //TODO: reference the region based on users country
        //String brand = 'RY';
        String productBrand = '';
        List<String> categoryFilter = new List<String>();
        String australiaCountry = '';
        String newZealandCountry = '';
        
        Community_Settings__c ryobiCS = Community_Settings__c.getValues(Site.getMasterLabel());
        if (ryobiCS != null) {
            productBrand = ryobiCS.ProductBrand__c;
            australiaCountry = ryobiCS.Australia_Country__c;
            newZealandCountry = ryobiCS.New_Zealand_Country__c;
            categoryFilter = ryobiCS.ProductSelectionIntialCategories__c.split(',');
        }
        String ryobiUserId = UserInfo.getUserId();
        List<User> userList = [SELECT Id, Contact.country__c
                              FROM User 
                              WHERE Id =:ryobiUserId Limit 1];
        
        System.debug('-----userList: '+ userList);
        System.debug('-----userList Country: '+ userList[0].Contact.country__c);
        System.debug('-----ryobiCS: '+ ryobiCS);
        System.debug('-----productBrand: '+ productBrand);
        System.debug('-----australiaCountry: '+ australiaCountry);
        System.debug('-----newZealandCountry: '+ newZealandCountry);
        System.debug('-----categoryFilter: '+ categoryFilter);
        
        if (userList[0].Contact.country__c != null && userList[0].Contact.country__c == australiaCountry && ryobiCS != null) {
            productList = [  SELECT Id,
                                    Customer_Facing_Name__c,
                                    Brand__c,
                                    Category_Customer_Level1__c,
                                    Category_Customer_Level2__c,
                                    Category_Customer_Level3__c,
                                    ProductCode,
                                    Image_URL__c,
                                    Small_Image_URL__c,
                                    Is_Serial_Number_Optional__c,
                                    (   SELECT  id, quantity__c, 
                                        kit__c, kit__r.Customer_Facing_Name__c, 
                                        kit_tool__c, kit_tool__r.Customer_Facing_Name__c, kit_tool__r.ProductCode, kit_tool__r.Image_URL__c, kit_tool__r.Small_Image_URL__c,
                                        kit_tool__r.SerialNumberDisplayType__c,
                                        kit_tool__r.SerialNumberDisplayType__r.Display_Week__c,
                                        kit_tool__r.SerialNumberDisplayType__r.Display_Year__c,
                                        kit_tool__r.SerialNumberDisplayType__r.Allow_Numbers_Only__c,
                                        kit_tool__r.SerialNumberDisplayType__r.Regexpression_Validator__c,
                                        kit_tool__r.SerialNumberDisplayType__r.Serial_Number_Length__c,
                                        kit_tool__r.SerialNumberDisplayType__r.HelpText__c,
                                        kit_tool__r.SerialNumberDisplayType__r.HelperImageURL__c,
                                        kit_tool__r.SerialNumberDisplayType__r.EnforceLength__c,
                                        kit_tool__r.Is_Serial_Number_Optional__c
                                        FROM    Kit_Products__r
                                        WHERE   kit_tool__r.Published__c = TRUE
                                    ),
                                    SerialNumberDisplayType__c, 
                                    SerialNumberDisplayType__r.Display_Week__c,
                                    SerialNumberDisplayType__r.Display_Year__c,
                                    SerialNumberDisplayType__r.Allow_Numbers_Only__c,
                                    SerialNumberDisplayType__r.Regexpression_Validator__c,
                                    SerialNumberDisplayType__r.Serial_Number_Length__c,
                                    SerialNumberDisplayType__r.HelpText__c,
                                    SerialNumberDisplayType__r.HelperImageURL__c,
                                    SerialNumberDisplayType__r.EnforceLength__c
                           FROM    product2
                           //WHERE   brand__c =: brand
                           WHERE   brand__c =: productBrand
                           //AND     category_customer_level1__c in('Outdoor','Power Tools','Accessories')
                           AND     category_customer_level1__c in:categoryFilter
                           //AND     category_customer_level1__c != null
                           AND   Available_AU__c = TRUE
                           //AND   Available_NZ__c TRUE
                           AND   Published__c = TRUE
                           //ORDER BY category_customer_level1__c DESC
                           ORDER BY Display_Order__c ASC
                           
                          ];
        } else if (userList[0].Contact.country__c != null && userList[0].Contact.country__c == newZealandCountry && ryobiCS != null) {
            productList = [  SELECT Id, 
                                    Customer_Facing_Name__c,
                                    Brand__c,
                                    Category_Customer_Level1__c,
                                    Category_Customer_Level2__c,
                                    Category_Customer_Level3__c,
                                    ProductCode,
                                    Image_URL__c,
                                    Small_Image_URL__c,
                                    Is_Serial_Number_Optional__c,
                                    (   SELECT  id, quantity__c, 
                                        kit__c, kit__r.Customer_Facing_Name__c, 
                                        kit_tool__c, kit_tool__r.Customer_Facing_Name__c, kit_tool__r.ProductCode, kit_tool__r.Image_URL__c, kit_tool__r.Small_Image_URL__c,
                                        kit_tool__r.SerialNumberDisplayType__c,
                                        kit_tool__r.SerialNumberDisplayType__r.Display_Week__c,
                                        kit_tool__r.SerialNumberDisplayType__r.Display_Year__c,
                                        kit_tool__r.SerialNumberDisplayType__r.Allow_Numbers_Only__c,
                                        kit_tool__r.SerialNumberDisplayType__r.Regexpression_Validator__c,
                                        kit_tool__r.SerialNumberDisplayType__r.Serial_Number_Length__c,
                                        kit_tool__r.SerialNumberDisplayType__r.HelpText__c,
                                        kit_tool__r.SerialNumberDisplayType__r.HelperImageURL__c,
                                        kit_tool__r.SerialNumberDisplayType__r.EnforceLength__c
                                        FROM    Kit_Products__r
                                        WHERE   kit_tool__r.Published__c = TRUE
                                    ),
                                    SerialNumberDisplayType__c, 
                                    SerialNumberDisplayType__r.Display_Week__c,
                                    SerialNumberDisplayType__r.Display_Year__c,
                                    SerialNumberDisplayType__r.Allow_Numbers_Only__c,
                                    SerialNumberDisplayType__r.Regexpression_Validator__c,
                                    SerialNumberDisplayType__r.Serial_Number_Length__c,
                                    SerialNumberDisplayType__r.HelpText__c,
                                    SerialNumberDisplayType__r.HelperImageURL__c,
                                    SerialNumberDisplayType__r.EnforceLength__c 
                           FROM    product2
                           //WHERE   brand__c =: brand
                           WHERE   brand__c =: productBrand
                           AND     category_customer_level1__c in :categoryFilter
                           //AND     category_customer_level1__c != null
                           //AND   Available_AU__c = TRUE
                           AND   Available_NZ__c = TRUE
                           AND   Published__c = TRUE
                           ORDER BY category_customer_level1__c DESC
                           
                          ];
        }
 
        DateTime t1 = DateTime.now();
        System.debug('ProductRegistrationCC.getProducts() time taken = ' + (t1.getTime()-t0.getTime()) + ' ms');
        return productList;
    } 
    
    @AuraEnabled
    public static List<Category_Image__c> getCategoryImages() {
        //TODO: make brand dynamic
        String BRAND = '';
        Community_Settings__c ryobiCS = Community_Settings__c.getValues(Site.getMasterLabel());
        if (ryobiCS != null) {
            BRAND = ryobiCS.Brand__c;
        }
        //String brand='Ryobi';

        DateTime t0 = DateTime.now();

        List<Category_Image__c> categoryImages = [   SELECT id, Name, Image_URL__c, External_Id__c, Display_Order__c
                                                        FROM Category_Image__c
                                                        WHERE Brand__c = :BRAND
                                                        ORDER BY Display_Order__c ASC
                                                    ];
        DateTime t1 = DateTime.now();
        System.debug('ProductRegistrationCC.getCategoryImages() time taken = ' + (t1.getTime()-t0.getTime()) + ' ms');
        
        return categoryImages;
    }
    
    @AuraEnabled
    public static SerialNumberDisplayType__c  getDefaultSerialNumerDisplay() {
       
        SerialNumberDisplayType__c defaultSNDisplay = [SELECT Id, Allow_Numbers_Only__c, Display_Week__c, Display_Year__c,
                                      Regexpression_Validator__c, Serial_Number_Length__c, HelpText__c, HelperImageURL__c, EnforceLength__c 
                                      FROM SerialNumberDisplayType__c WHERE IsDefault__c = true ORDER BY LastModifiedDate DESC LIMIT 1] ;
        
       
            return  defaultSNDisplay;
            
    }
}