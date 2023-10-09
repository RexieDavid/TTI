@IsTest
public class TTI_InvoicepdfExtTest {

    private static final String SETTINGS_SERVICE_PORTAL = 'Service Portal - AU';
    private static final String SETTINGS_ACCOUNT_NAME = 'Techtronic Industries Pty Ltd';
    private static final String SETTINGS_STREET = '21 Kelletts Road';
    private static final String SETTINGS_CITY = 'Rowville';
    private static final String SETTINGS_STATE = 'VIC';
    private static final String SETTINGS_POSTAL_CODE = '3108';
    private static final String SETTINGS_ABN = '98002277509';
    private static final String SETTINGS_PAYMENT_TERMS = '14 days from invoice date';
    private static final String SETTINGS_SERVICE_PAYMENT_QUERIES = 'accounts.payable@ttibrands.com.au';
    private static final String SETTINGS_EMAIL_QUERIES = 'warranty@ttibrands.com.au';

    @TestSetup
    static void makeData() {
        TTIPDFSettings__c pdfSetting = new TTIPDFSettings__c(
            Name = SETTINGS_SERVICE_PORTAL,
            TTIAccountName__c = SETTINGS_ACCOUNT_NAME,
            TTIRCTIStreet__c = SETTINGS_STREET,
            TTIRCTICity__c = SETTINGS_CITY,
            TTIRCTIState__c = SETTINGS_STATE,
            TTIRCTIPostalCode__c = SETTINGS_POSTAL_CODE,
            TTIABN__c = SETTINGS_ABN,
            PaymentTerms__c = SETTINGS_PAYMENT_TERMS,
            ServicePaymentQueries__c = SETTINGS_SERVICE_PAYMENT_QUERIES,
            Email_Queries__c = SETTINGS_EMAIL_QUERIES
        );

        insert pdfSetting;

        Account acct = new Account();
        acct.Name = 'Test';
        acct.ShippingCountry = 'Australia';
        acct.Company_Code__c = 'BP01';
        acct.GST__c = '0000001';
        insert acct;

        Case claim = new Case();
        claim.TTI_Closed_Datetime__c = Date.valueOf('2020-07-22');
        claim.Base_GST_Payable_AUD__c = 1;
        claim.Base_GST_Payable_NZD__c = 1;
        claim.Sundry_Expense_GST_Payable__c = 1;
        claim.Base_Amount_Payable_AUD__c  = 1; // TTI_BaseChargeCalculation__c
        claim.Base_Amount_Payable_NZD__c  = 1; // TTI_BaseChargeCalculation__c
        claim.Total_Sundry_Expenses__c = 1;
        claim.Bonus_GST_Payable_AUD__c = 1;
        claim.Bonus_GST_Payable_NZD__c = 1;
        claim.Bonus_Amount_Payable_AUD__c  = 1; // TTI_BonusCalculation__c
        claim.Bonus_Amount_Payable_NZD__c  = 1; // TTI_BonusCalculation__c
        claim.AccountId = acct.Id;
        insert claim;
    }
    
    @IsTest
    static void testTTISettings() {
        TTI_InvoicepdfExt ext;

        Case claim = [
            SELECT Id,
                   TTI_Closed_Datetime__c,
                   Base_GST_Payable_AUD__c,
                   Base_GST_Payable_NZD__c,
                   Sundry_Expense_GST_Payable__c,
                   TTI_BaseChargeCalculation__c,
                   Total_Sundry_Expenses__c,
                   Bonus_GST_Payable_AUD__c,
                   Bonus_GST_Payable_NZD__c,
                   Bonus_Amount_Payable_AUD__c,
                   Bonus_Amount_Payable_NZD__c,
                   TTI_BonusCalculation__c,
                   Account.ShippingCountry,
                   Account.Company_Code__c,
                   Account.GST__c
              FROM Case
             LIMIT 1
        ];

        Test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(claim);            
            ext = new TTI_InvoicepdfExt(sc);
        Test.stopTest();
        
        System.assertEquals(SETTINGS_ACCOUNT_NAME, ext.ttiSettings.accountName, 'Invalid account name');
        System.assertEquals(SETTINGS_STREET, ext.ttiSettings.street, 'Invalid street');
        System.assertEquals(SETTINGS_CITY, ext.ttiSettings.city, 'Invalid city');
        System.assertEquals(SETTINGS_STATE, ext.ttiSettings.state, 'Invalid state');
        System.assertEquals(SETTINGS_POSTAL_CODE, ext.ttiSettings.postalCode, 'Invalid postal code');
        System.assertEquals(SETTINGS_ABN, ext.ttiSettings.abn, 'Invalid ABN');
        System.assertEquals(SETTINGS_PAYMENT_TERMS, ext.ttiSettings.paymentTerms, 'Invalid payment terms');
        System.assertEquals(SETTINGS_SERVICE_PAYMENT_QUERIES, ext.ttiSettings.servicePaymentQueries, 'Invalid service payment queries');
        System.assertEquals(SETTINGS_EMAIL_QUERIES, ext.ttiSettings.emailQueries, 'Invalid email queries');
    }

    @IsTest
    static void testShowBonusFields() {
        TTI_InvoicepdfExt ext;

        Case claim = [
            SELECT Id,
                   TTI_Closed_Datetime__c,
                   Base_GST_Payable_AUD__c,
                   Base_GST_Payable_NZD__c,
                   Sundry_Expense_GST_Payable__c,
                   TTI_BaseChargeCalculation__c,
                   Total_Sundry_Expenses__c,
                   Bonus_GST_Payable_AUD__c,
                   Bonus_GST_Payable_NZD__c,
                   Bonus_Amount_Payable_AUD__c,
                   Bonus_Amount_Payable_NZD__c,
                   TTI_BonusCalculation__c,
                   Account.ShippingCountry,
                   Account.Company_Code__c,
                   Account.GST__c
              FROM Case
             LIMIT 1
        ];

        Test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(claim);            
            ext = new TTI_InvoicepdfExt(sc);
        Test.stopTest();        

        System.assertEquals(5, ext.totalAmount, 'Total amount should be 5.');
        System.assertEquals(5, ext.totalGST, 'Total GST should be 5.');
        System.assertEquals(10, ext.total, 'Total should be 10.');
    }    

    @IsTest
    static void testHideBonusFields() {
        TTI_InvoicepdfExt ext;

        Case claim = [SELECT Id, TTI_Closed_Datetime__c FROM Case LIMIT 1];
        claim.TTI_Closed_Datetime__c = Date.valueOf('2020-07-24');
        update claim;

        claim = [
            SELECT Id,
                   TTI_Closed_Datetime__c,
                   Base_GST_Payable_AUD__c,
                   Base_GST_Payable_NZD__c,
                   Sundry_Expense_GST_Payable__c,
                   TTI_BaseChargeCalculation__c,
                   Total_Sundry_Expenses__c,
                   Bonus_GST_Payable_AUD__c,
                   Bonus_GST_Payable_NZD__c,
                   TTI_BonusCalculation__c,
                   Account.ShippingCountry,
                   Account.Company_Code__c,
                   Account.GST__c
              FROM Case
             WHERE Id = :claim.Id
             LIMIT 1
        ];

        Test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(claim);            
            ext = new TTI_InvoicepdfExt(sc);
        Test.stopTest();        

        System.assertEquals(3, ext.totalAmount, 'Total amount should be 3.');
        System.assertEquals(3, ext.totalGST, 'Total GST should be 3.');
        System.assertEquals(6, ext.total, 'Total should be 6.');
    }
}