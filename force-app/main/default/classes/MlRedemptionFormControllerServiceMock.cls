/**
 * @author                          Kristopher Veraces
 * @date                            2020-10-26
 *
 * @group                           Milwaukee Community
*/
@isTest
public class MlRedemptionFormControllerServiceMock implements System.StubProvider {
    private final String MOCK_PLACEHOLDER = 'mock';
    private final String SUCCESS_MESSAGE = 'success';
    public static String errMessage;

    /*
     * @description         use to define method of a stubbed class
     */
    public Object handleMethodCall(
            Object stubbedObject, 
            String stubbedMethodName, 
            Type returnType, 
            List<Type> listOfParamTypes, 
            List<String> listOfParamNames, 
            List<Object> listOfArgs) {

        switch on stubbedMethodName {
            when 'getPersonAccountDetails' {
                this.throwErrorMessage();
                return this.createContact();
            }
            when 'getSiteSettings' {
                return new Community_Setting__mdt(MasterLabel = this.MOCK_PLACEHOLDER);
            }
            when 'upsertRecord' {
                this.throwErrorMessage();
                return this.createMockId(listOfArgs[0]);
            }
            when 'upsertRecords' {
                this.throwErrorMessage();

                List<String> ids = new List<String>();

                for (Sobject sobj : (List<SObject>) listOfArgs[0]) {
                    ids.add((String) this.createMockId(sobj));
                }

                return ids;
            }
            when 'fetchContentVersion' {
                this.throwErrorMessage();
                return this.createContentVersion();
            }
            when 'fetchContentDocument' {
                return this.createContentDocument();
            }
            when 'deleteContentDocuments' {
                this.throwErrorMessage();
                return this.SUCCESS_MESSAGE;
            }
            when 'getPurchaseProductLineItems' {
                this.throwErrorMessage();
                return new List<PurchasedProductLineItem__c>{ this.createPurchasedProductLineItem() };
            }
            when 'getRedeemableProducts' {
                this.throwErrorMessage();
                return new List<RedeemableProductItem__c>{ this.createRedeemableProductItem() };
            }
            when else {
                NoSuchElementException nsee = new NoSuchElementException();
                nsee.setMessage('The method called currently isn\'t set up and cannot be mocked.');
                throw nsee;
            }
        }
    }

    /**********************************************************************
     * @description                 Throw an error if any
     */
    private void throwErrorMessage() {
        if (String.isNotBlank(errMessage)) {
            throw new MlRedemptionFormControllerServiceMockException(errMessage);
        }
    }

    /**********************************************************************
     * @description                 Create mock contact
     * 
     * @return                      Serialize contact record
     */
    private String createContact() {
        Contact contact = new Contact(FirstName = this.MOCK_PLACEHOLDER, LastName = 'contact');
        return JSON.serialize(contact);
    }

    /**********************************************************************
     * @description                 Create mock Id depending on sObjecttype
     * 
     * @param obj                   Record
     * 
     * @return                      Mock Id
     */
    private String createMockId(Object obj) {
        SObject sobj = (SObject)obj;
        return MlRedemptionFormControllerTest.ID_GENERATOR.generate(sobj.getSObjectType());
    }

    /**********************************************************************
     * @description                 Create mock content version
     * 
     * @return                      Content Version record
     */
    private ContentVersion createContentVersion() {
        ContentVersion contentVersion = new ContentVersion(
            title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf(this.MOCK_PLACEHOLDER),
            IsMajorVersion = true
        );
        insert contentVersion;
        return [SELECT Id, Title, FileExtension, VersionData FROM ContentVersion WHERE Id = :contentVersion.Id];
    }

    /**********************************************************************
     * @description                 Create mock content document
     * 
     * @return                      Content document record
     */
    private ContentDocument createContentDocument() {
        return new ContentDocument(
            Id = MlRedemptionFormControllerTest.ID_GENERATOR.generate(ContentDocument.getSObjectType()), //Required to add title
            Title = this.MOCK_PLACEHOLDER
        );
    }

    private PurchasedProductLineItem__c createPurchasedProductLineItem() {
        return new PurchasedProductLineItem__c(
            Id = MlRedemptionFormControllerTest.ID_GENERATOR.generate(PurchasedProductLineItem__c.getSObjectType())
        );
    }

    private RedeemableProductItem__c createRedeemableProductItem() {
        return new RedeemableProductItem__c(
            Id = MlRedemptionFormControllerTest.ID_GENERATOR.generate(RedeemableProductItem__c.getSObjectType())
        );
    }

    public class MlRedemptionFormControllerServiceMockException extends Exception {}
}