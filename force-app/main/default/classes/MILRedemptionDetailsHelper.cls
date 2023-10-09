public class MILRedemptionDetailsHelper {

    // private static List<String> orderNumbers;
    private static List<SF_Order_DetailsSet__x> orderDetails;
    private static Map<String, Redemptions__c> redemptionMap;
    private static Map<String, SF_Order_DetailsSet__x> orderMap;
    private static Redemptions__c redemption;

    public static void updateRedemptions(List<Redemptions__c> scope) {
        // orderNumbers = new List<String>();
        orderDetails = new List<SF_Order_DetailsSet__x>();
        redemptionMap = new Map<String, Redemptions__c>();
        orderMap = new Map<String, SF_Order_DetailsSet__x>();
        for(redemptions__c rec : scope) {
            // orderNumbers.add(rec.SAP_Order_Number__c);
            if(rec.SAP_Order_Number__c != null) {
                redemptionMap.put(rec.SAP_Order_Number__c, rec);
            }
            callorder(rec.Id, rec.SAP_Order_Number__c);
                
        }

        /*if(!redemptionMap.isEmpty()) {
            orderDetails = [SELECT Id, IVbeln__c, Carrier__c, ConNote__c FROM SF_Order_DetailsSet__x WHERE IVbeln__c IN: redemptionMap.keySet()];

            for(SF_Order_DetailsSet__x order : orderDetails) {
                orderMap.put(order.IVbeln__c, order);
            }

            if(!orderDetails.isEmpty()) {
                redemptionMap = setRedemptionDetails(redemptionMap, orderMap);
                update redemptionMap.values();
            }
        }*/
    }

    public static Map<String, Redemptions__c> setRedemptionDetails(Map<String, Redemptions__c> redemptionMap, Map<String, SF_Order_DetailsSet__x> orderMap) {
        for(String sapNum : redemptionMap.keySet()) {
            redemption = new Redemptions__c();
            redemption = redemptionMap.get(sapNum);
            redemption.Carrier_Code__c = orderMap.get(sapNum).Carrier__c;
            redemption.Carrier_Tracking_Number__c = orderMap.get(sapNum).ConNote__c;
            redemptionMap.put(sapNum, redemption);
        }
        return redemptionMap;
    }
    
    @future(callout=true)
    public static void callOrder(String recId, String sapNum) {
        OrderDetailsController.OrderDetailsResponseData response = OrderDetailsController.getOrderDetails(false, sapNum);
        Redemptions__c rec = new Redemptions__c();
        rec.Id = recId;
        rec.Carrier_Code__c = response.lstOrderDetails[0].Carrier__c;
        rec.Carrier_Tracking_Number__c = response.lstOrderDetails[0].ConNote__c;
        System.debug(rec);
        update rec;
    }
}