({

    MAX_FILESIZE: 10500000,
    CHUNK_SIZE: 450000,
    
    validateForm: function(component) {
        
           var individualAssetList = component.get("v.individualAssetList");
        
        var today = new Date();
        var dd = today.getDate();
        var mm = today.getMonth() + 1;
        var yyyy = today.getFullYear();
        if (dd < 10) {
            dd = '0'+ dd
        } 
        
        if (mm < 10) {
            mm = '0'+ mm
        } 
        today = yyyy + '-' + mm + '-' + dd;
        
        var assetRec = component.get("v.asset");
        
        var sWeek = component.get("v.serialWeek");
        var sYear = component.get("v.serialYear");
        var hasWeek = assetRec.Display_Week__c;
        var hasYear = assetRec.Display_Year__c;
        var serialNumber = component.get("v.serialNoP");
        var serialNumberLen = assetRec.Serial_Number_Length__c;
        var hasFile = component.get("v.hasFile");
        var serialRegEx = assetRec.Regexpression_Validator__c;
        var enforceSerialLength = assetRec.EnforceLength__c;
        var errmessage = '';
        
        var purchaseddate = component.get("v.purchaseDateP");
        var purchaseLocation = component.get("v.locationP"); 
        var purchaseLocOther = component.get("v.locationHolderP");
        
        let serialNumberOptional = component.get("v.assetIsSerialNumberOptional");

        if (purchaseddate === '') {
            errmessage = "Please enter purchase date.";
        } else if (purchaseddate > today) {
            errmessage = "Please make sure that Date of purchase is not a future date.";
        } else if (purchaseLocation === '') {
            errmessage = "Please enter purchase location.";            
        } else if (purchaseLocation === 'Others' && purchaseLocOther === '') {
            errmessage = "Please specify other purchase location.";            
        } else {
            if (!serialNumber && !serialNumberOptional) {
                errmessage = "Serial number is required." ;
            }  else if (serialRegEx && serialNumber) {
                var patt = new RegExp(serialRegEx);
                if (!patt.test(serialNumber)) {
                    errmessage = "Invalid serial number.";
                }
            } else if (serialNumber && serialNumber.length !== serialNumberLen && enforceSerialLength) {
                errmessage = "Invalid serial number length, please enter length of " + serialNumberLen + " digits";
            } else if (hasWeek && !sWeek && !serialNumberOptional) {
                errmessage = "Serial week is required. (2)";
            } else if (hasWeek && sWeek.length !== 2) {
                errmessage = "Invalid serial week number, please enter two digits. (3)" ;
            } else if (hasYear && !sYear && !serialNumberOptional) {
                errmessage = "Serial year is required. (4)";
            } else if (hasYear && sYear.length !== 4) {
                errmessage = "Invalid serial year, please enter four digits.(4)" ;
            }
        }
        
        if (errmessage !== '') {
            this.showErrorMessage(component, errmessage);
            return false;
            
        } else {
            this.hideErrorMessage(component);
            return true;
        }
    },    

    saveRegsitration: function(component) {
        
        this.showprogress(component, "Saving product registration...", 10);

        var asset = component.get("v.asset");
        var isBunningReceipt = component.get("v.isBunningReceipt");
        var purchasedFromP = "";
        var purchasedFromPOther = "";


        purchasedFromP = component.get("v.locationP");
        if (purchasedFromP !== "Bunnings")
                purchasedFromPOther = component.get("v.locationHolderP");

        asset.PurchaseDate = component.get("v.purchaseDateP");
        asset.AssetSource__c = purchasedFromP;
        asset.Asset_Source_Other__c = purchasedFromPOther;
        asset.SerialNumber = component.get("v.serialNoP");
        asset.SerialNumberWeek__c = component.get("v.serialWeek");
        asset.SerialNumberYear__c = component.get("v.serialYear");

        this.executeSave(component, asset, isBunningReceipt); 
    },

    executeSave: function(component, 
                         asset, 
                         isBunningReceipt) {
        var t0 = performance.now();
        var hasFile = component.get("v.hasFile");
        var hasAttachment;
        var fileName = 'NoFile';
        if (hasFile) {
            hasAttachment = 'Yes';
            var fileInput = component.find("file").getElement();
            var file = fileInput.files[0];
            fileName = file.name;
        } else {
            hasAttachment = 'No';
        }

        var action = component.get("c.updateProductRegistration"); 

        action.setParams({
            updatedAsset: asset,
            isFromValidRetailer: isBunningReceipt,
            filename: fileName,
            retailerSource: component.get("v.locationP")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state !== 'SUCCESS') {
                this.displayServerError(response); 
                return;
            } else {
                    
                var result = response.getReturnValue();
                
                if (this.responseHasErrors(response) || result.error) {
                    this.displayServerErrorMessage(component, response);
                    return;
                } 
                
                if (result.standardWarranty > 0 && result.extendedWarranty > 0) {
                    component.set("v.warrantyResult", "You have qualified for a standard warranty of " + result.standardWarranty/12 + " years and an extended warranty of "+ result.extendedWarranty/12 + " years.");
                } else if (result.standardWarranty > 0) {
                    component.set("v.warrantyResult", "You have qualified for a standard warranty of " + result.standardWarranty/12 + " years.");
                } else {
                    component.set("v.warrantyResult", "Unfortunately, this product does not qualify for a warranty with the information provided.");
                }
                
                if (!hasFile) {
                    this.hideprogress(component);
                    this.showCompeleteMessage(component);
                } else {
                    this.saveFile(component, result.receiptID);
                }
            }
        });

        $A.enqueueAction(action);
    },
    
    
    saveFile: function(component, receiptId) {
        
        this.showprogress(component, "Uploading receipt....", 15);
         
        var fileInput = component.find("file").getElement();
        var file = fileInput.files[0];
        
   
        if (file.size > this.MAX_FILESIZE) {
            alert('File size cannot exceed ' + this.MAX_FILESIZE + ' bytes.\n' +
              'Selected file size: ' + file.size);
            return;
        }
        
        var fr = new FileReader();

        var self = this;
        fr.onload = function() {
            var fileContents = fr.result;
            var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;

            fileContents = fileContents.substring(dataStart);
            
            self.upload(component, file, fileContents, receiptId);
        };

        fr.readAsDataURL(file);
    },
        
    upload: function(component, file, fileContents, receiptId) {
        var fromPos = 0;
        var toPos = Math.min(fileContents.length, fromPos + this.CHUNK_SIZE);
        this.uploadChunk(component, file, fileContents, fromPos, toPos, '', receiptId);
    },
     
    uploadChunk: function(component, file, fileContents, fromPos, toPos, attachId, receiptId) {
        
        var action = component.get("c.saveFileChunk"); 
        var chunk = fileContents.substring(fromPos, toPos);
        
        action.setParams({
            parentId: receiptId,
            fileName: file.name,
            base64Data: encodeURIComponent(chunk), 
            contentType: file.type,
            fileId: attachId
        });
       
        var self = this;
        action.setCallback(this, function(a) {
            attachId = a.getReturnValue();
            
            fromPos = toPos;
            toPos = Math.min(fileContents.length, fromPos + self.CHUNK_SIZE);
            

            perComplete = ((fromPos + self.CHUNK_SIZE) / fileContents.length) * 100;
            
            this.showprogress(component, "Uploading receipt...", perComplete);
            
            if (fromPos < toPos) {
                self.uploadChunk(component, file, fileContents, fromPos, toPos, attachId, receiptId);
            } else {
                this.hideprogress(component);
                this.showCompeleteMessage(component);
                
            }
            
        });
            
        $A.enqueueAction(action); 
        
    }, 
    
    
    populateForEdit: function(component) {
        var asset = component.get("v.asset");
        
        this.hideErrorMessage(component);        
        this.loadReceipt(component, asset);       
        
        var purchasedFrom = asset.AssetSource__c;
        
       if (purchasedFrom !== "Others") {
            component.set("v.locationHolderP", asset.Asset_Source_Other__c);
            component.set("v.locationHolderP","");
        }      
        
        var isBunningsRec ='';
        if (asset.Receipt__c === null) {
               isBunningsRec= "Yes";
        } else {
            isBunningsRec = asset.Receipt__r.ReceiptSource__c === 'Other' ? "No" : "Yes";
        }
        component.set("v.isBunningReceipt", isBunningsRec);
    },
    
    
    loadReceipt: function(component, asset) {
        if (asset.Receipt__c === null) {
            var receiptName ='';
        } else {
            var receiptName = asset.Receipt__r.Receipt_Name__c;
        }

        if (receiptName === '' || receiptName === null) {
            component.set("v.previousFile", "N/A");
        } else {
            component.set("v.previousFile", receiptName);

            var action = component.get("c.getFileId");
            action.setParams({
                receiptId : asset.Receipt__c
            });

            action.setCallback(this, function(response) {
                var resultest = response.getReturnValue();
                this.populateFile(response, component);
            });

            $A.enqueueAction(action);

        }
    },

       
    populateFile: function(response, component) {
        
        var state = response.getState();
        
        if (state !== 'SUCCESS') {
            this.displayServerError(response); 
            return;
        } else {
            var result = response.getReturnValue();
            if (this.responseHasErrors(response)) {
                this.displayServerErrorMessage(component, response);
                return;
            } 
            
            var link = response.getReturnValue();
            component.set("v.attachmentLink", link);
        }
        
        
    },
    
     showprogress: function(component, message, progress) {
        
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

    hideprogress: function(component) {
        component.set("v.statusMessage", "");
        $("#uploadingnew").hide();        
    },
    
    showCompeleteMessage: function(component) {
        $("#promptDiv").show();
    },

            
    showErrorMessage: function(component, errmessage) {
        component.set("v.errorMessage", errmessage);
        component.set("v.showError", true);
        component.find("confirmBtn").set("v.disabled", false);
    },
        
    hideErrorMessage: function(component) {
        component.set("v.errorMessage", "");
        component.set("v.showError", false);
    },
    
   displayServerErrorMessage: function(component, response) {
       this.hideprogress(component);
       this.showErrorMessage(component, "Oops...something went wrong. Please try again, if error continues contact our customer support.") 
   },

   responseHasErrors: function(response) {
       let errors = response.getError();
        if (errors) {
           if (errors[0] && errors[0].message) {
               return true;
           }
        } 
      return false;
   },
       
  
   
   /*OLD - strill required*/

  //arjen added function for initialize custom settings
    initializeCustomSettings: function (component) {
        
        var action = component.get("c.getSiteSettings");
        action.setCallback(this, function(response) {
            var customSettingValues = response.getReturnValue();
            component.set("v.siteSettings", customSettingValues.communitySettings);
            component.set("v.userCountry", customSettingValues.userCountry);
            
            if (customSettingValues.userCountry === 'Australia') {
                component.set("v.warrantyURL", customSettingValues.communitySettings.Warranty_URL__c);
            } else {
                component.set("v.warrantyURL", customSettingValues.communitySettings.Warranty_URL_NZ__c);
            }
        });
        $A.enqueueAction(action);
    },
       
       
    updateLocationList: function(component) {
        let asset = component.get("v.asset");
        let assetReceiptSrc = asset.Receipt__r.ReceiptSource__c;
        let userCountry = component.get("v.userCountry");

        if (assetReceiptSrc && assetReceiptSrc === "Other") {
            assetReceiptSrc = "Others";
            component.set("v.isBunningReceipt", "No");
        }
        
        let action = component.get('c.fetchPurchaseFromValues');
        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                let locationsList = {};
                let payload = JSON.parse(response.getReturnValue());
                payload.sort((a, b) => a.Order__c < b.Order__c ? -1 : (a.Order__c > b.Order__c ? 1 : 0));
                payload.forEach(item => locationsList[item.MasterLabel] = item);
                component.set("v.locationList", Object.keys(locationsList));
                assetReceiptSrc = !assetReceiptSrc ? Object.keys(locationsList)[0] : assetReceiptSrc;
                
            } else {
                this.showToast(component, '', $A.get("$Label.c.AEG_Generic_Error_Message"), 'error');
            }
            component.set("v.locationP", assetReceiptSrc);
            component.set("v.locationHolderP", asset.Asset_Source_Other__c);
        });
        $A.enqueueAction(action);
    }, 
   
    fileUploaded: function(component) {
        var fileInput = component.find("file").getElement();
        var file = fileInput.files[0];
        
        if (file.size > this.MAX_FILE_SIZE) {
            alert('File size cannot exceed ' + this.MAX_FILE_SIZE + ' bytes.\n' +
              'Selected file size: ' + file.size);
            return;
        }
    
        var fr = new FileReader();

           fr.onload = function() {
            var fileContents = fr.result;
            $('#receiptView').attr('src', fr.result);
            $('#receiptView').attr('hidden', false);
            component.set("v.hasFile", true)      
        };

        fr.readAsDataURL(file);
    }
    
})