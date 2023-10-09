@isTest
public class TTIFormProductCreateControllerTest {
    
    @testSetup static void testData() {
        String uniqueKey = String.valueof(DateTime.now().getTime());
        Id showroomStockRecId = Schema.SObjectType.TTI_Form__c.getRecordTypeInfosByName().get('Showroom Stock Request').getRecordTypeId();
        Id promoStockRecId = Schema.SObjectType.TTI_Form__c.getRecordTypeInfosByName().get('Promo Stock Request').getRecordTypeId();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Industrial Lead Manager'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id, Country ='Australia',
        TimeZoneSidKey='America/Los_Angeles', UserName='teststandard@testing.com', TTI_SAP_Cust_No__c= uniqueKey.subString(0, 5), Division = 'Industrial');
        insert u;
        
        User u2 = new User(Alias = 'mtrez', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Tersting', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id, Country ='New Zealand',
        TimeZoneSidKey='America/Los_Angeles', UserName='teststandard2@testing.com', TTI_SAP_Cust_No__c= uniqueKey.subString(5, 10), Division = 'Industrial');
        insert u2;
        
        List<Account> accList = new List<Account>();
        accList.add(new Account(Name = 'acc', TTI_SAP_Cust_No__c = uniqueKey.subString(0, 5),Sales_Organisation__c ='BP01', OwnerId = u.id));
        insert accList;

        TTIForm_Defaults__c cs = new TTIForm_Defaults__c();
        cs.Default_JSS_Approver__c='teststandard@testing.com';
        cs.Default_Promo_Approver__c='teststandard@testing.com';
        cs.Default_Promo_Account_Number__c= uniqueKey.subString(0, 5);
        insert cs;
        
        TTIForm_Defaults_NZ__c cs4 = new TTIForm_Defaults_NZ__c();
        cs4.Default_JSS_Approver__c='teststandard2@testing.com';
        cs4.Default_Promo_Approver__c='teststandard2@testing.com';
        cs4.Default_Promo_Account_Number__c= uniqueKey.subString(0, 5);
        insert cs4;
        
        Brand_Defaults__c cs2 = new Brand_Defaults__c();
        cs2.Name='ML';
        cs2.Record_Type_Name__c='Showroom Stock Request';
        cs2.SAP_Material_Group__c='ML%;PI;';
        cs2.Division__c = 'Industrial';
        cs2.Sales_Organisation__c = 'BP01';
        insert cs2;
        
        Brand_Defaults__c cs3 = new Brand_Defaults__c();
        cs3.Name='MQ';
        cs3.Record_Type_Name__c='Promo Stock Request';
        cs3.SAP_Material_Group__c='ML%;PI;MQ-TL';
        cs3.Division__c = 'Industrial';
        cs3.Sales_Organisation__c = 'NZ01';
        insert cs3;
        
        List<TTI_Form__c> ttiFormList = new List<TTI_Form__c>();
        for (integer i=0; i < 10; i++) {
            ttiFormList.add(new TTI_Form__c(Purpose_of_order__c = 'Direct Marketing', Required_by_date__c = System.today(), recordTypeId = showroomStockRecId));
        }
        for(Account acct: accList){
            ttiFormList.add(new TTI_Form__c(Purpose_of_order__c = 'Direct Marketing', Required_by_date__c = System.today(), recordTypeId = promoStockRecId, Customer_Name__c = acct.id));
        }
        //ttiFormList.add(new TTI_Form__c(Purpose_of_order__c = 'Direct Marketing', Required_by_date__c = System.today(), recordTypeId = promoStockRecId, Customer_Name__c = acctNZ.id));
        
        
        List<Product2> prodList = new List<Product2>();
        for (integer i = 0; i < 18; i ++) {
            if (i < 2) {
                prodList.add(new Product2(SAP_Material_Group__c='ML-TL', Name='Prod'+i, SAP_MaterialNumber__c = '123' + i));
            } else if (i < 4) {
                prodList.add(new Product2(SAP_Material_Group__c='ML-AC', Name='Prod'+i, SAP_MaterialNumber__c = '123' + i));
            } else if (i < 6) {
                prodList.add(new Product2(SAP_Material_Group__c='PI', Name='Prod'+i, SAP_MaterialNumber__c = '123' + i));
            } else if (i < 8) {
                prodList.add(new Product2(SAP_Material_Group__c='ML-SP', Name='Prod'+i, SAP_MaterialNumber__c = '123' + i));
            } else if (i < 10) {
                prodList.add(new Product2(SAP_Material_Group__c='MQ-TL', Name='Prod'+i, SAP_MaterialNumber__c = '123' + i));
            } else if (i < 12) {
                prodList.add(new Product2(SAP_Material_Group__c='ML-TL', Name='Prod'+i, SAP_MaterialNumber__c = '123' + i, Rounding_Profile_AU__c = 'YG01', PAC__c = 3));
            } else if (i < 14) {
                prodList.add(new Product2(SAP_Material_Group__c='ML-TL', Name='Prod'+i, SAP_MaterialNumber__c = '123' + i, Rounding_Profile_AU__c = 'YG02', CAR__c = 3));
            } else if (i < 16) {
                prodList.add(new Product2(SAP_Material_Group__c='ML-TL', Name='Prod'+i, SAP_MaterialNumber__c = '123' + i, Rounding_Profile_NZ__c = 'YG01', PAC__c = 3));
            } else if (i < 18) {
                prodList.add(new Product2(SAP_Material_Group__c='ML-TL', Name='Prod'+i, SAP_MaterialNumber__c = '123' + i, Rounding_Profile_NZ__c = 'YG02', CAR__c = 3));
            }
        }

        insert prodList;
        
        System.runAs(u) {
            insert ttiFormList;
        }
        
    }
    
    public static testMethod void testTTIFormRecTypes() {
        User u = [SELECT Id FROM User WHERE username = 'teststandard@testing.com'];
        
        System.runAs(u) {
            PageReference pageRef = Page.TTIFormProductCreate;
            Test.setCurrentPage(pageRef);
            
            TTI_Form__c ttiform = [SELECT Id FROM TTI_Form__c WHERE recordTypeId = :Schema.SObjectType.TTI_Form__c.getRecordTypeInfosByName().get('Showroom Stock Request').getRecordTypeId() LIMIT 1];
            ApexPages.currentPage().getParameters().put('Id', ttiform.Id);
            
            Product2 product = [SELECT Id, SAP_Material_Group__c,Rounding_Profile_AU__c,Rounding_Profile_NZ__c,PAC__c,CAR__c FROM Product2 WHERE SAP_Material_Group__c = 'ML-TL' LIMIT 1];
            TTIFormProductCreateController cont = new TTIFormProductCreateController();
            cont.save();
            cont.cancel();
            Boolean hasNext = cont.hasNext;
            Boolean hasPrevious = cont.hasPrevious;
            
            TTIFormProductCreateController.productWrapper cmp = new TTIFormProductCreateController.productWrapper(product);
            cmp.selected=true;
            cmp.quantity=1;
            cont.prodWrap.add(cmp);
            cont.searchString = 'prod';
            cont.save();
            cont.search();
            cont.next();
            cont.previous();
            
            TTI_Form_Product__c ttiFormProduct = [SELECT Id,SAP_Material_Number__c FROM TTI_Form_Product__c WHERE Form_Number__c = :ttiform.Id];
            System.assertEquals(ttiFormProduct.SAP_Material_Number__c, product.Id);
        }        
    }
    
        public static testMethod void testValidation() {
        User u = [SELECT Id FROM User WHERE username = 'teststandard@testing.com'];
        
        System.runAs(u) {
            PageReference pageRef = Page.TTIFormProductCreate;
            Test.setCurrentPage(pageRef);
            
            TTI_Form__c ttiform = [SELECT Id FROM TTI_Form__c WHERE recordTypeId = :Schema.SObjectType.TTI_Form__c.getRecordTypeInfosByName().get('Promo Stock Request').getRecordTypeId() LIMIT 1];
            ApexPages.currentPage().getParameters().put('Id', ttiform.Id);
            
            Product2 product = [SELECT Id, SAP_Material_Group__c,Rounding_Profile_AU__c,Rounding_Profile_NZ__c,PAC__c,CAR__c FROM Product2 WHERE SAP_Material_Group__c = 'ML-TL' LIMIT 1];
            Product2 productMQ = [SELECT Id, SAP_Material_Group__c,Rounding_Profile_AU__c,Rounding_Profile_NZ__c,PAC__c,CAR__c FROM Product2 WHERE SAP_Material_Group__c = 'MQ-TL' LIMIT 1];
            TTIFormProductCreateController cont = new TTIFormProductCreateController();
            cont.save();
            cont.cancel();
            Boolean hasNext = cont.hasNext;
            Boolean hasPrevious = cont.hasPrevious;
            
            TTIFormProductCreateController.productWrapper cmp = new TTIFormProductCreateController.productWrapper(product);
            cmp.selected=true;
            cmp.quantity=1;
            TTIFormProductCreateController.productWrapper cmp2 = new TTIFormProductCreateController.productWrapper(productMQ);
            cmp2.selected=true;
            cmp2.quantity=1;
            cont.prodWrap.add(cmp);
            cont.prodWrap.add(cmp2);
            cont.searchString = 'prod';
            cont.save();
            cont.search();
            cont.next();
            cont.previous();
            
            //TTI_Form_Product__c ttiFormProduct = [SELECT Id,SAP_Material_Number__c FROM TTI_Form_Product__c WHERE Form_Number__c = :ttiform.Id];
            //System.assertEquals(ttiFormProduct.SAP_Material_Number__c, product.Id);
        }        
    }
    
   public static testMethod void testValidation2() {
        User u = [SELECT Id FROM User WHERE username = 'teststandard@testing.com'];
        
        System.runAs(u) {
            PageReference pageRef = Page.TTIFormProductCreate;
            Test.setCurrentPage(pageRef);
            
            TTI_Form__c ttiform = [SELECT Id FROM TTI_Form__c WHERE recordTypeId = :Schema.SObjectType.TTI_Form__c.getRecordTypeInfosByName().get('Promo Stock Request').getRecordTypeId() LIMIT 1];
            ApexPages.currentPage().getParameters().put('Id', ttiform.Id);
            
            Product2 product = [SELECT Id, SAP_Material_Group__c,Rounding_Profile_AU__c,Rounding_Profile_NZ__c,PAC__c,CAR__c FROM Product2 WHERE SAP_Material_Group__c = 'ML-TL' LIMIT 1];
            Product2 productMQ = [SELECT Id, SAP_Material_Group__c,Rounding_Profile_AU__c,Rounding_Profile_NZ__c,PAC__c,CAR__c FROM Product2 WHERE SAP_Material_Group__c = 'MQ-TL' LIMIT 1];
            
            TTI_Form_Product__c ttiFormProdMQTL = new TTI_Form_Product__c();
            ttiFormProdMQTL.Form_Number__c = ttiform.Id;
            ttiFormProdMQTL.SAP_Material_Number__c = productMQ.id;
            insert ttiFormProdMQTL;
            
            TTIFormProductCreateController cont = new TTIFormProductCreateController();
            cont.save();
            cont.cancel();
            Boolean hasNext = cont.hasNext;
            Boolean hasPrevious = cont.hasPrevious;
            
            TTIFormProductCreateController.productWrapper cmp = new TTIFormProductCreateController.productWrapper(product);
            cmp.selected=true;
            cmp.quantity=1;
            TTIFormProductCreateController.productWrapper cmp2 = new TTIFormProductCreateController.productWrapper(productMQ);
            cmp2.selected=true;
            cmp2.quantity=1;
            cont.prodWrap.add(cmp);
            cont.prodWrap.add(cmp2);
            cont.searchString = 'prod';
            cont.save();
            cont.search();
            cont.next();
            cont.previous();
            
            //TTI_Form_Product__c ttiFormProduct = [SELECT Id,SAP_Material_Number__c FROM TTI_Form_Product__c WHERE Form_Number__c = :ttiform.Id];
            //System.assertEquals(ttiFormProduct.SAP_Material_Number__c, product.Id);
        }
       
    }
   
      public static testMethod void testRoundingAU_PAC() {
        User u = [SELECT Id FROM User WHERE username = 'teststandard@testing.com'];
        
        System.runAs(u) {
            PageReference pageRef = Page.TTIFormProductCreate;
            Test.setCurrentPage(pageRef);
            
            TTI_Form__c ttiform = [SELECT Id FROM TTI_Form__c WHERE recordTypeId = :Schema.SObjectType.TTI_Form__c.getRecordTypeInfosByName().get('Promo Stock Request').getRecordTypeId() LIMIT 1];
            ApexPages.currentPage().getParameters().put('Id', ttiform.Id);
            
            Product2 productPAC = [SELECT Id, Name, SAP_Material_Group__c,Rounding_Profile_AU__c,Rounding_Profile_NZ__c,PAC__c,CAR__c FROM Product2 WHERE Rounding_Profile_AU__c = 'YG01' AND PAC__c != NULL LIMIT 1];
            Product2 productCAR = [SELECT Id, Name, SAP_Material_Group__c,Rounding_Profile_AU__c,Rounding_Profile_NZ__c,PAC__c,CAR__c FROM Product2 WHERE Rounding_Profile_AU__c != NULL AND CAR__c != NULL LIMIT 1];
            
            TTI_Form_Product__c ttiFormProd = new TTI_Form_Product__c();
            ttiFormProd.Form_Number__c = ttiform.Id;
            ttiFormProd.SAP_Material_Number__c = productPAC.id;
            insert ttiFormProd;
            
            TTI_Form_Product__c ttiFormProd2 = new TTI_Form_Product__c();
            ttiFormProd2.Form_Number__c = ttiform.Id;
            ttiFormProd2.SAP_Material_Number__c = productCAR.id;
            insert ttiFormProd2;
            
            TTIFormProductCreateController cont = new TTIFormProductCreateController();
            //cont.save();
            //cont.cancel();
            Boolean hasNext = cont.hasNext;
            Boolean hasPrevious = cont.hasPrevious;
            
            TTIFormProductCreateController.productWrapper cmp = new TTIFormProductCreateController.productWrapper(productPAC);
            cmp.selected=true;
            cmp.quantity=2;
            TTIFormProductCreateController.productWrapper cmp2 = new TTIFormProductCreateController.productWrapper(productCAR);
            cmp2.selected=true;
            cmp2.quantity=2;
            cont.prodWrap.add(cmp);
            cont.prodWrap.add(cmp2);
            cont.searchString = 'prod';
            cont.save();
            //cont.search();
            //cont.next();
            //cont.previous();
            
            //TTI_Form_Product__c ttiFormProduct = [SELECT Id,SAP_Material_Number__c FROM TTI_Form_Product__c WHERE Form_Number__c = :ttiform.Id];
            //System.assertEquals(ttiFormProduct.SAP_Material_Number__c, product.Id);
        }
       
    }
    
    public static testMethod void testRoundingAU_CAR() {
        User u = [SELECT Id FROM User WHERE username = 'teststandard@testing.com'];
        
        System.runAs(u) {
            PageReference pageRef = Page.TTIFormProductCreate;
            Test.setCurrentPage(pageRef);
            
            TTI_Form__c ttiform = [SELECT Id FROM TTI_Form__c WHERE recordTypeId = :Schema.SObjectType.TTI_Form__c.getRecordTypeInfosByName().get('Promo Stock Request').getRecordTypeId() LIMIT 1];
            ApexPages.currentPage().getParameters().put('Id', ttiform.Id);
            
            Product2 productPAC = [SELECT Id, Name, SAP_Material_Group__c,Rounding_Profile_AU__c,Rounding_Profile_NZ__c,PAC__c,CAR__c FROM Product2 WHERE Rounding_Profile_AU__c != NULL AND PAC__c != NULL LIMIT 1];
            Product2 productCAR = [SELECT Id, Name, SAP_Material_Group__c,Rounding_Profile_AU__c,Rounding_Profile_NZ__c,PAC__c,CAR__c FROM Product2 WHERE Rounding_Profile_AU__c = 'YG02' AND CAR__c != NULL LIMIT 1];
            /*
            TTI_Form_Product__c ttiFormProd = new TTI_Form_Product__c();
            ttiFormProd.Form_Number__c = ttiform.Id;
            ttiFormProd.SAP_Material_Number__c = productPAC.id;
            insert ttiFormProd;
            */
            TTI_Form_Product__c ttiFormProd2 = new TTI_Form_Product__c();
            ttiFormProd2.Form_Number__c = ttiform.Id;
            ttiFormProd2.SAP_Material_Number__c = productCAR.id;
            insert ttiFormProd2;
            
            TTIFormProductCreateController cont = new TTIFormProductCreateController();
            //cont.save();
            //cont.cancel();
            Boolean hasNext = cont.hasNext;
            Boolean hasPrevious = cont.hasPrevious;
            
            /*TTIFormProductCreateController.productWrapper cmp = new TTIFormProductCreateController.productWrapper(productPAC);
            cmp.selected=true;
            cmp.quantity=2;*/
            TTIFormProductCreateController.productWrapper cmp2 = new TTIFormProductCreateController.productWrapper(productCAR);
            cmp2.selected=true;
            cmp2.quantity=2;
            //cont.prodWrap.add(cmp);
            cont.prodWrap.add(cmp2);
            cont.searchString = 'prod';
            cont.save();
            //cont.search();
            //cont.next();
            //cont.previous();
            
            //TTI_Form_Product__c ttiFormProduct = [SELECT Id,SAP_Material_Number__c FROM TTI_Form_Product__c WHERE Form_Number__c = :ttiform.Id];
            //System.assertEquals(ttiFormProduct.SAP_Material_Number__c, product.Id);
        }
       
    }
    
   public static testMethod void testRoundingNZ_PAC() {
        User u2 = [SELECT Id,Country FROM User WHERE username = 'teststandard2@testing.com'];
        
        System.runAs(u2) {
            
            PageReference pageRef = Page.TTIFormProductCreate;
            Test.setCurrentPage(pageRef);
            
            TTI_Form__c ttiform = [SELECT Id, Customer_Name__c, OwnerId, Owner.Name FROM TTI_Form__c WHERE recordTypeId = :Schema.SObjectType.TTI_Form__c.getRecordTypeInfosByName().get('Showroom Stock Request').getRecordTypeId() LIMIT 1];
            ApexPages.currentPage().getParameters().put('Id', ttiform.Id);
            
            Product2 productPAC = [SELECT Id, Name, SAP_Material_Group__c,Rounding_Profile_AU__c,Rounding_Profile_NZ__c,PAC__c,CAR__c FROM Product2 WHERE Rounding_Profile_NZ__c = 'YG01' AND PAC__c != NULL LIMIT 1];
            Product2 productCAR = [SELECT Id, Name, SAP_Material_Group__c,Rounding_Profile_AU__c,Rounding_Profile_NZ__c,PAC__c,CAR__c FROM Product2 WHERE Rounding_Profile_NZ__c = 'YG02' AND CAR__c != NULL LIMIT 1];
            
            TTI_Form_Product__c ttiFormProd = new TTI_Form_Product__c();
            ttiFormProd.Form_Number__c = ttiform.Id;
            ttiFormProd.SAP_Material_Number__c = productPAC.id;
            insert ttiFormProd;
            
            TTI_Form_Product__c ttiFormProd2 = new TTI_Form_Product__c();
            ttiFormProd2.Form_Number__c = ttiform.Id;
            ttiFormProd2.SAP_Material_Number__c = productCAR.id;
            insert ttiFormProd2;
            
            TTIFormProductCreateController cont = new TTIFormProductCreateController();
            //cont.save();
            //cont.cancel();
            Boolean hasNext = cont.hasNext;
            Boolean hasPrevious = cont.hasPrevious;
            
            TTIFormProductCreateController.productWrapper cmp = new TTIFormProductCreateController.productWrapper(productPAC);
            cmp.selected=true;
            cmp.quantity=2;
            /*TTIFormProductCreateController.productWrapper cmp2 = new TTIFormProductCreateController.productWrapper(productCAR);
            cmp2.selected=true;
            cmp2.quantity=2;*/
            cont.prodWrap.add(cmp);
            //cont.prodWrap.add(cmp2);
            cont.searchString = 'prod';
            cont.save();
            //cont.search();
            //cont.next();
            //cont.previous();
            
            //TTI_Form_Product__c ttiFormProduct = [SELECT Id,SAP_Material_Number__c FROM TTI_Form_Product__c WHERE Form_Number__c = :ttiform.Id];
            //System.assertEquals(ttiFormProduct.SAP_Material_Number__c, product.Id);
        }
       
    }
    
   public static testMethod void testRoundingNZ_CAR() {
        User u2 = [SELECT Id FROM User WHERE username = 'teststandard2@testing.com'];
        
        System.runAs(u2) {
            PageReference pageRef = Page.TTIFormProductCreate;
            Test.setCurrentPage(pageRef);
            
            TTI_Form__c ttiform = [SELECT Id FROM TTI_Form__c WHERE recordTypeId = :Schema.SObjectType.TTI_Form__c.getRecordTypeInfosByName().get('Promo Stock Request').getRecordTypeId() LIMIT 1];
            ApexPages.currentPage().getParameters().put('Id', ttiform.Id);
            
            Product2 productPAC = [SELECT Id, Name, SAP_Material_Group__c,Rounding_Profile_AU__c,Rounding_Profile_NZ__c,PAC__c,CAR__c FROM Product2 WHERE Rounding_Profile_NZ__c = 'YG01' AND PAC__c != NULL LIMIT 1];
            Product2 productCAR = [SELECT Id, Name, SAP_Material_Group__c,Rounding_Profile_AU__c,Rounding_Profile_NZ__c,PAC__c,CAR__c FROM Product2 WHERE Rounding_Profile_NZ__c = 'YG02' AND CAR__c != NULL LIMIT 1];
            
            /*TTI_Form_Product__c ttiFormProd = new TTI_Form_Product__c();
            ttiFormProd.Form_Number__c = ttiform.Id;
            ttiFormProd.SAP_Material_Number__c = productPAC.id;
            insert ttiFormProd;*/
            
            TTI_Form_Product__c ttiFormProd2 = new TTI_Form_Product__c();
            ttiFormProd2.Form_Number__c = ttiform.Id;
            ttiFormProd2.SAP_Material_Number__c = productCAR.id;
            insert ttiFormProd2;
            
            TTIFormProductCreateController cont = new TTIFormProductCreateController();
            //cont.save();
            //cont.cancel();
            Boolean hasNext = cont.hasNext;
            Boolean hasPrevious = cont.hasPrevious;
            
            /*TTIFormProductCreateController.productWrapper cmp = new TTIFormProductCreateController.productWrapper(productPAC);
            cmp.selected=true;
            cmp.quantity=2;*/
            TTIFormProductCreateController.productWrapper cmp2 = new TTIFormProductCreateController.productWrapper(productCAR);
            cmp2.selected=true;
            cmp2.quantity=2;
            //cont.prodWrap.add(cmp);
            cont.prodWrap.add(cmp2);
            cont.searchString = 'prod';
            cont.save();
            //cont.search();
            //cont.next();
            //cont.previous();
            
            //TTI_Form_Product__c ttiFormProduct = [SELECT Id,SAP_Material_Number__c FROM TTI_Form_Product__c WHERE Form_Number__c = :ttiform.Id];
            //System.assertEquals(ttiFormProduct.SAP_Material_Number__c, product.Id);
        }
       
    }    

}