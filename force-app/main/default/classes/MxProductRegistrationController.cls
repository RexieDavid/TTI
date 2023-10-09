/**********************************************************************
 * @author        Samuel Oberes
 * @date          2020-07-17
 *
 * @group         MX Community
 * @group-content ../../ApexDocContent/mx-community.html
 *
 * @description   The MX community's product registration controller
 */
public without sharing class MxProductRegistrationController {
    private static String userAccountId;
    private static String personAccountRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
    private static final Integer OK_STATUS_CODE = 200;
    private static final Integer BAD_REQUEST_STATUS_CODE = 400;
    private static final Integer INTERNAL_SERVER_ERROR_STATUS_CODE = 500;
    private static final Id CONNECTED_APP_ADMIN_ID = [SELECT Id, Name FROM User WHERE Name = 'Connected App Administrator' LIMIT 1].Id;

    /**
     * @description                 Process MX Registration
     * 
     * @param payload               MxRegistrationDetails
     *                                  - Account
     *                                  - MX_Fuel_Registration__c
     *                                  - MX_Fuel_Registration_Product__c
     *                                  - Consumed Serial Numbers
     */
    @AuraEnabled
    public static String register(String payload) {
        Savepoint sp = Database.setSavepoint();
        MxProductRegistrationResponse response;
        MxRegistrationDetails data = (MxRegistrationDetails)JSON.deserialize(payload, MxRegistrationDetails.class);
        List<Account> matchAccounts = findAccountMatch(data.account.PersonEmail);
        Boolean isExist = !matchAccounts.isEmpty();
        String accountId = isExist ? String.valueOf(matchAccounts[0].Id) : data.externalId;

        // Validate server-side serial numbers
        if (!areSerialNumbersValid(data.consumedSerialNumbers)) {
            return JSON.serialize(new MxProductRegistrationResponse(BAD_REQUEST_STATUS_CODE, 'Serial number mismatch'));
        }

        // Process data
        processAccount(data.account, isExist, accountId);
        processRegistration(data, isExist, accountId);
        processRegisteredProducts(data);

        List<SObject> sobjects = new List<SObject>{ data.account, data.registration };
        sobjects.addAll(data.products);
        sobjects.addAll(fetchSerialNumbers(data.consumedSerialNumbers));

        try {
            upsert sobjects;
            Boolean isSuccess = submitRegistrationForApproval(data.registration.Id); // Submit registration for approval
            if (!isSuccess) {
                throw new MxProductRegistrationControllerException(Label.Generic_Error_Message);
            }
            return JSON.serialize(new MxProductRegistrationResponse(OK_STATUS_CODE, 'Thank you for registering your product.'));
        } catch(Exception ex) {
            Database.rollback(sp);
            return JSON.serialize(new MxProductRegistrationResponse(INTERNAL_SERVER_ERROR_STATUS_CODE, Label.Generic_Error_Message));
        }
    }

    /**
     * @description                 Validate if acccount with same email exists in salesforce
     * 
     * @return                      Account records
     */
    private static List<Account> findAccountMatch(String email) {
        return [SELECT Id
                FROM Account
                WHERE PersonEmail = :email
                AND Brand__pc = 'Milwaukee'
                AND RecordTypeId = :personAccountRecordtypeId];
    }

    /**
     * @desription                  Update account Id or External Id
     */
    private static void processAccount(Account account, Boolean isExist, String accountId) {
        String field = isExist ? 'Id' : 'External_Id__c';
        account.put(field, accountId);
        account.RecordTypeId = personAccountRecordtypeId;
        account.OwnerId = CONNECTED_APP_ADMIN_ID;
    }

    /**
     * @description                 Update MX_Fuel_Registration__c details
     *                                  - Link registration to user account (Dealer__c)
     *                                  - Link registration to account record (Customer_Account__c)
     */
    private static void processRegistration(MxRegistrationDetails data, Boolean isAccountExist, String accountId) {
        data.registration.Dealer__c = fetchUserAccountId();
        data.registration.External_Id__c = data.externalId;
        if (isAccountExist) {
            data.registration.Customer_Account__c = accountId;
        } else {
            data.registration.Customer_Account__r = new Account(External_Id__c = accountId);
        }
    }

    /**
     * @description                 Fetch user account Id
     */
    private static String fetchUserAccountId() {
        if (String.isBlank(userAccountId)) {
            userAccountId = [SELECT Contact.AccountId
                            FROM User
                            WHERE Id = :UserInfo.getUserId()
                            LIMIT 1].Contact.AccountId;
        }

        return userAccountId;
    }

    /**
     * @description                 Update MX_Fuel_Registration_Product__c details
     *                                  - Link registration product to new registration record
     */
    private static void processRegisteredProducts(MxRegistrationDetails data) {
        for (MX_Fuel_Registration_Product__c product : data.products) {
            product.MX_Fuel_Registration__r = new MX_Fuel_Registration__c(External_Id__c = data.externalId);
        }
    }

    /**
     * @description                 Update status of consumed serial number
     */
    private static List<MX_Serial_Numbers__c> fetchSerialNumbers(Set<String> ids) {
        List<MX_Serial_Numbers__c> serialNumbers = new List<MX_Serial_Numbers__c>();
        for (MX_Serial_Numbers__c serialNumber: [SELECT Id,
                                                        Status__c
                                                 FROM MX_Serial_Numbers__c 
                                                 WHERE Id IN :ids]) {
            serialNumber.Status__c = 'Consumed';
            serialNumbers.add(serialNumber);
        }
        return serialNumbers;
    }


    /**
     * @description                 Validate if all serial numbers are available
     *                              Can be check if id collection length is same with
     *                              SOQL response
     */
    private static Boolean areSerialNumbersValid(Set<String> ids) {
        List<MX_Serial_Numbers__c> serialNumbers = [SELECT Id 
                                                    FROM MX_Serial_Numbers__c
                                                    WHERE Id IN :ids
                                                    AND Status__c = 'Available'];
        return ids.size() == serialNumbers.size();
    }

    /**
     * @description                 Submit record for approval
     * 
     * @param {String} recordId     MX Product Registration recordId
     */
    private static Boolean submitRegistrationForApproval(String recordId) {
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();  
        req.setObjectId(recordId);
        Approval.ProcessResult result =  Approval.process(req);
        return result.isSuccess();
    }

    /**
     * @description                 Wrapper class for registration
     */
    public class MxRegistrationDetails {
        public String externalId { get; set; }
        public Account account { get; set; }
        public MX_Fuel_Registration__c registration { get; set; }
        public List<MX_Fuel_Registration_Product__c> products { get; set; }
        public Set<String> consumedSerialNumbers { get; set; }
    }

    public class MxProductRegistrationResponse {
        Integer statusCode { get; set; }
        String message { get; set; }
        public MxProductRegistrationResponse(Integer statusCode, String message) {
            this.statusCode = statusCode;
            this.message = message;
        }
    }

    public class MxProductRegistrationControllerException extends Exception {}
}