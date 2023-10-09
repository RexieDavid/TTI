@isTest
public class TTI_SubmitClaimTracker {
    
    static testmethod void Test1(){
       
      Id SerVagTypeIdqw = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Industry Association').getRecordTypeId();
        Id b2cRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Consumer Contact').getRecordTypeId();
        Account Accnt = new Account();
            Accnt.RecordTypeID=b2cRecTypeId;
            Accnt.FirstName='Test';
            Accnt.LastName='Saas';
            Accnt.PersonEmail='test@rest.com';
            Accnt.PersonMobilePhone='06423432442445';
            Accnt.Brand__pc='Ryobi';
            Accnt.Record_Status__c='Active';
            insert Accnt;
        
        Account accObj = TTI_CommonUtilityClass.createAccount();
        
        Contact objCon = TTI_CommonUtilityClass.createContact();
        insert objCon;  
        TTI_CommonUtilityClass.insertTemplates();
        Product2 prod = new Product2(Name = 'Laptop X200', Family = 'Hardware');
        insert prod;
        User u = TTI_CommonUtilityClass.createUser();
        u.ContactId = objCon.Id;
        u.isActive = true;
        insert u;
        
            
        
         Test.startTest();
        system.runAs(u){
           
            Asset objAsset = new Asset(Name = 'Test', 
                                       AccountId = accObj.Id, 
                                       ContactId = objCon.id, 
                                       Product2Id = prod.Id, 
                                       Allow_Numbers_Only__c = true, 
                                       Display_Week__c = true, 
                                       Display_Year__c = true,
                                       HelpText__c = 'Test Helper Text',
                                       Regexpression_Validator__c = 'Exp',
                                       Serial_Number_Length__c = 20,
                                       SerialNumber='1123454');
            insert objAsset;
            Contact ObjConTNotIn1 = new Contact();
            //ObjConTNotIn.Accountid=objAc1.id;
            ObjConTNotIn1.MobilePhone = '06423432442445';
            ObjConTNotIn1.Email = 'test@rest.com';
            ObjConTNotIn1.FirstName = 'Test';
            ObjConTNotIn1.LastName = 'Saas';
            //insert ObjConTNotIn;
            
            Case caseObj = TTI_CommonUtilityClass.createCase();
            
            caseObj.Diagnosed_Date__c = System.today().addDays(-3);
            caseObj.Product_Payment_Category__c = 'Generators';
            caseObj.Repair_Type__c = 'Declined Warranty - Inspection fee';
            caseObj.Claim_Type__c = 'Warranty';
            caseObj.Purchase_Date__c = System.today().addDays(-10);
            caseObj.Service_Request_Milestone__c = 'New';
            caseObj.Closed_Reason__c = 'Service Request Completed';
            caseObj.TTI_Email_Notification_Opt_In__c = true;
            caseObj.TTI_Customer_Contact__c = objCon.Id;
            caseObj.Invoiced_Approved__c = false;
            caseObj.SuppliedEmail = 'test@test.com';
            caseObj.Service_Agent__c = accObj.Id;
            
            Case caseObj1 = TTI_CommonUtilityClass.createCase();
            caseObj1.TTI_Freight_In_Required__c=true;
            caseObj1.Diagnosed_Date__c = System.today().addDays(-3);
            caseObj1.Product_Payment_Category__c = 'Generators';
            caseObj1.Repair_Type__c = 'Declined Warranty - Inspection fee';
            caseObj1.Claim_Type__c = 'Warranty';
            caseObj1.Service_Request_Milestone__c = 'New';
            caseObj1.Closed_Reason__c = 'Service Request Completed';
            caseObj1.TTI_Email_Notification_Opt_In__c = true;
            caseObj1.TTI_Customer_Contact__c = objCon.Id;
            caseObj1.Invoiced_Approved__c = false;
            caseObj1.Brand__c = 'Ryobi';
            caseObj1.Serial_Number__c = '1123454';
            caseObj1.Product_Name__c =prod.Id ;
            caseObj1.SuppliedEmail = 'test@test.com';
            caseObj1.Service_Agent__c = accObj.Id;
            insert caseObj1;
            
            Attachment objatt1= new Attachment();
            objatt1.Name = caseObj1.CaseNumber+'_Quote.pdf';
            objatt1.Body = Blob.valueof('QWERTRERTYTRT');
            objatt1.parentId = caseObj1.id;
            insert objatt1;
            Asset obj=TTI_SubmtClaimController.assetCheck('1123454' , prod.Id,objCon.Id);
            Id CaseRet1Id=TTI_SubmtClaimController.saveClaimDetails(caseObj1,objAsset,24,ObjConTNotIn1,False);
            //Case CaseRet1= ((Case)JSON.deserialize(TTI_SubmtClaimController.saveClaimDetails(caseObj1,objAsset,24,ObjConTNotIn1,False),Case.class));
            TTI_SubmtClaimController.handleEmailAndAttachment(CaseRet1Id);
            TTI_ServiceRequestController.openReceiptPdf(CaseRet1Id);
       
            
        }
             Test.stopTest();
    }
    
    Private static testmethod void Test3(){
        Id SerVagTypeIdqw = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Industry Association').getRecordTypeId();
        Id b2cRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Consumer Contact').getRecordTypeId();
        
        Account objAc1= new Account();
        objAc1.RecordTypeId = b2cRecTypeId;
        objAc1.LastName = 'Saas1';
        objAc1.FirstName = 'Test1';
        objAc1.PersonEmail = 'test@rest.com';
        objAc1.PersonMobilePhone = '06423432442445';
        objAc1.Brand__pc = 'Ryobi';
        objAc1.Brands__c = 'Ryobi'+';';
        objAc1.Record_Status__c = 'Active';


        insert objAc1;

        Account Accnt = new Account();
        Accnt.RecordTypeID=b2cRecTypeId;
        Accnt.FirstName='Test';
        Accnt.LastName='Saas';
        Accnt.PersonEmail='test@rest1.com';
        Accnt.PersonMobilePhone='06423432442445';
        Accnt.Brand__pc='Ryobi';
        Accnt.Record_Status__c='Active';
        insert Accnt;      

        Account accObj = TTI_CommonUtilityClass.createAccount();
        Contact objCon = TTI_CommonUtilityClass.createContact();
        insert objCon;  
        TTI_CommonUtilityClass.insertTemplates();
        Product2 prod = new Product2(Name = 'Laptop X200', Family = 'Hardware');
        insert prod;
        User u = TTI_CommonUtilityClass.createUser();
        u.ContactId = objCon.Id;
        insert u;
          
        Case CaseRet1;
        Test.startTest();
        system.runAs(u){
            Asset objAsset = new Asset(Name = 'Test', 
                                       AccountId = accObj.Id, 
                                       ContactId = objCon.id, 
                                       Product2Id = prod.Id, 
                                       Allow_Numbers_Only__c = true, 
                                       Display_Week__c = true, 
                                       Display_Year__c = true,
                                       HelpText__c = 'Test Helper Text',
                                       Regexpression_Validator__c = 'Exp',
                                       Serial_Number_Length__c = 20,
                                       SerialNumber='1123454');
            insert objAsset;
            Contact ObjConTNotIn = new Contact();
            ObjConTNotIn.Accountid=objAc1.id;
            ObjConTNotIn.MobilePhone = '06423432442445';
            ObjConTNotIn.FirstName = 'Test';
            ObjConTNotIn.LastName = 'Saas';
            ObjConTNotIn.Email = 'testtest23@test.com';
            Case caseObj = TTI_CommonUtilityClass.createCase();
            
            caseObj.Diagnosed_Date__c = System.today().addDays(-3);
            caseObj.Product_Payment_Category__c = 'Generators';
            caseObj.Repair_Type__c = 'Declined Warranty - Inspection fee';
            caseObj.Claim_Type__c = 'Warranty';
            caseObj.Purchase_Date__c = System.today().addDays(-10);
            caseObj.Service_Request_Milestone__c = 'New';
            caseObj.Closed_Reason__c = 'Service Request Completed';
            caseObj.TTI_Email_Notification_Opt_In__c = true;
            caseObj.TTI_Customer_Contact__c = ObjConTNotIn.Id;
            caseObj.Invoiced_Approved__c = false;
            caseObj.SuppliedEmail = 'test@test.com';
            caseObj.Brand__c = 'Ryobi';
            Id CaseRet1Id= TTI_SubmtClaimController.saveClaimDetails(caseObj,objAsset,24,ObjConTNotIn,True);
            //CaseRet1= ((Case)JSON.deserialize(TTI_SubmtClaimController.saveClaimDetails(caseObj,objAsset,24,ObjConTNotIn,True),Case.class));
            
            TTI_ServiceRequestController.handleEmailPart(CaseRet1Id, 'QuoteGeneration');
            
        }
        Test.stopTest();
        
        
        
    }
    /*
    Private static testmethod void Test2(){
        
        Id b2cRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Consumer Contact').getRecordTypeId();
        Id SerVagTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Agent').getRecordTypeId();
        Id SerVagTypeIdqw = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Industry Association').getRecordTypeId();
        Account objAc1= new Account();
        objAc1.RecordTypeId=SerVagTypeIdqw ;
        objAc1.Name = 'Saas1';
        objAc1.Record_Status__c = 'Active';
        insert objAc1;
        
        Contact objCon12 = new Contact();
        objCon12.FirstName= 'Saastest'; 
        objCon12.AccountId = objAc1.id;
        objCon12.LastName ='TestSaasaess';
        objCon12.Email = 'test@rest.com';
        objCon12.MobilePhone = '06423432442445';
        insert objCon12;
        Account objPersonAcc = new Account();
        objPersonAcc.RecordTypeId = b2cRecTypeId;
        objPersonAcc.LastName = 'Saas1';
        objPersonAcc.FirstName = 'Test1';
        objPersonAcc.PersonEmail = 'test@rest.com';
        objPersonAcc.PersonMobilePhone = '06423432442445';
        objPersonAcc.Brand__pc = 'Ryobi';
        objPersonAcc.Brands__c = 'Ryobi'+';';
        objPersonAcc.Record_Status__c = 'Active';
        insert objPersonAcc;
        
        Account objPersonAcc1 = new Account();
        objPersonAcc1.RecordTypeId = SerVagTypeId;
        objPersonAcc1.Name= 'Saastest TestSaasaess';
        insert objPersonAcc1;
        objPersonAcc1.Service_Agent_Status__c ='Gold';
        objPersonAcc1.Brands__c = 'Dirt Devil'+';';
        objPersonAcc1.Record_Status__c = 'Active';
        objPersonAcc1.ShippingStreet ='Sector-58';
        objPersonAcc1.ShippingCity='noida';
        objPersonAcc1.ShippingCountry='India';
        objPersonAcc1.ShippingState='NSW';
        objPersonAcc1.ShippingPostalCode ='201301';
        objPersonAcc1.Delivery_Street__c='Sector-58';
        objPersonAcc1.Delivery_Suburb__c='noida'; 
        objPersonAcc1.Delivery_State__c='Uttar pradesh';
        objPersonAcc1.Delivery_Postcode__c ='201301';
        objPersonAcc1.Services_DirtDevil_Brands__c=true;
        objPersonAcc1.Dirtdevil_Products__c='Floorcare - Commercial;';
        update objPersonAcc1;
        
        
        Account accObj = TTI_CommonUtilityClass.createAccount();
        Contact objCon = TTI_CommonUtilityClass.createContact();
        insert objCon;  
        TTI_CommonUtilityClass.insertTemplates();
        Product2 prod = new Product2(Name = 'Laptop X200', Family = 'Hardware',Locator_Category__c='Floorcare - Domestic');
        insert prod;
        User u = TTI_CommonUtilityClass.createUser();
        u.ContactId = objCon.Id;
        insert u;
        
        system.runAs(u){
            Asset objAsset = new Asset(Name = 'Test', 
                                       AccountId = accObj.Id, 
                                       ContactId = objCon.id, 
                                       Product2Id = prod.Id, 
                                       Allow_Numbers_Only__c = true, 
                                       Display_Week__c = true, 
                                       Display_Year__c = true,
                                       HelpText__c = 'Test Helper Text',
                                       Regexpression_Validator__c = 'Exp',
                                       Serial_Number_Length__c = 20,
                                       SerialNumber='1123454');
            insert objAsset;
            
            Contact objCon123 = new Contact(id=objCon12.id);
            objCon123.FirstName= 'Saastesttestinf'; 
            objCon123.AccountId = objAc1.id;
            objCon123.LastName ='TeswerttSaasaess';
            objCon123.Email = 'test@rest.com';
            objCon123.MobilePhone = '06423432442445';
            //insert objCon123;
            
            Case caseObj = TTI_CommonUtilityClass.createCase();
            
            caseObj.Diagnosed_Date__c = System.today().addDays(-3);
            caseObj.Product_Payment_Category__c = 'Generators';
            caseObj.Repair_Type__c = 'Declined Warranty - Inspection fee';
            caseObj.Claim_Type__c = 'Warranty';
            caseObj.Purchase_Date__c = System.today().addDays(-10);
            caseObj.Service_Request_Milestone__c = 'New';
            caseObj.Closed_Reason__c = 'Service Request Completed';
            caseObj.TTI_Email_Notification_Opt_In__c = true;
            caseObj.TTI_Customer_Contact__c = objCon.Id;
            caseObj.Invoiced_Approved__c = false;
            caseObj.SuppliedEmail = 'test@test.com';
            String str= TTI_SubmtClaimController.searchNearByLocation('201301','Dirt Devil',prod,'India','All',50);
            Id CaseRet2Id= TTI_SubmtClaimController.saveClaimDetails(caseObj,objAsset,24,objCon123,False);
            //Case CaseRet2= ((Case)JSON.deserialize(TTI_SubmtClaimController.saveClaimDetails(caseObj,objAsset,24,objCon123,False),Case.class));
            TTI_ServiceRequestController.handleEmailPart(CaseRet2Id, 'JobSummaryGeneration');
        }
        
    }
    
    Private static testmethod void Test4(){
        Id SerVagTypeIdqw = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Industry Association').getRecordTypeId();
        Id b2cRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Consumer Contact').getRecordTypeId();
        Account objAc1= new Account();
        objAc1.RecordTypeId = b2cRecTypeId;
        objAc1.LastName = 'Saas1';
        objAc1.FirstName = 'Test1';
        objAc1.PersonEmail = 'test@rest.com';
        objAc1.PersonMobilePhone = '06423432442445';
        objAc1.Brand__pc = 'Ryobi';
        objAc1.Brands__c = 'Ryobi'+';';
        objAc1.Record_Status__c = 'Active';
        insert objAc1;
        Account accObj = TTI_CommonUtilityClass.createAccount();
        Contact objCon = TTI_CommonUtilityClass.createContact();
        insert objCon;  
        list<TTI_Template__c> template = new list<TTI_Template__c>(); 
        TTI_Template__c consignmentNoteTemplate = new TTI_Template__c();
        consignmentNoteTemplate.Name = 'ConsignmentNoteTemplate';
        consignmentNoteTemplate.Approved_Claim_Notification_Template__c = 'NotificationContainingFreightCompanyConsignmentNoteTemplate';
        template.add(consignmentNoteTemplate);
        
        TTI_Template__c consignmentOutNoteTemplate = new TTI_Template__c();
        consignmentOutNoteTemplate.Name = 'ConsignmentNoteTemplateFreightOut';
        consignmentOutNoteTemplate.Approved_Claim_Notification_Template__c = 'NotificationContainingFreightOutCompanyConsignmentNoteTemplate';
        template.add(consignmentOutNoteTemplate);
        
        TTI_Template__c rejectedWarrantyClaimTemplate = new TTI_Template__c();
        rejectedWarrantyClaimTemplate.Name = 'TTI_RejectedWarrantyClaimTemplate';
        rejectedWarrantyClaimTemplate.Approved_Claim_Notification_Template__c = 'TTI_RejectedWarrantyClaimTemplate';
        template.add(rejectedWarrantyClaimTemplate);
        
        TTI_Template__c warrantyClaimApprovedNotification = new TTI_Template__c();
        warrantyClaimApprovedNotification.Name = 'TTI_WarrantyClaimApprovedNotification';
        warrantyClaimApprovedNotification.Approved_Claim_Notification_Template__c = 'TTI_WarrantyClaimApprovedNotification';
        template.add(warrantyClaimApprovedNotification);
        
        TTI_Template__c emailsentToTheServiceAgentTemplate = new TTI_Template__c();
        emailsentToTheServiceAgentTemplate.Name = 'TTI_EmailsentToTheServiceAgentTemplate';
        emailsentToTheServiceAgentTemplate.Approved_Claim_Notification_Template__c = '';
        template.add(emailsentToTheServiceAgentTemplate);
        
        TTI_Template__c rejectedNonWarrantyClaimToCustomer = new TTI_Template__c();
        rejectedNonWarrantyClaimToCustomer.Name = 'TTI_RejectedNonWarrantyClaimToCustomer';
        rejectedNonWarrantyClaimToCustomer.Approved_Claim_Notification_Template__c = 'TTI_RejectedNonWarrantyClaimToCustomer';
        template.add(rejectedNonWarrantyClaimToCustomer);
        
        insert template;
        Product2 prod = new Product2(Name = 'Laptop X200', Family = 'Hardware');
        insert prod;
        User u = TTI_CommonUtilityClass.createUser();
        u.ContactId = objCon.Id;
        insert u;
        
        system.runAs(u){
            Asset objAsset = new Asset(Name = 'Test', 
                                       AccountId = accObj.Id, 
                                       ContactId = objCon.id, 
                                       Product2Id = prod.Id, 
                                       Allow_Numbers_Only__c = true, 
                                       Display_Week__c = true, 
                                       Display_Year__c = true,
                                       HelpText__c = 'Test Helper Text',
                                       Regexpression_Validator__c = 'Exp',
                                       Serial_Number_Length__c = 20,
                                       SerialNumber='1123454');
            insert objAsset;
            Contact ObjConTNotIn = new Contact();
            ObjConTNotIn.Accountid=objAc1.id;
            //ObjConTNotIn.MobilePhone = '06423432442445';
            ObjConTNotIn.Email = 'test@rest.com';
            ObjConTNotIn.FirstName = 'Test';
            ObjConTNotIn.LastName = 'Saas';
            //insert ObjConTNotIn;
            Contact objold=new Contact();
            objold.Accountid=objAc1.id;
            objold.MobilePhone = '06423432442445';
            objold.Email = 'test@rest.com';
            objold.FirstName = 'Test';
            objold.LastName = 'Saas';
            //insert objold;
            Case caseObj = TTI_CommonUtilityClass.createCase();
            
            caseObj.Diagnosed_Date__c = System.today().addDays(-3);
            caseObj.Product_Payment_Category__c = 'Generators';
            caseObj.Repair_Type__c = 'Declined Warranty - Inspection fee';
            caseObj.Claim_Type__c = 'Warranty';
            caseObj.Purchase_Date__c = System.today().addDays(-10);
            caseObj.Service_Request_Milestone__c = 'New';
            caseObj.Closed_Reason__c = 'Service Request Completed';
            caseObj.TTI_Email_Notification_Opt_In__c = true;
            caseObj.TTI_Customer_Contact__c = objCon.Id;
            caseObj.Invoiced_Approved__c = false;
            caseObj.SuppliedEmail = 'test@test.com';
            ObjConTNotIn.LastName = 'Saas';
            ObjConTNotIn.MobilePhone = '06423432442445';
            ObjConTNotIn.Email = 'test@rest.com';
            TTI_SubmtClaimController.saveClaimDetails(caseObj,objAsset,24,ObjConTNotIn,True);
            //Case CaseRet2= ((Case)JSON.deserialize(TTI_SubmtClaimController.saveClaimDetails(caseObj,objAsset,24,ObjConTNotIn,True),Case.class));
            
        }
    }
    
    Private static testmethod void Test5(){
        Id SerVagTypeIdqw = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Industry Association').getRecordTypeId();
        Id b2cRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Consumer Contact').getRecordTypeId();
        Account objAc1= new Account();
        objAc1.RecordTypeId = b2cRecTypeId;
        objAc1.LastName = 'Saas1';
        objAc1.FirstName = 'Test1';
        objAc1.PersonEmail = 'test@rest.com';
        objAc1.PersonMobilePhone = '06423432442445';
        objAc1.Brand__pc = 'Ryobi';
        objAc1.Brands__c = 'Ryobi'+';';
        objAc1.Record_Status__c = 'Active';
        insert objAc1;
        Account accObj = TTI_CommonUtilityClass.createAccount();
        Contact objCon = TTI_CommonUtilityClass.createContact();
        insert objCon;  
        list<TTI_Template__c> template = new list<TTI_Template__c>(); 
        TTI_Template__c consignmentNoteTemplate = new TTI_Template__c();
        consignmentNoteTemplate.Name = 'ConsignmentNoteTemplate';
        consignmentNoteTemplate.Approved_Claim_Notification_Template__c = 'NotificationContainingFreightCompanyConsignmentNoteTemplate';
        template.add(consignmentNoteTemplate);
        
        TTI_Template__c consignmentOutNoteTemplate = new TTI_Template__c();
        consignmentOutNoteTemplate.Name = 'ConsignmentNoteTemplateFreightOut';
        consignmentOutNoteTemplate.Approved_Claim_Notification_Template__c = 'NotificationContainingFreightOutCompanyConsignmentNoteTemplate';
        template.add(consignmentOutNoteTemplate);
        
        TTI_Template__c rejectedWarrantyClaimTemplate = new TTI_Template__c();
        rejectedWarrantyClaimTemplate.Name = 'TTI_RejectedWarrantyClaimTemplate';
        rejectedWarrantyClaimTemplate.Approved_Claim_Notification_Template__c = 'TTI_RejectedWarrantyClaimTemplate';
        template.add(rejectedWarrantyClaimTemplate);
        
        TTI_Template__c warrantyClaimApprovedNotification = new TTI_Template__c();
        warrantyClaimApprovedNotification.Name = 'TTI_WarrantyClaimApprovedNotification';
        warrantyClaimApprovedNotification.Approved_Claim_Notification_Template__c = 'TTI_WarrantyClaimApprovedNotification';
        template.add(warrantyClaimApprovedNotification);
        
        TTI_Template__c emailsentToTheServiceAgentTemplate = new TTI_Template__c();
        emailsentToTheServiceAgentTemplate.Name = 'TTI_EmailsentToTheServiceAgentTemplate';
        emailsentToTheServiceAgentTemplate.Approved_Claim_Notification_Template__c = '';
        template.add(emailsentToTheServiceAgentTemplate);
        
        TTI_Template__c rejectedNonWarrantyClaimToCustomer = new TTI_Template__c();
        rejectedNonWarrantyClaimToCustomer.Name = 'TTI_RejectedNonWarrantyClaimToCustomer';
        rejectedNonWarrantyClaimToCustomer.Approved_Claim_Notification_Template__c = 'TTI_RejectedNonWarrantyClaimToCustomer';
        template.add(rejectedNonWarrantyClaimToCustomer);
        
        insert template;
        Product2 prod = new Product2(Name = 'Laptop X200', Family = 'Hardware');
        insert prod;
        User u = TTI_CommonUtilityClass.createUser();
        u.ContactId = objCon.Id;
        insert u;
        
        system.runAs(u){
            Asset objAsset = new Asset(Name = 'Test', 
                                       AccountId = accObj.Id, 
                                       ContactId = objCon.id, 
                                       Product2Id = prod.Id, 
                                       Allow_Numbers_Only__c = true, 
                                       Display_Week__c = true, 
                                       Display_Year__c = true,
                                       HelpText__c = 'Test Helper Text',
                                       Regexpression_Validator__c = 'Exp',
                                       Serial_Number_Length__c = 20,
                                       SerialNumber='1123454');
            insert objAsset;
            Contact ObjConTNotIn = new Contact();
            ObjConTNotIn.Accountid=objAc1.id;
            ObjConTNotIn.FirstName = 'Test';
            ObjConTNotIn.LastName = 'Saas';
            Contact objold=new Contact();
            objold.Accountid=objAc1.id;
            objold.MobilePhone = '06423432442445';
            objold.Email = 'test@rest.com';
            objold.FirstName = 'Test';
            objold.LastName = 'Saas';
            Case caseObj = TTI_CommonUtilityClass.createCase();
            
            caseObj.Diagnosed_Date__c = System.today().addDays(-3);
            caseObj.Product_Payment_Category__c = 'Generators';
            caseObj.Repair_Type__c = 'Declined Warranty - Inspection fee';
            caseObj.Claim_Type__c = 'Warranty';
            caseObj.Purchase_Date__c = System.today().addDays(-10);
            caseObj.Service_Request_Milestone__c = 'New';
            caseObj.Closed_Reason__c = 'Service Request Completed';
            caseObj.TTI_Email_Notification_Opt_In__c = true;
            caseObj.TTI_Customer_Contact__c = objCon.Id;
            caseObj.Invoiced_Approved__c = false;
            caseObj.SuppliedEmail = 'test@test.com';
            
            
            ObjConTNotIn.LastName = 'Saas';
            ObjConTNotIn.MobilePhone = '06423432442445';
            TTI_SubmtClaimController.saveClaimDetails(caseObj,objAsset,24,ObjConTNotIn,True);
            //Case CaseRet3= ((Case)JSON.deserialize(TTI_SubmtClaimController.saveClaimDetails(caseObj,objAsset,24,ObjConTNotIn,True),Case.class));
        }
    }
    
    Private static testmethod void Test6(){
        Account accObj = TTI_CommonUtilityClass.createAccount();
        Contact objCon = TTI_CommonUtilityClass.createContact();
        insert objCon;  
        list<TTI_Template__c> template = new list<TTI_Template__c>(); 
        TTI_Template__c consignmentNoteTemplate = new TTI_Template__c();
        consignmentNoteTemplate.Name = 'ConsignmentNoteTemplate';
        consignmentNoteTemplate.Approved_Claim_Notification_Template__c = 'NotificationContainingFreightCompanyConsignmentNoteTemplate';
        template.add(consignmentNoteTemplate);
        
        TTI_Template__c consignmentOutNoteTemplate = new TTI_Template__c();
        consignmentOutNoteTemplate.Name = 'ConsignmentNoteTemplateFreightOut';
        consignmentOutNoteTemplate.Approved_Claim_Notification_Template__c = 'NotificationContainingFreightOutCompanyConsignmentNoteTemplate';
        template.add(consignmentOutNoteTemplate);
        
        TTI_Template__c rejectedWarrantyClaimTemplate = new TTI_Template__c();
        rejectedWarrantyClaimTemplate.Name = 'TTI_RejectedWarrantyClaimTemplate';
        rejectedWarrantyClaimTemplate.Approved_Claim_Notification_Template__c = 'TTI_RejectedWarrantyClaimTemplate';
        template.add(rejectedWarrantyClaimTemplate);
        
        TTI_Template__c warrantyClaimApprovedNotification = new TTI_Template__c();
        warrantyClaimApprovedNotification.Name = 'TTI_WarrantyClaimApprovedNotification';
        warrantyClaimApprovedNotification.Approved_Claim_Notification_Template__c = 'TTI_WarrantyClaimApprovedNotification';
        template.add(warrantyClaimApprovedNotification);
        
        TTI_Template__c emailsentToTheServiceAgentTemplate = new TTI_Template__c();
        emailsentToTheServiceAgentTemplate.Name = 'TTI_EmailsentToTheServiceAgentTemplate';
        emailsentToTheServiceAgentTemplate.Approved_Claim_Notification_Template__c = '';
        template.add(emailsentToTheServiceAgentTemplate);
        
        TTI_Template__c rejectedNonWarrantyClaimToCustomer = new TTI_Template__c();
        rejectedNonWarrantyClaimToCustomer.Name = 'TTI_RejectedNonWarrantyClaimToCustomer';
        rejectedNonWarrantyClaimToCustomer.Approved_Claim_Notification_Template__c = 'TTI_RejectedNonWarrantyClaimToCustomer';
        template.add(rejectedNonWarrantyClaimToCustomer);
        
        insert template;
        Product2 prod = new Product2(Name = 'Laptop X200', Family = 'Hardware');
        insert prod;
        User u = TTI_CommonUtilityClass.createUser();
        u.ContactId = objCon.Id;
        insert u;
        
        system.runAs(u){
            Asset objAsset = new Asset(Name = 'Test', 
                                       AccountId = accObj.Id, 
                                       ContactId = objCon.id, 
                                       Product2Id = prod.Id, 
                                       Allow_Numbers_Only__c = true, 
                                       Display_Week__c = true, 
                                       Display_Year__c = true,
                                       HelpText__c = 'Test Helper Text',
                                       Regexpression_Validator__c = 'Exp',
                                       Serial_Number_Length__c = 20,
                                       SerialNumber='1123454');
            insert objAsset;
            Contact ObjConTNotIn = new Contact();
            //ObjConTNotIn.Accountid=objAc1.id;
            ObjConTNotIn.Email = 'test@rest.com';
            ObjConTNotIn.FirstName = 'Test';
            ObjConTNotIn.LastName = 'Saas';
            Id SerVagTypeIdqw = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Industry Association').getRecordTypeId();
            Id b2cRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Consumer Contact').getRecordTypeId();
            Account objAc1= new Account();
            objAc1.RecordTypeId = SerVagTypeIdqw;
            objAc1.Name = 'Saas1';
            objAc1.Record_Status__c='Active';
            objAc1.Type = 'Comsumer Company';
            //objAc1.Record_Status__c = 'Active';
            insert objAc1;
            Contact objold=new Contact();
            objold.Accountid=objAc1.id;
            objold.MobilePhone = '06423432442445';
            objold.Email = 'test@rest.com';
            objold.FirstName = 'Test';
            objold.LastName = 'Saas';
            insert objold;
            objold.Accountid=objAc1.id;
            update objold;
            Case caseObj = TTI_CommonUtilityClass.createCase();
            
            caseObj.Diagnosed_Date__c = System.today().addDays(-3);
            caseObj.Product_Payment_Category__c = 'Generators';
            caseObj.Repair_Type__c = 'Declined Warranty - Inspection fee';
            caseObj.Claim_Type__c = 'Warranty';
            caseObj.Purchase_Date__c = System.today().addDays(-10);
            caseObj.Service_Request_Milestone__c = 'New';
            caseObj.Closed_Reason__c = 'Service Request Completed';
            caseObj.TTI_Email_Notification_Opt_In__c = true;
            caseObj.TTI_Customer_Contact__c = objCon.Id;
            caseObj.Invoiced_Approved__c = false;
            caseObj.SuppliedEmail = 'test@test.com';
            
            TTI_SubmtClaimController.saveClaimDetails(caseObj,objAsset,24,ObjConTNotIn,True);
            //Case CaseRet1= ((Case)JSON.deserialize(TTI_SubmtClaimController.saveClaimDetails(caseObj,objAsset,24,ObjConTNotIn,True),Case.class));
        }
    }
    Private static testmethod void Test7(){
        Account accObj = TTI_CommonUtilityClass.createAccount();
        Contact objCon = TTI_CommonUtilityClass.createContact();
        insert objCon;  
        list<TTI_Template__c> template = new list<TTI_Template__c>(); 
        TTI_Template__c consignmentNoteTemplate = new TTI_Template__c();
        consignmentNoteTemplate.Name = 'ConsignmentNoteTemplate';
        consignmentNoteTemplate.Approved_Claim_Notification_Template__c = 'NotificationContainingFreightCompanyConsignmentNoteTemplate';
        template.add(consignmentNoteTemplate);
        
        TTI_Template__c consignmentOutNoteTemplate = new TTI_Template__c();
        consignmentOutNoteTemplate.Name = 'ConsignmentNoteTemplateFreightOut';
        consignmentOutNoteTemplate.Approved_Claim_Notification_Template__c = 'NotificationContainingFreightOutCompanyConsignmentNoteTemplate';
        template.add(consignmentOutNoteTemplate);
        
        TTI_Template__c rejectedWarrantyClaimTemplate = new TTI_Template__c();
        rejectedWarrantyClaimTemplate.Name = 'TTI_RejectedWarrantyClaimTemplate';
        rejectedWarrantyClaimTemplate.Approved_Claim_Notification_Template__c = 'TTI_RejectedWarrantyClaimTemplate';
        template.add(rejectedWarrantyClaimTemplate);
        
        TTI_Template__c warrantyClaimApprovedNotification = new TTI_Template__c();
        warrantyClaimApprovedNotification.Name = 'TTI_WarrantyClaimApprovedNotification';
        warrantyClaimApprovedNotification.Approved_Claim_Notification_Template__c = 'TTI_WarrantyClaimApprovedNotification';
        template.add(warrantyClaimApprovedNotification);
        
        TTI_Template__c emailsentToTheServiceAgentTemplate = new TTI_Template__c();
        emailsentToTheServiceAgentTemplate.Name = 'TTI_EmailsentToTheServiceAgentTemplate';
        emailsentToTheServiceAgentTemplate.Approved_Claim_Notification_Template__c = '';
        template.add(emailsentToTheServiceAgentTemplate);
        
        TTI_Template__c rejectedNonWarrantyClaimToCustomer = new TTI_Template__c();
        rejectedNonWarrantyClaimToCustomer.Name = 'TTI_RejectedNonWarrantyClaimToCustomer';
        rejectedNonWarrantyClaimToCustomer.Approved_Claim_Notification_Template__c = 'TTI_RejectedNonWarrantyClaimToCustomer';
        template.add(rejectedNonWarrantyClaimToCustomer);
        
        insert template;
        Product2 prod = new Product2(Name = 'Laptop X200', Family = 'Hardware');
        insert prod;
        User u = TTI_CommonUtilityClass.createUser();
        u.ContactId = objCon.Id;
        insert u;
        
        system.runAs(u){
            Asset objAsset = new Asset(Name = 'Test', 
                                       AccountId = accObj.Id, 
                                       ContactId = objCon.id, 
                                       Product2Id = prod.Id, 
                                       Allow_Numbers_Only__c = true, 
                                       Display_Week__c = true, 
                                       Display_Year__c = true,
                                       HelpText__c = 'Test Helper Text',
                                       Regexpression_Validator__c = 'Exp',
                                       Serial_Number_Length__c = 20,
                                       SerialNumber='1123454');
            insert objAsset;
            Contact ObjConTNotIn = new Contact();
            // ObjConTNotIn.Accountid=objAc1.id;
            //ObjConTNotIn.MobilePhone = '06423432442445';
            ObjConTNotIn.Email = 'test@rest.com';
            ObjConTNotIn.FirstName = 'Test';
            ObjConTNotIn.LastName = 'Saas';
            //insert ObjConTNotIn;
            Id SerVagTypeIdqw = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Industry Association').getRecordTypeId();
            Id b2cRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Consumer Contact').getRecordTypeId();
            Account objAc1= new Account();
            objAc1.RecordTypeId = SerVagTypeIdqw;
            objAc1.Name = 'Saas1';
            objAc1.Type = 'Comsumer Company';
            objAc1.Record_Status__c = 'Pending';
            insert objAc1;
            Contact objold=new Contact();
            //objold.Accountid=objAc1.id;
            objold.MobilePhone = '06423432442445';
            objold.Email = 'test@rest.com';
            objold.FirstName = 'Test';
            objold.LastName = 'Saas';
            insert objold;
            objold.Accountid=objAc1.id;
            update objold;
            Case caseObj = TTI_CommonUtilityClass.createCase();
            
            caseObj.Diagnosed_Date__c = System.today().addDays(-3);
            caseObj.Product_Payment_Category__c = 'Generators';
            caseObj.Repair_Type__c = 'Declined Warranty - Inspection fee';
            caseObj.Claim_Type__c = 'Warranty';
            caseObj.Purchase_Date__c = System.today().addDays(-10);
            caseObj.Service_Request_Milestone__c = 'New';
            caseObj.Closed_Reason__c = 'Service Request Completed';
            caseObj.TTI_Email_Notification_Opt_In__c = true;
            caseObj.TTI_Customer_Contact__c = objCon.Id;
            caseObj.Invoiced_Approved__c = false;
            caseObj.SuppliedEmail = 'test@test.com';
            ObjConTNotIn.LastName = 'Saas';
            ObjConTNotIn.LastName = 'FirstName';
            ObjConTNotIn.MobilePhone = '06423432442445';
            ObjConTNotIn.Email = 'test@rest.com';
            TTI_SubmtClaimController.saveClaimDetails(caseObj,objAsset,24,ObjConTNotIn,True);
            //Case CaseRet2= ((Case)JSON.deserialize(TTI_SubmtClaimController.saveClaimDetails(caseObj,objAsset,24,ObjConTNotIn,True),Case.class));
        }
    }
    
    Private static testmethod void Test8(){
        Account accObj = TTI_CommonUtilityClass.createAccount();
        Contact objCon = TTI_CommonUtilityClass.createContact();
        insert objCon;  
        list<TTI_Template__c> template = new list<TTI_Template__c>(); 
        TTI_Template__c consignmentNoteTemplate = new TTI_Template__c();
        consignmentNoteTemplate.Name = 'ConsignmentNoteTemplate';
        consignmentNoteTemplate.Approved_Claim_Notification_Template__c = 'NotificationContainingFreightCompanyConsignmentNoteTemplate';
        template.add(consignmentNoteTemplate);
        
        TTI_Template__c consignmentOutNoteTemplate = new TTI_Template__c();
        consignmentOutNoteTemplate.Name = 'ConsignmentNoteTemplateFreightOut';
        consignmentOutNoteTemplate.Approved_Claim_Notification_Template__c = 'NotificationContainingFreightOutCompanyConsignmentNoteTemplate';
        template.add(consignmentOutNoteTemplate);
        
        TTI_Template__c rejectedWarrantyClaimTemplate = new TTI_Template__c();
        rejectedWarrantyClaimTemplate.Name = 'TTI_RejectedWarrantyClaimTemplate';
        rejectedWarrantyClaimTemplate.Approved_Claim_Notification_Template__c = 'TTI_RejectedWarrantyClaimTemplate';
        template.add(rejectedWarrantyClaimTemplate);
        
        TTI_Template__c warrantyClaimApprovedNotification = new TTI_Template__c();
        warrantyClaimApprovedNotification.Name = 'TTI_WarrantyClaimApprovedNotification';
        warrantyClaimApprovedNotification.Approved_Claim_Notification_Template__c = 'TTI_WarrantyClaimApprovedNotification';
        template.add(warrantyClaimApprovedNotification);
        
        TTI_Template__c emailsentToTheServiceAgentTemplate = new TTI_Template__c();
        emailsentToTheServiceAgentTemplate.Name = 'TTI_EmailsentToTheServiceAgentTemplate';
        emailsentToTheServiceAgentTemplate.Approved_Claim_Notification_Template__c = '';
        template.add(emailsentToTheServiceAgentTemplate);
        
        TTI_Template__c rejectedNonWarrantyClaimToCustomer = new TTI_Template__c();
        rejectedNonWarrantyClaimToCustomer.Name = 'TTI_RejectedNonWarrantyClaimToCustomer';
        rejectedNonWarrantyClaimToCustomer.Approved_Claim_Notification_Template__c = 'TTI_RejectedNonWarrantyClaimToCustomer';
        template.add(rejectedNonWarrantyClaimToCustomer);
        
        insert template;
        Product2 prod = new Product2(Name = 'Laptop X200', Family = 'Hardware');
        insert prod;
        User u = TTI_CommonUtilityClass.createUser();
        u.ContactId = objCon.Id;
        insert u;
        
        system.runAs(u){
            Asset objAsset = new Asset(Name = 'Test', 
                                       AccountId = accObj.Id, 
                                       ContactId = objCon.id, 
                                       Product2Id = prod.Id, 
                                       Allow_Numbers_Only__c = true, 
                                       Display_Week__c = true, 
                                       Display_Year__c = true,
                                       HelpText__c = 'Test Helper Text',
                                       Regexpression_Validator__c = 'Exp',
                                       Serial_Number_Length__c = 20,
                                       SerialNumber='1123454');
            insert objAsset;
            Contact ObjConTNotIn = new Contact();
            //ObjConTNotIn.Accountid=objAc1.id;
            ObjConTNotIn.FirstName = 'Test';
            ObjConTNotIn.LastName = 'Saas';
            Id SerVagTypeIdqw = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Industry Association').getRecordTypeId();
            Id b2cRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Consumer Contact').getRecordTypeId();
            Account objAc1= new Account();
            objAc1.RecordTypeId = SerVagTypeIdqw;
            objAc1.Name = 'Saas1';
            objAc1.Record_Status__c='Active';
            objAc1.Type = 'Comsumer Company';
            insert objAc1;
            Contact objold=new Contact();
            objold.MobilePhone = '06423432442445';
            objold.FirstName = 'Test';
            objold.LastName = 'Saas';
            objold.Accountid=objAc1.id;
            insert objold;
            
            
            Case caseObj = TTI_CommonUtilityClass.createCase();
            
            caseObj.Diagnosed_Date__c = System.today().addDays(-3);
            caseObj.Product_Payment_Category__c = 'Generators';
            caseObj.Repair_Type__c = 'Declined Warranty - Inspection fee';
            caseObj.Claim_Type__c = 'Warranty';
            caseObj.Purchase_Date__c = System.today().addDays(-10);
            caseObj.Service_Request_Milestone__c = 'New';
            caseObj.Closed_Reason__c = 'Service Request Completed';
            caseObj.TTI_Email_Notification_Opt_In__c = true;
            caseObj.TTI_Customer_Contact__c = objCon.Id;
            caseObj.Invoiced_Approved__c = false;
            caseObj.SuppliedEmail = 'test@test.com';
            
            
            ObjConTNotIn.LastName = 'Saas';
            ObjConTNotIn.MobilePhone = '06423432442445';
            Id CaseRet3Id= TTI_SubmtClaimController.saveClaimDetails(caseObj,objAsset,24,ObjConTNotIn,True);
            //Case CaseRet3= ((Case)JSON.deserialize(TTI_SubmtClaimController.saveClaimDetails(caseObj,objAsset,24,ObjConTNotIn,True),Case.class));
            PageReference pdf = Page.TTI_Invoicepdf;
            string caseId=string.valueOf(CaseRet3Id);
            pdf.getParameters().put('caseId',CaseRet3Id);
            pdf.setRedirect(false);
            Test.setCurrentPage(pdf);
            TTI_Invoicepdf_controller ObjTTI_Invoicepdf_controller=new TTI_Invoicepdf_controller();
        }
    }
    
    private static testMethod void Test9(){
        TTI_SubmtClaimController.getUserType();
    }
    
    */
    
    
}