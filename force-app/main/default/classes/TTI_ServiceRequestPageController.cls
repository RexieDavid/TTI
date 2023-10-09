public without sharing class TTI_ServiceRequestPageController {

    @AuraEnabled
    public static String getCasedeatils(String whereQuery, String fields) {
        List<Case> lstcase = new List<Case>();
        string result = '';
        if (fields != null && fields != '' && whereQuery != null && whereQuery != '') {
            List<User> lstUser = [SELECT Id, AccountId, Profile.Name, UserRole.Name FROM User where Id = :UserInfo.getUserId()];
            String userId = lstUser[0].Id;
            String accId = lstUser[0].AccountId;
            String profileName = lstUser[0].Profile.Name;
            String userRole = lstUser[0].UserRole.Name;

            if (profileName == 'System Administrator' || profileName == '~ Customer Service' || profileName == 'Customer Service') {

            } else {
                if (userRole != null && userRole.contains('Customer Manager')) {
                    whereQuery = 'Service_Agent__c = :accId AND ' + whereQuery;
                } else {
                    whereQuery = 'Diagnosed_User__c = :userId AND Service_Agent__c = :accId AND ' + whereQuery;
                }
            }
            
            String strQuery = 'SELECT ' + fields + ' FROM Case WHERE ' + whereQuery;
            System.debug(strQuery);
            lstcase = Database.query(strQuery);
            result = JSON.serialize(lstcase);
        }

        return result;
    }

    @AuraEnabled
    public static string doSearchServiceReq(String caseNumber) {
        return TTI_SearchController.doSearchServiceReq(caseNumber, false);
    }

    @AuraEnabled
    public static User getUserType() {
        return TTI_ServiceRequestControllerV2.getUserType();
    }

    @AuraEnabled
    public static String getTableMaxRecords() {
        return TTIBrandsHelperClass.getTableMaxRecords();
    }
}