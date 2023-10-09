/**
* @author		Haider Raza
* @date			27/05/2016
* @description	Calculate rebates utility
**/

public with sharing class RebateCalculationsUtility {
	static String qry;
	static public List<Contract> contracts;
	static public Map<String, Contract> contractsMap;
	static public Set<String> accountIds = new Set<String>();
	static public Map<String, String> accountTocontractMap = new Map<String, String>();
	static public Map<String, List<Contract_Tier__c>> tiers = new Map<String, List<Contract_Tier__c>>();
	static public Map<String, Map<String, Contract_Tier__c>> tiers1 = new Map<String, Map<String, Contract_Tier__c>>();
	static public Map<String, Tier> rebateTiers = new Map<String, Tier>();
	static public Map<String, Tier> rebateNextYearSpend = new Map<String, Tier>();
	static public List<Rebate__c> rebates = new List<Rebate__c>();
	static public Map<String, Double> rollupSum = new Map<String, Double>();
	static public Map<String, Rebate__c> dailyRebates = new Map<String, Rebate__c>();
	static public Date DailyRebateDate;
	static public Date QuarterStartDate;
	static public Date QuarterEndDate;
	static public String maxAutoNumber;
	static public Map<String, String> maxTierContract = new Map<String, String>();

	public static void prepareCollections(){
    	if(contracts.isEmpty()) return;

    	contractsMap = new Map<String, Contract>();
    	contractsMap.putAll(contracts);

		for(Contract contract : contracts){
			if(!contract.Rebates__r.isEmpty()){
				for(Rebate__c r : contract.Rebates__r){
					dailyRebates.put(r.Rebate_Unique_Id__c, r);
				}
			}
			if(!contract.Contract_Accounts__r.isEmpty()){
				for(Contract_Account__c contractaccount : contract.Contract_Accounts__r){
					accountIds.add(contractaccount.Account__c);
					accountTocontractMap.put(contractaccount.Account__c, contract.Id);

					if(!contract.Contract_Tiers__r.isEmpty()){
						tiers.put(contract.Id, contract.Contract_Tiers__r);

						Map<String, Contract_Tier__c> itier = new Map<String, Contract_Tier__c>();
						for(Contract_Tier__c t : contract.Contract_Tiers__r){
							itier.put(t.Auto_Number__c, t);
							maxAutoNumber = t.Auto_Number__c;
						}
						tiers1.put(contract.Id, itier);
						maxTierContract.put(contract.Id, maxAutoNumber);
					}
				}
			}
		}
    }

    public static void retreiveOpportunityRollup(Date qStartDate, Date qEndDate, Date oppCloseDate, Boolean isQuarterRebate){
		if(!isQuarterRebate)
			DailyRebateDate = oppCloseDate;
		else{
			QuarterStartDate = qStartDate;
			QuarterEndDate   = qEndDate;
		}
		qry  = 'SELECT AccountId, Sum(Amount) ';
		qry += 'FROM Opportunity ';
		qry += 'WHERE AccountId IN: accountIds ';
		qry += 'AND IsClosed=TRUE ';
		qry += 'AND StageName=\'Closed Won\' ';

		if(isQuarterRebate){
			qry += 'AND CloseDate>=:qStartDate ';
			qry += 'AND CloseDate<=:qEndDate ';
		}else
			qry += 'AND CloseDate=:oppCloseDate ';

		qry += 'GROUP BY AccountId ';

		for(AggregateResult result : Database.query(qry)){
			String accId = String.valueOf(result.get('AccountId'));
			String conId = String.valueOf(accountTocontractMap.get(accId));
			if(rollupSum.containsKey(conId)){
				Double v = rollupSum.get(conId)==null ? 0 : rollupSum.get(conId) + Double.valueOf(result.get('expr0'));
				rollupSum.put(conId, v);
			}else{
				Double v = Double.valueOf(result.get('expr0'));
				rollupSum.put(conId, v);
			}
		}
    }

    public static void caluclateRebate(){
    	Boolean isTierFound = FALSE;

		for(String cId : rollupSum.keySet()){
			if(tiers.containsKey(cId)){
				Double rollupSumAmount;
				for(Contract_Tier__c t : tiers.get(cId)){
					rollupSumAmount = rollupSum.get(cId) * 4;
					if(rollupSumAmount >= t.Min__c && rollupSumAmount <= t.Max__c){
						Double NextMin = getNextMinTier(t.Auto_Number__c, t.Contract__c);
						rebateTiers.put(cId, new Tier(t.Id, NextMin, t.Rebate__c));
						isTierFound = TRUE;
						break;
					}
				}
				if(!isTierFound){
					Contract_Tier__c maxTier = tiers1.get(cId).get(maxAutoNumber);
					if(rollupSumAmount > maxTier.Min__c){
						rebateTiers.put(cId, new Tier(maxTier.Id, null, maxTier.Rebate__c));
					}
				}
			}
		}
    }


    public static void caluclateRebates(String key, String conId){
    	if(rollupSum.get(key)==null) return;

    	Boolean isTierFound = FALSE;

    	Double rollupSumAmount = rollupSum.get(key) * 4;
    	//Double rollupSumAmount = rollupSum.get(key);

    	for(Contract_Tier__c t : tiers.get(conId)){
    		if(rollupSumAmount >= t.Min__c && rollupSumAmount <= t.Max__c){
				Double NextMin = getNextMinTier(t.Auto_Number__c, conId);
				rebateTiers.put(key, new Tier(t.Id, NextMin, t.Rebate__c));
				isTierFound = TRUE;
				break;
			}
    	}

    	if(!isTierFound){
			Contract_Tier__c maxTier = tiers1.get(conId).get(maxAutoNumber);
			if(rollupSumAmount > maxTier.Min__c){
				rebateTiers.put(key, new Tier(maxTier.Id, null, maxTier.Rebate__c));
			}
		}
    }

	public static void evaluteNextYearSpends(String key, String conId){
		if(tiers.containsKey(conId)==FALSE) return;
		
		Boolean isTierFound = FALSE;

		Double rollupSumAmount;
		for(Contract_Tier__c t : tiers.get(conId)){
			rollupSumAmount = rollupSum.get(key);
			if(rollupSumAmount >= t.Min__c && rollupSumAmount <= t.Max__c){
				Double NextMin = getNextMinTier(t.Auto_Number__c, t.Contract__c);
				rebateNextYearSpend.put(key, new Tier(t.Id, NextMin, t.Rebate__c));
				isTierFound = TRUE;
				break;
			}
		}
		if(!isTierFound){
			Contract_Tier__c maxTier = tiers1.get(conId).get(maxTierContract.get(conId));
			if(rollupSumAmount > maxTier.Min__c){
				rebateNextYearSpend.put(key, new Tier(maxTier.Id, null, maxTier.Rebate__c));
			}
		}
    }

	public static Rebate__c createRebate(Boolean isQuarter, String key, String conId){
        if(rollupSum.get(key)==null) return null;
		try{
			return new Rebate__c(	Name 						= 'Y: '+key.split(':')[0]+ ' Q: '+key.split(':')[1],	
									Contract__c					= conId,
									Sales__c 					= rollupSum.get(key),
									Sales_4__c					= rollupSum.get(key)*4.0,
									Quarter__c 					= key.split(':')[1],
									Rebate_Type__c 				= 'Quarter',
									Spent_to_Next_Level_Up__c	= rebateNextYearSpend.get(key)!=null ? (rebateNextYearSpend.get(key).nextMin== null ? rollupSum.get(key) : rebateNextYearSpend.get(key).nextMin) - rollupSum.get(key) : null,
									Rebate_Unique_Id__c 		= ('Y: '+key.split(':')[0]+ ' Q: '+key.split(':')[1])+conId,
									Calucated_Rebate__c			= rollupSum.get(key) * (rebateTiers.get(key)!=null ? rebateTiers.get(key).currentRebate/100 : 0),
									Year__c						= key.split(':')[0],
									Contract_Tier__c			= rebateTiers.get(key)!=null ? rebateTiers.get(key).tierId : null,
									Current_Rebate__c 			= rebateTiers.get(key)!=null ? rebateTiers.get(key).currentRebate : null);
		}catch(Exception ex){
			throw new TTIException('Unable to create rebate: '+ex.getMessage());
		}
	}    

	public static void evaluteNextYearSpend(){
		Boolean isTierFound = FALSE;
		for(String cId : rollupSum.keySet()){
			if(tiers.containsKey(cId)){
				Double rollupSumAmount;
				for(Contract_Tier__c t : tiers.get(cId)){
					rollupSumAmount = rollupSum.get(cId);
					if(rollupSumAmount >= t.Min__c && rollupSumAmount <= t.Max__c){
						Double NextMin = getNextMinTier(t.Auto_Number__c, t.Contract__c);
						rebateNextYearSpend.put(cId, new Tier(t.Id, NextMin, t.Rebate__c));
						isTierFound = TRUE;
						break;
					}
				}
				if(!isTierFound){
					Contract_Tier__c maxTier = tiers1.get(cId).get(maxAutoNumber);
					if(rollupSumAmount > maxTier.Min__c){
						rebateNextYearSpend.put(cId, new Tier(maxTier.Id, null, maxTier.Rebate__c));
					}
				}
			}
		}
    }

	public static Double getNextMinTier(String currentAutoNumber, String currentCId){
		Map<String, Contract_Tier__c> t2 = tiers1.get(currentCId);

		for(Contract_Tier__c t3 : t2.values()){
			if(t3.Auto_Number__c > currentAutoNumber){
				return t3.Min__c;
			}
		}
		return null;
	}

	public static List<Rebate__c> createRebate(Boolean isQuarter, String qNumber){
		for(String cId : rollupSum.keySet()){
			if(isQuarter){
				rebates.add(new Rebate__c(	Name 						= 'Y: '+QuarterStartDate.year()+ ' Q: '+qNumber,
											Contract__c					= cId,
											Sales__c 					= rollupSum.get(cId),
											Sales_4__c					= rollupSum.get(cId)*4,
											Quarter__c 					= qNumber,
											Rebate_Type__c 				= 'Quarter',
											Spent_to_Next_Level_Up__c	= rebateNextYearSpend.get(cId)!=null ? (rebateNextYearSpend.get(cId).nextMin== null ? rollupSum.get(cId) : rebateNextYearSpend.get(cId).nextMin) - rollupSum.get(cId) : null,
											Rebate_Unique_Id__c 		= ('Y: '+System.Today().year()+ ' Q: '+qNumber)+cId,
											Calucated_Rebate__c			= rollupSum.get(cId) * (rebateTiers.get(cId)!=null ? rebateTiers.get(cId).currentRebate/100 : 0),
											Year__c						= String.valueOf(QuarterStartDate.year()),
											Contract_Tier__c			= rebateTiers.get(cId)!=null ? rebateTiers.get(cId).tierId : null,
											Current_Rebate__c 			= rebateTiers.get(cId)!=null ? rebateTiers.get(cId).currentRebate : null));
			}else{
				rebates.add(new Rebate__c(	Name 						= 'Daily',
				 							Contract__c					= cId,
											Sales__c 					= rollupSum.get(cId), //dailyRebates.get('Daily'+cId)!=null ? dailyRebates.get('Daily'+cId).Sales__c+rollupSum.get(cId) : rollupSum.get(cId),
											Rebate_Type__c 				= 'Daily',
											Spent_to_Next_Level_Up__c	= rebateNextYearSpend.get(cId)!=null ? (rebateNextYearSpend.get(cId).nextMin== null ? rollupSum.get(cId) : rebateNextYearSpend.get(cId).nextMin) - rollupSum.get(cId) : null,
											Rebate_Unique_Id__c 		= 'Daily'+cId,
											Calucated_Rebate__c			= rollupSum.get(cId) * (rebateTiers.get(cId)!=null ? rebateTiers.get(cId).currentRebate/100 : 0),
											Contract_Tier__c			= rebateTiers.get(cId)!=null ? rebateTiers.get(cId).tierId : null,
											Current_Rebate__c 			= rebateTiers.get(cId)!=null ? rebateTiers.get(cId).currentRebate : null));
			}
		}


		return null;
	}


	/*public static void flagOpportunities(Boolean isQuarterRebate){
		qry  = 'SELECT Id, Daily_Rebate_Calculated__c, Quarter_Rebate_Calculated__c ';
		qry += 'FROM Opportunity ';
		qry += 'WHERE AccountId IN: accountIds ';
		qry += 'AND IsClosed=TRUE ';
		qry += 'AND StageName=\'Closed Won\' ';

		if(isQuarterRebate){
			qry += 'AND CloseDate>=:QuarterStartDate ';
			qry += 'AND CloseDate<=:QuarterEndDate ';
		}else
			qry += 'AND CloseDate=:DailyRebateDate ';

		List<Opportunity> oppsToUpdate = new List<Opportunity>();
		for(Opportunity opp : Database.query(qry)){
			if(isQuarterRebate)
				opp.Quarter_Rebate_Calculated__c = true;
			else
				opp.Daily_Rebate_Calculated__c = true;
			oppsToUpdate.add(opp);
		}
		if(!oppsToUpdate.isEmpty())
			update oppsToUpdate;
	}*/

	public class Tier{
		String tierId;
		Double nextMin;
		Decimal currentRebate;
		public Tier(String t, Double m, Decimal r){
			tierId 			= t;
			nextMin			= m;
			currentRebate 	= r;
		}
	}



    public static void retreiveOpportunityRollup(Date qStartDate, Date qEndDate){
		QuarterStartDate = qStartDate;
		QuarterEndDate   = qEndDate;
		
		qry  = 'SELECT Sum(Amount), Year_Quarter__c ';
		qry += 'FROM Opportunity ';
		qry += 'WHERE AccountId IN: accountIds ';
		qry += 'AND IsClosed=TRUE ';
		qry += 'AND StageName=\'Closed Won\' ';		
		qry += 'AND CloseDate>=:qStartDate ';
		qry += 'AND CloseDate<=:qEndDate ';
		qry += 'GROUP BY Year_Quarter__c ';

		for(AggregateResult result : Database.query(qry)){			
			if(result.get('Year_Quarter__c')!=null || result.get('Year_Quarter__c')!=''){
				Double v = result.get('expr0')==null || result.get('expr0')=='' ? 0 : Double.valueOf(result.get('expr0'));
				rollupSum.put(String.valueOf(result.get('Year_Quarter__c')), v);
			}
		}
    }


    /*public static void retreiveOpportunityRollup(Date qStartDate, Date qEndDate, String cId){
		QuarterStartDate = qStartDate;
		QuarterEndDate   = qEndDate;
		
		qry  = 'SELECT Sum(Amount), Year_Quarter__c, AccountId ';
		qry += 'FROM Opportunity ';
		qry += 'WHERE AccountId IN: accountIds ';
		qry += 'AND IsClosed=TRUE ';
		qry += 'AND StageName=\'Closed Won\' ';		
		qry += 'AND CloseDate>=:qStartDate ';
		qry += 'AND CloseDate<=:qEndDate ';
		qry += 'GROUP BY AccountId, Year_Quarter__c ';

		for(AggregateResult result : Database.query(qry)){			
			if(result.get('Year_Quarter__c')!=null || result.get('Year_Quarter__c')!=''){
				Double v = result.get('expr0')==null || result.get('expr0')=='' ? 0 : Double.valueOf(result.get('expr0'));
				rollupSum.put(String.valueOf(result.get('Year_Quarter__c'))+':'+cId, v);
			}
		}
    }*/

}