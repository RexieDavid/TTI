/**
 * @author: TTI
 * @date: December 2022
 * @description: This is the test class for the AddProductRedemptionController class
 */

@isTest
public class AddProductRedemptionControllerTest {

    @TestSetup
    static void setupData() {

        Contact con2 = new Contact();
        con2.LastName = 'Testing';
        con2.FirstName = 'RAF';
        con2.Email = 'test2@test.com';
        con2.MobilePhone = '9999999999';
        con2.Phone = '5897899097';
        con2.Country__c = 'Australia';
        insert con2;

        Product2 product = new Product2();
        product.Name = 'test Product';
        product.Brand__c = 'AEG';
        product.IsActive = true;
        product.ProductCode = 'test123';
        insert product;

        Product2 productTest = new Product2();
        productTest.Name = 'sample Product';
        productTest.Brand__c = 'AEG';
        productTest.IsActive = true;
        productTest.ProductCode = 'test123sample123';
        insert productTest;
        
        PurchasedProducts__c purProds = new PurchasedProducts__c();
        insert purProds;

        RedeemableProducts__c redeemableProds = new RedeemableProducts__c();
        redeemableProds.RedeemType__c = 'All';
        insert redeemableProds;

        RedeemedProducts__c redeemedProds = new RedeemedProducts__c();
        insert redeemedProds;
        
        PurchasedProductLineItem__c purProdsLine = new PurchasedProductLineItem__c();
        purProdsLine.Product__c = product.Id;
        purProdsLine.PurchasedProduct__c = purProds.Id;
        purProdsLine.Quantity__c = 1;
        insert purProdsLine;

        RedeemableProductItem__c redProdsLine = new RedeemableProductItem__c();
        redProdsLine.Product__c = productTest.Id;
        redProdsLine.RedeemableProduct__c = redeemableProds.Id;
        redProdsLine.Quantity__c = 1;
        insert redProdsLine;

        RedeemableProductItem__c redProdsLineReq = new RedeemableProductItem__c();
        redProdsLineReq.Product__c = productTest.Id;
        redProdsLineReq.RedeemableProduct__c = redeemableProds.Id;
        redProdsLineReq.Quantity__c = 1;
        redProdsLineReq.Required__c = true;
        insert redProdsLineReq;
        
        Redemption_Campaigns__c redempCamp = new Redemption_Campaigns__c();
        redempCamp.RedeemableProducts__c = redeemableProds.Id;
        redempCamp.PurchasedProducts__c = purProds.Id;
        redempCamp.RAF__c = true;
        redempCamp.Valid_From__c = Date.valueOf(System.now().addDays(-2));
        redempCamp.Valid_To__c = Date.valueOf(System.now().addDays(2));
        redempCamp.Brand__c = 'AEG';        
        insert redempCamp;    
    }

    private static testMethod void testAddProductItem() { 

        Contact con = [SELECT Id, FirstName, LastName, MobilePhone, Phone, Email FROM Contact WHERE Email = 'test2@test.com' LIMIT 1];         
        Redemption_Campaigns__c redempCamp = [SELECT Id, Name, RAF__c, Brand__c FROM Redemption_Campaigns__c WHERE Brand__c = 'AEG' AND RAF__c = true LIMIT 1];
        RedeemedProducts__c redeemedProds = [SELECT Id, Name FROM RedeemedProducts__c LIMIT 1];

        Redemptions__c red = new Redemptions__c();
        red.Redemption_Campaign__c = redempCamp.Id;
        red.Brand__c = 'AEG';
        red.RAF__c = true;
        red.Name__c = con.Id;
        red.RedeemedProducts__c = redeemedProds.Id;
        insert red;

        AddProductRedemptionController.redemptionProductWrapper cv = new AddProductRedemptionController.redemptionProductWrapper();
            
        Test.startTest();
            cv = AddProductRedemptionController.getRedemptionCampaignProductItem(redempCamp.id, redeemedProds.Id);
        Test.stopTest();

        system.assertNotEquals(cv,null);

    }

    private static testMethod void testCreateProductItem() { 

        Contact con = [SELECT Id, FirstName, LastName, MobilePhone, Phone, Email FROM Contact WHERE Email = 'test2@test.com' LIMIT 1];         
        Redemption_Campaigns__c redempCamp = [SELECT Id, Name, RAF__c, Brand__c FROM Redemption_Campaigns__c WHERE Brand__c = 'AEG' AND RAF__c = true LIMIT 1];
        List<PurchasedProductLineItem__c> ppli = [SELECT Id, Product__c, Quantity__c FROM PurchasedProductLineItem__c WHERE Quantity__c = 1 LIMIT 1];
        List<RedeemableProductItem__c> rpli = [SELECT Id, Product__c, Quantity__c FROM RedeemableProductItem__c WHERE Quantity__c = 1 LIMIT 1];
        List<String> ppliList = new list<string>{ppli[0].Product__c + ';' + ppli[0].Quantity__c};
        List<String> rpliList = new list<string>{rpli[0].Product__c + ';' + rpli[0].Quantity__c};
        String strRedId;
        String strRedempcamp;

        Redemptions__c red = new Redemptions__c();
        red.Redemption_Campaign__c = redempCamp.Id;
        red.Brand__c = 'AEG';
        red.RAF__c = true;
        red.Name__c = con.Id;
        insert red;

        strRedId = String.valueOf(red.Id);
        strRedempcamp = String.valueOf(redempCamp.id);
            
        Test.startTest();
            AddProductRedemptionController.createPurchasedAndRedeemProducts(strRedId,strRedempcamp,ppliList,rpliList);
        Test.stopTest();

    }

}