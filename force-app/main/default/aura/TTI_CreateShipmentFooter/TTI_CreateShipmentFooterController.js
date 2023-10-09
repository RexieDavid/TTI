/**
 * @File Name          : TTI_CreateShipmentFooterController.js
 * @Description        : 
 * @Author             : Francis Nasalita
 * @Group              : 
 * @Last Modified By   : Francis Nasalita
 * @Last Modified On   : 09/08/2019, 1:03:09 pm
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author            Modification
 *==============================================================================
 * 1.0    09/08/2019, 1:03:09 pm   Francis Nasalita     Initial Version
**/
({
    handleCancel: function(component, event, helper) {
        component.set("v.isCaseUpdated", false);
        component.set('v.isChangedToPickup', false);

        component.set("v.execCreateShipment", false);
        component.find("overlayLib").notifyClose();
        component.set('v.hasFormError', false);
    },

	handleSave: function(component, event, helper) {
        let claim = component.get("v.serviceReqCase");
        const hasFormError = component.get('v.hasFormError');
        
        claim.FreightOutDeliverTo__c = null;
        claim.TTI_Freight_Out_Delivery_Address__c = null;
        claim.TTI_Freight_Out_Delivery_Suburb__c = null;
        claim.TTI_Freight_Out_Delivery_Postcode__c = null;
        claim.TTI_Freight_Out_Delivery_State__c = null;
        claim.TTI_Freight_Out_Delivery_Country__c = null;
        claim.TTI_Freight_Out_Courier__c = null;
        claim.TTI_Freight_Out_Required__c = false;
        
        if (!hasFormError) {
            component.set("v.isCaseUpdated", true);
            component.set('v.isChangedToPickup', true);
            component.set("v.execCreateShipment", false);
            component.find("overlayLib").notifyClose();
        }
    },
    
    handleOK: function(component, event, helper) {
        let claim = component.get("v.serviceReqCase");
        let ftype = event.getSource().get("v.value");
        let fileExtension = ftype === 'ZPL' ? 'txt' : ftype.toLowerCase();
        const isCaseUpdated = component.get("v.isCaseUpdated");
        const isCaseOrLabelUpdated = isCaseUpdated || (claim.Label_Url__c && !claim.Label_Url__c.includes('.' + fileExtension));
        const hasFormError = component.get('v.hasFormError');
        
        if (!hasFormError) {
            component.set("v.isCaseUpdated", isCaseOrLabelUpdated);
            component.set("v.labelFormat", ftype);
            component.set("v.execCreateShipment", true);
            component.find("overlayLib").notifyClose();
        }
    }
})