@isTest
private class CandidateControllerTest {
    static testMethod void myTest() {
        ContactPagedResult result = CandidateController.findAll(1);
        System.assert(result != null);
     }
}