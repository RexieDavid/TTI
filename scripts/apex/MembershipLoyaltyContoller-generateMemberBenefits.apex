//Kylie Tumulak Assets
Set<String> assetIds = new Set<String>();
assetIds.add('02iAD0000017ZwXYAU');
assetIds.add('02iAD0000017aCfYAI');
assetIds.add('02iAD0000017aMLYAY');
assetIds.add('02iAD0000017aHVYAY');
assetIds.add('02iAD0000018eAzYAI'); //Rex David
MembershipLoyaltyController.GenerateMemberBenefitWrapper test = MembershipLoyaltyController.generateMemberBenefits(assetIds);
System.debug('memberBenefitList size >>> '+test.memberBenefitList.size());
System.debug('assetList size >>> '+test.assetList.size());
insert(test.memberBenefitList);
update(test.assetList);

Database.executeBatch(new BlackhawkAPIBatch(test.memberBenefitList),10);

/*Member_Benefit__c member = [SELECT ID, Status__c FROM Member_Benefit__c WHERE ID = 'a7hAD0000000mJBYAY'];
member.Status__c = 'Approved - Activated';
update member;

