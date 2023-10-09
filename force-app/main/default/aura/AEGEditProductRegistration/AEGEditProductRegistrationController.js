({
    handleNavigateFromSelectionEvent: function (component, event, helper) {
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
        component.set("v.assetHelpText", asset.HelpText__c.split("_"));

        helper.updateLocationList(component);
        helper.populateForEdit(component);
        helper.initializeCustomSettings(component);
        
        $("#mainDetailDiv").show();
    },

    onGroupP: function (cmp, evt) {
        var selected = cmp.get("v.locationP");

        if (selected === "Bunnings") {
            $A.util.addClass(cmp.find("otherLocP"), "hidden");
        } else if (selected === "Others") {
            $A.util.removeClass(cmp.find("otherLocP"), "hidden");
        }
    },

    fileUploaded: function (component, event, helper) {
        helper.fileUploaded(component);
    },

    confirmAndEdit: function (component, event, helper) {

        event.getSource().set("v.disabled", true);

        if (helper.validateForm(component)) {
            helper.saveRegsitration(component);
        }

        event.getSource().set("v.disabled", false);
    },

    goBackToSelection: function (component, event, helper) {
        $("#mainDetailDiv").hide();
        $("#promptDiv").hide();
        $("#editError").hide();

        component.find("confirmBtn").set("v.disabled", false);
        var evt = $A.get("e.c:ProductDetailConfirmEvent");
        evt.fire();
    },
});