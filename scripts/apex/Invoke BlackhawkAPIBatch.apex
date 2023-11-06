List<Member_Benefit__c> memberList = [SELECT Id FROM Member_Benefit__c WHERE Id = 'a7hAD0000000muHYAQ'];
Database.executeBatch(new BlackhawkAPIBatch('retry',memberList),2);