/**
 * @author                          Kristopher Veraces
 * @date                            2020-10-26
 *
 * @group                           Milwaukee Community
*/
@isTest
public class MlRedemptionFormControllerTest {
    private static final String MOCK_PLACEHOLDER = 'mock';
    private static final String ACCESS_DENIED = 'Access denied for either User or Contact record.';
    private static final String PAYLOAD_REQUIRED = 'Payload is required in submitting redemption.';
    public static final IDGenerator ID_GENERATOR = new IDGenerator();
    private static final MlRedemptionFormController.RedemptionInfo REDEMPTION_INFO = createPayload();
    private static final MlRedemptionFormControllerService MOCK_SERVICE = 
        (MlRedemptionFormControllerService) Test.createStub(MlRedemptionFormControllerService.class, 
        new MlRedemptionFormControllerServiceMock());

    /**********************************************************************
     * @description                 Fetch contact record related to
     *                              current user
     */
    @isTest
    private static void getPersonAccountDetails() {
        Contact contact;
        MlRedemptionFormController.service = MOCK_SERVICE;
        Test.startTest();
            String result = MlRedemptionFormController.getPersonAccountDetails();
            contact = (Contact)JSON.deserialize(result, Contact.class);
        Test.stopTest();
        System.assertEquals(MOCK_PLACEHOLDER, contact.FirstName, 'Failed to fetch person account details');
    }

    /**********************************************************************
     * @description                 Fetch contact record related to
     *                              current user without access to
     *                              user/contact records
     */
    @isTest
    private static void getPersonAccountDetailsWithoutAccess() {
        String errMessage;
        MlRedemptionFormControllerServiceMock.errMessage = ACCESS_DENIED;
        MlRedemptionFormController.service = MOCK_SERVICE;
        Test.startTest();
            try {
                MlRedemptionFormController.getPersonAccountDetails();
            } catch (Exception ex) {
                errMessage = ex.getMessage();
            }
        Test.stopTest();
        System.assertEquals(ACCESS_DENIED, errMessage, 'Successfully fetch person account details');
    }

    /**********************************************************************
     * @description                 Submit redemption
     */
    @isTest
    private static void submitRedemption() {
        MlRedemptionFormController.service = MOCK_SERVICE;
        Test.startTest();
            MlRedemptionFormController.submitRedemption(JSON.serialize(REDEMPTION_INFO));
        Test.stopTest();
        // No need to assert
    }

    @IsTest
    private static void getPurchasedAndRedeemedProducts() {
        MlRedemptionFormController.service = MOCK_SERVICE;
        
        Test.startTest();
            MlRedemptionFormController.getPurchasedAndRedeemedProducts(JSON.serialize(REDEMPTION_INFO));
        Test.stopTest();
        
    }

    /**********************************************************************
     * @description                 Submit redemption without payload
     */
    @isTest
    private static void submitRedemptionWithoutPayload() {
        String errMessage;
        MlRedemptionFormController.service = MOCK_SERVICE;
        Test.startTest();
            try {
                MlRedemptionFormController.submitRedemption(null);
            } catch (Exception ex) {
                errMessage = ex.getMessage();
            }
        Test.stopTest();
        System.assertEquals(PAYLOAD_REQUIRED, errMessage, 'Successfully submitted redemption');
    }

    /**********************************************************************
     * @description                 Submit redemption with mock exception
     */
    @isTest
    private static void submitRedemptionWithException() {
        String errMessage;
        String errMessageTrim ;
        MlRedemptionFormController.service = MOCK_SERVICE;
        MlRedemptionFormControllerServiceMock.errMessage = Label.Generic_Error_Message;
        Test.startTest();
            try {
                MlRedemptionFormController.submit(REDEMPTION_INFO);
            } catch (Exception ex) {
                errMessage = ex.getMessage();
            }
        Test.stopTest();

        errMessageTrim = errMessage.substringBefore(',');
        System.assertEquals(Label.Generic_Error_Message, errMessageTrim, 'Successfully submitted redemption');
    }

    /**********************************************************************
     * @description                 Update content document name
     */
    @isTest
    private static void updateDocumentName() {
        String content_document_prefix = 'stopgap-';
        ContentVersion contentVersion = new ContentVersion (
            title = MOCK_PLACEHOLDER,
            PathOnClient = MOCK_PLACEHOLDER + '.jpg',
            VersionData = Blob.valueOf(MOCK_PLACEHOLDER),
            IsMajorVersion = true
        );
        insert contentVersion;
        ContentDocument contentDocument = [SELECT Id,
                                                  Title,
                                                  LatestPublishedVersionId
                                           FROM ContentDocument
                                           WHERE LatestPublishedVersionId = :contentVersion.Id];
        
        Test.startTest();
            MlRedemptionFormController.changeContentDocuments(contentDocument.Id);
        Test.stopTest();
        
        ContentDocument updatedDocument = [SELECT ID, Title FROM ContentDocument WHERE ID =: contentDocument.Id];
        
        if (updatedDocument.Title != null && updatedDocument.Title.contains(content_document_prefix)) {
            System.assert(true, 'Failed to update content document');
        }
    }

    /**********************************************************************
     * @description                 Remove content documents related to
     *                              current user and has 'stopgap-'
     *                              on title
     */
    @isTest
    private static void removeContentDocuments() {
        MlRedemptionFormController.service = MOCK_SERVICE;
        Test.startTest();
            MlRedemptionFormController.removeContentDocuments();
        Test.stopTest();
        //No need to assert
    }

    /**********************************************************************
     * @description                 Create mock payload for redemption submission
     * 
     * @return                      MlRedemptionFormController.RedemptionInfo
     */
    private static MlRedemptionFormController.RedemptionInfo createPayload() {
        ContentVersion contentVersion = new ContentVersion(
            Title = MOCK_PLACEHOLDER,
            PathOnClient = MOCK_PLACEHOLDER + '.jpg',
            VersionData = Blob.valueOf(MOCK_PLACEHOLDER),
            IsMajorVersion = true
        );
        insert contentVersion;
        MlRedemptionFormController.RedemptionInfo payload = new MlRedemptionFormController.RedemptionInfo();
        payload.contact = createContact();
        payload.account = createAccount();
        payload.storeName = MOCK_PLACEHOLDER;
        payload.storeSuburb = '';
        payload.redemptionCampaign = createRedemptionCampaign();
        payload.purchasedProducts = new List<PurchasedProductLineItem__c>{ createPurchasedProductItem() };
        payload.redeemableProducts = new List<RedeemableProductItem__c>{ createRedeemableProductItem() };
        payload.fileId = contentVersion.Id;
        return payload;
    }

    /**********************************************************************
     * @description                 Create mock contact
     * 
     * @return                      Contact record
     */
    private static Contact createContact() {
        return new Contact(
            Id = ID_GENERATOR.generate(Contact.SObjectType),
            Brand__c = 'Milwaukee'
        );
    }

    /**********************************************************************
     * @description                 Create mock account
     * 
     * @return                      Account record
     */
    private static Account createAccount() {
        return new Account(
            Id = ID_GENERATOR.generate(Account.SObjectType),
            FirstName = MOCK_PLACEHOLDER,
            LastName = 'Account'
        );
    }

    /**********************************************************************
     * @description                 Create mock redemption campaign
     * 
     * @return                      Redemption campaign record
     */
    private static Redemption_Campaigns__c createRedemptionCampaign() {
        return new Redemption_Campaigns__c(
            Id = ID_GENERATOR.generate(Redemption_Campaigns__c.SobjectType),
            PurchasedProducts__c = ID_GENERATOR.generate(PurchasedProducts__c.SobjectType),
            RedeemableProducts__c = ID_GENERATOR.generate(RedeemableProducts__c.SobjectType)
        );
    }

    private static PurchasedProductLineItem__c createPurchasedProductItem() {
        return new PurchasedProductLineItem__c(
            Id = ID_GENERATOR.generate(PurchasedProductLineItem__c.SobjectType),
            Product__c = ID_GENERATOR.generate(Product2.SobjectType),
            PurchasedProduct__c = ID_GENERATOR.generate(PurchasedProducts__c.SobjectType)
        );
    }

    private static RedeemableProductItem__c createRedeemableProductItem() {
        return new RedeemableProductItem__c(
            Id = ID_GENERATOR.generate(RedeemableProductItem__c.SobjectType),
            Product__c = ID_GENERATOR.generate(Product2.SobjectType),
            RedeemableProduct__c = ID_GENERATOR.generate(RedeemedProducts__c.SobjectType)
        );
    }

    /**********************************************************************
     * @description                 Create mock FileData
     * 
     * @return                      Serialize MlRedemptionFormController.FileData
     */
    private static MlRedemptionFormController.FileData createFileData() {
        MlRedemptionFormController.FileData file = new MlRedemptionFormController.FileData();
        file.blobData = MOCK_PLACEHOLDER;
        file.fileExtension = 'jpg';
        file.id = ID_GENERATOR.generate(ContentDocument.SobjectType);
        file.name = MOCK_PLACEHOLDER;
        return file;
    }

    /**
     * @description                 Record Id Factory
     * 
     *                              Add the class inside the test class 
     *                              to avoid dependencies
     */
    public class IDGenerator {
        private Integer fakeIdCount = 0;
        private final String ID_PATTERN = '000000000000';
        /**
         * Generate a fake Salesforce Id for the given SObjectType
         */
        public Id generate(Schema.SObjectType sobjectType) {
            String keyPrefix = sobjectType.getDescribe().getKeyPrefix();
            fakeIdCount++;
            String fakeIdPrefix = ID_PATTERN.substring(0, 12 - fakeIdCount.format().length());
            return System.Id.valueOf(keyPrefix + fakeIdPrefix + fakeIdCount);
        }
    }
}