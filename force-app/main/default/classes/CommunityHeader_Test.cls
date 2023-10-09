@isTest(SeeAllData = true)
public class CommunityHeader_Test {
    
    static testMethod void getCommunitySettings_Test() {
     	
        CommunityHeader.getCommunitySettings();
    }
    /* static testMethod void getCommunityHeader_Test1() {
     	//CustomSetting__c cs = new CustomSetting__c();
        CommunityHeader.getCommunityHeader('mytoolbag');
    }*/
    static testMethod void getCommunityHeader_Test2() {
     	   
        CommunityHeader.getCommunityHeader('RegisterNewTool');
    }
    static testMethod void getCommunityHeader_Test3() {
     	   
        CommunityHeader.getCommunityHeader('test');
    }
    
    static testMethod void getCommunityHeader_Test4() {
     	   
        CommunityHeader.testDummy();
             
    }

}