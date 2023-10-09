@isTest 
public class SendEmailToRefreeAndRefererTest {

    @TestSetup
    static void setupData() {
        
        UserRole userrole = [Select Id, DeveloperName From UserRole WHERE DeveloperName = 'CEO' Limit 1];
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = '~ CX System Admin' Limit 1];
        Id rafCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Refer a Friend cases').getRecordTypeId();

        User admUser = new User(
            Alias = 'adminu',
            Email = 'adminuser@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = adminProfile.Id,
            UserRoleId = userrole.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testadmin12345@test.com'
        );
        insert admUser;

        System.runAs(admUser) {
            Profile custAEGProfile = [
                SELECT Id
                FROM Profile
                WHERE Name = '~Customer Community AEG'
            ];

            Contact con = new Contact();
            con.LastName = 'Testing';
            con.FirstName = 'RAF';
            con.Email = 'test@test.com';
            con.MobilePhone = '9999999999';
            con.Phone = '5897899097';
            con.Country__c = 'Australia';
            insert con;

            User custAEGUser = new User(
                Alias = 'raft',
                Email = 'test@test.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'Testing',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = custAEGProfile.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = 'test@test.com',
                Referral_Code__c = '',
                ContactId = con.Id
            );
            insert custAEGUser;

            Contact con2 = new Contact();
            con2.LastName = 'Testing';
            con2.FirstName = 'RAF';
            con2.Email = 'test2@test.com';
            con2.MobilePhone = '9999999999';
            con2.Phone = '5897899097';
            con2.Country__c = 'Australia';
            insert con2;

            User custAEGUser2 = new User(
                Alias = 'raft2',
                Email = 'test2@test.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'Testing2',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = custAEGProfile.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = 'test2@test.com',
                Referral_Code__c = 'sh4hs6',
                ContactId = con2.Id
            );
            insert custAEGUser2;

            Case cs = new Case();
            cs.ContactId = con.Id;
            cs.RecordTypeId = rafCaseRecTypeId;
            cs.Brand__c = 'AEG';
            cs.Used_referral_Code__c = custAEGUser2.Referral_Code__c;   
            cs.Referred_By__c = con2.id;
            cs.FirstName__c = con.FirstName;
            cs.LastName__c = con.LastName;
            cs.TTI_Customer_Contact_email__c = con.email;
            cs.Priority = 'Medium';
            cs.Status = 'New';
            cs.Subject = 'Case RAF Test';
            cs.Approve_Reject__c = '';
            insert cs;

            PurchasedProducts__c purProds = new PurchasedProducts__c();
            insert purProds;
            
            RedeemableProducts__c redeemableProds = new RedeemableProducts__c();
            redeemableProds.RedeemType__c = 'All';
            insert redeemableProds;
            
            Product2 product = new Product2();
            product.Name = 'test Product';
            product.Brand__c = 'AEG';
            product.IsActive = true;
            product.ProductCode = 'test123';
            insert product;

            RedeemedProducts__c record = new RedeemedProducts__c();
            insert record;
            
            RedeemableProductItem__c redeemableProdItem = new RedeemableProductItem__c();
            redeemableProdItem.Quantity__c = 1;
            redeemableProdItem.Product__c = Product.id;
            redeemableProdItem.RedeemableProduct__c = redeemableProds.Id;   
            insert redeemableProdItem;
            
            Redemption_Campaigns__c redempCamp = new Redemption_Campaigns__c();
            redempCamp.RedeemableProducts__c = redeemableProds.Id;
            redempCamp.PurchasedProducts__c = purProds.Id;
            redempCamp.RAF__c = true;
            redempCamp.Valid_From__c = Date.valueOf(System.now().addDays(-2));
            redempCamp.Valid_To__c = Date.valueOf(System.now().addDays(2));
            redempCamp.Brand__c = 'AEG';        
            insert redempCamp;

        }
    }
    
    static testMethod void sendEmailInvokedFromFlow(){

        Contact con = [SELECT Id, FirstName, LastName, MobilePhone, Phone, Email FROM Contact WHERE Email = 'test2@test.com' LIMIT 1];
        Case cs = [SELECT Id, Approve_Reject__c, Case_Encrypted_Id__c, TTI_Customer_Contact_email__c FROM Case WHERE Subject = 'Case RAF Test' LIMIT 1];
        cs.Approve_Reject__c = 'Approve';
        cs.Case_Encrypted_Id__c = 'qwetqw326534erhtru6535';
        update cs;

        SendEmailToRefreeAndReferer.CaseWrapper objwrap = new SendEmailToRefreeAndReferer.CaseWrapper();
        objwrap.approvalpicklist='Approve';
        objwrap.caseId = cs.Id;
        objwrap.contactId=con.id;
        objwrap.customerContactemail=cs.TTI_Customer_Contact_email__c;
        objwrap.referralCode='XYZ';
        List<SendEmailToRefreeAndReferer.CaseWrapper> lstobjwrap = new List<SendEmailToRefreeAndReferer.CaseWrapper>();
        lstobjwrap.add(objwrap);

        Test.startTest();
            SendEmailToRefreeAndReferer.sendEmailInvokedFromFlow(lstobjwrap);
        Test.stopTest();

    }
}