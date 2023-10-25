@isTest
private class BlackhawkAPITest {

    @testSetup static void setup() {

        Id b2cPersonAccountRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Consumer Contact').getRecordTypeId();
            
        List<Account> accList = new List<Account>();
        accList.add(new Account(FirstName = 'Hayley', LastName = 'Williams', PersonEmail = 'hayley.williams@fueledbyramen.com', Brand__pc = 'Ryobi', RecordTypeId = b2cPersonAccountRecId, PersonMobilePhone = '042142321', Country__pc = 'AUS'));
        accList.add(new Account(FirstName = 'Test Name', LastName = 'Test1', PersonEmail = 'Testing@yahoo.com', Brand__pc = 'Ryobi', RecordTypeId = b2cPersonAccountRecId));
        
        Database.insert(accList, false);

        Contact personContact = [SELECT Id FROM Contact WHERE AccountId = :accList[0].Id LIMIT 1];
        Contact personContactTwo = [SELECT Id FROM Contact WHERE AccountId = :accList[1].Id LIMIT 1];

        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = '~Customer Community Ryobi'];
        
        User portalUser = new User();
        portalUser.Username = accList[0].PersonEmail + '.tst';
        portalUser.Email = accList[0].PersonEmail;
        portalUser.CommunityNickname = 'Cardo';
        portalUser.ProfileId = portalProfile.Id;
        portalUser.ContactId = personContact.Id;
        portalUser.Alias = 'Cardo123';
        portalUser.EmailEncodingKey = 'UTF-8';
        portalUser.LastName = accList[0].LastName;
        portalUser.TimeZoneSidKey = 'America/Los_Angeles';
        portalUser.LocaleSidKey = 'en_US';
        portalUser.LanguageLocaleKey = 'en_US';

        User portalUserTwo = new User();
        portalUserTwo.Username = accList[1].PersonEmail + '.tst';
        portalUserTwo.Email = accList[1].PersonEmail;
        portalUserTwo.CommunityNickname = 'Cardo1';
        portalUserTwo.ProfileId = portalProfile.Id;
        portalUserTwo.ContactId = personContactTwo.Id;
        portalUserTwo.Alias = 'Cardo55';
        portalUserTwo.EmailEncodingKey = 'UTF-8';
        portalUserTwo.LastName = accList[1].LastName;
        portalUserTwo.TimeZoneSidKey = 'America/Los_Angeles';
        portalUserTwo.LocaleSidKey = 'en_US';
        portalUserTwo.LanguageLocaleKey = 'en_US';
        
        insert new List<User> {portalUser,portalUserTwo};

        Blackhawk_API_Settings__c blackhawkSetting = new Blackhawk_API_Settings__c();
        blackhawkSetting.Catalog_API_Endpoint__c = '/rewardsCatalogProcessing/v1/clientProgram/byKey';
        blackhawkSetting.Client_Program_Id__c = '95006278';
        blackhawkSetting.Is_Active__c = true;
        blackhawkSetting.Merchant_Id__c = '60300009755';
        blackhawkSetting.Milliseconds_To_Wait__c = '30000';
        blackhawkSetting.Monitoring_Status_Endpoint__c = '/rewardsOrderProcessing/v1/monitor';
        blackhawkSetting.Payment_Type__c = 'DRAW_DOWN';
        blackhawkSetting.Real_time_eGift_Endpoint__c = '/rewardsOrderProcessing/v1/submitRealTimeEgiftBulk';
        blackhawkSetting.Return_Card_Number_and_PIN__c = false;
        blackhawkSetting.SYNCHRONOUS_ONLY__c = true;
        blackhawkSetting.Client_Certificate_Name__c = 'BlackhawkPreProd';
        blackhawkSetting.Name = 'PreProd';
        blackhawkSetting.Maximum_Retry_Count__c = 3;
        insert blackhawkSetting;

        SerialNumberDisplayType__c snType = new SerialNumberDisplayType__c();
        snType.Name = 'test';
        snType.Serial_Number_Length__c = 10;
        snType.HelperImageURL__c = 'https://www.google.com.au/images/branding/googlelogo/2x/googlelogo_color_120x44dp.png';
        snType.IsDefault__c = true;
        snType.HelpText__c = 'Please enter the ten digit serial number located on your tool.';
        insert snType;

        List<Product2> productList = TestUtilityClass.createProduct(2);
        productList[0].SerialNumberDisplayType__c = snType.Id;
        productList[0].brand__c = 'RY';
        productList[0].SAP_Product_Heirarchy__c = 'RY-PT-OPL-CSW';
        productList[0].Customer_Facing_Name__c = '18V ONE+ HP™ Brushless Circular Saw - Tool Only';
        productList[0].category_customer_level1__c =  'Power Tools';
        productList[1].SerialNumberDisplayType__c = snType.Id;
        productList[1].Brand__c = 'RY';
        productList[1].SAP_Product_Heirarchy__c = 'RY-PT-OPL-CSW';
        productList[1].Customer_Facing_Name__c = '18V ONE+ HP™ Brushless Compact Drill Driver - Tool Only';
        insert productList;

        Blackhawk_Card_Product__c blackhawkCardProduct = new Blackhawk_Card_Product__c(
            Client_Program_Id__c = '95006278',
            Content_Provider_Code__c = 'ASOS_AUD_en_eGift',
            Currency__c = 'AUD',
            Locale__c = 'EN',
            Logo_Image__c = 'https://content.blackhawknetwork.com/gcmimages/manufacturer/large/2B49PJLDAYY3V27T3G522Q5ZJ8-en_AU.png?dt=1611083086932',
            Name = 'ASOS_AUD_en_eGift',
            Parent_Brand_Name__c = 'ASOS',
            Product_Description__c = 'If youâre looking for new ways to engage with, reward and motivate existing staff, alongside attracting new employees, this is where ASOS corporate gift cards come in.',
            Product_Image__c = 'https://content.blackhawknetwork.com/gcmimages/product/xlarge/1007093.jpeg?dt=1615227766940',
            Product_Name__c = 'ASOS eGift',
            Program_Name__c = 'Techtronic Industries Australia Pty Limited',
            Program_Type__c = 'DIGITAL',
            Redemption_Info__c = 'DIGITAL',
            TNC_Text__c = 'https://www.asos.com/terms-and-conditions/https://www.asos.com/terms-and-conditions/https://www.asos.com/terms-and-conditions/',
            TNC_Type__c = 'INLINE',
            VR_Maximum__c = 500,
            VR_Minimum__c = 20
        );

        insert blackhawkCardProduct;

        Eligible_Products__c eligibleProducts = new Eligible_Products__c();
        insert eligibleProducts;

        List<Eligible_Product_Line_Item__c> eligibleProductLineItems = new List<Eligible_Product_Line_Item__c>();
        eligibleProductLineItems.add(new Eligible_Product_Line_Item__c(
            Eligible_Product__c = eligibleProducts.Id,
            Product__c = productList[0].Id
            // Required__c = true,
            // Quantity__c = 1
        ));
        eligibleProductLineItems.add(new Eligible_Product_Line_Item__c(
            Eligible_Product__c = eligibleProducts.Id,
            Product__c = productList[1].Id
            // Required__c = true,
            // Quantity__c = 1
        ));

        insert eligibleProductLineItems;

        Member_Benefit_Program__c memberBenefitProgram = new Member_Benefit_Program__c(
            Activation_Validity_Days__c = 45,
            Blackhawk_Catalog_Lookup__c = blackhawkCardProduct.Id,
            Brand__c = 'Ryobi',
            Country__c = 'Australia',
            End_Date__c = Date.valueOf('2025-01-15'),
            Gift_Card_Validity_Days__c = 183,
            Gift_Card_Value__c = 30,
            Maximum_Gift_Card_Per_Customer__c = 1,
            Name = 'Test 1. Drill/Driver to Blower/Saws',
            Product_Hierarchies__c = 'RY-PT-BTP-MIT;RY-PT-OPL-TSW;RY-PT-OPL-SMI;RY-PT-OPL-RCS;RY-PT-OPL-PLS;RY-PT-12L-RCS;RY-PT-12N-JSW;RY-PT-ACE-CSW;RY-PT-ACE-JSW;RY-PT-ACE-OTH;RY-PT-ACE-RCS;RY-PT-BTP-BDS;RY-PT-BTP-COS;RY-PT-BTP-SMI;RY-PT-BTP-SSW;RY-PT-BTP-TCT;RY-PT-BTP-TSW;RY-PT-OPL-CCK;RY-PT-OPL-CSW;RY-PT-OPL-JSW;RY-PT-OPL-MIT;RY-PT-OPL-SPS;RY-PT-OPL-TCT;RY-PT-PNU-RCS;RY-PG-ACE-CHS;RY-PT-BTP-STD;RY-PG-ACE-BVC;RY-PG-PED-BVC;RY-PG-OPL-BVC;RY-PG-OPL-BLW;RY-PG-36L-BVC;RY-PG-36L-BLW;RY-PG-OPL-LMW;RY-PG-OPL-LTR;RY-PG-OPL-CCK;RY-PG-36L-CCK;RY-PG-36L-LTR',
            Start_Date__c = Date.valueOf('2023-10-01'),
            Terms_and_Conditions__c = 'https://www.ryobi.com.au/',
            Valid_From__c = Date.valueOf('2023-10-01'),
            Valid_To__c = Date.valueOf('2024-01-29')
        );

        Member_Benefit_Program__c memberBenefitProgramTwo = new Member_Benefit_Program__c(
            Activation_Validity_Days__c = 45,
            Blackhawk_Catalog_Lookup__c = blackhawkCardProduct.Id,
            Brand__c = 'Ryobi',
            Country__c = 'Australia',
            End_Date__c = Date.valueOf('2025-01-15'),
            Gift_Card_Validity_Days__c = 183,
            Gift_Card_Value__c = 30,
            Maximum_Gift_Card_Per_Customer__c = 1,
            Name = 'Test 2.Blower to Trimmer/Drills',
            Product_Hierarchies__c = 'RY-PT-BTP-MIT',
            Start_Date__c = Date.valueOf('2023-10-01'),
            Terms_and_Conditions__c = 'https://www.ryobi.com.au/',
            Valid_From__c = Date.valueOf('2023-10-01'),
            Valid_To__c = Date.valueOf('2024-01-29'),
            Eligible_Products__c = eligibleProducts.Id
        );
        List<Member_Benefit_Program__c> memberBenefitList = new List<Member_Benefit_Program__c> {memberBenefitProgram,memberBenefitProgramTwo};
        insert memberBenefitList;

        List<Eligible_Customer__c> eligibleCustomerList = new List<Eligible_Customer__c>();
        eligibleCustomerList.add(new Eligible_Customer__c(
            Customer__c = accList[0].Id,
            Member_Benefit_Program__c = memberBenefitList[0].Id,
            Send_To_MC__c = false
        ));
        eligibleCustomerList.add(new Eligible_Customer__c(
            Customer__c = accList[1].Id,
            Member_Benefit_Program__c = memberBenefitList[0].Id,
            Send_To_MC__c = false
        ));
        eligibleCustomerList.add(new Eligible_Customer__c(
            Customer__c = accList[0].Id,
            Member_Benefit_Program__c = memberBenefitList[1].Id,
            Send_To_MC__c = false
        ));
        eligibleCustomerList.add(new Eligible_Customer__c(
            Customer__c = accList[1].Id,
            Member_Benefit_Program__c = memberBenefitList[1].Id,
            Send_To_MC__c = false
        ));
        insert eligibleCustomerList;
    }

    static testMethod void testSingleMemberBenefit() {
        Test.setMock(HttpCalloutMock.class, new BlackhawkAPIServiceMock(201,'{"transactionId" : "G8BD11WHSNC5MZPSZRQ8X023AW","isCompleted" : true,"percentComplete" : 100,"success" : true,"orderNumber" : "403062844","contentProviderCode" : "ASOS_AUD_en_eGift","transactionAmount" : 30.00,"url" : "https://egift.certification.blackhawknetwork.com/egift?tid=657Q0RGVTJTZKC50AW2P8STYQC&gcm=n&gs=n&gw=n&eid=YK15H5RBKC4NG97K48G3P98GW8"}'));
        Test.startTest();

            List<Product2> productList = [SELECT Id FROM Product2];
            List<Account> personAccount = [SELECT Id, PersonContactId FROM Account];
            List<Asset> assetList = new List<Asset>();
            assetList.add(new Asset(Name = 'Test', 
                                    AccountId = personAccount[0].Id, 
                                    ContactId = personAccount[0].PersonContactId, 
                                    Product2Id = productList[0].Id, 
                                    PurchaseDate = Date.valueOf('2023-10-24'),
                                    HelpText__c = 'Test Helper Text',
                                    Regexpression_Validator__c = 'Exp',
                                    Serial_Number_Length__c = 20));
            assetList.add(new Asset(Name = 'Test1', 
                                    AccountId = personAccount[1].Id, 
                                    ContactId = personAccount[1].PersonContactId, 
                                    Product2Id = productList[1].Id, 
                                    PurchaseDate = Date.valueOf('2023-10-24'),
                                    HelpText__c = 'Test Helper Text',
                                    Regexpression_Validator__c = 'Exp',
                                    Serial_Number_Length__c = 20));
            
            insert assetList;

            Set<String> assetIds = new Set<String>();
            assetIds.add(assetList[0].Id);
            assetIds.add(assetList[1].Id);

            MembershipLoyaltyController.GenerateMemberBenefitWrapper memberBenefitWrap = MembershipLoyaltyController.generateMemberBenefits(assetIds);
            if(memberBenefitWrap!=NULL){
                if(memberBenefitWrap.memberBenefitList != NULL)insert(memberBenefitWrap.memberBenefitList);
                if(memberBenefitWrap.assetList != NULL)update(memberBenefitWrap.assetList);    
                List<Member_Benefit__c> memberBenefitList = [SELECT Id FROM Member_Benefit__c];
                System.assertEquals(memberBenefitList.size(),2);
                memberBenefitList[0].Status__c = 'Approved - Awaiting Activation';
                update memberBenefitList[0];
                memberBenefitList[0].Status__c = 'Approved - Activated';
                update memberBenefitList[0];
            }

        Test.stopTest();
    }

    static testMethod void testBulkMemberBenefit() {
        Test.setMock(HttpCalloutMock.class, new BlackhawkAPIServiceMock(201,'{"transactionId" : "G8BD11WHSNC5MZPSZRQ8X023AW","isCompleted" : true,"percentComplete" : 100,"success" : true,"orderNumber" : "403062844","contentProviderCode" : "ASOS_AUD_en_eGift","transactionAmount" : 30.00,"url" : "https://egift.certification.blackhawknetwork.com/egift?tid=657Q0RGVTJTZKC50AW2P8STYQC&gcm=n&gs=n&gw=n&eid=YK15H5RBKC4NG97K48G3P98GW8"}'));
        Test.startTest();

            Member_Benefit_Program__c memberBenefitToDelete = [SELECT Id FROM Member_Benefit_Program__c WHERE Name = 'Test 1. Drill/Driver to Blower/Saws'];
            delete memberBenefitToDelete;

            List<Product2> productList = [SELECT Id FROM Product2];
            List<Account> personAccount = [SELECT Id, PersonContactId FROM Account];
            List<Asset> assetList = new List<Asset>();
            assetList.add(new Asset(Name = 'Test', 
                                    AccountId = personAccount[0].Id, 
                                    ContactId = personAccount[0].PersonContactId, 
                                    Product2Id = productList[0].Id, 
                                    PurchaseDate = Date.valueOf('2023-10-24'),
                                    HelpText__c = 'Test Helper Text',
                                    Regexpression_Validator__c = 'Exp',
                                    Serial_Number_Length__c = 20));
            assetList.add(new Asset(Name = 'Test1', 
                                    AccountId = personAccount[1].Id, 
                                    ContactId = personAccount[1].PersonContactId, 
                                    Product2Id = productList[1].Id, 
                                    PurchaseDate = Date.valueOf('2023-10-24'),
                                    HelpText__c = 'Test Helper Text',
                                    Regexpression_Validator__c = 'Exp',
                                    Serial_Number_Length__c = 20));
            insert assetList;

            Set<String> assetIds = new Set<String>();
            assetIds.add(assetList[0].Id);
            
            MembershipLoyaltyController.GenerateMemberBenefitWrapper memberBenefitWrap = MembershipLoyaltyController.generateMemberBenefits(assetIds);

            if(memberBenefitWrap!=NULL){

                if(memberBenefitWrap.memberBenefitList != NULL){
                    insert(memberBenefitWrap.memberBenefitList);    
                }
                if(memberBenefitWrap.assetList != NULL){
                    update(memberBenefitWrap.assetList);    
                }

                memberBenefitWrap = MembershipLoyaltyController.generateMemberBenefits(new Set<String>{assetList[1].Id});
                if(memberBenefitWrap!=NULL){
                    if(memberBenefitWrap.memberBenefitList != NULL){
                        insert(memberBenefitWrap.memberBenefitList);    
                    }
                    if(memberBenefitWrap.assetList != NULL){
                        update(memberBenefitWrap.assetList);    
                    }
                }

                memberBenefitWrap = MembershipLoyaltyController.generateMemberBenefits(new Set<String>{assetList[1].Id});
                if(memberBenefitWrap!=NULL){
                    if(memberBenefitWrap.memberBenefitList != NULL){
                        insert(memberBenefitWrap.memberBenefitList);    
                    }
                    if(memberBenefitWrap.assetList != NULL){
                        update(memberBenefitWrap.assetList);    
                    }
                }
            
                List<Member_Benefit__c> memberBenefitList = [SELECT Id, Member_Benefit_Program__r.Name FROM Member_Benefit__c];
                System.assertEquals(memberBenefitList.size() ,2);
                System.assertEquals(memberBenefitList[0].Member_Benefit_Program__r.Name ,'Test 2.Blower to Trimmer/Drills');
                System.assertEquals(memberBenefitList[1].Member_Benefit_Program__r.Name ,'Test 2.Blower to Trimmer/Drills');
            }

        Test.stopTest();
    }

    static testMethod void testAPIError(){
        Test.setMock(HttpCalloutMock.class, new BlackhawkAPIServiceMock(400,'{"errors" : [ {"errorCode" : "invalid.request","message" : "Does not have permissions to submit order using this quote"} ]}'));
        List<Member_Benefit__c> memberBenefitList = new List<Member_Benefit__c>();
        Test.startTest();

            List<Product2> productList = [SELECT Id FROM Product2];
            List<Account> personAccount = [SELECT Id, PersonContactId FROM Account];
            List<Asset> assetList = new List<Asset>();
            assetList.add(new Asset(Name = 'Test', 
                                    AccountId = personAccount[0].Id, 
                                    ContactId = personAccount[0].PersonContactId, 
                                    Product2Id = productList[0].Id, 
                                    PurchaseDate = Date.valueOf('2023-10-24'),
                                    HelpText__c = 'Test Helper Text',
                                    Regexpression_Validator__c = 'Exp',
                                    Serial_Number_Length__c = 20));
            insert assetList;

            Set<String> assetIds = new Set<String>();
            assetIds.add(assetList[0].Id);

            MembershipLoyaltyController.GenerateMemberBenefitWrapper memberBenefitWrap = MembershipLoyaltyController.generateMemberBenefits(assetIds);
            if(memberBenefitWrap.memberBenefitList != NULL)insert(memberBenefitWrap.memberBenefitList);
            if(memberBenefitWrap.assetList != NULL)update(memberBenefitWrap.assetList);    
            memberBenefitList = [SELECT Id FROM Member_Benefit__c];
            System.assertEquals(memberBenefitList.size(),1);
            memberBenefitList[0].Status__c = 'Approved - Awaiting Activation';
            update memberBenefitList[0];
            memberBenefitList[0].Status__c = 'Approved - Activated';
            update memberBenefitList[0];
        Test.stopTest();
        memberBenefitList = [SELECT Id FROM Member_Benefit__c WHERE Status__c = 'Approved - Gift Card Platform Error'];
        System.assertEquals(memberBenefitList.size(),1);
    }

    static testMethod void testAPISchedule(){

        Test.setMock(HttpCalloutMock.class, new BlackhawkAPIServiceMock(500,'{"errors" : [ {"errorCode" : "invalid.request","message" : "Does not have permissions to submit order using this quote"} ]}'));
        List<Member_Benefit__c> memberBenefitList = new List<Member_Benefit__c>();

        Test.startTest();

        List<Product2> productList = [SELECT Id FROM Product2];
        List<Account> personAccount = [SELECT Id, PersonContactId FROM Account];
        List<Asset> assetList = new List<Asset>();
        assetList.add(new Asset(Name = 'Test', 
                                AccountId = personAccount[0].Id, 
                                ContactId = personAccount[0].PersonContactId, 
                                Product2Id = productList[0].Id, 
                                PurchaseDate = Date.valueOf('2023-10-24'),
                                HelpText__c = 'Test Helper Text',
                                Regexpression_Validator__c = 'Exp',
                                Serial_Number_Length__c = 20));
        insert assetList;

        Set<String> assetIds = new Set<String>();
        assetIds.add(assetList[0].Id);

        MembershipLoyaltyController.GenerateMemberBenefitWrapper memberBenefitWrap = MembershipLoyaltyController.generateMemberBenefits(assetIds);
        if(memberBenefitWrap.memberBenefitList != NULL)insert(memberBenefitWrap.memberBenefitList);
        if(memberBenefitWrap.assetList != NULL)update(memberBenefitWrap.assetList);    
        memberBenefitList = [SELECT Id FROM Member_Benefit__c];
        System.assertEquals(memberBenefitList.size(),1);
        memberBenefitList[0].Status__c = 'Approved - Awaiting Activation';
        update memberBenefitList[0];
        memberBenefitList[0].Status__c = 'Approved - Activated';
        update memberBenefitList[0];
        
        Test.stopTest();
        
        String CRON_EXP = '0 6 * * * ?';
        memberBenefitList = [SELECT Id FROM Member_Benefit__c WHERE Status__c = 'Approved - Gift Card Platform Error'];
        System.assertEquals(memberBenefitList.size(),1);

        String jobId = System.schedule('BlackhawkAPISchedule',  CRON_EXP, new BlackhawkAPISchedule());
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
		System.assertEquals(CRON_EXP, ct.CronExpression);
		System.assertEquals(0, ct.TimesTriggered);
            
        MembershipLoyaltyController.WithoutShare membershipLoyaltyCtrl = new MembershipLoyaltyController.WithoutShare();
        Database.executeBatch(new BlackhawkAPIBatch('retry',membershipLoyaltyCtrl.getMemberBenefitToResubmit()),10);
       
    }

    static testMethod void testGetCatalogAPI(){
        List<Blackhawk_Card_Product__c>  blackhawkCardProductList = [SELECT Id FROM Blackhawk_Card_Product__c];
        delete blackhawkCardProductList;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new BlackhawkAPIServiceMock(200,'{"STATUS":"SUCCESS"}'));
            BlackhawkAPIService.monitorRewards();
            Test.setMock(HttpCalloutMock.class, new BlackhawkAPIServiceMock(200,'{"clientProgramId" : 95006278,"programName" : "Techtronic Industries Australia Pty Limited","programType" : "DIGITAL","currency" : "AUD","products" : [ {  "contentProviderCode" : "ASOS_AUD_en_eGift",  "productName" : "ASOS eGift",  "productDescription" : "If youâre looking for new ways to engage with, reward and motivate existing staff, alongside attracting new employees, this is where ASOS corporate gift cards come in.",  "parentBrandName" : "ASOS",  "redemptionInfo" : "Enter card number onto your ASOS account. eGift will be stored in the ASOS account and will be available as a payment option at checkout when the next purchase is made",  "termsAndConditions" : {    "type" : "INLINE",    "text" : "https://www.asos.com/terms-and-conditions/https://www.asos.com/terms-and-conditions/https://www.asos.com/terms-and-conditions/"  },  "productImage" : "https://content.blackhawknetwork.com/gcmimages/product/xlarge/1007093.jpeg?dt=1615227766940",  "logoImage" : "https://content.blackhawknetwork.com/gcmimages/manufacturer/large/2B49PJLDAYY3V27T3G522Q5ZJ8-en_AU.png?dt=1611083086932",  "valueRestrictions" : {    "minimum" : 20.00,    "maximum" : 500.00  },  "locale" : "EN"}, {  "contentProviderCode" : "IAGOnly1VirtualVisa_AUD_en_eGift",  "productName" : "OnlyOne Digital Visa eGift",  "productDescription" : "The Only 1 Virtual Visa Gift Card is the perfect way to say \'Happy Birthday\', \'Congratulations\', \'Thank You\', and many more. This card can be used online,over the phone or for mail orders where Visa prepaid is accepted. Use your gift card as many times as you would like - the amount of every purchase you make is automatically deducted from your available balance.",  "parentBrandName" : "OnlyOne Digital Visa",  "redemptionInfo" : "OnlyOne Digital Visa can be used for online, over the phone or for mail order transactions at any merchant where Visa prepaid cards are accepted. To use your OnlyONE digital Visa instore, add the eGift to your mobile wallet by visiting www.myprepaidcentre.com.au",  "termsAndConditions" : {    "type" : "INLINE",    "text" : "The Only 1 Virtual Visa Account Gift Card (\'Card\') is issued by Indue Ltd ABN 97 087 822 464 (\'Indue\'). In these conditions, \'you\' are the Card purchaser or user. Blackhawk Australia Pty. Ltd. ACN 123 251 703 (\'Blackhawk\') is Indue\'s program manager for the Card, and Indue and Blackhawk are collectively âusâ and âweâ in these conditions. By using the Card, you agree to be bound by these Terms & Conditions. If you are not the intended user of the Card, then you must provide these Terms & Conditions to the intended user of the Card). Only 1 Virtual Visa Cards must be registered prior to being used. Failing to register the Virtual Visa Card will result in the card being inactive. The Card can be used for purchases of goods and services online, over the phone or for mail orders where prepaid VISA Gift Cards are accepted and processed electronically (merchants and merchant groups who elect not to accept VISA prepaid gift cards). The Card cannot be used for card present transactions at merchants where a swipe, insert or Paywave is available. Card expires 3 years from the date of activation.For Full Terms and Conditions visit www.only1visagiftcard.com.auThe Only 1 Virtual Visa Account Gift Card (\'Card\') is issued by Indue Ltd ABN 97 087 822 464 (\'Indue\'). In these conditions, \'you\' are the Card purchaser or user. Blackhawk Australia Pty. Ltd. ACN 123 251 703 (\'Blackhawk\') is Indue\'s program manager for the Card, and Indue and Blackhawk are collectively âusâ and âweâ in these conditions. By using the Card, you agree to be bound by these Terms & Conditions. If you are not the intended user of the Card, then you must provide these Terms & Conditions to the intended user of the Card). Only 1 Virtual Visa Cards must be registered prior to being used. Failing to register the Virtual Visa Card will result in the card being inactive. The Card can be used for purchases of goods and services online, over the phone or for mail orders where prepaid VISA Gift Cards are accepted and processed electronically (merchants and merchant groups who elect not to accept VISA prepaid gift cards). The Card cannot be used for card present transactions at merchants where a swipe, insert or Paywave is available. Card expires 3 years from the date of activation.For Full Terms and Conditions visit www.only1visagiftcard.com.auThe Only 1 Virtual Visa Account Gift Card (\'Card\') is issued by Indue Ltd ABN 97 087 822 464 (\'Indue\'). In these conditions, \'you\' are the Card purchaser or user. Blackhawk Australia Pty. Ltd. ACN 123 251 703 (\'Blackhawk\') is Indue\'s program manager for the Card, and Indue and Blackhawk are collectively âusâ and âweâ in these conditions. By using the Card, you agree to be bound by these Terms & Conditions. If you are not the intended user of the Card, then you must provide these Terms & Conditions to the intended user of the Card). Only 1 Virtual Visa Cards must be registered prior to being used. Failing to register the Virtual Visa Card will result in the card being inactive. The Card can be used for purchases of goods and services online, over the phone or for mail orders where prepaid VISA Gift Cards are accepted and processed electronically (merchants and merchant groups who elect not to accept VISA prepaid gift cards). The Card cannot be used for card present transactions at merchants where a swipe, insert or Paywave is available. Card expires 3 years from the date of activation.For Full Terms and Conditions visit www.only1visagiftcard.com.au"  },  "productImage" : "https://content.blackhawknetwork.com/gcmimages/product/xlarge/1011945.png?dt=1631897736624",  "logoImage" : "https://content.blackhawknetwork.com/gcmimages/manufacturer/large/LVW1XZJBX6VTZ6V64M4VAYZT2R-en_AU.png?dt=1632156110212",  "valueRestrictions" : {    "minimum" : 5.00,    "maximum" : 1000.00  },  "locale" : "EN"} ]}'));
            Blackhawk_API_Settings__c bhAPISetting = BlackhawkAPIService.getActiveBlackhawkApiSetting();
            BlackhawkClientProgramWrapper bhcpWrapObj = BlackhawkClientProgramWrapper.parse(BlackhawkAPIService.getCatalogByKey(bhAPISetting.Client_Program_Id__c).getBody());
            blackhawkCardProductList = BlackhawkAPIService.generateBlackhawkCardProducts(bhcpWrapObj);
            insert blackhawkCardProductList;
            blackhawkCardProductList = [SELECT Id FROM Blackhawk_Card_Product__c];
            System.assertEquals(blackhawkCardProductList.size(),2);
        Test.stopTest();
       
    }

}