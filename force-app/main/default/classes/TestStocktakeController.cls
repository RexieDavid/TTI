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
@isTest (SeeAllData=false)
private class TestStocktakeController {

		//Test StocktakeGenController
	    public static testMethod void testStocktakeGen() {
	    	//Running Users
	    		Profile ap = [SELECT Id FROM Profile WHERE Name='~System Administrator'];
	    		Profile sp = [SELECT Id FROM Profile WHERE Name='~Industral BDM Sales'];
	    		
	    		//Admin User
	    		list <User> UsersAP = [SELECT Id, name, TTI_SAP_Cust_No__c, LastLoginDate FROM User WHERE IsActive = true AND ProfileId = :ap.id AND LastLoginDate != null ORDER BY LastLoginDate desc];
	    		User u1 = UsersAP[0];
				//Normal User
				list <User> UsersSP = [SELECT Id, TTI_SAP_Cust_No__c FROM User WHERE IsActive = true AND ProfileId = :sp.id AND LastLoginDate != null ORDER BY LastLoginDate desc];
				User u2 = UsersSP[0];
				
    		//Create Data
				//Inventory
				Inventory__c Inv = new Inventory__c (
					Inventory_Link__c = u2.TTI_SAP_Cust_No__c+'-Test',
					Quantity__c = 1,
					Status__c = 'Active',
					Ownerid = u2.Id
				);
				insert Inv;
					
			//Run as Admin ****************************************
			system.runAs(u1){
	        	StocktakeGenController C0 = new StocktakeGenController(); 
	        	//Test page section view
	        	system.assertEquals(C0.Admin, True);
	        	//Test QTR Options ******************************
	        	C0.getQtr();
	        	//system.assertEquals(C1.QtrOptions.size(), 4);
	        	//Run Bulk
	        	C0.BulkYr = 9999;
	        	C0.BulkQtr = 'Qtr1';
	        	C0.BulkGen();
			}
			//Run as User ****************************************
			system.runAs(u2){
	        	StocktakeGenController C1 = new StocktakeGenController(); 
	        	//Test page section view
	        	system.assertEquals(C1.Admin, False);
	        	system.assertEquals(C1.UserRun, True);
	        	system.assertEquals(C1.UserGen, True);
	        	//***User Stock at Start***
				list <Stocktake__c> UsrStock = [ SELECT 
	        		st.Stocktake_Identity__c,
	        		st.Due_Date__c,
	        		st.Name
	        		FROM
	        		Stocktake__c st 
	        		WHERE 
	        		st.Ownerid = :u2.Id
	        		AND
	        		st.Active__c = true];

	        	system.assertEquals(C1.ActiveSt, UsrStock.size());
	        	
	        	if (UsrStock.size()==0){
		        	//Generate new stocktake************
		        	C1.GenNew();
		        	system.assertEquals(C1.ActiveSt, 1);
	        	}
	        	
	        	//Try Generate another active stocktake ************
	        	C1.GenNew();
	        	system.assertEquals(C1.ActiveSt, 1);
	        	
	        	//Run Stocktake
	        	C1.runStocktake();
    		}
		}

		//Test StocktakeController
	    public static testMethod void testStocktake() {
			//Normal User
			Profile sp = [SELECT Id FROM Profile WHERE Name='~Industral BDM Sales'];
			list <User> UsersSP = [SELECT Id,TTI_SAP_Cust_No__c FROM User WHERE IsActive = true AND ProfileId = :sp.id AND LastLoginDate != null ORDER BY LastLoginDate desc];
			User u2 = UsersSP[0];
			
    		//Create Data
				//Inventory
				Inventory__c Inv = new Inventory__c (
					Inventory_Link__c = u2.TTI_SAP_Cust_No__c+'-Test',
					Quantity__c = 1,
					Status__c = 'Active',
					Ownerid = u2.Id
				);
				insert Inv;
				//Generate new stocktake************
				system.runAs(u2){
					StocktakeGenController C1 = new StocktakeGenController();
					C1.GenNew();
				}

			//Run as User ****************************************
			system.runAs(u2){
				StockTakeController C2 = new StockTakeController();
				//Get Active Stocktake
				list <Stocktake__c> UsrStock = [ SELECT st.Stocktake_Identity__c, st.Date_Submitted__c, st.Submitted__c, st.Active__c FROM Stocktake__c st WHERE st.Ownerid = :u2.Id AND st.Active__c = true];
				system.assertEquals(C2.UsrStock.size(),UsrStock.size());
				list <Stocktake_Items__c> StockItems = [ SELECT sti.Name FROM Stocktake_Items__c sti WHERE sti.Owner__c = :u2.Id AND sti.Stocktake_Link__r.Active__c = true];
				system.assertEquals(C2.stockitems.size(),StockItems.size());
				
								
				//Save
				C2.saveChanges();
				
				//Edit
				C2.editChanges();
				
				//Cancel
				C2.cancelChanges();
				
				//Edit
				C2.editChanges();
				
				//Submit StockItems
				system.debug(C2.UsrStock.size());
				if (C2.UsrStock.size() == 1){
					system.assertEquals(c2.Usrstock[0].Active__c,true);
					system.assertEquals(c2.Usrstock[0].Submitted__c,false);
					C2.stockitems[0].Stocktake_Quantity__c = 5;
				}
				
				C2.submitChanges();
				
				if (C2.UsrStock.size() == 1){
					system.assertEquals(c2.Usrstock[0].Active__c,false);
					system.assertEquals(c2.Usrstock[0].Submitted__c,true);
				}
    		}
				
				  
					
		}
	    
}