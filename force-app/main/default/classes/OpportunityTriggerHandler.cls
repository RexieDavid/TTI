/**
* @author: Stephen James Laylo
* @date: Apr 2017
* @description: This class handles all CRUD operations for the
* Opportunity Trigger. All logic should be placed here and not in the
* trigger itself
*/
public class OpportunityTriggerHandler {

	/**
	* @author: Stephen James Laylo
	* @date: Apr 2017
	* @description: This method handles all on After Insert
	* functionalities of the Opportunity
	*/
	public static void onBeforeInsert(List<Opportunity> newOpportunities) {
		updateYearQuarter(newOpportunities);
		updateDocumentAttachedCheckbox(newOpportunities);
	}

	/**
	* @author: Stephen James Laylo
	* @date: Apr 2017
	* @description: This method handles all on After Insert
	* functionalities of the Opportunity
	*/
	public static void onAfterInsert(List<Opportunity> newOpportunities) {
		recalculateRebatesOnInsert(newOpportunities);
	}

	/**
	* @author: Stephen James Laylo
	* @date: May 2018
	* @description: This method handles all on Before Update
	* functionalities of the Opportunity
	*/
	public static void onBeforeUpdate(List<Opportunity> newOpportunities, Map<Id, Opportunity> oldOpportunitiesMap) {
		updateDocumentAttachedCheckbox(newOpportunities);
	}

	/**
	* @author: Stephen James Laylo
	* @date: Apr 2017
	* @description: This method handles all on After Update
	* functionalities of the Opportunity
	*/
	public static void onAfterUpdate(List<Opportunity> newOpportunities, Map<Id, Opportunity> oldOpportunitiesMap) {
		recalculateRebatesOnUpdate(newOpportunities, oldOpportunitiesMap);
	}

	/**
	* @author: Stephen James Laylo
	* @date: Apr 2017
	* @description: This method handles all on After Delete
	* functionalities of the Opportunity
	*/
	public static void onAfterDelete(List<Opportunity> oldOpportunities) {
		recalculateRebatesOnDelete(oldOpportunities);
	}

	/**
	* @author: Stephen James Laylo
	* @date: Apr 2017
	* @description: This method handles the update of Year Quarter
	*/
	public static void updateYearQuarter(List<Opportunity> opportunities) {
		for (Opportunity o : opportunities) {
			if (o.CloseDate != null) {
				o.Year_Quarter__c = o.CloseDate.Year() + ':' + (((o.CloseDate.Month() - 1) / 3) + 1);
			}
		}
	}

	/**
	* @author: Stephen James Laylo
	* @date: Apr 2017
	* @description: This method handles the recalculation of Rebates on Insert
	*/
	public static void recalculateRebatesOnInsert(List<Opportunity> opportunities) {
		Set<Opportunity> recalculateRebate = new Set<Opportunity>();

		for (Opportunity o : opportunities) {
			if (o.StageName == 'Closed Won') {
				recalculateRebate.add(o);
			}
		}

		recalculateRebates(recalculateRebate);
	}

	/**
	* @author: Stephen James Laylo
	* @date: Apr 2017
	* @description: This method handles the recalculation of Rebates on Update
	*/
	public static void recalculateRebatesOnUpdate(List<Opportunity> opportunities, Map<Id, Opportunity> oldOpportunitiesMap) {
		Set<Opportunity> recalculateRebate = new Set<Opportunity>();

		for (Opportunity o : opportunities) {
			if (oldOpportunitiesMap.containsKey(o.Id)) {
				if (o.StageName == 'Closed Won' || oldOpportunitiesMap.get(o.Id).StageName == 'Closed Won' || o.CloseDate != oldOpportunitiesMap.get(o.Id).CloseDate || o.Amount != oldOpportunitiesMap.get(o.Id).Amount) {
					recalculateRebate.add(o);
				}
			}
		}

		recalculateRebates(recalculateRebate);
	}

	/**
	* @author: Stephen James Laylo
	* @date: Apr 2017
	* @description: This method handles the recalculation of Rebates on Delete
	*/
	public static void recalculateRebatesOnDelete(List<Opportunity> oldOpportunities) {
		Set<Opportunity> recalculateRebate = new Set<Opportunity>();

		for (Opportunity o : oldOpportunities) {
			if (o.StageName == 'Closed Won') {
				recalculateRebate.add(o);
			}
		}

		recalculateRebates(recalculateRebate);
	}

	/**
	* @author: Stephen James Laylo
	* @date: Apr 2017
	* @description: This method handles the process of the recalculation of Rebates
	*/
	public static void recalculateRebates(Set<Opportunity> recalculateRebate) {
		if (!recalculateRebate.isEmpty()) {
			List<String> accIds = new List<String>();

			for (Opportunity o : recalculateRebate) {
				accIds.add(o.AccountId);
			}

			if (!accIds.isEmpty()) {
				List<String> contractIds = new List<String>();
				for (Contract_Account__c ca : [SELECT Contract__c, Account__c FROM Contract_Account__c WHERE Account__c IN : accIds]) {
					contractIds.add(ca.Contract__c);
				}

				Set<String> accountIds = new Set<String>();
				for (Contract_Account__c ca : [SELECT Account__c FROM Contract_Account__c WHERE Contract__c IN : contractIds]) {
					accountIds.add(ca.Account__c);
				}

				if (!contractIds.isEmpty()) {
					String approvedRecordTypeId = TTIUtilClass.getRecordTypeId('Contract', 'Approved').get('Approved');
					String qry  = 'SELECT Id, StartDate, EndDate, ContractTerm, AccountId, Status, Temp_Quarter_End_Date__c, ';
					qry += '(SELECT Id, Account__c FROM Contract_Accounts__r), ';
					qry += '(SELECT Id, Contract__c, Max__c, Min__c, Auto_Number__c, Rebate__c FROM Contract_Tiers__r ORDER BY Auto_Number__c) ';
					qry += 'FROM Contract ';
					qry += 'WHERE Id =: contractIds ';
					qry += 'AND RecordTypeId =: approvedRecordTypeId ';

					List<Contract> allContracts = Database.query(qry);

					Date rDate = Date.Today();
					RebateCalculations.isDailyRebate = TRUE;
					RebateCalculations.isDailyretrospective = TRUE;
					RebateCalculations.contracts = allContracts;
					RebateCalculations.prepareCollections();
					RebateCalculations.retreiveDailyOpportunityRollup(rDate);
					RebateCalculations.caluclateRebate();
					RebateCalculations.evaluteNextYearSpend();
					RebateCalculations.createRebate(false, null);
					List<Rebate__c> dailyrebates = RebateCalculations.rebates;


					Map<String, Period> allQuarters = new Map<String, Period>();

					for (Contract c : allContracts) {
						for (String key : TTIUtilClass.periods.keySet()) {
							if (TTIUtilClass.periods.containsKey(key) && TTIUtilClass.periods.get(key).StartDate >= c.StartDate && TTIUtilClass.periods.get(key).EndDate <= c.EndDate) {
								if (key == 'Current') {
									break;
								}
								allQuarters.put(c.Id + ':' + key, TTIUtilClass.periods.get(key));
							}
						}
					}

					Map<String, Contract> contracts = new Map<String, Contract>();

					for (Period p : allQuarters.values()) {
						for (Contract c : allContracts) {
							Contract aContract = c.clone(true, true, true, true);
							aContract.StartDate = p.StartDate;
							aContract.Temp_Quarter_End_Date__c = p.EndDate;
							contracts.put(p.StartDate.Year() + ':' + p.Number, aContract);
						}
					}

					Map<String, Rebate__c> rebates = new Map<String, Rebate__c>();
					Date lastQuarterEndDate = TTIUtilClass.periods.get('Current').StartDate.addDays(-1);


					Date cStartDate;

					for (Contract c : allContracts) {
						cStartDate  = cStartDate == null ? c.StartDate : (cStartDate < c.StartDate ? cStartDate : c.StartDate);
					}

					RebateCalculationsUtility.accountIds = accountIds;
					RebateCalculationsUtility.retreiveOpportunityRollup(cStartDate, lastQuarterEndDate);
					Map<String, Double> rollupSum = RebateCalculationsUtility.rollupSum;

					for (String key : contracts.keySet()) {
						RebateCalculationsUtility.contracts = new List<Contract> {contracts.get(key)};
						RebateCalculationsUtility.prepareCollections();

						RebateCalculationsUtility.caluclateRebates(key, contracts.get(key).Id);
						RebateCalculationsUtility.evaluteNextYearSpends(key, contracts.get(key).Id);
						if (RebateCalculationsUtility.createRebate(true, key, contracts.get(key).Id) != null) {
							rebates.put(key, RebateCalculationsUtility.createRebate(true, key, contracts.get(key).Id));
						}
					}

					List<Rebate__c> allRebates = new List<Rebate__c>();

					if (!rebates.isEmpty()) {
						allRebates.addAll(rebates.values());
					}

					if (!dailyrebates.isEmpty()) {
						allRebates.addAll(dailyrebates);
					}

					List<Rebate__c> rebatesToDelete = [SELECT Id FROM Rebate__c WHERE Contract__c IN: contractIds];
					if (rebatesToDelete != null) {
						delete rebatesToDelete;
					}

					if (!allRebates.isEmpty()) {
						Database.upsert(allRebates, Rebate__c.Fields.Rebate_Unique_Id__c, false);
					}

				}
			}
		}
	}

	/**
    * @author: Stephen James Laylo
    * @date: May 2018
    * @description: This method handles the flag of Document Attached field in Opportunity
    */
	public static void updateDocumentAttachedCheckbox(List<Opportunity> oppties) {
		Set<Id> opptyIds = new Set<Id>();

		for (Opportunity oppty : oppties) {
			opptyIds.add(oppty.Id);
			oppty.Document_Attached__c = false;
		}

		try {
			List<Attachment> attachments = [SELECT Id, ParentId FROM Attachment WHERE ParentId = :opptyIds];
			List<ContentDocumentLink> contentDocLinks = [SELECT Id, ContentDocumentId, ContentDocument.LatestPublishedVersionId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :opptyIds];

			Set<Id> opptiesWithFilesIds = new Set<Id>();

			for (Attachment att : attachments) {
				if (att.ParentId != null && TTIUtilClass.findObjectNameFromRecordIdPrefix(att.ParentId) == 'Opportunity') {
					opptiesWithFilesIds.add(att.ParentId);
				}
			}

			for (ContentDocumentLink contentDocLink : contentDocLinks) {
				if (contentDocLink.ContentDocumentId != null && TTIUtilClass.findObjectNameFromRecordIdPrefix(contentDocLink.LinkedEntityId) == 'Opportunity') {
					opptiesWithFilesIds.add(contentDocLink.LinkedEntityId);
				}
			}

			for (Opportunity oppty : oppties) {
				for (Id opptyId : opptiesWithFilesIds) {
					if (oppty.Id == opptyId) {
						oppty.Document_Attached__c = true;
					}
				}
			}
		} catch (Exception err) {
			System.debug('@@@err: ' + err);
		}
	}

}