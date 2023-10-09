global class scheduledbatchSHS implements Schedulable {

	global void execute(SchedulableContext sc) {
		
		System.debug('***** START: scheduledbatchSHS *****');
	
	//Build Query
		List<Id> a = new List<Id>();

		List<Account> accList = [SELECT Id FROM Account WHERE Type='Retailer' AND Record_Status__c = 'Active'];
		for (Account acc:accList){
			a.add(acc.Id);
		}

		System.debug('AccId Size: ' + a.size());
	
	//Run Batch
		batchSalesHistorySummary b = new batchSalesHistorySummary(a);
		Database.executebatch(b,5);

		System.debug('***** END: scheduledbatchSHS *****');
	}
}