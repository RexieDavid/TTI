//Write a scheduler which will creae accounts for the Authors which were created in last 10 minutes. if not created

// Run in every 1 Hour
// Fetch the Authors which were created in between last 1 hour to last 3 hour and not assciated with any Account.
// Store the emails address of those authors
// Fetch the accounts of these email address
// If account does not exist, then create the account..

//Invoke this class
//and pass the list of Accounts..

public class CreateAccountAndMapWithInteraction implements Schedulable
{
    public void execute(SchedulableContext sc)
    {
        DateTime rightnow =  DateTime.now();
        DateTime fifteenMinutesBefore = rightnow.addMinutes(-15);
        DateTime fourtyFiveMinutesBefore = rightnow.addMinutes(-45);
        String queryStr;
        if(Test.isRunningTest())
        {
           queryStr  = 'select FirstName__c, LastName__c, BV2__Email_Address__c, BV2__Bazaarvoice_Setting__c from BV2__Author__c where BV2__Contact__c = null';
        }
        else
        { 
        	 queryStr = 'select FirstName__c, LastName__c, BV2__Email_Address__c, BV2__Bazaarvoice_Setting__c from BV2__Author__c where LastModifiedDate <: fifteenMinutesBefore and LastModifiedDate >:fourtyFiveMinutesBefore and BV2__Contact__c = null';
        }
		//String em1 = '6devoncrt@gmail.com';
		//String em2 = 'adj.mailme@gmail.com';
		//String queryStr = 'select FirstName__c, LastName__c, BV2__Email_Address__c, BV2__Bazaarvoice_Setting__c from BV2__Author__c where BV2__Contact__c = null and BV2__Email_Address__c in (:em1 , :em2)';
        		
        List<BV2__Author__C> authors = Database.query(queryStr);
		System.Debug('authors' + authors);
		
        Map<String, BV2__Author__C> authorByEmail = new Map<String, BV2__Author__C>();
        for(BV2__Author__C aut : authors)
        {
            authorByEmail.put(aut.BV2__Email_Address__c, aut);
        }
		System.Debug('authorByEmail ' + authorByEmail);
		
        Map<String, String> toBecreatedAccount = new Map<String, String>();
        AggregateResult[] lst = [select personemail, count(Id) numbers from Account where personemail =: authorByEmail.keySet() group by personemail];
        System.Debug('lst ' + lst);
		
		//If lst size is zero, then, We need to create Account for all the emails.
		for(AggregateResult ag : lst)
        {
            if((Integer)ag.get('numbers') >= 2)
            {
                toBecreatedAccount.put((String)ag.get('personemail'), authorByEmail.get((String)ag.get('personemail')).BV2__Bazaarvoice_Setting__c);
            }
        }
		System.Debug('toBecreatedAccount ' + toBecreatedAccount);
		
        List<Account> lstNewAc = new List<Account>();
		Set<String>  accountsCreatedWithEmail = new Set<String>();
        for(BV2__Author__C auth : authorByEmail.values())
        {  
            if(toBecreatedAccount.size() > 0 & toBecreatedAccount.containsKey(auth.BV2__Email_Address__c))
				continue;
		
            Account newAc = new Account(); 
            newAc.FirstName = auth.FirstName__C;
            newAc.LastName = auth.LastName__C;
            newAc.PersonEmail = auth.BV2__Email_Address__c;
            //System.assert(false, 'll' + auth.BV2__Bazaarvoice_Setting__c);
            if(( auth.BV2__Bazaarvoice_Setting__c).equals('a3l90000000Ncq6'))
            {                        
                newAc.Brand__pc = 'Ryobi';
                newAc.Brands__c = 'Ryobi';
                //system.debug('assign Ryobi brand');
            }
            else if((auth.BV2__Bazaarvoice_Setting__c).equals('a3l90000000Ncpw'))
            {
                newAc.Brand__pc = 'AEG';
                newAc.Brands__c = 'AEG';
                //system.debug('assign AEG brand');
            }
            else if( (auth.BV2__Bazaarvoice_Setting__c).equals('a3l90000000Ncq1'))
            {
                newAc.Brand__pc = 'Vax';
                newAc.Brands__c = 'Vax';
                //system.debug('assign Vax brand');
            }
            newAc.PersonHomePhone   = 'placeholder';
            newAc.PersonMobilePhone = 'placeholder1';
			accountsCreatedWithEmail.add(auth.BV2__Email_Address__c);
            lstNewAc.add(newAc);
        }
        if( !lstnewAc.isEmpty()){
            BV2__BVCustomSetting__c mc = BV2__BVCustomSetting__c.getValues('BVDefaultSetting');
        	mc.BV2__Disable_Triggers__c = true;
        	update mc;
            database.upsert(lstnewAc, false);
            mc.BV2__Disable_Triggers__c = false;
        	update mc;
            system.debug('Custom Linking: '+lstnewAc);
        }
        
        system.debug('Custom Linking lstAc '+lstnewAc); 
        List<Account> acs = [select Id, personemail, PersonContactId from Account where personemail =:accountsCreatedWithEmail];
        system.debug('acs: '+acs);
		
		Map<String, Id> mapAccount = new Map<String, ID>();
        for(Account a: acs)
        {
            mapAccount.put(a.personemail, a.PersonContactId);
        }
        system.debug('mapAccount: '+mapAccount);
		
        List<BV2__Interaction__c> ineractions = [select Id, BV2__Author__r.BV2__Contact__c, BV2__IsManualMapping__c, BV2__Contact__c, BV2__Author_Email_Address__c FROM BV2__Interaction__c where BV2__Author_Email_Address__c =: accountsCreatedWithEmail];
        List<BV2__Interaction__c> toUpdate = new List<BV2__Interaction__c>();
        System.Debug('ineractions' + ineractions);
		for(BV2__Interaction__c i : ineractions)
        {
            i.BV2__Contact__c = mapAccount.get(i.BV2__Author_Email_Address__c);
            i.BV2__IsManualMapping__c = true;
            i.BV2__Author__r.BV2__Contact__c = i.BV2__Contact__c;
            toUpdate.add(i);
        }
        Database.update(toUpdate, false);
		System.Debug('toUpdate' + toUpdate);
    }
    
}