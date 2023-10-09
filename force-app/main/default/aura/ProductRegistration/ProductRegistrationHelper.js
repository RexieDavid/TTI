({
    //MAX_FILESIZE: 4 500 000, /* 6 000 000 * 3/4 to account for base64 */
    MAX_FILESIZE: 10500000, /* 6 000 000 * 3/4 to account for base64 */
    CHUNK_SIZE: 450000, /* Use a multiple of 4 */

    validateForm: function (component) {
        var today = new Date();
        var dd = today.getDate();
        var mm = today.getMonth() + 1;
        var yyyy = today.getFullYear();

        if (dd < 10) {
            dd = '0' + dd;
        }

        if (mm < 10) {
            mm = '0' + mm;
        }
        today = yyyy + '-' + mm + '-' + dd;

        var individualAssetList = component.get("v.individualAssetList");
        var assetRec = component.get("v.asset");
        var sWeek = component.get("v.serialWeek");
        var sYear = component.get("v.serialYear");
        var hasWeek = assetRec.Display_Week__c;
        var hasYear = assetRec.Display_Year__c;
        var serialNumber = component.get("v.serialNoP");
        var serialNumberLen = assetRec.Serial_Number_Length__c;
        var hasFile = component.get("v.hasFile");
        var isOthers = (component.get("v.locationP") == "Others");
        var isBunningsReceipt = (component.get("v.isBunningReceipt") == "Yes");
        var serialRegEx = assetRec.Regexpression_Validator__c;
        var errmessage = '';
        var enforceSerialLength = assetRec.EnforceLength__c;
        var fileInput = component.find("file").getElement();
        var file = fileInput.files[0];
        let serialNumberOptional = component.get("v.assetIsSerialNumberOptional");

        if (individualAssetList.length > 1) {
            var purchaseddate = component.get("v.purchaseDateK");
            var purchaseLocation = component.get("v.locationK");
            var purchaseLocOther = component.get("v.locationHolderK");
        } else {
            var purchaseddate = component.get("v.purchaseDateP");
            var purchaseLocation = component.get("v.locationP");
            var purchaseLocOther = component.get("v.locationHolderP");
        }

        if (purchaseddate == '') {
            errmessage = "Please enter purchase date.";
        } else if (purchaseddate > today) {
            errmessage = "Please make sure that Date of purchase is not a future date.";
        } else if (purchaseLocation == '') {
            errmessage = "Please enter purchase location.";
        } else if (purchaseLocation != 'Bunnings' && purchaseLocOther == '') {
            errmessage = "Please specify other purchase location.";
        } 
        /* RDAVID 12/16/2022 INC0030635 - Remove code block
        else if (!hasFile) {
            if (!isOthers && isBunningsReceipt) {
                errmessage = "Please enter a receipt.";
            }
        }*/ 
        else if (file && file.size > this.MAX_FILESIZE) {
            errmessage = "File size cannot exceed " + this.MAX_FILESIZE + " bytes. Selected file size: " + file.size;
        } else {
            if (individualAssetList.length == 1) {
                if (!serialNumber && !serialNumberOptional) {
                    errmessage = "Serial number is required.";
                } else if (serialRegEx && serialNumber) {
                    var patt = new RegExp(serialRegEx);
                    if (!patt.test(serialNumber)) {
                        errmessage = "Invalid serial number.";
                    }
                } else if (serialNumber && serialNumber.length != serialNumberLen && enforceSerialLength) {
                    errmessage = "Invalid serial number length, please enter length of " + serialNumberLen + " digits";
                } else if (hasWeek && !sWeek && !serialNumberOptional) {
                    errmessage = "Serial week is required.";
                } else if (hasWeek && sWeek.length != 2) {
                    errmessage = "Invalid serial week number, please enter two digits.";
                } else if (hasYear && !sYear && !serialNumberOptional) {
                    errmessage = "Serial year is required.";
                } else if (hasYear && sYear.length != 4) {
                    errmessage = "Invalid serial year, please enter four digits.";
                }
            } else if (individualAssetList.length > 1) {
                for (let i = 0; i < individualAssetList.length; i++) {
                    if (!individualAssetList[i].SerialNumber && !individualAssetList[i].Is_Serial_Number_Optional__c) {
                        errmessage = "Serial number is required for product " + individualAssetList[i].Name + '.';
                        break;
                    } else if (individualAssetList[i].Regexpression_Validator__c && individualAssetList[i].SerialNumber) {
                        var patt = new RegExp(individualAssetList[i].Regexpression_Validator__c);
                        if (!patt.test(individualAssetList[i].SerialNumber)) {
                            errmessage = "Invalid serial number " + individualAssetList[i].Name + '.'
                        }
                    } else if (individualAssetList[i].SerialNumber && individualAssetList[i].SerialNumber.length != individualAssetList[i].Serial_Number_Length__c && individualAssetList[i].EnforceLength__c) {
                        errmessage = "Invalid serial number length. Please enter length of " + individualAssetList[i].Serial_Number_Length__c + " digits for product " + individualAssetList[i].Name + '.';
                    } else if (individualAssetList[i].Display_Week__c && !individualAssetList[i].SerialNumberWeek__c && !individualAssetList[i].Is_Serial_Number_Optional__c) {
                        errmessage = "Serial week is required for product " + individualAssetList[i].Name + '.';
                    } else if (individualAssetList[i].Display_Week__c && individualAssetList[i].SerialNumberWeek__c.length != 2) {
                        errmessage = "Invalid serial week number. Please enter two digits for product " + individualAssetList[i].Name + '.';
                    } else if (individualAssetList[i].Display_Year__c && !individualAssetList[i].SerialNumberYear__c && !individualAssetList[i].Is_Serial_Number_Optional__c) {
                        errmessage = "Serial year is required for product " + individualAssetList[i].Name + '.';
                    } else if (individualAssetList[i].Display_Year__c && individualAssetList[i].SerialNumberYear__c.length != 4) {
                        errmessage = "Invalid serial year. Please enter four digits for product " + individualAssetList[i].Name + '.';
                    }
                }
            }
        }

        if (errmessage != '') {
            this.showErrorMessage(component, errmessage);
            return false;
        } else {
            this.hideErrorMessage(component);
            return true;
        }
    },

    saveRegistration: function (component) {
        this.showProgress(component, "Saving product registration...", 10);

        var individualAssetList = component.get("v.individualAssetList");
        var isBunningReceipt = component.get("v.isBunningReceipt");
        var assetRec = component.get("v.asset");
        var purchasedFrom = "";
        var purchasedFromOther = "";
        var purchasedDate;
        var serialNumber = "";

        if (individualAssetList.length > 1) {
            purchasedDate = component.get("v.purchaseDateK");
            purchasedFrom = component.get("v.locationK");
            if (component.get("v.locationK") != "Bunnings")
                purchasedFromOther = component.get("v.locationHolderK");

            for (let i = 0; i < individualAssetList.length; i++) {
                individualAssetList[i].PurchaseDate = purchasedDate;
                individualAssetList[i].AssetSource__c = purchasedFrom;
                individualAssetList[i].Asset_Source_Other__c = purchasedFromOther;
            }

        } else {
            purchasedDate = component.get("v.purchaseDateP");
            purchasedFrom = component.get("v.locationP");
            serialNumber = component.get("v.serialNoP");

            if (component.get("v.locationP") != "Bunnings") {
                purchasedFromOther = component.get("v.locationHolderP");
            }

            individualAssetList[0].PurchaseDate = purchasedDate
            individualAssetList[0].AssetSource__c = purchasedFrom;
            individualAssetList[0].Asset_Source_Other__c = purchasedFromOther;
            individualAssetList[0].SerialNumber = component.get("v.serialNoP");
            individualAssetList[0].SerialNumberWeek__c = component.get("v.serialWeek");
            individualAssetList[0].SerialNumberYear__c = component.get("v.serialYear");
            individualAssetList[0].Display_Week__c = assetRec.Display_Week__c;
            individualAssetList[0].Display_Year__c = assetRec.Display_Year__c;
            individualAssetList[0].Allow_Numbers_Only__c = assetRec.Allow_Numbers_Only__c;
            individualAssetList[0].Helper_Image_URL__c = assetRec.Helper_Image_URL__c;
            individualAssetList[0].HelpText__c = assetRec.HelpText__c;
            individualAssetList[0].Regexpression_Validator__c = assetRec.Regexpression_Validator__c;
            individualAssetList[0].Serial_Number_Length__c = assetRec.Serial_Number_Length__c;
            individualAssetList[0].EnforceLength__c = assetRec.EnforceLength__c;
        }

        var fileInput = component.find("file").getElement();

        if(fileInput.files[0] == null || fileInput.files[0] == ""){
            fileInput = component.find("kitFile").getElement();
        }

        var file = fileInput.files[0];
        var filename = (file == null ? '' : file.name);

        this.executeSave(component, individualAssetList, isBunningReceipt, filename);
    },

    executeSave: function (component, individualAssetList, isBunningReceipt, filename) {
        var assetList = [];

        for (var i = 0; i < individualAssetList.length; i++) {
            var asset = individualAssetList[i];

            assetList.push({
                sobjectType: "Asset",
                Name: asset.Name,
                Product2Id: asset.Product2Id,
                KitProduct__c: asset.KitProduct__c,
                Status: 'Confirmed',
                Quantity: 1.00,
                Purchased_From__c: asset.Purchased_From__c,
                SerialNumber: asset.SerialNumber,
                PurchaseDate: asset.PurchaseDate,
                AssetSource__c: asset.AssetSource__c,
                Asset_Source_Other__c: asset.Asset_Source_Other__c,
                SerialNumberWeek__c: asset.SerialNumberWeek__c,
                SerialNumberYear__c: asset.SerialNumberYear__c,
                Display_Week__c: asset.Display_Week__c,
                Display_Year__c: asset.Display_Year__c,
                Allow_Numbers_Only__c: asset.Allow_Numbers_Only__c,
                Helper_Image_URL__c: asset.Helper_Image_URL__c,
                HelpText__c: asset.HelpText__c,
                Regexpression_Validator__c: asset.Regexpression_Validator__c,
                Serial_Number_Length__c: asset.Serial_Number_Length__c,
                EnforceLength__c: asset.EnforceLength__c,
                Is_Serial_Number_Optional__c: asset.Is_Serial_Number_Optional__c
            });
        }

        var action = component.get("c.saveProductRegistration");
        action.setParams({
            assets: assetList,
            isBunningReceipt: isBunningReceipt,
            filename: filename,
            productCode: component.get('v.assetProductCode'),
            isCustomMedata: false
        });

        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state != 'SUCCESS') {
                this.displayServerError(response);
                return;
            } else {
                var result = response.getReturnValue();

                result.assets.forEach(asset => {
                    if (!!asset.SerialNumberWeek__c && !!asset.SerialNumberYear__c) {
                        asset.SerialNumber = `${asset.SerialNumber}W${asset.SerialNumberWeek__c}Y${asset.SerialNumberYear__c}`;
                    }
                });

                component.find('ga').push(result.assets, component.get('v.userCountry'));

                if (this.responseHasErrors(response) || result.error) {
                    this.displayServerErrorMessage(component, response);
                    return;
                }

                var individualAssetList = component.get("v.individualAssetList");

                if (individualAssetList.length > 1) {
                    component.set("v.warrantyResult", "Warranty for each product within the kit varies, please check your toolbag for details of warranty received.");
                } else {
                    if (result.standardWarranty > 0 && result.extendedWarranty > 0) {
                        component.set("v.warrantyResult", "You have qualified for a standard warranty of " + result.standardWarranty / 12 + " years and an extended warranty of " + result.extendedWarranty / 12 + " years.");
                    } else if (result.standardWarranty > 0) {
                        component.set("v.warrantyResult", "You have qualified for a standard warranty of " + result.standardWarranty / 12 + " years.");
                    } else {
                        component.set("v.warrantyResult", "Unfortunately, this product does not qualify for a warranty with the information provided.");
                    }
                }
                this.saveFile(component, result.receiptID);
            }
        });

        $A.enqueueAction(action);
    },

    saveFile: function (component, receiptid) {
        this.showProgress(component, "Uploading receipt....", 15);

        var fileInput = component.find("file").getElement();

        if(fileInput.files[0] == null || fileInput.files[0] == ""){
            fileInput = component.find("kitFile").getElement();
        }
        var file = fileInput.files[0];

        if (file != null) {
            if (file.size > this.MAX_FILESIZE) {
                alert('File size cannot exceed ' + this.MAX_FILESIZE + ' bytes.\n' + 'Selected file size: ' + file.size);
                return;
            }

            var fr = new FileReader();
            var self = this;

            fr.onload = function () {
                var fileContents = fr.result;
                var base64Mark = 'base64, ';
                var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;

                fileContents = fileContents.substring(dataStart);
                self.upload(component, file, fileContents, receiptid);
            };

            fr.readAsDataURL(file);
        } else {
            this.hideProgress(component);
            this.showCompeleteMessage(component);
        }
    },

    upload: function (component, file, fileContents, receiptid) {
        var fromPos = 0;
        var toPos = Math.min(fileContents.length, fromPos + this.CHUNK_SIZE);
        this.uploadChunk(component, file, fileContents, fromPos, toPos, '', receiptid);
    },

    uploadChunk: function (component, file, fileContents, fromPos, toPos, attachId, receiptid) {
        var action = component.get("c.saveFileChunk");
        var chunk = fileContents.substring(fromPos, toPos);

        action.setParams({
            parentId: receiptid, //component.get("v.parentId"), 
            fileName: file.name,
            base64Data: encodeURIComponent(chunk),
            contentType: file.type,
            fileId: attachId
        });


        action.setCallback(this, function (response) {
            attachId = response.getReturnValue();
            fromPos = toPos;
            toPos = Math.min(fileContents.length, fromPos + this.CHUNK_SIZE);

            let perComplete = ((fromPos + this.CHUNK_SIZE) / fileContents.length) * 100;
            this.showProgress(component, "Uploading receipt...", perComplete);

            if (fromPos < toPos) {
                this.uploadChunk(component, file, fileContents, fromPos, toPos, attachId, receiptid);
            } else {
                this.hideProgress(component);
                this.showCompeleteMessage(component);
            }

        });

        /**
         * FileReader onload is an asynchronous process
         * and put this method outside Aura's normal rendering cycle.
         * Quick fix is to enclose it to a callback to run the method.
         */
        $A.getCallback(function() {
            $A.enqueueAction(action);
       })();
    },

    showProgress: function (component, message, progress) {
        component.set("v.statusMessage", message);
        $("#uploadingnew").show();
        $("#progressbar").removeClass("progress1 progress2 progress3 progress4 progress5 progress6 progress7 progress8 progress9 progress10");
        if (progress < 10) {
            $("#progressbar").addClass("progress1");
        } else if (progress < 20) {
            $("#progressbar").addClass("progress2");
        } else if (progress < 30) {
            $("#progressbar").addClass("progress3");
        } else if (progress < 40) {
            $("#progressbar").addClass("progress4");
        } else if (progress < 50) {
            $("#progressbar").addClass("progress5");
        } else if (progress < 60) {
            $("#progressbar").addClass("progress6");
        } else if (progress < 70) {
            $("#progressbar").addClass("progress7");
        } else if (progress < 80) {
            $("#progressbar").addClass("progress8");
        } else if (progress < 90) {
            $("#progressbar").addClass("progress9");
        } else {
            $("#progressbar").addClass("progress10");
        }
    },

    hideProgress: function (component) {
        component.set("v.statusMessage", "");
        $("#uploadingnew").hide();
    },

    showCompeleteMessage: function () {
        $("#promptDiv").show();
    },

    showErrorMessage: function (component, errmessage) {
        component.set("v.errorMessage", errmessage);
        component.set("v.showError", true);
        // component.find("confirmBtn").set("v.disabled", false);
    },

    hideErrorMessage: function (component) {
        component.set("v.errorMessage", "");
        component.set("v.showError", false);
    },

    displayServerErrorMessage: function (component, response) {
        this.hideProgress(component);
        this.showErrorMessage(component, "Oops...something went wrong. Please try again, if error continues contact our customer support.")

        var errors = response.getError();
        if (errors) {
            if (errors[0] && errors[0].message) {
                //
            }
        }
    },

    responseHasErrors: function (response) {
        var errors = response.getError();
        if (errors) {
            if (errors[0] && errors[0].message) {
                return true;
            }
        }
        return false;
    },

    updateLocationList: function (component) {
        var locationList = ['Bunnings', 'Others'];
        component.set("v.locationList", locationList);
        component.set("v.locationP", locationList[0]);
        component.set("v.locationK", locationList[0]);
    },

    initializeCustomSettings: function (component) {
        var action = component.get("c.getSiteSettings");
        action.setCallback(this, function (response) {
            var customSettingValues = response.getReturnValue();

            component.set("v.siteSettings", customSettingValues.communitySettings);
            component.set("v.userCountry", customSettingValues.userCountry);

            if (customSettingValues.userCountry == 'Australia') {
                component.set("v.warrantyURL", customSettingValues.communitySettings.Warranty_URL__c);
            } else {
                component.set("v.warrantyURL", customSettingValues.communitySettings.Warranty_URL_NZ__c);
            }
        });
        $A.enqueueAction(action);
    },

    fileUploaded: function (component) {
        var fileInput = component.find("file").getElement();
        var file = fileInput.files[0];

        if (file.size > this.MAX_FILE_SIZE) {
            alert('File size cannot exceed ' + this.MAX_FILE_SIZE + ' bytes.\n' + 'Selected file size: ' + file.size);
            return;
        }
        var fr = new FileReader();

        fr.onload = function () {
            $('#receiptView').attr('src', fr.result);
            $('#receiptView').attr('hidden', false);
            component.set("v.hasFile", true)
        };
        fr.readAsDataURL(file);
    },

    kitFileUploaded: function (component) {
        var fileInput = component.find("kitFile").getElement();
        var file = fileInput.files[0];

        if (file.size > this.MAX_FILE_SIZE) {
            alert('File size cannot exceed ' + this.MAX_FILE_SIZE + ' bytes.\n' + 'Selected file size: ' + file.size);
            return;
        }
        var fr = new FileReader();

        fr.onload = function () {
            $('#kitReceiptView').attr('src', fr.result);
            $('#kitReceiptView').attr('hidden', false);
            component.set("v.hasFile", true)
        };
        fr.readAsDataURL(file);
    },

    setSerialHelperPromptValues: function (component, selectedProduct) {
        var individualAssetList = component.get("v.individualAssetList");
        for (let i = 0; i < individualAssetList.length; i++) {
            if (selectedProduct == individualAssetList[i].ProductCode) {
                component.set('v.serialHelperText', individualAssetList[i].HelpText__c);
                component.set('v.serialHelperImageURL', individualAssetList[i].Helper_Image_URL__c);
            }
        }
    },

    navigateTo: function(page) {
        const urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": page,
            "isredirect": false
        });
        urlEvent.fire();
    }
})