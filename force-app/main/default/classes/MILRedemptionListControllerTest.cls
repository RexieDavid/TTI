@isTest
public without sharing class MILRedemptionListControllerTest {

    /**********************************************************************
     * @description     Setup test data
     */
    @testSetup
    static void initData() {
        User sysAdminUser = MyMilwaukeeTestDataFactory.createSystemAdminUser();
        insert sysAdminUser;

        Account portalAcct;
        Contact portalCntct;
        User portalUser;
        System.runAs(sysAdminUser) {
            portalAcct = MyMilwaukeeTestDataFactory.createPersonAccount('Doe');
            insert portalAcct;

            portalCntct = [SELECT Id FROM Contact WHERE AccountId = :portalAcct.Id];
            
            Profile communityMilwaukeeProfile = [SELECT Id, Name FROM Profile WHERE UserType = 'CspLitePortal' LIMIT 1];
            
            portalUser = MyMilwaukeeTestDataFactory.createCustomerCommunityMilwaukeeUser(portalCntct.Id);
            insert portalUser;
        }

        System.runAs(portalUser) {
            List<Product2> newProductsList = new List<Product2>();
            List<Redemptions__c> newRedemptionsList = new List<Redemptions__c>();
            List<Redemption_Campaigns__c> newRedCampsList = new List<Redemption_Campaigns__c>();

            //Insert New product
            newProductsList = MILTestUtilityClass.createProduct(10);
            for (Integer index = 0; index < newProductsList.size(); index++ ) {
                newProductsList[index].ProductCode += String.valueOf(index);
                newProductsList[index].Name += String.valueOf(index);
                newProductsList[index].Customer_Facing_Name__c = 'Customer Name - ' + index;
                newProductsList[index].Kit__c = true;
            }
            insert newProductsList;

            for (Integer index = 0; index < newProductsList.size(); index += 2 ) {
                //Insert Redemption Campaign
                Redemption_Campaigns__c newRedCamp = createRedemptionCampaign('Camp-' + index, 'Milwaukee', 'anz', 14, newProductsList.get(index).Id, newProductsList.get(index + 1).Id);
                newRedCampsList.add(newRedCamp);
            }

            insert newRedCampsList;

            for (Integer index = 0; index < 5; index++ ) {
                Redemptions__c newRedemption = new Redemptions__c();
                newRedemption.Name__c = portalCntct.Id;
                newRedemption.Redemption_Campaign__c = newRedCampsList.get(index).Id;
                newRedemptionsList.add(newRedemption);
            }
            insert newRedemptionsList;
        }
    }

    @IsTest
    static void testGetRedemptions() {
        String res;
        Contact eContact = [SELECT Id FROM Contact WHERE AccountId IN (SELECT Id FROM Account WHERE IsPersonAccount = TRUE)];
        User portalUser = [SELECT Id FROM User WHERE ContactId = :eContact.Id];

        String redemptionsJSON;
        Test.startTest();
            System.runAs(portalUser) {
                redemptionsJSON = MILRedemptionListController.getRedemptions();
            }
        Test.stopTest();
        
        System.assert(String.isNotBlank(redemptionsJSON), 'Redemptions not found');
    }

    private static Redemption_Campaigns__c createRedemptionCampaign(String name, String brand, String country, Integer gracePeriod, String purchasedProdId, String redeemedProdId) {
        Redemption_Campaigns__c newRedCamp = new Redemption_Campaigns__c();
        newRedCamp.Name = name;
        newRedCamp.Brand__c = brand;
        newRedCamp.Country__c = country;
        newRedCamp.Valid_From__c = System.today().addDays(-gracePeriod);
        newRedCamp.Redeemed_Item__c = redeemedProdId;
        newRedCamp.Purchased_Product__c = purchasedProdId;
        newRedCamp.Valid_To__c = System.today();
        newRedCamp.Redemption_Type__c = 'External';
        return newRedCamp;
    }

}