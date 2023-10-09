({
    doInit: function(component, event, helper) {
        helper.initializeView(component);
        helper.inializeList(component);
        helper.inializeRemove(component);
        helper.initializeCustomSettings(component);
    },

    handleNavigateFromDetailPage: function(component, event, helper) {
        helper.inializeList(component);
        component.set("v.toolbagView", component.get("v.tempView"));
    },

    editAsset: function(component, event, helper) {
        var assetIndex = event.getSource().get("v.value");
        var assetList = component.get("v.assetList");
        const toolbagView = component.get('v.toolbagView');
        component.set("v.tempView", toolbagView);
        component.set("v.toolbagView", '');
        //build the selected top line asset variable to send
        var asset = assetList[assetIndex];
        asset.ProductCode = asset.Product2.ProductCode;
        asset.Image_URL__c = asset.Product2.Image_URL__c;
        asset.Receipt__c = asset.Receipt__c;
        asset.SerialNumberWeek__c = asset.SerialNumberWeek__c;
        asset.SerialNumberYear__c = asset.SerialNumberYear__c;
        asset.Display_Week__c = asset.Display_Week__c;
        asset.Display_Year__c = asset.Display_Year__c;
        asset.Allow_Numbers_Only__c = asset.Allow_Numbers_Only__c;
        asset.Regexpression_Validator__c = asset.Regexpression_Validator__c;
        asset.Serial_Number_Length__c = asset.Serial_Number_Length__c;
        asset.HelpText__c = asset.HelpText__c;
        asset.Helper_Image_URL__c = asset.Helper_Image_URL__c;
        asset.EnforceLength__c = asset.EnforceLength__c;

        var navEvent = $A.get("e.c:ToolBoxListEvent");
        navEvent.setParams({ "selectedAsset": asset });
        navEvent.fire();
    },

    editAssetBtn: function(component, event, helper) {
        var assetIndex = event.currentTarget.value;
        var assetList = component.get("v.assetList");
        const toolbagView = component.get('v.toolbagView');
        component.set("v.tempView", toolbagView);
        component.set("v.toolbagView", '');

        //build the selected top line asset variable to send
        var asset = assetList[assetIndex];

        asset.ProductCode = asset.Product2.ProductCode;
        asset.Image_URL__c = asset.Product2.Image_URL__c;
        asset.Receipt__c = asset.Receipt__c;
        asset.SerialNumberWeek__c = asset.SerialNumberWeek__c;
        asset.SerialNumberYear__c = asset.SerialNumberYear__c;
        asset.Display_Week__c = asset.Display_Week__c;
        asset.Display_Year__c = asset.Display_Year__c;
        asset.Allow_Numbers_Only__c = asset.Allow_Numbers_Only__c;
        asset.Regexpression_Validator__c = asset.Regexpression_Validator__c;
        asset.Serial_Number_Length__c = asset.Serial_Number_Length__c;
        asset.HelpText__c = asset.HelpText__c;
        asset.Helper_Image_URL__c = asset.Helper_Image_URL__c;
        asset.EnforceLength__c = asset.EnforceLength__c;
        var navEvent = $A.get("e.c:ToolBoxListEvent");
        navEvent.setParams({ "selectedAsset": asset });
        navEvent.fire();
    },

    removeAsset: function(component, event, helper) {
        var assetIndex = event.getSource().get("v.value");
        component.set("v.selectedIndex", assetIndex);
        var removeDiv = component.find('removeDiv');
        $A.util.removeClass(removeDiv, 'slds-hide');
        $A.util.addClass(removeDiv, 'slds-show');
    },
    removeAssetBtn: function(component, event, helper) {
        var assetIndex = event.currentTarget.value;
        component.set("v.selectedIndex", assetIndex);

        var removeDiv = component.find('removeDiv');
        $A.util.removeClass(removeDiv, 'slds-hide');
        $A.util.addClass(removeDiv, 'slds-show');
    },

    confirmRemove: function(component, event, helper) {
        var assetIndex = component.get("v.selectedIndex");
        var assetList = component.get("v.assetList");
        var asset = assetList[assetIndex];
        helper.removeAst(asset, component);
    },

    cancelRemove: function(component, event, helper) {
        component.set("v.selectedIndex", "-1");
        var removeDiv = component.find('removeDiv');
        $A.util.removeClass(removeDiv, 'slds-show');
        $A.util.addClass(removeDiv, 'slds-hide');
    },

    successDone: function(component, event, helper) {
        var successDiv = component.find('successDiv');
        $A.util.removeClass(successDiv, 'slds-show');
        $A.util.addClass(successDiv, 'slds-hide');
        var url = window.location.href;
        var index = 0;

        if (url.includes("#")) {
            if (url.includes("#!")) {
                url = url.slice(0, url.indexOf("#!"));
            } else {
                url = url.slice(0, url.indexOf("#"));
            }
        }

        url = (url.includes("toolbagview=")) ? url : url + '?toolbagview=' + component.get("v.toolbagView");
        location.replace(url);
    },

    errorDone: function(component, event, helper) {
        var errorDiv = component.find('errorDiv');
        $A.util.removeClass(errorDiv, 'slds-show');
        $A.util.addClass(errorDiv, 'slds-hide');
    },

    displayReceipt: function(component, event, helper) {
        var assetIndex = event.getSource().get("v.value");
        var assetList = component.get("v.assetList");
        var asset = assetList[assetIndex];
        helper.setAttachment(component, asset);

    },
    displayReceiptBtn: function(component, event, helper) {
        var assetIndex = event.currentTarget.value;
        var assetList = component.get("v.assetList");
        var asset = assetList[assetIndex];

        helper.setAttachment(component, asset);

    },

    hideReceipt: function(component, event, helper) {
        var cmpTarget = component.find('ImageDisplay');
        $A.util.removeClass(cmpTarget, 'slds-show');
        $A.util.addClass(cmpTarget, 'slds-hide');
    },

    /*  Sorting and Pagination methods  */
    sortColumn: function(component, event, helper) {
        var colID = event.target.id,
            colID = colID.slice(colID.indexOf("-") + 1, colID.length);
        helper.sortBy(component, colID);
    },

    renderPage: function(component, event, helper) {
        helper.renderPage(component);
    },

    searchFor: function(component, event, helper) {
        helper.sortBySearch(component,
            component.get("v.sortField"),
            helper.searchFor(component, component.get("v.searchTxt"), component.get("v.allAsset")));
    },

    changeView: function(component, event, helper) {
        var toolbagView = component.get("v.toolbagView");
        toolbagView = toolbagView === 'tile' ? 'list' : 'tile';
        component.set("v.toolbagView", toolbagView);
        component.set("v.tempView", toolbagView);
    },

    navigateToRegisterProduct: function(component, event, helper) {
        event.preventDefault();
        const settings = component.get('v.siteSettings');
        // Remove /s only if it is in the beginning
        helper.navigateTo(settings.Register_New_Product__c.replace(/^(\/s)/, ""));
    }
})