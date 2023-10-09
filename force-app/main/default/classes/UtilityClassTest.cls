@isTest
private class UtilityClassTest {
    
    private static testMethod void testGetRecordTypeIdbyName() {
        
        Test.startTest();
            Id recordTypeId = UtilityClass.getRecordTypeIdbyName('Redemptions__c', 'Internal');
            UtilityClass.dummyTest();
        Test.stopTest();
    }
    
    private static testMethod void testFieldSets() {
        Test.startTest();
            List<Schema.FieldSetMember> lstFieldSet = UtilityClass.readFieldSetToList('Active_Redemptions', 'Redemptions__c');
            System.debug('>>> lstFieldSet: ' + lstFieldSet);
            List<Schema.FieldSetMember> lstSoqlFieldSet = UtilityClass.constructFieldsFromFieldSet('Active_Redemptions', 'Redemptions__c');
            System.debug('>>> lstSoqlFieldSet: ' + lstSoqlFieldSet);
        Test.stopTest();
    }
    
    private static testMethod void testConstructQuery() {
        Test.startTest();
            String query = UtilityClass.constructSOQLQuery('Active_Redemptions', 'Redemptions__c', null, 10, null, true, false);
            System.debug('>>> query: ' + query);
        Test.stopTest();
    }

    private static testMethod void approvalProcessLastStepTest() {
        Product2 prod = new Product2(Name = 'Laptop X200', Family = 'Hardware', AU_Landed_Cost__c=null, NZ_Landed_Cost__c = null, Standard_Warranty_Months__c = -10.00);
        insert prod;
        
        Redemption_Campaigns__c redCampaign = new Redemption_Campaigns__c();
        redCampaign.Name = 'test';
        insert redCampaign;


        Redemptions__c red = new Redemptions__c();
        red.Redemption_Campaign__c = redCampaign.Id;
        insert red; 

        //Approval.ProcessSubmitRequest r = new Approval.ProcessSubmitRequest();
        //r.setObjectId(red.Id);
        //Approval.process(r);

        Test.startTest();
            UtilityClass.getApprovalProcessLastStep(red.Id);
        Test.stopTest();
    }

    private static testMethod void objectRecordTypeIdTest() {
        String endConsumerRTId = UtilityClass.getObjectRecordTypeId(Account.sObjectType, 'End Consumer');
    }

    private static testMethod void getPicklistValuesTest() {
        Map<String, Set<String>> mapObjAndPicklist = new Map<String, Set<String>>();
        mapObjAndPicklist.put('Account', new Set<String>{'Type'});
        Test.startTest();
            String picklistValues = UtilityClass.getPickListValuesToJSON(JSON.serialize(mapObjAndPicklist));
        Test.stopTest();
    }

    @isTest static void test_method_two() {
        
        String apiResponse = '{"predictions":[{"description" : "224 Princes Highway, Bairnsdale VIC, Australia","id" : "ba6091844fc2ac0c4dfb97587ad431328be43e88","matched_substrings":[{"length" : 3,'+
            '"offset" : 0}],"place_id" : "ChIJpyc7anZ_L2sRld1mZlaUpvs","reference" : "ClRGAAAAyOOyI9Of8rRwLUV9fnCEpk_z_40-YibkYgvOnQ2VHHGeQ6vaDc2wfRRc387Z9M9G0frM6QFN5XSimGeDLD7f6euULYBFuU8vrU72R1ksWw' +
            'ESEPqBBGmHknITxJ6jL-VipSsaFMfpHRsOo_vjJ-CHnKyLIuSdnkDE","structured_formatting" : {"main_text" : "224 Princes Highway", "main_text_matched_substrings" : [{"length" : 3, "offset" : 0}],' +
            '"secondary_text" : "Bairnsdale VIC, Australia" },"terms" : [{"offset" : 0,"value" : "224"},{"offset" : 4,"value" : "Princes Highway"},{"offset" : 21,"value" : "Bairnsdale"},{"offset" :' +
            '32,"value" : "VIC"},{"offset" : 37,"value" : "Australia"}],"types" : [ "street_address", "geocode" ]},],"status" : "OK"}';
        
        SingleRequestMock googleAPIMock = new SingleRequestMock(200,'OK', apiResponse , null);
        
        Map<String, HttpCalloutMock> endpoint2TestResp =
                                   new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put('http://api.example.com/accounts',googleAPIMock );

        Test.setMock(HttpCalloutMock.class, googleAPIMock );
        MILRedemptionController.getAddressAutoComplete('244','au');
    }

}