({
    doInit: function(component, event, helper) {
        helper.getProductCategoryImages(component);
        helper.getDefaultSNDisplay(component);
        helper.getSiteBrand(component);
        helper.getProducts(component);
    },

    handleKeyUp: function(component, event, helper) {
        let searchTerm = component.find('enter-search').get('v.value').trim().toLowerCase();
        let payload = component.get('v.payload');
        payload = payload.filter(el => el.custom.label.toLowerCase().indexOf(searchTerm) !== -1);
        component.set('v.productsList', payload);
        component.set('v.hasResult', payload && payload.length > 0);
    },

    showList: function(component, event, helper) {
        let listbox = component.find('productsList');
        $A.util.removeClass(listbox, 'slds-hide');
        event.stopPropagation();
    },

    handleSelect: function(component, event, helper) {
        let productsList = component.get('v.productsList');
        let dataId = event.currentTarget.dataset.id;
        let selectedProduct = productsList.filter(el => el.Id === dataId)[0];
        component.set('v.selectedProduct', selectedProduct);
        component.set('v.hasProductKit', selectedProduct.Kit_Products__r && selectedProduct.Kit_Products__r.length > 0);
        $A.util.removeClass(component.find('productView'), 'slds-hide');
        helper.closeDropdown(component, event);
    },

    handleChangeCategory: function(component, event, helper) {
        let eventObj = event.currentTarget;
        const dataCategory = eventObj.dataset.category;
        let dataLevel = eventObj.dataset.level;
        let categoryLevel = component.get('v.categoryLevel');
        helper.setupProducts(component, dataCategory, dataLevel ? ++dataLevel : ++categoryLevel);

    },

    handleRegister: function(component, event, helper) {
        const mainDiv = component.find('mainSelectionDiv');
        const navEvent = $A.get("e.c:WarrantyProductSelectionEvent");
        const defaultSNDisplay = component.get("v.defaultSerialNumberDisplay");
        const dataId = event.getSource().get('v.value');
        const payload = component.get('v.payload');
        const selectedProduct = payload.filter(el => el.Id === dataId)[0];
        
        let asset = {};
        let assetsList = [];

        asset.Name = selectedProduct.Customer_Facing_Name__c;
        asset.Product2Id = selectedProduct.Id;
        asset.Quantity = 1.00;
        asset.ProductCode = selectedProduct.ProductCode;
        asset.Image_URL__c = selectedProduct.Image_URL__c;
        asset.SerialNumber = '';
        asset.Is_Serial_Number_Optional__c = selectedProduct.Is_Serial_Number_Optional__c;

        if (selectedProduct.SerialNumberDisplayType__c && selectedProduct.SerialNumberDisplayType__r) {
            asset.Display_Week__c = selectedProduct.SerialNumberDisplayType__r.Display_Week__c;
            asset.Display_Year__c = selectedProduct.SerialNumberDisplayType__r.Display_Year__c;
            asset.Allow_Numbers_Only__c = selectedProduct.SerialNumberDisplayType__r.Allow_Numbers_Only__c;
            asset.Regexpression_Validator__c = selectedProduct.SerialNumberDisplayType__r.Regexpression_Validator__c;
            asset.Serial_Number_Length__c = selectedProduct.SerialNumberDisplayType__r.Serial_Number_Length__c;
            asset.HelpText__c = selectedProduct.Is_Serial_Number_Optional__c ? $A.get("$Label.c.Exclude_Serial_Number") : selectedProduct.SerialNumberDisplayType__r.HelpText__c;
            asset.Helper_Image_URL__c = selectedProduct.SerialNumberDisplayType__r.HelperImageURL__c;
            asset.EnforceLength__c = selectedProduct.SerialNumberDisplayType__r.EnforceLength__c;
        } else {
            asset.Display_Week__c = defaultSNDisplay.Display_Week__c;
            asset.Display_Year__c = defaultSNDisplay.Display_Year__c;
            asset.Allow_Numbers_Only__c = defaultSNDisplay.Allow_Numbers_Only__c;
            asset.Regexpression_Validator__c = defaultSNDisplay.Regexpression_Validator__c;
            asset.Serial_Number_Length__c = defaultSNDisplay.Serial_Number_Length__c;
            asset.HelpText__c = defaultSNDisplay.HelpText__c;
            asset.Helper_Image_URL__c = defaultSNDisplay.HelperImageURL__c;
            asset.EnforceLength__c = defaultSNDisplay.EnforceLength__c;
        }

        if (selectedProduct.Kit_Products__r && selectedProduct.Kit_Products__r.length > 0) {
            console.log('inside if');
            selectedProduct.Kit_Products__r.forEach(el => {
                var displayWeek = defaultSNDisplay.Display_Week__c;
                var displayYear = defaultSNDisplay.Display_Year__c;
                var allowsNumber = defaultSNDisplay.Allow_Numbers_Only__c;
                var regExVal = defaultSNDisplay.Regexpression_Validator__c;
                var snLength = defaultSNDisplay.Serial_Number_Length__c;
                var helpText = defaultSNDisplay.HelpText__c;
                var helperImage = defaultSNDisplay.HelperImageURL__c;
                var enforceLength = defaultSNDisplay.EnforceLength__c;

                if (el.Kit_Tool__r.SerialNumberDisplayType__c && el.Kit_Tool__r.SerialNumberDisplayType__r) {
                    displayWeek = el.Kit_Tool__r.SerialNumberDisplayType__r.Display_Week__c;
                    displayYear = el.Kit_Tool__r.SerialNumberDisplayType__r.Display_Year__c;
                    allowsNumber = el.Kit_Tool__r.SerialNumberDisplayType__r.Allow_Numbers_Only__c;
                    regExVal = el.Kit_Tool__r.SerialNumberDisplayType__r.Regexpression_Validator__c;
                    snLength = el.Kit_Tool__r.SerialNumberDisplayType__r.Serial_Number_Length__c;
                    helpText = el.Kit_Tool__r.SerialNumberDisplayType__r.HelpText__c;
                    helperImage = el.Kit_Tool__r.SerialNumberDisplayType__r.HelperImageURL__c;
                    enforceLength = el.Kit_Tool__r.SerialNumberDisplayType__r.EnforceLength__c;
                }



                for (var j = 0; j < el.Quantity__c; j++) {
                    assetsList.push({
                        sobjectType: "Asset",
                        KitProduct__c: selectedProduct.Id,
                        Name: el.Kit_Tool__r.Customer_Facing_Name__c,
                        Product2Id: el.Kit_Tool__r.Id,
                        Quantity: 1.00,
                        ProductCode: el.Kit_Tool__r.ProductCode,
                        Image_URL__c: el.Kit_Tool__r.Image_URL__c,
                        Small_Image_URL__c: el.Kit_Tool__r.Small_Image_URL__c,
                        SerialNumber: '',
                        Display_Week__c: displayWeek,
                        Display_Year__c: displayYear,
                        Allow_Numbers_Only__c: allowsNumber,
                        Regexpression_Validator__c: regExVal,
                        Serial_Number_Length__c: snLength,
                        HelpText__c: helpText,
                        Helper_Image_URL__c: helperImage,
                        EnforceLength__c: enforceLength,
                        Is_Serial_Number_Optional__c: el.Kit_Tool__r.Is_Serial_Number_Optional__c
                    });
                }
            });
            navEvent.setParams({ "individualAssetList": assetsList });
        	console.log('called assetlist' + JSON.stringify(assetsList));
        } else {
            navEvent.setParams({"individualAssetList": [asset]});
			console.log('called asset' +JSON.stringify(asset));
        }

        $A.util.addClass(mainDiv, 'slds-hide');
        navEvent.setParams({
            "selectedAsset": asset
        });
        navEvent.fire();
    },

    handleNavigateFromDetailPage: function(component, event) {
        const mainDiv = component.find('mainSelectionDiv');
        $A.util.removeClass(mainDiv, 'slds-hide');
    },

    clearSelected: function(component, event, helper) {
        component.set('v.selectedProduct', {});
        $A.util.addClass(component.find('productView'), 'slds-hide');
    }
})