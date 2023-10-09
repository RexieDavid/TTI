global class Batch_UpdateJSSBudgetTotals implements Database.Batchable <SObject>, Database.Stateful {

	List<Dmlexception> dmlExceptions = new List<Dmlexception>();
	
	global Database.QueryLocator start(Database.BatchableContext ctx) {
		
		List<User> users = [Select u.Id, u.Name From User u where u.UserRole.Name like '%IND%' AND  u.UserRole.Name like '%JSS%'];
		List<Id> userIds = new List<Id>();
		
		for (User u :users)
		{
			userIds.add(u.Id);
		}
		
		// Get a list of all users in the system that comply with JSS conditions:
		String theQuery = 'Select s.Posting_Date__c, s.Customer_Group_2_Code__c, s.OwnerId, s.JSS_Totals__c, s.IsDeleted, s.Id, s.Revenue__c From Sales_History__c s where s.IsDeleted = False and s.OwnerId In :userIds';		
		
		System.debug(logginglevel.DEBUG, '## DEBUG: Pulling all JSS users, count: ' + String.valueOf(users.size()));
		
		return Database.getQueryLocator(theQuery);
	}
	
	global void execute(Database.BatchableContext ctx, List<SObject> scope) {
		
		List<Sales_History__c> salesHistoryObjects = (List<Sales_History__c>)scope;
		Date lowestBudgetDateThreshold = date.today();
		
		System.debug(logginglevel.DEBUG, '## DEBUG: Count of Sales History records: ' + salesHistoryObjects.size());
		
		// Now that we have all budgets, set up a map of each element, so that we can update the values later:
		Map<String, Sales_History__c> mapJSSUserMonthToSalesBudget = new Map<String, Sales_History__c>();
		Date postingDate = date.Today();
		for (Sales_History__c sh : salesHistoryObjects)
		{
			// add a map entry:
			postingDate = (Date)sh.Posting_Date__c;
			String mapKey = String.valueOf(sh.OwnerId) + sh.Customer_Group_2_Code__c + String.valueOf(postingDate.year()) + String.valueOf(postingDate.month());
			
			System.debug(logginglevel.DEBUG, '## DEBUG: Entering value into mapJSSUserMonthToSalesBudget: KEY ['+mapKey+'] - VALUE ['+sh.Id+']');
			
			mapJSSUserMonthToSalesBudget.put (mapKey, sh);
			
			// Update the lower bound threshold:
			if (sh.Posting_Date__c < lowestBudgetDatethreshold)
				lowestBudgetDateThreshold = sh.Posting_Date__c;
			
		}
		
		lowestBudgetDateThreshold = lowestBudgetDateThreshold.addMonths(-1);
		lowestBudgetDateThreshold = date.newInstance(lowestBudgetDateThreshold.Year(), lowestBudgetDateThreshold.Month(), 1);
		System.debug(logginglevel.DEBUG, '## DEBUG: Minimum Date threshold: ' + String.valueOf(lowestBudgetDateThreshold));
		
		// Next, we pull up the activities in the system that have occured after the minimum date of the budgets:
		List<Event> activities = [Select e.Account.BillingState, e.Suggested_Order_Value__c, e.OwnerId, e.Order_Value_Taken__c, e.Order_Confirmed_Date__c From Event e Where e.Order_Confirmed_Date__c >= :lowestBudgetDatethreshold AND e.RecordType.Name = 'Sales RunSheet JSS'];
		
		// For each task record, aggegate up the user/month data pair into a new data strcuture:
		Map<String, Boolean> mapJSSUserStateDateToTampered = new Map<String, Boolean>();
		
		for (Event t : activities)
		{
			// Pull the correct mapped value and update the data:
			// Get the order date:
			Date orderDate = t.Order_Confirmed_Date__c;
			// Get the order amount:
			Decimal orderAmount = t.Order_Value_Taken__c;
			// Get the state:
			String orderState = t.Account.BillingState;
			// Get the user Id:
			String orderUserId = String.valueOf(t.OwnerId);
			
			String retKey = '';
			
			if (orderAmount == null)
				orderAmount = 0;
			
			// First pull the value from the map, if it exists:
			if (orderDate != null)
			{
				retKey = orderUserId + orderState + orderDate.year() + orderDate.month();
			}
			
			System.debug(loggingLevel.DEBUG, '## DEBUG: Key to retreive value for: ' + retKey);
			
			Sales_History__c value = mapJSSUserMonthToSalesBudget.get(retKey);
			
			if (value == null)
				System.debug(loggingLevel.DEBUG, '## DEBUG: No value was retrieved');
			else 
				System.debug(loggingLevel.DEBUG, '## DEBUG: A value was retrieved');
				
			// If we have a valid value, and mapJSSUserStateDateToTampered checkss out:
			if (value != null)
			{
				Boolean zeroFlag = false;
				if (mapJSSUserStateDateToTampered.get(retKey) == null)
				{
					System.debug(loggingLevel.DEBUG, '## DEBUG: Key ['+retKey+'] - zero flag set!');
					mapJSSUserStateDateToTampered.put(retKey, true);
					zeroFlag = true;
				}
				
				if (zeroFlag==true)
				{	
					value.JSS_Totals__c = 0;
					System.debug(loggingLevel.DEBUG, '## DEBUG: Key [' + retKey + '] - value reset!');
				}
				
				System.debug(loggingLevel.DEBUG, '## DEBUG: Key ['+retKey+'] - Existing value= ' + String.valueOf(value.JSS_Totals__c)+' - added value= ' + String.valueOf(orderAmount));
				
				value.JSS_Totals__c = value.JSS_Totals__c + orderAmount;
								
				System.debug(loggingLevel.DEBUG, '## DEBUG: Key ['+retKey+'] - Final cummulative value= ' + String.valueOf(value.JSS_Totals__c));
				
			}
		}
		
		// Traverse mapJSSUserMonthToSalesBudget, and build an update list:
		List<Sales_History__c> sHist = new List<Sales_History__c>();
		for	(Sales_History__c target : mapJSSUserMonthToSalesBudget.values()) {
			sHist.add(target);
		}
		
		// Update system:
		update sHist;
		
	}
	
	global void finish(Database.BatchableContext ctx) {
		
	}

}