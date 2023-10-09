/**
 * @author Francis Nasalita
 * @description SAPQASOrderDetails controller
*/
public with sharing class SAPQASOrderDetailsController {

    public String fieldsetApiName;
    public static Boolean isInSalesforce1 = UserInfo.getUiThemeDisplayed() == 'Theme4t';

    public String inputSalesOrd { get; set; }
    public String salesOrderNumber { get; set; }
    public String customerPONumber { get; set; }
    public Boolean isUserInMobile { get; set; }
    public Boolean hasOrderDetails { get; set; }
    public List<SF_Order_DetailsSet__x> orderdet { get; set; }
    public List<OrderDetailWrapper> listOrderDetailWrapper { get; set; }
    public List<OrderDetailGroupedWrapper> listOrderDetailGroupedWrapper { get; set; } 
    public List<OrderDetailGroupedWrapper> listOrderNoBilling { get; set; } 

    /**@description Indicates if a custom message is present*/
    public boolean hasMessages {
        get {
            return ApexPages.hasMessages();
        }
    }

    /**@description The custom error message */
    public String errorMessage {
        get {
            if (hasMessages) {
                return ApexPages.getMessages()[0].getDetail();
            }
            return null;
        }
    }

    /**@description The type of message: 'error' or 'success' */
    public string alertType {
        get {
            if (hasMessages) {
                ApexPages.Severity severity = ApexPages.getMessages()[0].getSeverity();
                if (severity == ApexPages.Severity.CONFIRM) {
                    return 'success';
                }
                if (severity == ApexPages.Severity.ERROR || severity == ApexPages.Severity.FATAL) {
                    return 'error';
                }
                if (severity == ApexPages.Severity.INFO) {
                    return 'offline';
                }
                if (severity == ApexPages.Severity.WARNING) {
                    return 'warning';
                }
                return '';
            }
            return 'error';
        }
        private set;
    }

    public SAPQASOrderDetailsController() {
        listOrderDetailWrapper = new List<OrderDetailWrapper> ();
        inputSalesOrd = '';
        salesOrderNumber = '';
        customerPONumber = '';
        hasOrderDetails = false;

        if (isInSalesforce1) {
            fieldsetApiName = 'Sales_Order_Information_Salesforce1';
            isUserInMobile = true;
        } else {
            fieldsetApiName = 'Sales_Order_Information';
            isUserInMobile = false;
        }
    }
    
    public SAPQASOrderDetailsController(ApexPages.StandardController controller) {
        listOrderDetailWrapper = new List<OrderDetailWrapper> ();
        inputSalesOrd = '';
        salesOrderNumber = '';
        customerPONumber = '';
        hasOrderDetails = false;

        fieldsetApiName = 'Sales_Order_Information_Salesforce1';
        isUserInMobile = true;
        
        if (!Test.isRunningTest()) {
            controller.addFields(new List<String>{'Name'});
        }
        Order__c orderRec = (Order__c) controller.getRecord();
        inputSalesOrd = orderRec.Name;
        showList();
    }
    
    /**
     * @description Find Order Details by Id
     */
    public void showList() {
        Boolean hasError = false;
	
        if (String.isEmpty(inputSalesOrd)) {
            ApexPages.addMessage(New ApexPages.Message(ApexPages.severity.WARNING, 'Please enter Sales Order Number'));
            hasError = true;
        }

        if (inputSalesOrd.length() > 10) {
            ApexPages.addMessage(New ApexPages.Message(ApexPages.severity.WARNING, 'You have entered invalid Sales Order Number'));
            hasError = true;
        }

        if (!hasError) {
            inputSalesOrd = inputSalesOrd.trim();
            String tempInputSalesOrd = inputSalesOrd;

            inputSalesOrd = inputSalesOrd.leftPad(10, '0');
   
            String condition = 'IVbeln__c = ' + UtilityClass.encloseStringWithApos(inputSalesOrd);
            
            String query = UtilityClass.constructSOQLQuery(fieldsetApiName, 'SF_Order_DetailsSet__x', condition, 999, null, null, null);
            if (String.isNotEmpty(query)) {
                if (!Test.isRunningTest()) {
                    orderdet = Database.query(query);
                } else {
                    orderdet = new List<SF_Order_DetailsSet__x>();

                    if (inputSalesOrd == '00test1234') {
                        orderdet.add(SAPQASOrderDetailsControllerTest.createOrderDetailSetRecord());
                    }
                }
                
                transient Map<String, List<OrderDetailWrapper>> orderWrapMap = new Map<String, List<OrderDetailWrapper>>();
                if (!orderdet.isEmpty()) {
                   
                    Map<String, String> mapCarrierTrackingUrl = new Map<String, String> ();
                    salesOrderNumber = orderdet[0].VbelnVa__c;
                    customerPONumber = orderdet[0].Bstnk__c;
                    hasOrderDetails = true;

                    // get carriers
                    Set<String> setCarriers = new Set<String> ();
                    for (SF_Order_DetailsSet__x orderDetail : orderdet) {
                        setCarriers.add(orderDetail.Carrier__c);
                    }

                    // get carrier tracking url
                    if (!setCarriers.isEmpty()) {
                        for (Carrier_Tracking_URL__mdt carrierDetails : [SELECT DeveloperName, TrackingURL__c
                                                                           FROM Carrier_Tracking_URL__mdt
                                                                          WHERE DeveloperName IN :setCarriers]) {

                            mapCarrierTrackingUrl.put(carrierDetails.DeveloperName, carrierDetails.TrackingURL__c);
                        }
                    }

                    String noBillofLading = 'No Bill of Lading Available';
                    listOrderDetailWrapper = new List<OrderDetailWrapper> ();
                    for (SF_Order_DetailsSet__x orderDetail : orderdet) {                    
                        OrderDetailWrapper odw;
                        if (!mapCarrierTrackingUrl.isEmpty()) {
                            if (mapCarrierTrackingUrl.containsKey(orderDetail.Carrier__c)) {
                                odw = new OrderDetailWrapper(orderDetail, mapCarrierTrackingUrl.get(orderDetail.Carrier__c));   
                            } else {
                                odw = new OrderDetailWrapper(orderDetail, '');
                            }
                        } else {
                            odw = new OrderDetailWrapper(orderDetail, '');
                        }
                        
                        listOrderDetailWrapper.add(odw);
                        if (String.isNotBlank(orderDetail.ConNote__c)) {
                            String billOfLading = 'Bill of Lading: ' + orderDetail.ConNote__c;
                            if (orderWrapMap.containsKey(billOfLading)) {
                                List<OrderDetailWrapper> ordDetailWrapList = orderWrapMap.get(billOfLading);
                                ordDetailWrapList.add(odw);
                                orderWrapMap.put(billOfLading, ordDetailWrapList);
                            } else { 
                                orderWrapMap.put(billOfLading, new List<OrderDetailWrapper>{odw});
                            }
                        } else {                            
                            if (orderWrapMap.containsKey(noBillofLading)) {
                                List<OrderDetailWrapper> ordDetailWrapList = orderWrapMap.get(noBillofLading);
                                ordDetailWrapList.add(odw);
                                orderWrapMap.put(noBillofLading, ordDetailWrapList);
                            } else { 
                                orderWrapMap.put(noBillofLading, new List<OrderDetailWrapper>{odw});
                            }                        
                        }
                    }

                    listOrderNoBilling = new List<OrderDetailGroupedWrapper>();  
                    listOrderDetailGroupedWrapper = new List<OrderDetailGroupedWrapper>();               
                    for (String connote : orderWrapMap.keySet()) {
                      
                        if (connote != noBillofLading) {
                            listOrderDetailGroupedWrapper.add(new OrderDetailGroupedWrapper(connote, orderWrapMap.get(connote)));
                        } else {
                            listOrderNoBilling.add(new OrderDetailGroupedWrapper(connote, orderWrapMap.get(connote)));
                        }
                    }    
                } else {
                    ApexPages.addMessage(New ApexPages.Message(ApexPages.severity.INFO, 'Sales Order Number not exist'));
                    hasError = true;

                    salesOrderNumber = '';
                    customerPONumber = '';
                    hasOrderDetails = false;
                }                    
            }

            inputSalesOrd = tempInputSalesOrd;
        }
    }

    /**
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
            this.showTrackButton = String.isNotEmpty(orderDetail.Carrier__c) 
                    && String.isNotEmpty(orderDetail.ConNote__c) && String.isNotEmpty(trackURL);
        }
    }
    
    public class OrderDetailGroupedWrapper {
        public String billofLading { get; set; }
        public List<OrderDetailWrapper> orderDetailWrapperList { get; set; }
        
        public OrderDetailGroupedWrapper(String billofLading, List<OrderDetailWrapper> orderDetailWrapperList) {
            this.billofLading = billofLading;
            this.orderDetailWrapperList = orderDetailWrapperList;
        }
    }
}