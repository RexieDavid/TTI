({
    doInit: function (component, event, helper) {
        let getUser = component.get('c.getUserType');
        getUser.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS') {
                let productQuery = `Kit__c = FALSE 
                                    AND Spare_Part__c = FALSE 
                                    AND RecordType.Name != 'Spare Part' 
                                    AND IsActive = true 
                                    AND ProductCode LIKE :searchString 
                                    AND Brand_Name_Formula__c = dynamicValueObject`;
                let user = response.getReturnValue();

                if (!user.Account.MX_Authorised__c) {
                    productQuery += `AND (NOT SAP_Material_Group__c LIKE '%MQ%')`;
                }
                component.set('v.productQuery', productQuery);
            }
        });
        $A.enqueueAction(getUser);

        let productFieldsToQuery = `SerialNumberDisplayType__r.EnforceLength__c,
                                    SerialNumberDisplayType__r.Display_Week__c, 
                                    SerialNumberDisplayType__r.Display_Year__c, 
                                    SerialNumberDisplayType__r.Serial_Number_Length__c, 
                                    SerialNumberDisplayType__r.Allow_Numbers_Only__c, 
                                    SerialNumberDisplayType__r.HelpText__c,
                                    SerialNumberDisplayType__r.HelperImageURL__c, 
                                    SerialNumberDisplayType__r.Regexpression_Validator__c`;

        let serialNumberQuery = `FullSerialNumber__c LIKE :searchString 
                                    AND ContactId=dynamicValueObject 
                                    AND Product2Id = dynamicValueObject2`;

        component.set('v.serialNumberQuery', serialNumberQuery);
        component.set('v.productFieldsToQuery', productFieldsToQuery);
    },

    getCustomerInformation: function (component, event, helper) {
        var customerInformation = event.getParam("customerInformation");
        if (!$A.util.isUndefinedOrNull(customerInformation)) {
            component.set("v.claim.Brand__c", customerInformation.contactObj.Brand__c);
        } else {
            component.set("v.claim.Brand__c", '');
        }

        var isSearch = event.getParam("isSearch");
        component.set("v.newcustomer", isSearch);
    },

    searchValueChanged: function (component, event, helper) {
        if (event.getParam("selectedObjectApiName") == 'Product2') {
            var predictiveSearchBox = component.find("serialnumber");
            component.set("v.claim.Serial_Number__c", null);
            component.set("v.selectedAssetObj", null);
            if (predictiveSearchBox != undefined) {
                predictiveSearchBox.set("v.disabledFlag", true);
                component.set("v.serialNumberLocated", false);
                component.set("v.claim.Purchase_Date__c", null);
                component.set("v.claim.Receipt_No__c", null);

            }
            event.stopPropagation();
        }
        if (event.getParam("selectedObjectApiName") == 'Asset') {
            component.set("v.serialNumberLocated", false);
            component.set("v.claim.Purchase_Date__c", null);
            component.set("v.claim.Receipt_No__c", null);
            event.stopPropagation();
        }
    },

    getSobject: function (component, event, helper) {
        var selectedObj = event.getParam("sObject");
        var selectedObjectApiName = event.getParam("selectedObjectApiName");
        if (selectedObjectApiName == 'Product2') {
            var predictiveSearchBox = component.find("serialnumber");
            if (predictiveSearchBox != undefined) {
                predictiveSearchBox.set("v.disabledFlag", false);
            }
            component.set("v.claim.Product_Name__c", selectedObj);
            var product = component.find("product");
            var inputBox = product.find("lookup");
            inputBox.set("v.errors", [{ message: "" }]);
        }
        if (selectedObjectApiName == 'Asset') {
            component.set("v.claim.Serial_Number__c", selectedObj.SerialNumber);
            component.set("v.claim.Purchase_Date__c", selectedObj.PurchaseDate);
            component.set("v.claim.Receipt_No__c", selectedObj.Receipt_No__c);
            component.set("v.selectedAssetObj", selectedObj);
            component.set("v.SerialNumberWeek", selectedObj.SerialNumberWeek__c);
            component.set("v.SerialNumberYear", selectedObj.SerialNumberYear__c);
            var serialnumber = component.find("serialnumber");
            var serialnumberText = component.find("serialnumberText");
            if (serialnumber != undefined && serialnumber != null) {
                var inputBox = serialnumber.find("lookup");
                inputBox.set("v.errors", [{ message: "" }]);
            } else {
                serialnumberText.set("v.errors", [{ message: "" }]);
            }
            component.set("v.serialNumberLocated", true);

        }
        event.stopPropagation();
        helper.refreshCodeCondition(component);
    },

    blurreceipt: function (component, event, helper) {
        helper.receiptvalidation(component);
    },
    blurserialnumber: function (component, event, helper) {
        helper.serialnumberblank(component);
    },
    blurnoserialnumber: function (component, event, helper) {
        helper.clearSerialnumber(component);
        var productFieldValue = component.find("product").get("v.SelectedItemName").trim();

        if (event.getSource().get('v.value') && (productFieldValue != "" || productFieldValue.length > 0)) {
            component.set("v.isNextButtonDisabled", false);
            document.getElementById("nextButton").style.visibility = "visible";
        } else {
            component.set("v.isNextButtonDisabled", true);
            document.getElementById("nextButton").style.visibility = "hidden";
        }
    },
    datechange: function (component, event, helper) {
        helper.dateinpastvalidation(component);
    },
    changebrand: function (component, event, helper) {
        helper.brandvalidation(component);
    },
    blurProduct: function (component, event, helper) {
        helper.productvalidation(component);
    },
    blurfault: function (component, event, helper) {
        helper.faultvalidation(component);
    },
    blurSerialNumberWeek: function (component, event, helper) {
        helper.serialNumberWeekValidation(component);
    },
    blurSerialNumberYear: function (component, event, helper) {
        helper.serialNumberYearValidation(component);
    },
    next: function (component, event, helper) {
        var claim = component.get("v.claim");
        var SelectedItemName = component.get("v.selectedAssetObj");
        var product = component.find("product");
        var inputBox = product.find("lookup");
        inputBox.set("v.errors", null);
        var nextStep = {};

        nextStep.run = function () {
            var correctserialnumber = helper.serialnumberblank(component);
            var correctpurchasedate = helper.dateinpastvalidation(component);
            var correctbrand = helper.brandvalidation(component);
            var correctproduct = helper.productvalidation(component);
            var correctreceipt = helper.receiptvalidation(component);
            var correctfault = helper.faultvalidation(component);

            if (correctserialnumber && correctpurchasedate &&
                correctbrand && correctproduct && correctreceipt && correctfault) {
                var userType = component.get("v.userType");

                if (userType == 'SAAD') {
                    component.set("v.activeScreenId", "6");
                } else if (userType == 'SA') {
                    component.set("v.activeScreenId", "7");
                } else {
                    component.set("v.activeScreenId", "5");
                }
            }
        }

        if ($A.util.isUndefinedOrNull(SelectedItemName)) {
            helper.checkAsset(component, claim, nextStep);
        } else {
            var assetValue = component.get("v.selectedAssetObj");
            assetValue.Receipt_No__c = component.get("v.claim.Receipt_No__c");
            if (component.get("v.claim.Product_Name__c.SerialNumberDisplayType__c") != null) {
                if (component.get("v.claim.Product_Name__c.SerialNumberDisplayType__r.Display_Week__c")) {
                    assetValue.SerialNumberWeek__c = component.get("v.SerialNumberWeek");
                }
                if (component.get("v.claim.Product_Name__c.SerialNumberDisplayType__r.Display_Year__c")) {
                    assetValue.SerialNumberYear__c = component.get("v.SerialNumberYear");
                }
            }
            component.set("v.selectedAssetObj", assetValue);
            nextStep.run();
        }
    },
    previous: function (component, event, helper) {
        component.set("v.activeScreenId", "3");
    },
    submit: function (component, event, helper) {
        var claim = component.get("v.claim");
        var SelectedItemName = component.get("v.selectedAssetObj");
        var nextStep = {};
        var product = component.find("product");
        var inputBox = product.find("lookup");
        inputBox.set("v.errors", null);

        nextStep.run = function () {
            var correctserialnumber = helper.serialnumberblank(component);
            var correctpurchasedate = helper.dateinpastvalidation(component);
            var correctbrand = helper.brandvalidation(component);
            var correctproduct = helper.productvalidation(component);
            var correctreceipt = helper.receiptvalidation(component);
            var correctfault = helper.faultvalidation(component);

            if (correctserialnumber && correctpurchasedate &&
                correctbrand && correctproduct && correctreceipt && correctfault) {

                var compEvent = component.getEvent("submitClaimEvent");
                compEvent.fire();
            }
        }

        if ($A.util.isUndefinedOrNull(SelectedItemName)) {
            helper.checkAsset(component, claim, nextStep);
        } else {
            if (component.get("v.claim.Product_Name__c.SerialNumberDisplayType__c") != null) {
                var assetValue = component.get("v.selectedAssetObj");
                if (component.get("v.claim.Product_Name__c.SerialNumberDisplayType__r.Display_Week__c")) {
                    assetValue.SerialNumberWeek__c = component.get("v.SerialNumberWeek");
                }
                if (component.get("v.claim.Product_Name__c.SerialNumberDisplayType__r.Display_Year__c")) {
                    assetValue.SerialNumberYear__c = component.get("v.SerialNumberYear");
                }
                component.set("v.selectedAssetObj", assetValue);
            }
            nextStep.run();
        }
    },

    disableNextButton: function (component, event, helper) {
        if (component.get("v.activeScreenId") == component.get("v.myId")) {
            if (component.get("v.userType") != 'SA') {
                var isDisabled = event.getParam("isDisabled");
                component.set("v.isNextButtonDisabled", isDisabled);
                var isNextButtonDisabled = component.get("v.isNextButtonDisabled");
                var removeHide = component.find('nextBtn');

                if (!isNextButtonDisabled) {
                    $A.util.removeClass(removeHide, 'slds-hide');
                    document.getElementById("nextButton").style.visibility = "visible";
                } else {
                    document.getElementById("nextButton").style.visibility = "hidden";
                }
            }
        }
    }
})