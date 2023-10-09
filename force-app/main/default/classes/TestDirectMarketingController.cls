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
private class TestDirectMarketingController {
	/*

	//Instantiate DirectMarketingController***************************************************************
		public static DirectMarketingController controller = new DirectMarketingController();
	
	//Test Navigation*************************************************************************************
	    static testMethod void NavigationTest() {
	    	controller.Section1 = true;//True on load
	    	controller.Section2 = false;//false on load
	    	controller.Section3 = false;//false on load
	        //Test Navigation
			if(controller.Section1 == true){
				controller.NextStep();
				System.assertEquals(controller.Section1, false);
				System.assertEquals(controller.Section2, true);
				System.assertEquals(controller.Section3, false);
				system.debug('NextStep on Step 1');
			}
			
			if(controller.Section2 == true){
				controller.NextStep();
				System.assertEquals(controller.Section1, false);
				System.assertEquals(controller.Section2, false);
				System.assertEquals(controller.Section3, true);
				system.debug('NextStep on Step 2');
			}
	
			if(controller.Section3 == true){
				controller.BackStep();
				System.assertEquals(controller.Section1, false);
				System.assertEquals(controller.Section2, true);
				System.assertEquals(controller.Section3, false);
				system.debug('BackStep on Step 3');
			}
			if(controller.Section2 == true){
				controller.BackStep();
				System.assertEquals(controller.Section1, true);
				System.assertEquals(controller.Section2, false);
				System.assertEquals(controller.Section3, false);
				system.debug('BackStep on Step 2');
			}
	    	
	    }
	//Test Product Search & Select Account*************************************************************************************
	    static testMethod void ContorllerTest() {
	    	
	    	system.debug('Search Products');
	    	system.assert(controller.SelProd == null, true);
	    	controller.inputkey1 = 'hammer';
			controller.SearchFuzzy();
			system.debug('SelProd records: '+controller.SelProd);
			system.debug('Search Accounts');
			controller.getSelAcc();
			system.debug('AccList records: '+controller.AccList);
			
	//Test Select-All Account*************************************************************************************
			System.assertEquals(controller.SelectAll, 'Select All');
			controller.runSelectAll();//Select All and Rename button
			System.assertEquals(controller.SelectAll, 'De-Select All');
			controller.runSelectAll();//De-Select All and Rename button
			System.assertEquals(controller.SelectAll, 'Select All');
			
			//Select one account for running DM
			controller.AccList[0].Selected = true;
			system.debug('Selected AccList records: '+controller.AccList);
	
	//Test Promo Search**************************************************************************************************
			//Add Product 1
			controller.inputkey2 = '48001303';
			controller.SearchPromo();
			controller.AddPromo();
			system.debug('Add 1 Product - PromoCount: '+controller.PromoCount);
			system.assertEquals(controller.PromoList.Size(),1);
			
			// Clear Products
			controller.ClearPromo();
			system.debug('Clear Products - Promolist: '+controller.PromoList);
			system.assertEquals(controller.PromoList.Size(),0);
			
			//Add 2 Products of the same ID
			controller.inputkey2 = '48001303';
			controller.SearchPromo();
			controller.AddPromo();
			controller.inputkey2 = '48001303';
			controller.SearchPromo();
			controller.AddPromo();
			system.debug('Add 2 Product - PromoCount: '+controller.PromoCount);
			system.assertEquals(controller.PromoList.Size(),1);
	
	//Test Select Accounts and Promo Products**************************************************************************************************
			controller.getSAccounts();
			system.debug('Selected Accounts: '+controller.selectedAccounts);
			
			controller.getSProducts(); 
			system.debug('Selected Products: '+controller.selectedProducts);
			
	//Run Magic
			//Opportunity Name
			controller.OppName = 'TestDirectMarketingController';
			controller.runMagic();
			
		}
		*/
}