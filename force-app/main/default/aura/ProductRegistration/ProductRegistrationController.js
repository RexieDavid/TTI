({ 
    onGroupP: function(cmp, evt) {
        var selected = cmp.get("v.locationP");    
        if (selected === "Bunnings") {
            $A.util.addClass(cmp.find("otherLocP"), 'hidden');

        } else if (selected === "Others") {
            $A.util.removeClass(cmp.find("otherLocP"), 'hidden');
        }
    }, 
    
    navigateToCreateRedemption : function(component, event, helper) {
        var url = component.get('v.siteSettings').Redemption__c + '?PromotionId=' + component.get('v.redemptionCampaign').Id;
        window.location.href = url;
    },
    
    onGroupK: function(cmp, evt) {
        var selected = cmp.get("v.locationK");
        if (selected === "Bunnings") {
            $A.util.addClass(cmp.find("otherLocK"), 'hidden');
        } else if (selected === "Others") {
            $A.util.removeClass(cmp.find("otherLocK"), 'hidden');
        }
    }, 
    
    handleNavigateFromSelectionEvent : function(component, event, helper) {
        
        // set the handler attributes based on event data
        var asset = event.getParam("selectedAsset");
        component.set("v.asset", asset);
        component.set("v.assetImageURL", asset.Image_URL__c);
        component.set("v.assetProductCode", asset.ProductCode);
        component.set("v.assetIsSerialNumberOptional", asset.Is_Serial_Number_Optional__c);

        var individualAssetList = event.getParam("individualAssetList");
        component.set("v.individualAssetList", individualAssetList);

        component.set("v.purchaseDateP", '');
        component.set("v.purchaseDateK", '');
        component.set("v.serialNoP", '');
        component.set("v.locationHolderP", '');
        component.set("v.locationHolderK", '');
        component.set("v.serialWeek", '');
        component.set("v.serialYear", '');
        component.set("v.isBunningReceipt", 'Yes');
                
        helper.updateLocationList(component);
        helper.initializeCustomSettings(component);
        
        $("#confirmBtn").blur();
        
        if (individualAssetList.length > 1) {
            $("#kitDetailDiv").show(); 
            $("#productDetailDiv").hide(); 
        } else {
            $("#kitDetailDiv").hide(); 
            $("#productDetailDiv").show(); 
        }
        
        $("#mainDetailDiv").show(); 
    }, 

    fileUploaded : function(component, event, helper) {
        helper.fileUploaded(component);
    }, 
    
    kitFileUploaded : function(component, event, helper) {
        helper.kitFileUploaded(component);
    }, 
    
    confirmAddMore : function(component, event, helper) {
        event.getSource().set("v.disabled", true);      
        
        if (helper.validateForm(component)) {          
            helper.saveRegistration(component);
        }
        
        event.getSource().set("v.disabled", false);
    }, 
    
    goBackToSelection : function(component, event, helper) {
        $("#mainDetailDiv").hide();
        $("#promptDiv").hide();
        var evt = $A.get("e.c:ProductDetailConfirmEvent");
        evt.fire();
    }, 
    
    goBackToToolbox : function(component, event, helper) {
        $("#mainDetailDiv").hide();
        $("#promptDiv").hide();
        component.find("confirmBtn").set("v.disabled", false);
        var evt = $A.get("e.c:ToolBoxListEvent");
        evt.fire();
    }, 

    displaySerialHelper: function(component, event, helper) {
        var idx = event.target.id;
        helper.setSerialHelperPromptValues(component, idx);
        
       $("#SerialHelperInfo").show();
    }, 

    hideSerialHelper: function(component, event, helper) {
        $("#SerialHelperInfo").hide();
    },

    navigateToToolbag: function(component, event, helper) {
        event.preventDefault();
        // Remove /s only if it is in the beginning
        helper.navigateTo(component.get('v.siteSettings').My_Toolbag__c.replace(/^(\/s)/,""));
    }
})