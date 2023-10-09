({
    handleNavigateFromSelectionEvent: function(component, event, helper) {
        var url = window.location.href;
        url += '#!'
        window.location.href = url;
        // set the handler attributes based on event data
        var asset = event.getParam("selectedAsset");
        component.set("v.asset", asset);
        component.set("v.assetImageURL", asset.Image_URL__c);
        component.set("v.assetProductCode", asset.ProductCode);
        component.set("v.purchaseDateP", asset.PurchaseDate);
        component.set("v.registerDate", asset.CreatedDate);
        component.set("v.serialNoP", asset.SerialNumber);
        component.set("v.serialWeek", asset.SerialNumberWeek__c);
        component.set("v.serialYear", asset.SerialNumberYear__c);
        component.set("v.assetIsSerialNumberOptional", asset.Is_Serial_Number_Optional__c);
        
        helper.updateLocationList(component);
        helper.populateForEdit(component);
        helper.initializeCustomSettings(component);
        
        //added below line to hide view div in the Toolbox Page Component
        $("#viewToolBagDiv").hide();
        $("#mainDetailDiv").show(); 
    },
    // INC0032031 - My Ryobi edit screen details does not match initial  details - 01/20/2022 - JAC
    // onGroupP: function(component) {
    //     var selected = component.get("v.locationP");
    //     if (selected === "Bunnings") {
    //         $A.util.addClass(component.find("otherLocP"), 'hidden');
    //     } else if (selected === "Others") {
    //         $A.util.removeClass(component.find("otherLocP"), 'hidden');
    //     }
    // },
    // INC0032031 - End
    
    fileUploaded: function(component, event, helper) {
        helper.fileUploaded(component);
    },
    
    confirmAndEdit: function(component, event, helper) {
        event.getSource().set("v.disabled", true);
        if (helper.validateForm(component)) {
            helper.saveRegsitration(component);
        }
        event.getSource().set("v.disabled", false);
    },
    
    goBackToSelection: function(component,event,helper) {
        $("#mainDetailDiv").hide();
        $("#promptDiv").hide();
        $("#editError").hide();
        //added below line to show view div in the Toolbox Page Component
        $("#viewToolBagDiv").show();

        component.find("confirmBtn").set("v.disabled", false);
        var evt = $A.get("e.c:ProductDetailConfirmEvent");
        evt.fire();
    }
})