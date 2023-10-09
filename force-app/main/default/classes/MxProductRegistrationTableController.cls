/**********************************************************************
 * @author        Samuel Oberes
 * @date          2020-07-06
 *
 * @group         MX Community
 * @group-content ../../ApexDocContent/mx-community.html
 *
 * @description   The MX community's product registration table controller
*/
public without sharing class MxProductRegistrationTableController {
    /**
     * Developer Note:              For future tickets enabling SAP Material groups 
     *                              Please create a configurable approach(e.g. custom settings, 
     *                              custom metadata) and reference in on the query
     */
    public static final Set<String> VALID_SAP_MATERIAL_GROUPS = new Set<String>{ 'MQ-TL', 'MQ-TM' };
    public static final Set<String> VALID_MRP_TYPES = new Set<String>{ 'ZD' };

    /**
     * @description                 Fetch MX Related products with available and consumed serial numbers
     *                              and serial number display type
     * 
     * @return                      Serialized JSON records
     */
    @AuraEnabled
    public static String getProductInformation() {
        return JSON.serialize([SELECT Id,
                        Name,
                        SAP_MaterialNumber__c
                FROM Product2
                WHERE SAP_Material_Group__c IN :VALID_SAP_MATERIAL_GROUPS
                AND AU_MRPty__c IN :VALID_MRP_TYPES
                AND NZ_MRPty__c IN :VALID_MRP_TYPES]);
    }

    /**
     * @description                 Server-side serial number validations
     * 
     * @return                      Serialized map collection { <productId>: records }
     */
    @AuraEnabled
    public static String getSerialNumberInformation(String payload) {
        Set<String> serialNumbers = (Set<String>)JSON.deserialize(payload, Set<String>.class);
        List<String> statuses = new List<String>{ 'Available', 'Consumed' };
        Map<String, List<MX_Serial_Numbers__c>> productSerialNumbers = new Map<String, List<MX_Serial_Numbers__c>>();
        for (MX_Serial_Numbers__c serialNumber : [SELECT Id, 
                                                         Status__c,
                                                         Serial_Number__c,
                                                         MX_Product__c
                                                  FROM MX_Serial_Numbers__c
                                                  WHERE Serial_Number__c IN :serialNumbers
                                                  AND Status__c IN :statuses]) {

            String key = serialNumber.MX_Product__c;
            if (!productSerialNumbers.containsKey(key)) {
                productSerialNumbers.put(key, new List<MX_Serial_Numbers__c>());
            }
            productSerialNumbers.get(key).add(serialNumber);
        }
        return JSON.serialize(productSerialNumbers);
    }
}