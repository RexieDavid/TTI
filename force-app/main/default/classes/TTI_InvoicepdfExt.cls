public class TTI_InvoicepdfExt {

    private final String TTI_PDF_SETTINGS_SERVICE_PORTAL_FORMAT = 'Service Portal - {0}';
    private final Datetime NEW_PAYOUT_SCHEME_START_DATE_TIME = DateTime.newInstance(2020, 7, 23, 0, 0, 0); // '2020/07/23 12:00 AM'

    public TTISettings ttiSettings { get; set; }
    public PDFLabels pdfLabels { get; set; }
    public Boolean isBonusVisible { get; set; }
    public Boolean isGSTVisible { get; set; }
    public Double totalAmount { get; set; }
    public Double totalGST { get; set; }
    public Double total { get; set; }

    public TTI_InvoicepdfExt(ApexPages.StandardController controller) {
        if (!Test.isRunningTest()) {
            controller.addFields(new List<String>{ 
                'TTI_Closed_Datetime__c',
                'Account.ShippingCountry',
                'Account.Company_Code__c',
                'Account.GST__c',
                'AccountId'
            });
        }

        Case claim = (Case) controller.getRecord();
        String country = this.getCountry(claim);
        String pdfSettingName = String.format(
            TTI_PDF_SETTINGS_SERVICE_PORTAL_FORMAT, 
            new List<String>{ country }
        );

        this.pdfLabels = new PDFLabels(country);
        this.ttiSettings = new TTISettings(TTIPDFSettings__c.getValues(pdfSettingName));
        this.isGSTVisible = country == 'NZ';
        this.compute(claim);
    }


    private String getCountry(Case claim) {
        String key;
        Map<String, String> countries = new Map<String, String>{
            'BP01' => 'AU',
            'NZ01' => 'NZ',
            'AUSTRALIA' => 'AU',
            'NEW ZEALAND' => 'NZ'
        };


        if (claim.AccountId != null) {
            if (String.isNotBlank(claim.Account.Company_Code__c)) {
                key = claim.Account.Company_Code__c.toUpperCase();
            }

            if (String.isBlank(key) && String.isNotEmpty(claim.Account.ShippingCountry)) {
                key = claim.Account.ShippingCountry.toUpperCase();
            }
        }

        if (String.isBlank(key)) {
            throw new TTI_InvoicepdfExtException('Missing account country/company code');
        }

        return countries.containsKey(key) ? countries.get(key) : key;
    }

    private void compute(Case claim) {
        Decimal totalAmount = 0;
        Decimal totalGST = 0;
        Boolean isBonusApplicable = claim.TTI_Closed_Datetime__c != null && claim.TTI_Closed_Datetime__c < NEW_PAYOUT_SCHEME_START_DATE_TIME;
        totalAmount += this.setValueToZeroIfNull(claim.TTI_BaseChargeCalculation__c) + 
            this.setValueToZeroIfNull(claim.Total_Sundry_Expenses__c);
        totalGST += this.setValueToZeroIfNull(claim.Base_GST_Payable_AUD__c) + 
            this.setValueToZeroIfNull(claim.Base_GST_Payable_NZD__c) + 
            this.setValueToZeroIfNull(claim.Sundry_Expense_GST_Payable__c);
        if (isBonusApplicable) {
            totalAmount += this.setValueToZeroIfNull(claim.TTI_BonusCalculation__c);
            totalGST += this.setValueToZeroIfNull(claim.Bonus_GST_Payable_NZD__c) + 
                this.setValueToZeroIfNull(claim.Bonus_GST_Payable_AUD__c);
        }


        this.totalAmount = totalAmount;
        this.totalGST = totalGST;
        this.total = totalAmount + totalGST;
        this.isBonusVisible = isBonusApplicable;
    }

    private Decimal setValueToZeroIfNull(Decimal value) {
        return value == null ? 0 : value;
    }

    public class PDFLabels {
        public String bn { get; set; }
        public String gst { get; set; }

        public PDFLabels(String country) {
            if (country == 'AU') {
                this.bn = 'ABN';
                this.gst = 'GST (10%)';
            } else if (country == 'NZ') {
                this.bn = 'NZBN';
                this.gst = 'GST (15%)';
            } else {
                this.bn = '';
                this.gst = '';
            }
        }
    }
    
    public class TTISettings {
        public String accountName { get; set; }
        public String street  { get; set; }
        public String city  { get; set; }
        public String state  { get; set; }
        public String postalCode  { get; set; }
        public String abn  { get; set; }
        public String paymentTerms  { get; set; }
        public String servicePaymentQueries  { get; set; }
        public String emailQueries  { get; set; }
        public String header { get; set; }
        public String subHeader { get; set; }
        public String gst { get; set; }

        public TTISettings(TTIPDFSettings__c ttiSettings) {
            this.accountName = ttiSettings.TTIAccountName__c;
            this.street = ttiSettings.TTIRCTIStreet__c;
            this.city = ttiSettings.TTIRCTICity__c;
            this.state = ttiSettings.TTIRCTIState__c;
            this.postalCode = ttiSettings.TTIRCTIPostalCode__c;
            this.abn = ttiSettings.TTIABN__c;
            this.paymentTerms = ttiSettings.PaymentTerms__c;
            this.servicePaymentQueries = ttiSettings.ServicePaymentQueries__c;
            this.emailQueries = ttiSettings.Email_Queries__c;
            this.header = ttiSettings.Header__c;
            this.subHeader = ttiSettings.Sub_Header__c;
            this.gst = ttiSettings.GST__c;
        }
    }

    private class TTI_InvoicepdfExtException extends Exception {}
}