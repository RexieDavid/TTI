@isTest
public class LeadScoringTriggerHandlerTest {

    @IsTest
    static void testLeadScore100() {
        String email = 'kimat010191-001@yopmail.com';
        Lead lead = createLead();
        
        lead.Email = email; // 10
        lead.LeadSource = 'Website (Trade Solutions)'; // 50
        lead.Trade__c = 'Agriculture/Farmer'; // 20
        lead.Description = 'Purchase AEG 24V Battery.'; // 20
        
        Test.startTest();
            insert lead;
        Test.stopTest();
            
        System.assertEquals(100, getLeadScore(email), 'Incorrect lead score calculation.');
        
    }

    @IsTest
    static void testLeadScore25() {
        String email = 'kimat010191-001@gmail.com';
        Lead lead = createLead();
        
        lead.Email = email; // 0
        lead.LeadSource = 'social – trade night rsvp​'; // 10
        lead.Trade__c = 'Handyman'; // 5
        lead.Description = 'Repair AEG 24V Battery.'; // 10
        
        Test.startTest();
            insert lead;
        Test.stopTest();
            
        System.assertEquals(25, getLeadScore(email), 'Incorrect lead score calculation.');
        
    }

    @IsTest
    static void testLeadScore65() {
        String email = 'kimat010191-001@ttibrands.com.au';
        Lead lead = createLead();
        
        lead.Email = email; // 10
        lead.LeadSource = 'Bunnings Store​'; // 30
        lead.Trade__c = 'Other'; // 5
        lead.Description = 'Quote'; // 20
        
        Test.startTest();
            insert lead;
        Test.stopTest();
            
        System.assertEquals(65, getLeadScore(email), 'Incorrect lead score calculation.');
        
    }

    @IsTest
    static void testLeadScore20() {
        String email = 'kimat010191-001@gmail.com';
        Lead lead = createLead();
        
        lead.Email = email; // 0
        lead.LeadSource = 'Test​'; // 0
        lead.Trade__c = 'Test'; // 20
        lead.Description = 'Test'; // 0
        
        Test.startTest();
            insert lead;
        Test.stopTest();
            
        System.assertEquals(20, getLeadScore(email), 'Incorrect lead score calculation.');
        
    }

    @IsTest
    static void testLeadScore0() {
        String email = 'kimat010191-001@gmail.com';
        Lead lead = createLead();
        
        lead.Email = email; // 0
        lead.LeadSource = ''; // 0
        lead.Trade__c = ''; // 20
        lead.Description = ''; // 0
        
        Test.startTest();
            insert lead;
        Test.stopTest();
            
        System.assertEquals(0, getLeadScore(email), 'Incorrect lead score calculation.');
        
    }

    private static Lead createLead() {
        Id tradeLeadRecordtTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Trade Lead').getRecordTypeId();
        
        Lead lead = new Lead();
        lead.RecordTypeId = tradeLeadRecordtTypeId;
        lead.FirstName = 'Kim';
        lead.LastName = 'Mat';

        return lead;
    }

    private static Decimal getLeadScore(String email) {
        Lead lead = [SELECT Lead_Score__c FROM Lead WHERE Email = :email];
        return lead.Lead_Score__c;
    }
}