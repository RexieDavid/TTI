({
   
    updateLocationList: function(component) {
        console.log('locationList start');
        
        var locationList = ['Bunnings','Others'];
        
        component.set("v.locationList", locationList);
        component.set("v.locationP", locationList[0]);
        component.set("v.locationK", locationList[0]);
        
		console.log("locationList passed in", locationList);
        console.log('locationList end');
        
        //var fileInput = component.find("file").getElement().type;
    	//var file = fileInput.files.length;
        //console.log("fileInput---:" fileInput);
	},
    
    //arjen added function for initialize custom settings
    initializeCustomSettings : function (component){
        var action = component.get("c.getCommunitySettings");
        action.setStorable();
        action.setCallback(this, function(response){
            this.getCustomSettingsValues(response,component);
        });
        $A.enqueueAction(action);

        
    },
    
    getCustomSettingsValues : function(response,component){
        
        var customSettingValues = response.getReturnValue();
        console.log('customSettingValues---', customSettingValues);
        component.set("v.siteSettings", customSettingValues);
    },
    
    fileUploaded : function(component) {
        
        console.log("fileUploaded helper start");
        var fileInput = component.find("file").getElement();
    	var file = fileInput.files[0];
        
        if (file.size > this.MAX_FILE_SIZE ){
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
    },
    
    //for file upload
    MAX_FILE_SIZE: 5242880, /* =((5*1024)*1024) 1 000 000 * 3/4 to account for base64 */
	
    checkPopulatedFields : function(component){
    
    	var today = new Date();
        var dd = today.getDate();
        var mm = today.getMonth()+1; //January is 0!
        var yyyy = today.getFullYear();
        if(dd<10) {
        	dd='0'+dd
        } 
        
        if(mm<10) {
            mm='0'+mm
        } 
		today = yyyy+'-'+ mm+'-'+dd;
    	
    	
      
        
    	var individualAssetList = component.get("v.individualAssetList");
        
        var assetRec = component.get("v.asset");
    	
        var sWeek = component.get("v.serialWeek");
        var sYear = component.get("v.serialYear");
        var hasWeek = assetRec.Display_Week__c;
        var hasYear = assetRec.Display_Year__c;
        var serialNumber = component.get("v.serialNoP");
        var serialNumberLen = assetRec.Serial_Number_Length__c;       
        var hasFile = component.get("v.hasFile");
		var serialRegEx = assetRec.Regexpression_Validator__c;
        var errmessage = '';
        //console.log('0--------locationHolderP:', component.get("v.locationHolderP");
    	
        if(individualAssetList.length > 1){
        	var purchaseddate = component.get("v.purchaseDateK");
            var purchaseLocation = component.get("v.locationK"); 
            var purchaseLocOther = component.get("v.locationHolderK"); 
        }
        else{
            var purchaseddate = component.get("v.purchaseDateP");
            var purchaseLocation = component.get("v.locationP"); 
            var purchaseLocOther = component.get("v.locationHolderP"); 
            
        }
        console.log('1--------varSWeek:'+sWeek);
        console.log('2--------varSYear:'+sYear);
        console.log('3--------varhasWeek:'+ hasWeek) ;
        console.log('4--------varhasYear:' + hasYear) ;
        console.log('5--------varSerialNumber:' + serialNumber);
        console.log('6--------varSerialNumberLen:' + serialNumberLen);
        
        console.log('7--------purchaseddate:' + purchaseddate);
        console.log('8--------purchaseLocation:' + purchaseLocation);
        console.log('9--------purchaseLocOther:' + purchaseLocOther);
        console.log('10--------hasFile:' + hasFile);
        console.log('11--------serialRegEx:' + serialRegEx);
        
        console.log('component.get("v.serialNoP")', component.get("v.serialNoP"));
        console.log('component.get("v.locationP")', component.get("v.locationP"));
        console.log('component.get("v.locationHolderP")', component.get("v.locationHolderP"));
		console.log('component.get("v.serialWeek")', component.get("v.serialWeek"));
        
        
        
        if(purchaseddate == ''){
            errmessage = "Please enter purchase date.";
        }        
        else if(purchaseddate > today){
            errmessage = "Please make sure that Date of purchase is not a future date.";
        }        
        
        else if (purchaseLocation == ''){
            errmessage = "Please enter purchase location.";            
        }
        else if (purchaseLocation != 'Bunnings' && purchaseLocOther == ''){
            errmessage = "Please specify other purchase location.";            
        }
        else if (!hasFile){
			errmessage = "Please enter a receipt.";            
		}
        else {
            if(individualAssetList.length == 1){
                
                var serialRegExTest;        		
                if (serialRegEx != null && serialRegEx != '' && serialNumber != ''){        
            		var patt = new RegExp(serialRegEx);
        			serialRegExTest = patt.test(serialNumber);		 	            
        		}

                if ( serialNumber == '' ){
                    errmessage ="Serial number is required." ;
                }
                else if (serialRegExTest == false){
                    errmessage ="Invalid serial number.";
                } 
                else if (serialNumber.length != serialNumberLen){
                    errmessage ="Invalid serial number length, please enter length of " + serialNumberLen + " digits";
                }
                else if (hasWeek == true && (sWeek == null || sWeek == '')){
                    
                    errmessage ="Serial week is required.";
                }		
                else if (hasWeek == true && sWeek.length != 2){
                    errmessage ="Invalid serial week number, please enter two digits. (3)" ;
                }
    
                else if (hasYear == true &&  (sYear == null || sYear == '')){
                    errmessage ="Serial year is required.";
                }
                else if (hasYear == true && sYear.length != 4){
                    errmessage ="Invalid serial year, please enter four digits." ;
                }
            }
            else if(individualAssetList.length > 1){
                for(i = 0; i < individualAssetList.length; i++){
                    var serialRegExTest;        		
                    if (individualAssetList[i].Regexpression_Validator__c  != null && individualAssetList[i].Regexpression_Validator__c != '' && individualAssetList[i].SerialNumber != ''){        
                        var patt = new RegExp(individualAssetList[i].Regexpression_Validator__c);
                        serialRegExTest = patt.test(individualAssetList[i].SerialNumber);		 	            
                    }
                    if(individualAssetList[i].SerialNumber == null || individualAssetList[i].SerialNumber == ''){
                                      
                        errmessage ="Serial number is required." ;
                        break;
                    }
                    else if (serialRegExTest == false){
                        errmessage ="Invalid serial number.";
                    }
                    else if (individualAssetList[i].SerialNumber.length != individualAssetList[i].Serial_Number_Length__c){
                    	errmessage ="Invalid serial number length, please enter length of " + individualAssetList[i].Serial_Number_Length__c + " digits";
                	}
                    else if (individualAssetList[i].Display_Week__c  == true && (individualAssetList[i].SerialNumberWeek__c == null || individualAssetList[i].SerialNumberWeek__c == '')){
                    
                    	errmessage ="Serial week is required.";
                	}
                    else if (individualAssetList[i].Display_Week__c == true && individualAssetList[i].SerialNumberWeek__c.length != 2){
                    	errmessage ="Invalid serial week number, please enter two digits." ;
                	}
                    else if (individualAssetList[i].Display_Year__c == true &&  (individualAssetList[i].SerialNumberYear__c == null || individualAssetList[i].SerialNumberYear__c == '')){
                    	errmessage ="Serial year is required.";
                	}
                    else if (individualAssetList[i].Display_Year__c == true && individualAssetList[i].SerialNumberYear__c.length != 4){
                    	errmessage ="Invalid serial year, please enter four digits." ;
                	}
                    
                }
            }
        }
        
        if(errmessage != ''){
           	console.log('--------Validation Error:' + errmessage );
           	component.set("v.errorMessage",errmessage);
            component.set("v.showError",true);
            component.find("confirmBtn").set("v.disabled",false);
            
        }else{
            console.log('--------processRegistration:Start');
            this.processRegistration(component);
        }
	},
    
    processRegistration : function(component) {
		var t0 = performance.now();
    	var individualAssetList = component.get("v.individualAssetList");
        var isBunningReceipt = component.get("v.isBunningReceipt");
		
        var purchasedFrom = "";
		var purchasedFromOther = ""; 
        var purchasedDate;
        var serialNumber="";
        var assetRec = component.get("v.asset");
        
        
      
        if(individualAssetList.length > 1){
            //Kit
            purchasedDate =component.get("v.purchaseDateK");
            purchasedFrom =component.get("v.locationK");
           
            if(component.get("v.locationK") != "Bunnings")
            	purchasedFromOther = component.get("v.locationHolderK");
            
            for (i = 0; i < individualAssetList.length; i++) {
                individualAssetList[i].PurchaseDate = purchasedDate//component.get("v.purchaseDateP");
                individualAssetList[i].AssetSource__c = purchasedFrom;
                individualAssetList[i].Asset_Source_Other__c = purchasedFromOther;
            }
            
        }else{
            //Not a kit
            purchasedDate =component.get("v.purchaseDateP");
            purchasedFrom = component.get("v.locationP");
            serialNumber = component.get("v.serialNoP");
            console.log('-----------------purchasedFrom:' + purchasedFrom);
            
            if(component.get("v.locationP") != "Bunnings")
            	purchasedFromOther = component.get("v.locationHolderP");
			
            
            console.log('-----------------purchasedFromOther:' + purchasedFromOther);
          
            individualAssetList[0].PurchaseDate = purchasedDate//component.get("v.purchaseDateP");
            individualAssetList[0].AssetSource__c = purchasedFrom;
            individualAssetList[0].Asset_Source_Other__c = purchasedFromOther;
            individualAssetList[0].SerialNumber = component.get("v.serialNoP");
            
            //arjen add new serial number fields 
            individualAssetList[0].SerialNumberWeek__c = component.get("v.serialWeek");
            individualAssetList[0].SerialNumberYear__c = component.get("v.serialYear");
            individualAssetList[0].Display_Week__c = assetRec.Display_Week__c;
            individualAssetList[0].Display_Year__c = assetRec.Display_Year__c;
            individualAssetList[0].Allow_Numbers_Only__c = assetRec.Allow_Numbers_Only__c;
            individualAssetList[0].Helper_Image_URL__c = assetRec.Helper_Image_URL__c;
            individualAssetList[0].HelpText__c = assetRec.HelpText__c;
            individualAssetList[0].Regexpression_Validator__c = assetRec.Regexpression_Validator__c;
            individualAssetList[0].Serial_Number_Length__c = assetRec.Serial_Number_Length__c;
            
        }
        
        console.log('asset to be inserted is: ', individualAssetList);
        
        /* Current conde*/
        var fileInput = component.find("file").getElement();
    	var file = fileInput.files[0];
   
        
        if (file.size > this.MAX_FILE_SIZE) {
            alert('File size cannot exceed ' + this.MAX_FILE_SIZE + ' bytes.\n' +
    		  'Selected file size: ' + file.size);
    	    return;
        }
    	
        var fr = new FileReader();
        var fileContents;
        var thisJS = this;
       	fr.onload = function() {
            var fileContents = fr.result;
    	    var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;

            fileContents = fileContents.substring(dataStart); 
            thisJS.saveRegistration(individualAssetList, isBunningReceipt, component, file, fileContents);
            var t1 = performance.now();
            console.log("Call to controller.processRegistration() took " + t1 + " upto " + t0 + " ms");
        };

        fr.readAsDataURL(file);        
       
        /*Old Code
        var fileInput = component.find("file").getElement();
    	var file = fileInput.files[0];
   
        if (file.size > this.MAX_FILE_SIZE) {
            alert('File size cannot exceed ' + this.MAX_FILE_SIZE + ' bytes.\n' +
    		  'Selected file size: ' + file.size);
    	    return;
        }
    	
        var fr = new FileReader();
        var fileContents;
        
       	fr.onload = function() {
            var fileContents = fr.result;
    	    var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;

            fileContents = fileContents.substring(dataStart);
        };

        fr.readAsDataURL(file);        
        
        this.saveRegistration(individualAssetList, isBunningReceipt, component, file, fileContents);
        var t1 = performance.now();
        
		*/        
       
    },
        
    saveRegistration: function(individualAssetList, 
                               isBunningReceipt, 
                               component, 
                               file, 
                               fileContents
                              ) {
		var t0 = performance.now();
        $A.util.addClass(component.find("uploading"), "uploading");
        var action = component.get("c.saveTheFile"); 
		
        var assetList = [];
        
        for(var i = 0; i < individualAssetList.length; i++) {
            var asset = individualAssetList[i];
            console.log('@@@asset.KitProduct__c',asset.KitProduct__c);
            assetList.push({sobjectType: "Asset", 
                            Name: asset.Name, 
                            Product2Id: asset.Product2Id, 
                            KitProduct__c: asset.KitProduct__c,
                            Status: 'Registered', 
                            Quantity: 1.00,
                            Purchased_From__c: asset.Purchased_From__c,
                            SerialNumber: asset.SerialNumber,
                            PurchaseDate: asset.PurchaseDate,
                            AssetSource__c: asset.AssetSource__c,
                            Asset_Source_Other__c : asset.Asset_Source_Other__c,
                            SerialNumberWeek__c : asset.SerialNumberWeek__c,
                            SerialNumberYear__c : asset.SerialNumberYear__c,
                            Display_Week__c : asset.Display_Week__c,
                            Display_Year__c : asset.Display_Year__c,
                            Allow_Numbers_Only__c : asset.Allow_Numbers_Only__c,
                            Helper_Image_URL__c : asset.Helper_Image_URL__c,
                            HelpText__c : asset.HelpText__c,
                            Regexpression_Validator__c : asset.Regexpression_Validator__c,
                            Serial_Number_Length__c : asset.Serial_Number_Length__c
                           });
        }
        
        console.log('saving Assets: ', assetList);
        action.setParams({
            assets: assetList,
            isBunningReceipt: isBunningReceipt,
            fileName: file.name,
            base64Data: encodeURIComponent(fileContents), 
        });
        action.setCallback(this, function(response) {
            this.returnSavingMessage(response, component)
        });
        
        $A.run(function() {
            $A.enqueueAction(action);
        });
		
        console.log('enqueing Assets: ', assetList);
        var t1 = performance.now();
        console.log("Call to controller.saveRegistration() took " + t1 + " upto " + t0 + " ms");

    },
    
    returnSavingMessage : function(response, component) {
		var t0 = performance.now();
        console.log("Upsert Response", response);
        var res = response.getReturnValue();
        console.log("res", res);
        var resSplit = res.split(":");
        console.log("resSplit", resSplit);
        if(resSplit[0] != "insertSuccess") {

            $A.createComponents([
                ["ui:message",{
                    "title" : "Product Registration Error",
                    "severity" : "error",
                }],
                ["ui:outputText",{
                    "value" : res
                }]
                ],
                function(components, status, errorMessage){
                        var message = components[0];
                        var outputText = components[1];
                        // set the body of the ui:message to be the ui:outputText
                        message.set("v.body", outputText);
                        var errorDiv = component.find("errorDiv");
                        // Replace div body with the dynamic component
                        errorDiv.set("v.body", message);
                }
           );
            component.find("confirmBtn").set("v.disabled",false);
            
        }
        else {
                var individualAssetList = component.get("v.individualAssetList");

            if(individualAssetList.length > 1){
            	component.set("v.warrantyResult","Thank you for registering your kit.");
            }
            
            else{
                if(resSplit[2] != 0){
                    component.set("v.warrantyResult", "You have qualified for a standard warranty of " + resSplit[1]/12 + " years and an extended warranty of "+ resSplit[2]/12 + " years");
                }else if(resSplit[1] != 0){
                    component.set("v.warrantyResult", "You have qualified for a standard warranty of " + resSplit[1]/12 + " years.");
                }else{
                    component.set("v.warrantyResult", "Unfortunately, this product does not qualify for a warranty with the information provided.");
                }
            }
	        $("#promptDiv").show();
        }        
    	$A.util.removeClass(component.find("uploading"), "uploading");    	
        $A.util.addClass(component.find("uploading"), "notUploading");
        var t1 = performance.now();
        console.log("Call to controller.saveRegistration() took " + t1 + " upto " + t0 + " ms");
    }
     
    
})