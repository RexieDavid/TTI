({
    doInit: function(component, event, helper) {
        helper.getProductCategoryImages(component);
        helper.getDefaultSNDisplay(component);
        helper.getSiteBrand(component);
    },


    afterScriptsLoaded: function(component, event, helper) {
        helper.getProducts(component);
    },

    resizeTest: function(component, event, helper) {
        var maxHeight = 0;
        $('.globalProductItemBox')
            .each(function() { maxHeight = Math.max(maxHeight, $(this).height()); })
            .height(maxHeight);

        alert(maxHeight);
        maxHeight = 0;
        $('.globalProductItemBlurb')
            .each(function() { maxHeight = Math.max(maxHeight, $(this).height()); })
            .height(maxHeight);
        alert(maxHeight);

    },


    selectionMade: function(component, event, helper) {
        var selectedCategory = event.target.getAttribute('data-index');
        var nextLevel = event.target.getAttribute('data-nextLevel');
        helper.setActiveCrumb(nextLevel);

        switch (parseInt(nextLevel)) {
            case 2:
                $('#level1CatDiv').hide();
                component.set("v.level1Selected", selectedCategory);
                helper.buildCategoryList(component, selectedCategory, nextLevel);
                $('#level2CatDiv').show();
                break;
            case 3:
                $('#level2CatDiv').hide();
                component.set("v.level2Selected", selectedCategory);
                helper.buildCategoryList(component, selectedCategory, nextLevel);
                if (component.get("v.level3").length === 0) {
                    component.set("v.level3Selected", '');
                    helper.buildCategoryList(component, '', 4);
                    $('#productsDiv').show();
                    //$('#crumb2').addClass('last-child');
                } else {
                    $('#level3CatDiv').show();
                }
                break;
            case 4:
                $('#level3CatDiv').hide();
                component.set("v.level3Selected", selectedCategory);
                helper.buildCategoryList(component, selectedCategory, nextLevel);

                $('#productsDiv').show();
                break;
            default:
                break;
        }
    },

    //go back based on breadcrumb selection
    breadcrumbSelection: function(component, event, helper) {
        var selectedCategoryLevel = event.target.getAttribute('data-index');
        helper.setActiveCrumb(selectedCategoryLevel);
        switch (parseInt(selectedCategoryLevel)) {
            case 1:
                $('#level2CatDiv').hide();
                $('#level3CatDiv').hide();
                $('#productsDiv').hide();
                helper.buildCategoryList(component, '', selectedCategoryLevel);
                $('#level1CatDiv').show();
                break;
            case 2:
                var selectedCategory = component.get("v.level1Selected");
                $('#level1CatDiv').hide();
                $('#level3CatDiv').hide();
                $('#productsDiv').hide();
                $('#crumb0').removeClass('active');
                $('#crumb1').removeClass('active');
                $('#crumb2').addClass('active');
                $('#crumb3').removeClass('active');
                helper.buildCategoryList(component, selectedCategory, selectedCategoryLevel);
                $('#level2CatDiv').show();
                break;
            case 3:
                var selectedCategory = component.get("v.level2Selected");
                $('#level1CatDiv').hide();
                $('#level2CatDiv').hide();
                $('#productsDiv').hide();
                helper.buildCategoryList(component, selectedCategory, selectedCategoryLevel);
                $('#level3CatDiv').show();
                break;
            default:
                break;

        }

    },

    handleNavigateFromDetailPage: function(component, event) {
        $("#mainSelectionDiv").show();
    },

    productSelected2: function(component, event, helper) {
        var selectedId = event.target.getAttribute('value');

        if (selectedId === null) {
            var selectedId = event.target.getAttribute('data-index');
        }

        var searchRegister;
        if (event !== null && selectedId === null) {
            var searchRegister = event.getSource().getLocalId() === "searchRegister"; //user has selected product from search
        }

        var productList = component.get("v.productListFull");

        if (searchRegister) {
            var selectedProduct = component.get("v.selectedProduct");
        }
        else {
            var selectedProduct = undefined;

            for (var i = 0; productList.length; i++) {
                if (productList[i].Id === selectedId) {
                    selectedProduct = productList[i];
                    break;
                }
            }
        }

        component.set("v.selectedProduct", selectedProduct);


        $("#mainSelectionDiv").hide();

        var selectedProduct = component.get("v.selectedProduct");

        //build the selected top line asset variable to send
        var asset = component.get('v.selectedAsset');

        asset.Name = selectedProduct.Customer_Facing_Name__c;
        asset.Product2Id = selectedProduct.Id;
        asset.Quantity = 1.00;
        asset.ProductCode = selectedProduct.ProductCode;
        asset.Image_URL__c = selectedProduct.Image_URL__c;
        asset.SerialNumber = '';

        var defaultSNDisplay = component.get("v.defaultSerialNumberDisplay");
        if (selectedProduct.SerialNumberDisplayType__c != null) {
            asset.Display_Week__c = selectedProduct.SerialNumberDisplayType__r.Display_Week__c;
            asset.Display_Year__c = selectedProduct.SerialNumberDisplayType__r.Display_Year__c;
            asset.Allow_Numbers_Only__c = selectedProduct.SerialNumberDisplayType__r.Allow_Numbers_Only__c;
            asset.Regexpression_Validator__c = selectedProduct.SerialNumberDisplayType__r.Regexpression_Validator__c;
            asset.Serial_Number_Length__c = selectedProduct.SerialNumberDisplayType__r.Serial_Number_Length__c;
            asset.HelpText__c = selectedProduct.SerialNumberDisplayType__r.HelpText__c;
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

        var navEvent = $A.get("e.c:WarrantyProductSelectionEvent");
        navEvent.setParams({ "selectedAsset": asset });

        //check if this is a kit and build the individual assets for the contents
        var kitProductsMapByKitId = component.get("v.kitProductsMapByKitId");
        var kitProductsList = kitProductsMapByKitId[selectedProduct.Id];

        if (kitProductsList != undefined) {

            var assetList = [];

            for (var i = 0; i < kitProductsList.length; i++) {
                var currentKitProduct = kitProductsList[i];
                var displayWeek = defaultSNDisplay.Display_Week__c;
                var displayYear = defaultSNDisplay.Display_Year__c;
                var allowsNumber = defaultSNDisplay.Allow_Numbers_Only__c;
                var regExVal = defaultSNDisplay.Regexpression_Validator__c;
                var snLength = defaultSNDisplay.Serial_Number_Length__c;
                var helpText = defaultSNDisplay.HelpText__c;
                var helperImage = defaultSNDisplay.HelperImageURL__c;
                var enforceLength = defaultSNDisplay.EnforceLength__c;

                if (currentKitProduct.Kit_Tool__r.SerialNumberDisplayType__c != null) {
                    displayWeek = currentKitProduct.Kit_Tool__r.SerialNumberDisplayType__r.Display_Week__c;
                    displayYear = currentKitProduct.Kit_Tool__r.SerialNumberDisplayType__r.Display_Year__c;
                    allowsNumber = currentKitProduct.Kit_Tool__r.SerialNumberDisplayType__r.Allow_Numbers_Only__c;
                    regExVal = currentKitProduct.Kit_Tool__r.SerialNumberDisplayType__r.Regexpression_Validator__c;
                    snLength = currentKitProduct.Kit_Tool__r.SerialNumberDisplayType__r.Serial_Number_Length__c;
                    helpText = currentKitProduct.Kit_Tool__r.SerialNumberDisplayType__r.HelpText__c;
                    helperImage = currentKitProduct.Kit_Tool__r.SerialNumberDisplayType__r.HelperImageURL__c;
                    enforceLength = currentKitProduct.Kit_Tool__r.SerialNumberDisplayType__r.EnforceLength__c;
                }

                for (var j = 0; j < currentKitProduct.Quantity__c; j++) {
                    assetList.push({
                        sobjectType: "Asset",
                        KitProduct__c: selectedProduct.Id,
                        Name: currentKitProduct.Kit_Tool__r.Customer_Facing_Name__c,
                        Product2Id: currentKitProduct.Kit_Tool__r.Id,
                        Quantity: 1.00,
                        ProductCode: currentKitProduct.Kit_Tool__r.ProductCode,
                        Image_URL__c: currentKitProduct.Kit_Tool__r.Image_URL__c,
                        Small_Image_URL__c: currentKitProduct.Kit_Tool__r.Small_Image_URL__c,
                        SerialNumber: '',
                        Display_Week__c: displayWeek,
                        Display_Year__c: displayYear,
                        Allow_Numbers_Only__c: allowsNumber,
                        Regexpression_Validator__c: regExVal,
                        Serial_Number_Length__c: snLength,
                        HelpText__c: helpText,
                        Helper_Image_URL__c: helperImage,
                        EnforceLength__c: enforceLength
                    });
                }
            }

            navEvent.setParams({ "individualAssetList": assetList });
        } else {
            navEvent.setParams({ "individualAssetList": [asset] });
        }

        var locationList = component.get('v.locationList');
        navEvent.setParams({ "locationList": locationList });
        navEvent.fire();

    },

    clearSelected: function(component) {
        component.set("v.selectedProduct", undefined);
        component.set("v.buttonDisabled", true);
        $("#productSearch").val('');
        $("#selectedText").html('');
        $(".basket").hide();
    }

})