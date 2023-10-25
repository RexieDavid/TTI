//Kylie Tumulak Assets
Set<String> assetIds = new Set<String>();
assetIds.add('02iAD000001EEtlYAG');
// assetIds.add('02iAD000001DLFmYAO');
// assetIds.add('02iAD000001DLFnYAO');
//assetIds.add('02iAD000001ClLxYAK');
// assetIds.add('02iAD0000017aMLYAY');
// assetIds.add('02iAD0000017aHVYAY');
// assetIds.add('02iAD0000018eAzYAI'); //Rex David
MembershipLoyaltyController.GenerateMemberBenefitWrapper test = MembershipLoyaltyController.generateMemberBenefits(assetIds);
System.debug('test >>> '+test);
if(test!=NULL){
    System.debug('memberBenefitList size >>> '+test.memberBenefitList);
    System.debug('assetList size >>> '+test.assetList);
    if(test.memberBenefitList != NULL)insert(test.memberBenefitList);
    if(test.assetList != NULL)update(test.assetList);    
}

BlackhawkAPISchedule bhAPISched = new BlackhawkAPISchedule();
String sch = '0 12 23 * * ?'; //5:30 PM
System.schedule('BlackhawkAPISchedule', sch, bhAPISched);


// Database.executeBatch(new BlackhawkAPIBatch('retry',[SELECT ID, Status__c FROM Member_Benefit__c WHERE ID = 'a7hAD0000000o3FYAQ']),10);

/*Member_Benefit__c member = [SELECT ID, Status__c FROM Member_Benefit__c WHERE ID = 'a7hAD0000000mJBYAY'];
member.Status__c = 'Approved - Activated';
update member;

//GENERATE PRODUCTS
insert(BlackhawkAPIService.generateBlackhawkCardProducts(BlackhawkClientProgramWrapper.parse(BlackhawkAPIService.getCatalogByKey(BlackhawkAPIService.getActiveBlackhawkApiSetting().Client_Program_Id__c).getBody())));
System.debug(generateBlackhawkCardProducts.size());