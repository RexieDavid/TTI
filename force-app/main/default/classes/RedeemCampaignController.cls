global class RedeemCampaignController {
    private final String BRAND = 'AEG';
    private final String INVALID_LINK_ERROR = 'You have already redeemed a product using the link.';
    private final String INVALID_LINK_PARAMS_ERROR = 'Missing URL Parameters';
    private final String TOKEN_NOT_FOUND_ERROR = 'Token not found';
    private Case claim { get; set; }

    public List<Product2> productList { get; set; }
    public String productId { get; set; }
    public String productCode { get; set; }
    public String street { get; set; }
    public String suburb { get; set; }
    public String zipcode { get; set; }
    public String region { get; set; }
    public String sessionId { get; set; }
    public String errorMessage { get;set; }
    public Boolean isValidSession { get;set; }
    public Redemption_Campaigns__c campaign { get; set; }
    public Contact contact { get; set; }
    public Product2 selectedProduct { get; set; }
    public String contactIdFromURL { get; set; }
    public Boolean hasSelectedProduct {
        get {
            return selectedProduct != null;
        }
        set;
    }

    public String pageContactId {
        get {
            return Apexpages.currentPage().getParameters().get('ContactId');
        } 
        set;
    }

    /**
     * @description                 Constructor
     * 
     * @param controller            Standard Controller
     */
    public RedeemCampaignController(ApexPages.StandardController controller) {
        this.init();
    }

    /**
     * @description                 Constructor
     */
    public RedeemCampaignController() {
        this.init();
    }

    /**
     * @description                 Initialize values in the page
     */
    public void init() {
        this.setDefaultValues();
        if (this.isValidSession) {
            this.campaign = this.getRedemptionCampaign();
            if (this.campaign != null) {
                this.contact = this.getContact();
                this.productList = this.getProductList();
            }
        }
    }

    /**
     * @description                 Set Default values(e.g., session Id, isValidSession, etc..)
     */
    public void setDefaultValues() {
        this.sessionId = Apexpages.currentPage().getParameters().get('TokenId');
        this.isValidSession = this.validate();
    }

    /**
     * @description                 Get contact details
     * 
     * @return                       Contact record
     */
    public Contact getContact() {
        return [SELECT Id,
                       FirstName,
                       LastName,
                       MobilePhone,
                       Phone,
                       Email,
                       Country__c
                FROM Contact
                WHERE Id = :this.pageContactId];
    }

    /**
     * @description                 Get RAF Redemption Campaign
     * 
     *                              In instance that there are multiple
     *                              RAF campaigns found, it will retrieve
     *                              the oldest one.
     * 
     * @return                      Contact record
     */
    public Redemption_Campaigns__c getRedemptionCampaign() {
        List<Redemption_Campaigns__c> campaigns = [SELECT Id,
                                                          RedeemableProducts__c,
                                                          RedeemableProducts__r.RedeemType__c,
                                                          PurchasedProducts__c
                                                   FROM Redemption_Campaigns__c
                                                   WHERE RAF__c = TRUE
                                                   AND Brand__c = :this.BRAND
                                                   AND Valid_From__c <= TODAY
                                                   AND Valid_To__c >= TODAY
                                                   AND PurchasedProducts__c != NULL
                                                   AND RedeemableProducts__c != NULL];
        return campaigns.isEmpty() ? null : campaigns[0];
    }

    /**
     * @description                 Get product details
     * 
     * @return                      List of products
     */
    public List<Product2> getProductList() {
        return [SELECT Id,
                       Image_URL__c,
                       Name,
                       ProductCode,
                       Brand__c
               FROM Product2
               WHERE Id IN (SELECT Product__c 
                            FROM RedeemableProductItem__c
                            WHERE RedeemableProduct__c = :this.campaign.RedeemableProducts__c)];     
    }

    /**
     * @description                 Validate page details. See criteria below:
     *                                  - Must have required parametrs
     *                                  - Case is existing
     *                                  - Don't have any existing RAF Redemptions
     * 
     * @return                      Is Valid or Not
     */
    public Boolean validate() {
        Boolean hasRequiredParams = this.validateParams();
        if (!hasRequiredParams) {
            this.setErrorMessage(this.INVALID_LINK_PARAMS_ERROR);
            return false;
        }

        this.claim = this.getCase();
        if (this.claim == null) {
            this.setErrorMessage(this.TOKEN_NOT_FOUND_ERROR);
            return false;
        }

        Boolean isValid = this.hasExistingRedemption(this.claim.Id);
        if (!isValid) {
            this.setErrorMessage(this.INVALID_LINK_ERROR);
        }
        return isValid;
    }

    /**
     * @description                 Validate URL has the following required parameters:
     *                                  - TokenId
     *                                  - ContactId
     * 
     * @return                      Has required URL parameters or not
     */
    public Boolean validateParams() {
        return String.isNotBlank(this.sessionId) && String.isNotBlank(this.pageContactId);
    }

    /**
     * @description                 Get case record filtered via sessionId
     * 
     * @return                      Case record
     */
    public Case getCase() {
        List<Case> cases = [SELECT Id, 
                                   Case_Encrypted_Id__c 
                            FROM Case 
                            WHERE Case_Encrypted_Id__c = :this.sessionId 
                            LIMIT 1];
        return cases.isEmpty() ? null : cases[0];
    }

    /**
     * @description                 Validate if there are redemptions that have
     *                              the related to the given caseId
     * 
     * @param caseId                Case record Id
     * 
     * @return                      Case has existing redemptions or not
     */
    public Boolean hasExistingRedemption(String caseId) {
        List<Redemptions__c> redemptions = [SELECT Id 
                                            FROM Redemptions__c 
                                            WHERE Case__c = :caseId
                                            AND Name__c = :this.pageContactId];
        return redemptions.isEmpty();
    }

    /**
     * @description                 Set error message in the page
     */
    public void setErrorMessage(String message) {
        this.errorMessage = message;
    }

    /**
     * @description                 Set selected product based on the button clicked
     */
    public void setSelectedProduct() {
        for (Product2 product : this.productList) {
            if (product.Id == this.productId) {
                this.selectedProduct = product;
            }
        }
    }

    /**
     * @description                 Create redemption record
     */
    public void createRedemptionRecord() {
        Savepoint sp = Database.setSavePoint();
        try {
            RedeemedProducts__c redeemedProduct = createRedeemedProduct();
            this.createRedeemedItems(redeemedProduct.Id);
            insert this.buildRedemption(redeemedProduct.Id);
            updateContactAddress(contact.Id);
        } catch (Exception ex) {
            Database.rollback(sp);
        }
    }

    /**
     * @description                 Update contact record
     */
    private void updateContactAddress(Id contactId) {
        Contact contact = new Contact(
            Id = contactId,
            MailingStreet = street,
            MailingCity = suburb,
            MailingPostalCode = zipcode,
            MailingState = region
        );

        update contact;
    }

    /**
     * @description                 Build redemption details
     * 
     * @param redeemedProductId     Redeemed Product record Id
     * 
     * @return                      Redemption object without Id
     */
    private Redemptions__c buildRedemption(String redeemedProductId) {
        String recordTypeId = Schema.SObjectType.Redemptions__c.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        return new Redemptions__c(
            Redemption_Campaign__c = this.campaign.Id,
            RecordTypeId = recordTypeId,
            RAF__c = true,
            Brand__c = this.BRAND,
            Product_Codes__c = this.selectedProduct.ProductCode,
            PurchasedProducts__c= this.campaign.PurchasedProducts__c,
            RedeemedProducts__c = redeemedProductId,
            Name__c = this.contact.Id,
            Captured_Email_Address__c = this.contact.Email,
            Captured_FirstName__c = this.contact.FirstName,
            Captured_Mobile__c = this.contact.MobilePhone,
            Captured_Surname__c = this.contact.LastName,
            Captured_Phone__c = this.contact.Phone, 
            Captured_Street_Number__c = this.street,
            Captured_Suburb__c = this.suburb, 
            Captured_Postcode__c = this.zipcode, 
            Captured_Region__c = this.region,
            Case__c = this.claim.Id
        );
    }

    /**
     * @description                 Create Redeemed Product record
     * 
     * @return                      Redeemed Product object with Id
     */
    private RedeemedProducts__c createRedeemedProduct() {
        RedeemedProducts__c record = new RedeemedProducts__c();
        insert record;
        return record;
    }

    /**
     * @description                 Create Redeemed Product Item record/s
     * 
     * @param parentId              Redeemed Product Id
     * 
     * @return                      Redeemed Product object with Id
     */
    public void createRedeemedItems(String parentId) {
        Boolean isAllRedeemable = this.campaign.RedeemableProducts__r.RedeemType__c == 'All';
        List<RedeemedProductItem__c> redeemedItems = new List<RedeemedProductItem__c>();
        for (RedeemableProductItem__c item : [SELECT Product__c,
                                                     Quantity__c 
                                              FROM RedeemableProductItem__c 
                                              WHERE RedeemableProduct__c = :this.campaign.RedeemableProducts__c]) {
            if (isAllRedeemable) {
                redeemedItems.add(createRedeemedProductItem(parentId, item));
            } else {
                if (item.Product__c == this.selectedProduct.Id) {
                    redeemedItems.add(createRedeemedProductItem(parentId, item));
                }
            } 
        }
        insert redeemedItems;
    }

    /**
     * @description                 Build Redeemed Product Item
     * 
     * @return                      Redeemed Product Item object without Id
     */
    public static RedeemedProductItem__c createRedeemedProductItem(String parentId, RedeemableProductItem__c item) {
        return new RedeemedProductItem__c(
            Product__c = item.Product__c,
            Quantity__c = item.Quantity__c,
            RedeemedProduct__c = parentId
        );
    }
}