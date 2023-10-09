/**
* @author                   Francis Nasalita
* @date                     2021-11-19
*
* @description              Calculates Lead score and contains the Lead Criteria (https://ttianz.atlassian.net/wiki/spaces/SAL/pages/2721055017/AEG+Lead+Automation#Lead-Scoring-Criteria:)
*/
public without sharing class LeadScoringHelper {

    private static final String LEAD_SOURCE_FIELD = 'LeadSource';
    private static final String LEAD_TRADE_FIELD = 'Trade__c';
    private static final String LEAD_EMAIL_FIELD = 'Email';
    private static final String LEAD_DESCRIPTION_FIELD = 'Description';
    private static final String ELSE_VALUE = 'else'; // 
    private static final String DELIMITER = ', '; // comma with a space
    private static final String HIGH_SCORE_KEYWORDS = System.Label.High_score_Lead_Score_Keywords; // 'buy, purchase, quote​'
    private static final String LOW_SCORE_KEYWORDS = System.Label.Low_score_Lead_Score_Keywords; // 'repair, part, receipt​'
    private static final String COMMON_EMAIL_DOMAIN = System.Label.Common_Email_Domain; // common email domain - custom label

    /**
     *      Lead Scoring Criteria matrix
     * 
     *      note: 
     *          key is Lead Field API Name
     *          values should be in lower case
     */
    private static Map<String, map<String, Integer>> mapScoringCriteria = new Map<String, map<String, Integer>> {
        LEAD_SOURCE_FIELD => new map<String, Integer> { // Max weightage = 50
            'aeg onsite initiated​'             => 50,
            'website (trade solutions)'        => 50,
            'customer referral​'                => 50,
            'onsite event​'                     => 50,
            'tti retail team​'                  => 45,
            'customer service​'                 => 45,
            'bunnings store​'                   => 30,
            'bunnings trade account manager​'   => 30,
            'social – trade night rsvp​'        => 10,
            'social – other​'                   => 10
        },
        LEAD_TRADE_FIELD => new map<String, Integer> { // Max weightage = 20
            'handyman'                         => 5,
            'other'                            => 5,
            ELSE_VALUE                         => 20 // 
        },
        LEAD_EMAIL_FIELD => new map<String, Integer> { // Max weightage = 10
            COMMON_EMAIL_DOMAIN                => 0, 
            ELSE_VALUE                         => 10    
        },
        LEAD_DESCRIPTION_FIELD => new map<String, Integer> { // Max weightage = 20
            HIGH_SCORE_KEYWORDS                => 20,
            LOW_SCORE_KEYWORDS                 => 10
        }
    };

    public static Integer calculateLeadScore(Lead lead) {
        Integer totalScore = 0;

        for (String field : mapScoringCriteria.keySet()) {
            String value = String.valueOf(lead.get(field));

            if (String.isBlank(value)) {
                continue;
            }

            value = value.toLowerCase().trim();
            Integer score = String.isNotBlank(value) ? LeadScoringHelper.getLeadScoreByFieldAndValue(field, value) : 0;
            totalScore += score;
        }

        return totalScore;
    }

    private static Integer getLeadScoreByFieldAndValue(String field, String value) {
        Map<String, Integer> mapLeadFieldCriteria = mapScoringCriteria.get(field);
        Integer score = 0;
        Boolean isScoreSet = false;
        
        for (String key : mapLeadFieldCriteria.keySet()) {
            if (key.contains(DELIMITER)) { // ", " comma with space
                for (String keyword : key.split(DELIMITER)) {
                    keyword = keyword.toLowerCase();
                    if (value.contains(keyword)) {
                        score = mapLeadFieldCriteria.get(key);
                        isScoreSet = true;
                        break;
                    }
                }
            } else if (value.contains(key)) {
                score = mapLeadFieldCriteria.get(key);
                isScoreSet = true;
            } else if (key == ELSE_VALUE) {
                score = mapLeadFieldCriteria.get(ELSE_VALUE);
                isScoreSet = true;
            } else {
                score = 0;
            }
                
            if (isScoreSet) {
                break;
            }
        }

        return score;
    }
}