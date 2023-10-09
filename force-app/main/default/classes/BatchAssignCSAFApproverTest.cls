/**
 * @author:                         Ericka Jan Cajucom
 * @date:                           2021-03-25
 */
@isTest
public class BatchAssignCSAFApproverTest {
    /**********************************************************************
     * @description             Initialize data
     */
    @TestSetup
    static void setupData() {
        Profile marketingProfile = [
            SELECT Id
            FROM Profile
            WHERE Name = '~Marketing User'
        ];
        User approverUser = new User(
            Alias = 'mktg',
            Email = 'marketinguser@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = marketingProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testmarketingd@testing.com',
            TTI_SAP_Cust_No__c = '54321',
            Division = 'Industrial',
            Department = 'Supply and Demand'
        );
        insert approverUser;

        Profile stdProfile = [
            SELECT Id
            FROM Profile
            WHERE Name = 'Standard User'
        ];
        User nUser = new User(
            Alias = 'standt',
            Email = 'standarduser@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = stdProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'teststandard@testing.com',
            TTI_SAP_Cust_No__c = '12345',
            Division = 'Industrial'
        );
        insert nUser;

        System.runAs(nUser) {
            Account nAccount = new Account(
                Name = 'Test Account',
                Type = 'Head Office',
                TTI_SAP_Cust_No__c = '401322'
            );
            insert nAccount;

            Pricebook2 nPbook = new Pricebook2(
                Name = 'Standard Price Book Test',
                Description = 'Price Book Test Products',
                IsActive = true
            );
            insert nPbook;

            Product2 nProduct = new Product2(
                Name = 'SLA: Bronze',
                IsActive = true,
                Family = 'Power Tools',
                SAP_Material_Group__c = 'ML-TL',
                AU_MRPty__c = 'ZB'
            );
            insert nProduct;

            PricebookEntry nPBookEntry = new PricebookEntry(
                unitprice = 0.01,
                Product2Id = nProduct.Id,
                Pricebook2Id = nPbook.Id,
                IsActive = true
            );
            insert nPBookEntry;

            TTI_Template__c temp = new TTI_Template__c(
                Name = 'TTI_EmailsentToTheServiceAgentTemplate'
            );
            insert temp;

            Catalogue_Submission__c csaf = new Catalogue_Submission__c(
                Account__c = nAccount.Id,
                Catalogue_Name__c = 'Test CSAF - ' + System.datetime.now(),
                Stage__c = 'Initial Proposal',
                Status__c = 'Draft',
                Artwork_Conducted__c = 'Internally',
                Artwork_Sizing__c = '123',
                Advertising_Start_Date__c = System.today(),
                Advertising_End_Date__c = System.today().addYears(2),
                Buy_In_Start_Date__c = System.today(),
                Buy_In_End_Date__c = System.today().addYears(2)
            );
            insert csaf;

            Catalogue_Product__c csafProduct = new Catalogue_Product__c(
                Catalogue__c = csaf.Id,
                Product__c = nProduct.Id,
                Product_Family__c = 'Power Tool',
                Dealer_Pricing__c = 12,
                Minimum_Order_Quantity__c = 100,
                Forecast_Order_Quantity__c = 150
            );
            insert csafProduct;

            Approval.ProcessSubmitRequest processReq = new Approval.ProcessSubmitRequest();
            processReq.setComments('Submitting request for approval.');
            processReq.setObjectId(csaf.id);
            processReq.setSubmitterId(nUser.Id);
            processReq.setNextApproverIds(new List<Id>{ approverUser.Id });

            Approval.ProcessResult result = Approval.process(processReq);

            System.assert(result.isSuccess());

            System.assertEquals(
                'Pending',
                result.getInstanceStatus(),
                'Instance Status' + result.getInstanceStatus()
            );
        }

    }

    /**********************************************************************
     * @description             Check if batch reminder email is sent
     */
    private static testMethod void testExecuteBatch() {
        Catalogue_Submission__c csaf = [
            SELECT Id, Next_Approval_Reminder__c
            FROM Catalogue_Submission__c
        ];
        csaf.Next_Approval_Reminder__c = System.today();
        update csaf;

        User approver = [
            SELECT Id, Name, Email
            FROM User
            WHERE Department = 'Supply and Demand'
            LIMIT 1
        ];

        ProcessInstanceWorkItem pwi = [SELECT Id, ActorId FROM ProcessInstanceWorkItem LIMIT 1];
        pwi.ActorId = approver.Id;
        update pwi;

        Id batchId;

        Test.startTest();
        BatchAssignCSAFApprover batch = new BatchAssignCSAFApprover();
        batchId = DataBase.executeBatch(batch);
        Test.stopTest();

        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors FROM AsyncApexJob]; 
        System.assertEquals(batchId, job.Id, 'Batch not executed!');
        System.assertEquals('Completed', job.Status, 'Batch job did not complete');
        System.assertEquals(0, job.NumberOfErrors, 'Batch failed');
    }
}