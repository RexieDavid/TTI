({
    serialnumberblank: function (component) {
        var claim = component.get("v.claim");
        var serialnumber = component.find("serialnumber");
        var serialnumberText = component.find("serialnumberText");
        if (claim.Serial_Number_not_found__c) {
            this.handleSerialNumberError(component, null);
            return true;
        }

        if (serialnumber != undefined && serialnumber != null) {
            var inputBox = serialnumber.find("lookup");
        }
        var serialNum = claim.Serial_Number__c;
        var errEnterSerialNumber = component.get("v.errEnterSerialNumber");
        if (($A.util.isUndefinedOrNull(serialNum) || $A.util.isEmpty(serialNum)) &&
            (claim.Serial_Number_not_found__c == '' || claim.Serial_Number_not_found__c == false)) {
            this.handleSerialNumberError(component, errEnterSerialNumber);
            return false;

        } else {
            if (component.get("v.claim.Product_Name__c.SerialNumberDisplayType__c") != null) {
                var isValid = true;
                if (component.get("v.claim.Product_Name__c.SerialNumberDisplayType__r.Display_Week__c")) {
                    isValid = this.serialNumberWeekValidation(component) && isValid;
                }
                if (component.get("v.claim.Product_Name__c.SerialNumberDisplayType__r.Display_Year__c")) {
                    isValid = this.serialNumberYearValidation(component) && isValid;
                }
                var rexpAlphanumeric = /^[0-9a-zA-Z_-]+$/;
                if ((component.get("v.claim.Product_Name__c.SerialNumberDisplayType__r.EnforceLength__c") &&
                    serialNum.length != component.get("v.claim.Product_Name__c.SerialNumberDisplayType__r.Serial_Number_Length__c")) ||
                    (component.get("v.claim.Product_Name__c.SerialNumberDisplayType__r.EnforceLength__c") == false &&
                        serialNum.length > component.get("v.claim.Product_Name__c.SerialNumberDisplayType__r.Serial_Number_Length__c"))) {
                    this.handleSerialNumberError(component, "Please enter the " + component.get("v.claim.Product_Name__c.SerialNumberDisplayType__r.Serial_Number_Length__c") + " digit serial number");
                    isValid = false;
                } else if (component.get("v.claim.Product_Name__c.SerialNumberDisplayType__r.Allow_Numbers_Only__c") &&
                    !rexpAlphanumeric.test(serialNum)) {
                    this.handleSerialNumberError(component, "Serial Number must only contain numbers");
                    isValid = false;
                } else {
                    this.handleSerialNumberError(component, null);

                }
                return isValid;
            } else {
                this.handleSerialNumberError(component, null);
                return true;

            }
        }

    },
    handleSerialNumberError: function (component, erromessage) {
        var serialnumber = component.find("serialnumber");
        var serialnumberText = component.find("serialnumberText");
        if (serialnumber != undefined || serialnumber != null) {
            var inputBox = serialnumber.find("lookup");
            inputBox.set("v.errors", [{ message: erromessage }]);
        } else {
            serialnumberText.set("v.errors", [{ message: erromessage }]);
        }
    },
    receiptvalidation: function (component) {
        var claim = component.get("v.claim");
        var receiptnumber = component.find("receiptnumber");
        var errMandatoryField = component.get("v.errMandatoryField");
        if ($A.util.isEmpty(claim.Receipt_No__c)) {
            receiptnumber.set("v.errors", [{ message: errMandatoryField }]);
            return false;
        } else {
            receiptnumber.set("v.errors", [{ message: "" }]);
            return true;
        }
    },
    checkProduct: function (component, claim, nextStep) {
        try {
            var action = component.get("c.productCheck");
            var errInvalidProduct = component.get("v.errInvalidProduct");

            action.setParams({
                "productId": claim.Product_Name__c.Id
            });

            action.setCallback(this, function (response) {
                var productState = response.getState();
                var productValue = response.getReturnValue();
                var product = component.find("product");
                var inputBox = product.find("lookup");
                inputBox.set("v.errors", null);
                if (productState === "SUCCESS" && (productValue != undefined || productValue != null)) {
                    nextStep.run();
                } else {
                    inputBox.set("v.errors", [{ message: errInvalidProduct }]);
                }
            });
            $A.enqueueAction(action);
        } catch (err) {

        }

    },
    checkAsset: function (component, claim, nextStep) {
        var serialnumber = null;
        if (!$A.util.isUndefinedOrNull(claim)) {
            serialnumber = claim.Serial_Number__c;
        }
        var action = component.get("c.assetCheck");
        action.setParams({
            "serialnumber": serialnumber,
            "productId": claim.Product_Name__c.Id,
            "contactId": claim.TTI_Customer_Contact__c.Id
        });

        var self = this;

        action.setCallback(this, function (response) {
            var assetState = response.getState();
            var assetValue = response.getReturnValue();

            if (assetState === "SUCCESS" && (assetValue != undefined && assetValue != null)) {
                if (assetValue.SerialNumber == null || assetValue.SerialNumber == '') {
                    assetValue.SerialNumber = serialnumber;
                    if (component.get("v.claim.Product_Name__c.SerialNumberDisplayType__c") != null) {
                        if (component.get("v.claim.Product_Name__c.SerialNumberDisplayType__r.Display_Week__c")) {
                            assetValue.SerialNumberWeek__c = component.get("v.SerialNumberWeek");
                        }
                        if (component.get("v.claim.Product_Name__c.SerialNumberDisplayType__r.Display_Year__c")) {
                            assetValue.SerialNumberYear__c = component.get("v.SerialNumberYear");
                        }
                    }
                }
                assetValue.PurchaseDate = claim.Purchase_Date__c;
                assetValue.Receipt_No__c = claim.Receipt_No__c;
                component.set("v.selectedAssetObj", assetValue);
            }
            self.checkProduct(component, claim, nextStep);
        });
        $A.enqueueAction(action);
    },

    clearSerialnumber: function (component) {
        component.set("v.claim.Serial_Number__c", '');
        component.set("v.selectedAssetObj", null);
        component.set("v.serialNumberLocated", false);
        component.set("v.SerialNumberWeek", null);
        component.set("v.SerialNumberYear", null);

        var claim = component.get("v.claim");
        var serialnumber = component.find("serialnumber");
        var serialnumberText = component.find("serialnumberText");
        if (serialnumber != undefined && serialnumber != null) {
            var inputBox = serialnumber.find("lookup");
        }
        if (claim.Serial_Number_not_found__c === true) {
            if (serialnumber != undefined && serialnumber != null) {
                inputBox.set("v.disabled", true);
            } else {
                serialnumberText.set("v.disabled", true);
            }
        } else {
            if (serialnumber != undefined && serialnumber != null) {
                inputBox.set("v.disabled", false);
            } else {
                serialnumberText.set("v.disabled", false);
            }
        }
    },

    dateinpastvalidation: function (component) {
        var claim = component.get("v.claim");
        var purchasedate = new Date(claim.Purchase_Date__c);
        var purchasedateinput = component.find("purchasedate");
        var errMandatoryField = component.get("v.errMandatoryField");
        var errPurchaseDateMustInThePast = component.get("v.errPurchaseDateMustInThePast");
        var errInvalidDate = component.get("v.errInvalidDate");

        var dateformat = /^\d{4}\-\d{1,2}\-\d{1,2}$/;
        var now = new Date();
        if ($A.util.isUndefinedOrNull(claim.Purchase_Date__c) || $A.util.isEmpty(claim.Purchase_Date__c)) {
            purchasedateinput.set("v.errors", [{ message: errMandatoryField }]);
            return false;
        } else if (!claim.Purchase_Date__c.match(dateformat)) {
            purchasedateinput.set("v.errors", [{ message: errInvalidDate }]);
            return false;
        } else {
            let purchasedateTxt = $A.localizationService.formatDate(purchasedate, "YYYY-MM-DD");
            let nowTxt = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");

            if (purchasedateTxt >= nowTxt) {
                purchasedateinput.set("v.errors", [{ message: errPurchaseDateMustInThePast }]);
                return false;
            } else {
                purchasedateinput.set("v.errors", [{ message: "" }]);
                return true;
            }
        }
    },

    brandvalidation: function (component) {
        var claim = component.get("v.claim");
        var brand = component.find("brand");
        var errMandatoryField = component.get("v.errMandatoryField");
        if ($A.util.isEmpty(claim.Brand__c) || claim.Brand__c === 'None') {
            brand.set("v.errors", [{ message: errMandatoryField }]);
            return false;
        } else {
            brand.set("v.errors", null);
            return true;
        }
    },

    productvalidation: function (component) {
        var claim = component.get("v.claim");
        var product = component.find("product");
        var inputBox = product.find("lookup");
        var inputSerialNo = inputBox.get("v.value");
        var errMandatoryField = component.get("v.errMandatoryField");
        if ($A.util.isEmpty(inputSerialNo)) {
            inputBox.set("v.errors", [{ message: errMandatoryField }]);
            return false;
        } else {
            inputBox.set("v.errors", [{ message: null }]);
            return true;
        }
    },

    faultvalidation: function (component) {
        var claim = component.get("v.claim");
        var fault = component.find("fault");
        var errMandatoryField = component.get("v.errMandatoryField");
        if ($A.util.isEmpty(claim.Fault_Description__c)) {
            fault.set("v.errors", [{ message: errMandatoryField }]);
            return false;
        } else {
            fault.set("v.errors", null);
            return true;
        }
    },
    serialNumberWeekValidation: function (component) {
        var SN_Week = component.get("v.SerialNumberWeek");
        var SN_Week_Id = component.find("SN_Week_Id");
        var errEnterSerialNumberWeek = component.get("v.errEnterSerialNumberWeek");
        var errInvalidSerialNumberWeek = component.get("v.errInvalidSerialNumberWeek");
        if ($A.util.isEmpty(SN_Week) || $A.util.isUndefinedOrNull(SN_Week)) {
            SN_Week_Id.set("v.errors", [{ message: errEnterSerialNumberWeek }]);
            return false;
        } else if (SN_Week < 1 || SN_Week > 52) {
            SN_Week_Id.set("v.errors", [{ message: errInvalidSerialNumberWeek }]);
            return false;
        } else {
            SN_Week_Id.set("v.errors", null);
            return true;
        }
    },
    serialNumberYearValidation: function (component) {
        var SN_Year = component.get("v.SerialNumberYear");
        var SN_Year_Id = component.find("SN_Year_Id");
        var errEnterSerialNumberYear = component.get("v.errEnterSerialNumberYear");
        var errInvalidSerialNumberYear = component.get("v.errInvalidSerialNumberYear");
        var date = new Date();
        if ($A.util.isEmpty(SN_Year) || $A.util.isUndefinedOrNull(SN_Year)) {
            SN_Year_Id.set("v.errors", [{ message: errEnterSerialNumberYear }]);
            return false;
        } else if (SN_Year > date.getFullYear()) {
            SN_Year_Id.set("v.errors", [{ message: errInvalidSerialNumberYear }]);
            return false;
        } else {
            SN_Year_Id.set("v.errors", null);
            return true;
        }
    },
    refreshCodeCondition: function (component) {
        var claim = component.get("v.claim");
        let userType = component.get("v.userType");
        if (userType === 'SA') {
            component.set('v.isServiceAgent', true);
        }

        if (claim.Serial_Number_not_found__c) {
            component.set('v.numberNotFound', true)
        } else {
            component.set('v.numberNotFound', false);
        }

        if (claim.Product_Name__c.SerialNumberDisplayType__r && claim.Product_Name__c) {
            component.set('v.hasSerialNumber', true)
            if (claim.Product_Name__c.SerialNumberDisplayType__r.Display_Week__c) {
                component.set('v.hasDisplayWeek', true)
            }

            if (claim.Product_Name__c.SerialNumberDisplayType__r.Display_Year__c) {
                component.set('v.hasDisplayYear', true)
            }
        } else {
            component.set('v.hasSerialNumber', false);
            component.set('v.hasDisplayYear', false);
            component.set('v.hasDisplayWeek', false);
        }
    }

})