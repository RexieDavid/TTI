List<Member_Benefit__c> memberList = [SELECT Id FROM Member_Benefit__c WHERE Id = 'a7hAD0000000u2DYAQ'];
Database.executeBatch(new BlackhawkAPIBatch('retry',memberList),2);

keytool -list -v -keystore "salesforceprod.jks" -storepass NFFZPWSZ

keytool -importkeystore -srckeystore TTI-HMI-API-Production.p12.p12 -srcstoretype pkcs12 -destkeystore SFPROD.jks -deststoretype JKS