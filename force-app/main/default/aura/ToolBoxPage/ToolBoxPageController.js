({
    doInit: function(component, event, helper) {
        helper.initializeView(component);
        helper.inializeList(component);
        helper.inializeRemove(component);
        helper.initializeCustomSettings(component);
    },

    handleNavigateFromDetailPage: function(component, event, helper) {
        component.set("v.fromNavigation", true); //RD INC0020163 12/20 Fix for List Ordering after viewing the product
        helper.inializeList(component);
        component.set("v.toolbagView", component.get("v.tempView"));
    },

    editAssetBtn: function(component, event, helper) {
        var assetIndex = event.currentTarget.value;
        var assetList = component.get("v.assetList");
        var pageNum = component.get("v.pageNumber");
        component.set("v.toolbagView", '');
        //RD INC0020163 12/20 Fix for Toolbox selection 
        const concat = '' + (pageNum-1) + assetIndex;
        var asset = assetList[parseInt(concat)];
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
        navEvent.setParams({"selectedAsset": asset});
        navEvent.fire();
    },

    removeAsset: function(component, event, helper) {
        var assetIndex = event.getSource().get("v.value");
        component.set("v.selectedIndex", assetIndex);
        var removeDiv = component.find('removeDiv');
        helper.toggleClasses(removeDiv);
    },

    removeAssetBtn: function(component, event, helper) {
        var assetIndex = event.currentTarget.value;
        component.set("v.selectedIndex", assetIndex);
        var removeDiv = component.find('removeDiv');
        helper.toggleClasses(removeDiv);
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
        helper.toggleClasses(removeDiv);
    },

    successDone: function(component, event, helper) {
        var successDiv = component.find('successDiv');
        helper.toggleClasses(successDiv);
        var url = window.location.href;

        if (url.includes("#")) {
           url = url.includes("#!") ? url.slice(0, url.indexOf("#!")) : url.slice(0, url.indexOf("#"));
        }
        url = (url.includes("toolbagview=")) ? url : url + '?toolbagview=' + component.get("v.toolbagView");
        location.replace(url);
    },

    errorDone: function(component, event, helper) {
        const errorDiv = component.find('errorDiv');
        helper.toggleClasses(errorDiv);
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
        helper.toggleClasses(cmpTarget);
    },

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
                            helper.searchFor(component, component.get("v.searchTxt").trim(), component.get("v.allAsset")));
    },

    changeView: function(component, event, helper) {
        var toolbagView = component.get("v.toolbagView");
        const tileButton = component.find('tile-button');
        const listButton = component.find('list-button');
        const listView = component.find('list-view');
        const toolBoxDetailDiv = component.find('toolBoxDetailDiv');
        let arr = [tileButton, listButton, listView, toolBoxDetailDiv];
        toolbagView = toolbagView === 'tile' ? 'list' : 'tile';
        component.set("v.toolbagView", toolbagView);
        component.set("v.tempView", toolbagView);
        helper.toggleClasses(arr);
    },

    navigateToRegisterNewProduct: function(component, event, helper) {
        event.preventDefault();
        // Remove /s only if it is in the beginning
        helper.navigateTo(component.get('v.siteSettings').Register_New_Product__c.replace(/^(\/s)/,""));
    }
})