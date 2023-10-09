({
    populateForEdit : function(component){
        var asset = component.get("v.asset");
        console.log('populateOnEdit start', asset);

        console.log('populateForEdit-----asset.Purchased_From__c',asset.Purchased_From__c);
        console.log('populateForEdit-----asset.SerialNumberField1__c',asset.SerialNumberField1__c);
        console.log('populateForEdit-----v.serialNoP', asset.SerialNumber);
        console.log('populateForEdit-----v.serialWeek', asset.SerialNumberWeek__c);
        console.log('populateForEdit-----v.serialYear', asset.SerialNumberYear__c);
        console.log('populateForEdit-----v.serialNoP', asset.SerialNumber);
        console.log('populateForEdit-----v.serialWeek', asset.SerialNumberWeek__c);
        console.log('populateForEdit-----v.serialYear', asset.SerialNumberYear__c);
        console.log('populateForEdit-----v.Allow_Numbers_Only__c', asset.Allow_Numbers_Only__c);
        console.log('populateForEdit-----v.Display_Week__c', asset.Display_Week__c);
        console.log('populateForEdit-----v.Display_Year__c', asset.Display_Year__c);
        console.log('populateForEdit-----v.HelpText__c', asset.HelpText__c);
        console.log('populateForEdit-----v.Helper_Image_URL__c', asset.Helper_Image_URL__c);
        console.log('populateForEdit-----v.Regexpression_Validator__c', asset.Regexpression_Validator__c);
        console.log('populateForEdit-----v.Serial_Number_Length__c', asset.Serial_Number_Length__c);
        
        component.set("v.purchaseDateP", asset.PurchaseDate);
        component.set("v.registerDate", asset.CreatedDate);
        
        component.set("v.serialNoP", asset.SerialNumber);
        component.set("v.serialWeek", asset.SerialNumberWeek__c);
        component.set("v.serialYear", asset.SerialNumberYear__c);
        
		component.set("v.errorMessage",'');
        component.set("v.showError",false);        


        var receiptName = asset.Receipt__r.Receipt_Name__c;
        if(receiptName === '' || receiptName == null){
        	component.set("v.previousFile", "N/A");
        }else{
        	component.set("v.previousFile", receiptName);
        }
        
        var purchasedFrom = asset.AssetSource__c;
        
        console.log('--------purchasedFrom:' + purchasedFrom);
        
        if(purchasedFrom !== "Retailer - Bunnings"){
        	component.set("v.locationP", "Others");
        	component.set("v.locationHolderP", asset.Asset_Source_Other__c);
			$A.util.removeClass(component.find("otherLocP"), 'hidden');
        }else{
            component.set("v.locationHolderP","");
            $A.util.addClass(component.find("otherLocP"), 'hidden');
        	component.set("v.locationP", "Bunnings");
            
        }
       
        console.log('-----isBunningReceipt:' +  isBunningsRec);
        var isBunningsRec = asset.Receipt__r.ReceiptSource__c == 'Bunnings' ? "Yes" : "No";
        component.set("v.isBunningReceipt", isBunningsRec);
        
        
        
        var action = component.get("c.getFileId");
        console.log('---asset.Receipt__c---' + asset.Receipt__c);
        action.setParams({
            receiptId : asset.Receipt__c
        });
        action.setCallback(this, function(response) {
            this.populateFile(response, component);
        });
        
        
        
        $A.enqueueAction(action);
        
        console.log('populateOnEdit end');
    },
    
    populateFile : function(response, component){
        var link = response.getReturnValue();
        console.log('---link---- :',link);
        component.set("v.attachmentLink",link);
    },
    
   
    updateLocationList: function(component) {
        console.log('locationList start');
        var locationList = ['Bunnings','Others'];
        
        component.set("v.locationList", locationList);
        
		console.log("locationList passed in", locationList);
        console.log('locationList end');
	},
    
    fileUploaded : function(component) {
        console.log("fileUploaded helper start");
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
    },
    
    //for file upload
    MAX_FILE_SIZE: 5242880, /* =((5*1024)*1024) 1 000 000 * 3/4 to account for base64 */
	
 	checkPopulatedFields : function(component){
	        
   		var individualAssetList = component.get("v.individualAssetList");
        
        
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
    	
        var purchaseddate = component.get("v.purchaseDateP");
        var purchaseLocation = component.get("v.locationP"); 
        var purchaseLocOther = component.get("v.locationHolderP"); 
    
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
        else {
                var serialRegExTest = true;
            	
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
                else if (serialNumber.length > serialNumberLen){
                    errmessage ="Invalid serial number length, please enter length of " + serialNumberLen + " digits or below.";
                }
                else if (hasWeek == true && (sWeek == null || sWeek == '')){
                    
                    errmessage ="Serial week is required. (2)";
                }		
                else if (hasWeek == true && sWeek.length != 2){
                    errmessage ="Invalid serial week number, please enter two digits. (3)" ;
                }
    
                else if (hasYear == true &&  (sYear == null || sYear == '')){
                    errmessage ="Serial year is required. (4)";
                }
                else if (hasYear == true && sYear.length != 4){
                    errmessage ="Invalid serial year, please enter four digits.(4)" ;
                }
        }
     
       
        if(errmessage != ''){
           	console.log('--------Validation Error:' + errmessage );
           	component.set("v.errorMessage",errmessage);
            component.set("v.showError",true);
            component.find("confirmBtn").set("v.disabled",false);
            
        }else{
           	component.set("v.errorMessage",errmessage);
            component.set("v.showError",false);
            console.log('--------processRegistration:Start');
            this.processRegistration(component);
        }
        
        
        /*OLD CODE
        
        var hasDate = true;
        var hasLocation = true;
        var hasSerial = true;
        var hasFile = component.get("v.hasFile");
    	var errmessage = 'Please make sure to populate the following: ';
    	//Arjen Added new Variables for WR-161
        var errDateMessage =  $A.get("$Label.c.myCommunity_Invalid_Purchase_Date")
    	var correctDate = true;
    
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
    	
        console.log('component.get("v.purchaseDateP")', component.get("v.purchaseDateP"));
        console.log('component.get("v.serialNoP")', component.get("v.serialNoP"));
        console.log('component.get("v.locationP")', component.get("v.locationP"));
        console.log('component.get("v.locationHolderP")', component.get("v.locationHolderP"));
		console.log('component.get("v.registerDate")', component.get("v.registerDate"));
		
    	if(component.get("v.purchaseDateP") == null || component.get("v.purchaseDateP") == '' ){
            hasDate = false;
            errmessage = errmessage + " \"Purchase Date\" ";
        }
        if(component.get("v.locationP") != "Bunnings"){
            if(component.get("v.locationHolderP") == null || component.get("v.locationHolderP") == '' ){
                hasLocation = false;
                errmessage = errmessage + " \"Purchase Location\" ";
            }	
        }
        if(component.get("v.serialNoP") == null || component.get("v.serialNoP") == '' ){
            hasSerial = false;                
            errmessage = errmessage + " \"Serial Number\" ";
        }
        if(component.get("v.purchaseDateP") != null && component.get("v.purchaseDateP") > component.get("v.registerDate")){
            correctDate = false;
            errmessage= errDateMessage;
        }
        //arjen add validation for the length of serial number
        if(component.get("v.showSerialWeek")  && (component.get("v.serialWeek") == null || component.get("v.serialWeek") == '') ){
            hasSerial = false;   
            errmessage = errmessage + " \"Serial Number Week\" ";
        }
        if(component.get("v.showSerialYear")  && (component.get("v.serialYear") == null || component.get("v.serialYear") == '')){
            hasSerial = false;   
            errmessage = errmessage + " \"Serial Number Year\" ";
        }
        if((component.get("v.serialNoP") != null || component.get("v.serialNoP") != '') 
           	&& component.get("v.serialNoP").length != component.get("v.serialNumberLength")
            && component.get("v.serialNumberLength") != null){
            hasSerial = false;  
            errmessage ="Serial Number field should have a length of " + component.get("v.serialNumberLength") + " characters.";
        }
        if((component.get("v.serialWeek") != null || component.get("v.serialWeek") != '') && component.get("v.serialWeek").length != 2){
            hasSerial = false;
            errmessage ="Serial Year field should have a length of 2 characters." ;
        }
        if((component.get("v.serialYear") != null || component.get("v.serialYear") != '') && component.get("v.serialYear").length != 4){
            hasSerial = false;
            errmessage ="Serial Year field should have a length of 4 characters." ;
        }
		
        console.log('hasDate', hasDate);
        console.log('hasLocation', hasLocation);
        console.log('hasSerial', hasSerial);
        
        if(!hasDate || !hasLocation || !hasSerial || !correctDate){
			$A.createComponents([
                ["ui:message",{
                    "title" : "Product Registration Error",
                    "severity" : "error"
                }],
                ["ui:outputText",{
                    "value" : errmessage
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
            $("#editError").show();
        }else{
            $("#editError").hide();
            this.processRegistration(component);
        }
        */
	},
        
    processRegistration : function(component) {
    	var asset = component.get("v.asset");
        var isBunningReceipt = component.get("v.isBunningReceipt");
        var purchasedFromP = "";
        var purchasedFromPOther = "";
    	var hasFile = component.get("v.hasFile"); 
        
        purchasedFromP = component.get("v.locationP");
        if(purchasedFromP != "Bunnings")
            	purchasedFromPOther = component.get("v.locationHolderP");
     
        console.log('hasFile', hasFile );
        console.log('component.get("v.serial1")---', component.get("v.serial1") );
        asset.PurchaseDate = component.get("v.purchaseDateP");
        asset.AssetSource__c = purchasedFromP;
        asset.Asset_Source_Other__c = purchasedFromPOther;
        asset.SerialNumber = component.get("v.serialNoP");
        asset.SerialNumberWeek__c = component.get("v.serialWeek");
        asset.SerialNumberYear__c = component.get("v.serialYear");
        //asset.SerialNumberField3__c = component.get("v.serial3");
     
        var fileInput = component.find("file").getElement();
        var file = fileInput.files[0];        
        var fr = new FileReader();
        var fileContents;
        var self = this;
        if(hasFile){
            
            if (file.size > this.MAX_FILE_SIZE) {
                alert('File size cannot exceed ' + this.MAX_FILE_SIZE + ' bytes.\n' +
                      'Selected file size: ' + file.size);
                return;
            }
			 
            fr.onload = function() {
                var fileContents = fr.result;
                console.log('fileContents:',fileContents);
                var base64Mark = 'base64,';
                
                var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
                
                fileContents = fileContents.substring(dataStart);
                console.log('fileContents2:',fileContents);
                
                self.saveRegistration(asset, isBunningReceipt, component, file, fileContents, hasFile);
                
            };
            
            fr.readAsDataURL(file);
        }else{
            this.saveRegistration(asset, isBunningReceipt, component, file, fileContents, hasFile);
        }
        //this.saveRegistration(asset, isBunningReceipt, component, file, fileContents, hasFile);
    },
        
    saveRegistration: function(asset, isBunningReceipt, component, file, fileContents, hasFile) {

        console.log('1' );
        $A.util.addClass(component.find("uploading"), "uploading");
        console.log('1' );
        var action; 
        console.log('1' );

        console.log('hasFile', hasFile );
        if(!hasFile){
        	console.log('if');
            action = component.get("c.updateNoFile"); 
            action.setParams({
                assets: asset,
                isBunningReceipt: isBunningReceipt,
            });
        }else{
        	console.log('else');
            //console.log('encodeURIComponent(fileContents):',encodeURIComponent(fileContents));
            action = component.get("c.updateFile"); 
            action.setParams({
                assets: asset,
                isBunningReceipt: isBunningReceipt,
                fileName: file.name,
                base64Data: encodeURIComponent(fileContents)
                //base64Data:fileContents
            });
        }

        action.setCallback(this, function(response) {
            this.returnSavingMessage(response, component)
        });
        
		$A.run(function() {
            $A.enqueueAction(action); 
        });
    },
    
    returnSavingMessage : function(response, component) {
        console.log("Upsert Response", response);
        var res = response.getReturnValue();
        console.log("res", res);
        var resSplit = res.split(":");
        console.log("resSplit", resSplit);
        
        
        
        if(resSplit[0] != "updateSuccess") {

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
            $("#editError").show();
            
        }
        else {
            //error somewhere here on chaning from other to bunnings?
           	
            if(resSplit[2] != 0){
                component.set("v.warrantyResult","You have qualified for a standard warranty of " + resSplit[1]/12 + " years and an extended warranty of "+ resSplit[2]/12 + " years");
                
            }else if(resSplit[1] != 0){
                component.set("v.warrantyResult", "You have qualified for a standard warranty of " + resSplit[1]/12 + " years.");
            }else{
                component.set("v.warrantyResult", "Unfortunately, this product does not qualify for a warranty with the information provided.");
            }
            
            $("#editError").hide();
	        $("#promptDiv").show();
        }        
    	$A.util.removeClass(component.find("uploading"), "uploading");    	
        $A.util.addClass(component.find("uploading"), "notUploading");
        
    },
    initializeSerialNumber : function(component, event){
        var action = component.get("c.getSerialNumerDisplayHelper");
        var asset = component.get("v.asset");
        console.log("asset---", asset.Product2Id);
         action.setParams({
             productId: asset.Product2Id
         });
         action.setCallback(this, function(a){
          var rtnValue = a.getReturnValue();
          console.log('a.getReturnValue()',a.getReturnValue());
             console.log('display week: ',rtnValue.Display_Week__c);
             component.set("v.showSerialWeek", rtnValue.Display_Week__c);
             component.set("v.showSerialYear", rtnValue.Display_Year__c);
             component.set("v.allowNumbersOnly", rtnValue.Allow_Numbers_Only__c);
             component.set("v.serialNumberLength", rtnValue.Serial_Number_Length__c);
          });
        	//console.log('v.showSerialWeek: ',v.showSerialWeek);
        	//console.log('v.showSerialYear: ',v.showSerialYear);
          $A.enqueueAction(action);
        console.log("v.showSerialWeek: ",component.get("v.showSerialWeek"));
        console.log('v.showSerialYear: ',component.get("v.showSerialYear"));
    },
    
    toggleHelper : function(component,event) {
    var toggleText = component.find("tooltip");
    $A.util.toggleClass(toggleText, "toggle");
     //$('toggleText').tooltip({ container: 'body' }) 
   }
    /*
    serialTest1 : function(component, event){
        console.log("here123");
        //var serial1 = component.find("serialNoP1");
        //console.log("serial1--", serial1);
        var serial1Value = component.get("v.serial1");
        var serial1length = serial1Value.length;
        
        console.log("serial1value--", serial1Value);
        console.log("serial1--", serial1Value.length);
        if(serial1length ==6){
            component.find("serialNoP2").focus();
        }
        Var serial2Value = component.get("v.serial2");
        console.log("serial2--", serial2Value.length);
        
    },
    serialTest2 : function(component, event){
        console.log("here1234");
        //var serial1 = component.find("serialNoP1");
        //console.log("serial1--", serial1);
        var serial2Value = component.get("v.serial2");
        var serial2length = serial2Value.length;
        console.log("serial2value--", serial2Value);
        console.log("serial2--", serial2Value.length);
        if(serial2length ==2){
            component.find("serialNoP3").focus();
        }
        
    } */
    
    
    
})