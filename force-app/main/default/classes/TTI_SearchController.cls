public without sharing class TTI_SearchController {
    
    private static final String ERR_GENERIC_MESSAGE = 'Something went wrong. Please contact your administrator.';
    private static final String NO_LIST_ERROR_MESSAGE = 'We could not accurately locate the service request you are looking for. Please try again';

    /**
     * @description                 Search service request
     * 
     * @param claimNumber           Case number
     * @param displayOpenClaims     Toggle to show open or close cases
     */
    public static String doSearchServiceReq(String claimNumber, boolean displayOpenClaims) {
        return TTI_SearchController.doSearchServiceReq(claimNumber, '', '', '', '', '', '', displayOpenClaims, '', '', '');
    }

    /**
     * @description                 Detailed Search of service request
     * 
     * @param claimNumber           Case number
     * @param lastName              Customer LastName
     * @param email                 Customer Email
     * @param mobile                Customer Mobile Number
     * @param retailerId            Retailer Account
     * @param productId             Case Product
     * @param consignmentNumber     Case Freight Consignment Number
     * @param displayOpenClaims     Toggle to show open or close cases
     * @param jobNumber             Case Service Agent Number
     * @param fromDate              Custom Date Range - Start Date
     * @param toDate                Custom Date Range - End Date
     */
    @AuraEnabled
    public static String doSearchServiceReq(
        String claimNumber, 
        String lastName, 
        String email, 
        String mobile, 
        String retailerId, 
        String productId, 
        String consignmentNumber, 
        Boolean displayOpenClaims, 
        String jobNumber, 
        String fromDate, 
        String toDate) {
        AuraHandledException customException;
        try {
            String fields = getSOQLFields();
            String soql = 'SELECT {0} FROM Case {1}';
            String whereClause = 'WHERE RecordType.DeveloperName = \'Service_Request\' ';
            if (displayOpenClaims) {
                whereClause += ' AND Status != \'Closed\' ';
            }
         
            whereClause += createWhereClause('CaseNumber', 'LIKE', '%' + claimNumber + '%');
            whereClause += createWhereClause('TTI_Customer_Account__r.LastName', '=', lastName);
            whereClause += createWhereClause('TTI_Customer_Account__r.PersonEmail', '=', email);
            whereClause += createWhereClause('TTI_Customer_Account__r.PersonMobilePhone', '=', mobile);
            whereClause += createWhereClause('Retailer_Account__c', '=', retailerId);
            whereClause += createWhereClause('Product_Name__c', '=', productId);
            whereClause += createWhereClause('Freight_in_consignment_number__c', '=', consignmentNumber);
            whereClause += createWhereClause('TTI_Service_Agent_Job_Number__c', '=', jobNumber);
            whereClause += getUserSOQLFilter();
            
            if (String.isNotBlank(fromDate) && String.isNotBlank(toDate)) {
                Date startDate = Date.valueOf(fromDate);
                Date endDate = Date.valueOf(toDate);
                /**
                 * Compare only the Date
                 * Reference: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_date_functions.htm
                 */
                whereClause += ' AND (DAY_ONLY(CreatedDate) >= :startDate AND DAY_ONLY(CreatedDate) <= :endDate)';
            }

            List<sObject> lstSObject = Database.query(String.format(soql, new List<String>{ fields, whereClause }));
            if (!lstSObject.isEmpty()) {
                return JSON.serialize(lstSObject);
            } else {
                customException = new AuraHandledException(NO_LIST_ERROR_MESSAGE);
                customException.setMessage(NO_LIST_ERROR_MESSAGE);
                throw customException;
            }
            
        } catch (Exception err) {
            String errMessage = err.getMessage().indexOf(NO_LIST_ERROR_MESSAGE) != -1 ? NO_LIST_ERROR_MESSAGE : ERR_GENERIC_MESSAGE;
            customException = new AuraHandledException(errMessage);
            customException.setMessage(errMessage);
            throw customException;
        }
    }

    /**
     * @description                 Fetch SOQL fields
     */
    private static String getSOQLFields() {
        Set<String> fields = new Set<String>{
    		//09.09.2022:DJC:INC0024955:added the 'TTI_Service_Agent_Job_Number__c' field on the list.
            'TTI_Service_Agent_Job_Number__c',
            'AWS_Invoice_File_Key__c',
            'CaseNumber',
            'Store_Credits__c',
            'Claim_Type__c',
            'Field_Service_Status__c',
            'Fault_Codes__c',
            'Goodwill__c',
            'Goodwill_parts_only__c',
            'Id',
            'Invoice_Number_PC__c',
            'Label_Url__c',
            'Labour_Percentage_Discount__c',
            'OrderId__c',
            'OwnerId',
            'Parts_Percentage_Discount__c',
            'Payment_Reference__c',
            'Product_Fault_Category__c',
            'Product_Payment_Category__c',
            'Product_Size_Category__c',
            'Purchase_Order_Reference__c',
            'Repair_Type__c',
            'Retailer_Account__c',
            'Retailer_Email_Address__c',
            'SAP_Error_Text__c',
            'Service_Request_Milestone__c',
            'Shipment_Id__c',
            'Sundry_Expense_Reason__c',
            'SuppliedEmail',
            'SuppliedPhone',
            'Total_Invoice_Amount__c',
            'Total_Sundry_Expenses__c',
            'TTI_Count_parts_not_having_sap_number__c',
            'TTI_Customer_Account__c',
            'TTI_Customer_Delivery_Method__c',
            'TTI_Email_Notification_Opt_In__c',
            'TTI_Quote_to_Customer__c',
            'TTI_Quote_to_Retailer__c',
            'TTI_Service_Agent_Comments__c',
            'TTI_Time_Spent_Hours__c',
            'TTI_Time_Spent_Minutes__c',
            'MilestoneStatus',
            'Closed_Reason__c',
            'Priority',
            'Customer_Account__c',
            'Brand__c',
            'ProductId',
            'Serial_Number__c',
            'Serial_Number_not_found__c',
            'Fault_Description__c',
            'Purchase_Date__c',
            'Receipt_No__c',
            'Parts_Discount_Value__c',
            'Repair_Type__c',
            'Courier_Name__c',
            'TTI_Freight_in_tracking_url__c',
            'TTI_Freight_out_tracking_url__c',
            'SAP_order_number__c',
            'Freight_Out_Manifest_Order_Number__c',
            'Category__c',
            'SKU_Number__c',
            'Description',
            'Status',
            'Quantity__c',
            'Account.Allow_Delivery_to_Customers__c',
            'Asset.Receipt__c',
            'Asset.Name',
            'Contact.Email',
            'Contact.Phone',
            'Owner.Name',
            'Product_Name__r.Name',
            'Product_Name__r.SOH_BP01__c',
            'Product_Name__r.Technical_Drawing_URL__c',
            'Product_Name__r.Dangerous_Goods_Text__c',
            'Product_Name__r.SAP_MaterialNumber__c',
            'Product_Name__r.Height__c',
            'Product_Name__r.Length__c',
            'Product_Name__r.Width__c',
            'Product_Name__r.Weight__c',
            'Retailer_Account__r.Name',
            'Retailer_Account__r.Phone',
            'Retailer_Account__r.Delivery_Country__c',
            'Retailer_Account__r.Delivery_Postcode__c',
            'Retailer_Account__r.Delivery_State__c',
            'Retailer_Account__r.Delivery_Street__c',
            'Retailer_Account__r.Delivery_Suburb__c',
            'Service_Agent__r.Max_Claimable_Sundry_Expenses__c',
            'Service_Agent__r.Delivery_Country__c',
            'Service_Agent__r.Freight_Company__c',
            'Service_Agent__r.Company_Code__c',
            'Service_Agent__r.Name',
            'TTI_Customer_Account__r.Name',
            'TTI_Customer_Account__r.PersonMobilePhone',
            'TTI_Customer_Account__r.PersonHomePhone',
            'Number_of_Interactions__c'
        };
        return String.join(new List<String>(fields), ', ');
    }

    /**
     * @description                 Create SOQL where clause
     * 
     * @param fieldName             Field API Name
     * @param operator              SOQL filter operator(e.g. =, !=, <, >)
     * @param value                 Value to compare
     */
    private static String createWhereClause(String fieldName, String operator, String value) {
        String whereClause = '';
        String singleQuoteValue = String.escapeSingleQuotes(value);
        String enquoteValue = '\''+ singleQuoteValue + '\'';
        if (String.isNotBlank(value) && String.isNotBlank(operator)) {
            String template = ' AND {0} {1}';
            String escapedValue = operator + enquotevalue;
            whereClause = String.format(template, new List<Object> {fieldName, escapedValue});
        }
        return whereClause;
    }

    /**
     * @description                 Construct User SOQL filter. 
     *                              For managers or admins, fetch all all claims
     *                              otherwise be specific
     */
    private static String getUserSOQLFilter() {
        String filter = ' AND (Service_Agent__c = null ';
        Set<String> managerProfiles = new Set<String>{ 'System Administrator', '~ Customer Service', 'Customer Service' };
        User currUser = [SELECT Id, AccountId, Profile.Name FROM User where Id = :UserInfo.getUserId()];
        if (managerProfiles.contains(currUser.Profile.Name)) {
            filter += 'OR Service_Agent__c != null) ';
        } else {
            filter += (currUser.AccountId == null) ? ') ' : ' OR Service_Agent__c = \'' + currUser.AccountId + '\') ';
        }
        return filter;
    }
}