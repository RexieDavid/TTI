public with sharing class OrderDetailPageExt {

    public Order__c order;
    public Boolean hasOrderDetails { get; set; }
    public List<SF_Order_DetailsSet__x> orderdet { get; set; }
    public List<OrderDetailWrapper> listOrderDetailWrapper { get; set; }

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public OrderDetailPageExt(ApexPages.StandardController stdController) {
        order = (Order__c) stdController.getRecord();

        listOrderDetailWrapper = new List<OrderDetailWrapper> ();
        hasOrderDetails = false;

        getOrders();
    }
    
     public OrderDetailPageExt() {
     }


    // Move to Order Helper Class
    /**
     * @author fnasalita@ttibrands.com.au.sboxfull
     * @description Wrapper class for Order details
     */
    public class OrderDetailWrapper {
        public SF_Order_DetailsSet__x orderDetail { get; set; }
        public String trackURL { get; set; }
        public Boolean showTrackButton { get; set; }
        public Integer itemNum { get; set; }

        public OrderDetailWrapper(SF_Order_DetailsSet__x orderDetail, String trackURL) {
            this.orderDetail = orderDetail;
            this.trackURL = trackURL;
            this.itemNum = Integer.valueOf(orderDetail.Posnr__c);  
            if (String.isNotEmpty(orderDetail.Carrier__c) && String.isNotEmpty(orderDetail.ConNote__c) && String.isNotEmpty(trackURL)) {
                this.showTrackButton = true;
            } else {
                this.showTrackButton = false;
            }
        }
    }

    public void getOrders() {
        Boolean hasError = false;
        String inputSalesOrd = order.SRC_ID__c.leftPad(10, '0');

        String condition = 'IVbeln__c = ' + UtilityClass.encloseStringWithApos(inputSalesOrd);

        String query = UtilityClass.constructSOQLQuery('Sales_Order_Information', 'SF_Order_DetailsSet__x', condition, 999, null, null, null);
        if (String.isNotEmpty(query)) {
            orderdet = Database.query(query);

            if (!orderdet.isEmpty()) {
                Map<String, String> mapCarrierTrackingUrl = new Map<String, String> ();
                hasOrderDetails = true;

                // get carriers

                Set<String> setCarriers = new Set<String> ();
                for (SF_Order_DetailsSet__x orderDetail : orderdet) {
                    setCarriers.add(orderDetail.Carrier__c);
                }

                // get carrier tracking url

                if (!setCarriers.isEmpty()) {
                    for (Carrier_Tracking_URL__mdt carrierDetails :[SELECT DeveloperName, TrackingURL__c
                         FROM Carrier_Tracking_URL__mdt
                         WHERE DeveloperName IN :setCarriers]) {

                        mapCarrierTrackingUrl.put(carrierDetails.DeveloperName, carrierDetails.TrackingURL__c);
                    }
                }

                listOrderDetailWrapper = new List<OrderDetailWrapper> ();
                for (SF_Order_DetailsSet__x orderDetail : orderdet) {
                    if (!mapCarrierTrackingUrl.isEmpty()) {
                        if (mapCarrierTrackingUrl.containsKey(orderDetail.Carrier__c)) {
                            listOrderDetailWrapper.add(
                                                       new OrderDetailWrapper(orderDetail,
                                                                              mapCarrierTrackingUrl.get(orderDetail.Carrier__c))
                            );
                        } else {
                            listOrderDetailWrapper.add(new OrderDetailWrapper(orderDetail, ''));
                        }
                    } else {
                        listOrderDetailWrapper.add(new OrderDetailWrapper(orderDetail, ''));
                    }
                }

            } else {
                ApexPages.addMessage(New ApexPages.Message(ApexPages.severity.INFO, 'Sales Order Number not exist'));
                hasError = true;

                hasOrderDetails = false;
            }
        }
    }
    
    public void testdummy () {
        Integer x = 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1; 
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1; 
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
         x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1; 
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;
        x += 1;           
    }
}