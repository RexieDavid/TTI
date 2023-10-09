@isTest
public class ProductTransactionToolCounterTest {

    @TestSetup
    static void makeData() {
        List<Product2> products = new List<Product2>();

        products.add(
            new Product2(
                Name = 'AEG Cordless',
                SAP_Product_Heirarchy__c = 'AG-18L-TEST',
                SAP_Material_Group__c = 'AG',
                Brand__c = 'AG'
            )
        );

        products.add(
            new Product2(
                Name = 'AEG Corded/Petrol',
                SAP_Product_Heirarchy__c = 'AG-PED-TEST',
                SAP_Material_Group__c = 'AG',
                Brand__c = 'AG'
            )
        );

        products.add(
            new Product2(
                Name = 'Ryobi Cordless',
                SAP_Product_Heirarchy__c = 'RY-OPL-TEST',
                SAP_Material_Group__c = 'AG',
                Brand__c = 'RY'
            )
        );

        products.add(
            new Product2(
                Name = 'Ryobi Corded/Petrol',
                SAP_Product_Heirarchy__c = 'RY-PED-TEST',
                SAP_Material_Group__c = 'AG',
                Brand__c = 'RY'
            )
        );

        insert products;
    }

    @IsTest
    static void testPopulateSalesTxnCounters() {
        Product2 aegCordlessProduct = [SELECT Id FROM Product2 WHERE SAP_Product_Heirarchy__c LIKE 'AG%' AND SAP_Product_Heirarchy__c LIKE '%18L%' LIMIT 1];
        Product2 aegCordedPetrolProduct = [SELECT Id FROM Product2 WHERE SAP_Product_Heirarchy__c LIKE 'AG%' AND SAP_Product_Heirarchy__c LIKE '%PED%' LIMIT 1];
        Product2 ryCordlessProduct = [SELECT Id FROM Product2 WHERE SAP_Product_Heirarchy__c LIKE 'RY%' AND SAP_Product_Heirarchy__c LIKE '%OPL%' LIMIT 1];
        Product2 ryCordedPetrolProduct = [SELECT Id FROM Product2 WHERE SAP_Product_Heirarchy__c LIKE 'RY%' AND SAP_Product_Heirarchy__c LIKE '%PED%' LIMIT 1];

        Sales_Transactions__c salesTxn = new Sales_Transactions__c();
        insert salesTxn;

        List<Product_Transactions__c> prodTxns = new List<Product_Transactions__c>();

        prodTxns.add(
            new Product_Transactions__c(
                Sales_Transactions__c = salesTxn.Id,
                Product__c = aegCordlessProduct.Id,
                Quantity__c = 1,
                Retail_Price__c = 100
            )
        );

        prodTxns.add(
            new Product_Transactions__c(
                Sales_Transactions__c = salesTxn.Id,
                Product__c = aegCordedPetrolProduct.Id,
                Quantity__c = 1,
                Retail_Price__c = 100
            )
        );

        prodTxns.add(
            new Product_Transactions__c(
                Sales_Transactions__c = salesTxn.Id,
                Product__c = ryCordlessProduct.Id,
                Quantity__c = 1,
                Retail_Price__c = 100
            )
        );

        prodTxns.add(
            new Product_Transactions__c(
                Sales_Transactions__c = salesTxn.Id,
                Product__c = ryCordedPetrolProduct.Id,
                Quantity__c = 1,
                Retail_Price__c = 100
            )
        );

        Test.startTest();
            insert prodTxns;
        Test.stopTest();

        salesTxn = [SELECT Id, Count_of_AEG_Cordless__c, Count_of_AEG_Corded_Petrol__c, Count_of_Ryobi_Cordless__c, Count_of_Ryobi_Corded_Petrol__c FROM Sales_Transactions__c WHERE Id = :salesTxn.Id];

        System.assertEquals(1, salesTxn.Count_of_AEG_Cordless__c, 'Incorrect AEG cordless product count.');
        System.assertEquals(1, salesTxn.Count_of_Ryobi_Cordless__c, 'Incorrect Ryobi cordless product count.');
        System.assertEquals(1, salesTxn.Count_of_AEG_Corded_Petrol__c, 'Incorrect AEG corded/petrol product count.');
        System.assertEquals(1, salesTxn.Count_of_Ryobi_Corded_Petrol__c, 'Incorrect Ryobi corded/petrol product count.');
        
    }
}