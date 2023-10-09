/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest (SeeAllData=true)
private class TestOpportunityProductExtension {

    static testMethod void myUnitTest() {
        
        list<RecordType> RT = [SELECT r.Id FROM RecordType r WHERE r.SobjectType = 'Opportunity' AND r.DeveloperName = 'IND_Expression_of_Interest'];
        
        list<Opportunity> Opp = [Select o.Id From Opportunity o WHERE o.RecordTypeId = :RT[0].Id AND o.StageName != 'Closed Won'];
        
        ApexPages.StandardController sc = new ApexPages.standardController(Opp[0]);
        
        //Instantiate Controller************************************************
        OpportunityProductExtension controller = new OpportunityProductExtension(sc);

        controller.Code = '';
        controller.searchProduct();
        controller.addProduct();
        
        controller.Code = 'M18BX';
        controller.searchProduct();
        //system.assertEquals(controller.PDesc, 'M18BX');
        
        controller.Qty = 0;
        controller.addProduct();

        controller.Qty = 2;
        controller.Price = 252.53;
        controller.addProduct();
        
    }
}