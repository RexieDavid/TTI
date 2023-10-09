({ 
    onGroupP: function(cmp, evt) {
        //var elem = evt.getSource();
        //var selected = elem.get("v.label"); 
		var selected = cmp.get("v.locationP");    
        if(selected === "Bunnings"){
            //cmp.set("v.locationP", "Bunnings");
            //cmp.find("otherLocP").set("v.disabled", "true");
            $A.util.addClass(cmp.find("otherLocP"), 'hidden');

        }else if(selected === "Others"){
            //cmp.set("v.locationP", "Others");
            //cmp.find("otherLocP").set("v.disabled", "false");
			$A.util.removeClass(cmp.find("otherLocP"), 'hidden');
        }
    },
    
    onGroupK: function(cmp, evt) {
        //var elem = evt.getSource();
        //var selected = elem.get("v.label"); 
        
		var selected = cmp.get("v.locationK");
        if(selected === "Bunnings"){
            //cmp.set("v.locationK", "Bunnings");
            //cmp.find("otherLocK").set("v.disabled", "true");
            $A.util.addClass(cmp.find("otherLocK"), 'hidden');
        }else if(selected === "Others"){
            //cmp.set("v.locationK", "Others");
            //cmp.find("otherLocK").set("v.disabled", "false");
            $A.util.removeClass(cmp.find("otherLocK"), 'hidden');
            
        }
    },
    
	handleNavigateFromSelectionEvent : function(component, event, helper) {
        var url = window.location.href;    
           url += '#!'
        window.location.href = url;
        
       	// set the handler attributes based on event data
        var asset = event.getParam("selectedAsset");
        component.set("v.asset", asset);
        component.set("v.assetImageURL", asset.Image_URL__c);
        component.set("v.assetProductCode", asset.ProductCode);

        var individualAssetList = event.getParam("individualAssetList");
        component.set("v.individualAssetList", individualAssetList);
        console.log("assetparentKitId passed in Here", individualAssetList[0].KitProduct__c);
        
        console.log("@@asset passed in here", asset);
        console.log("individualAssetList passed in Here", individualAssetList);
        
        component.set("v.purchaseDateP", '');
        component.set("v.purchaseDateK", '');
        component.set("v.serialNoP", '');
        component.set("v.locationHolderP", '');
        component.set("v.locationHolderK", '');
        component.set("v.serialWeek", '');
        component.set("v.serialYear", '');
        //component.set("v.hasFile", false);
        component.set("v.isBunningReceipt", 'Yes');
        
 
        
       
        //helper.setLocationList(component);
        helper.updateLocationList(component);
        //helper.populateForEdit(component);
        helper.initializeCustomSettings(component);
     
        
        $("#confirmBtn").blur();
        
        
        if(individualAssetList.length > 1){
        	$("#kitDetailDiv").show(); 
        	$("#productDetailDiv").hide(); 
        }else{
        	$("#kitDetailDiv").hide(); 
        	$("#productDetailDiv").show(); 
        }
        
    
        $("#mainDetailDiv").show(); 
   	},
    
    afterScriptsLoaded : function(component, event, helper) {
    },
    
    fileUploaded : function(component, event, helper) {        
        console.log("fileUploaded start");
        helper.fileUploaded(component);          
        console.log("fileUploaded end");
    },
    
    confirmAddMore : function(component,event,helper) {
        
       
        
        event.getSource().set("v.disabled",true);
        helper.checkPopulatedFields(component);
	},
    
    goBackToSelection : function(component,event,helper) {
        console.log('Go Back to Selection');
        $("#mainDetailDiv").hide();
        $("#promptDiv").hide();
        var evt = $A.get("e.c:ProductDetailConfirmEvent");
        evt.fire();
        
	},
    
    goBackToToolbox : function(component,event,helper) {
	     $("#mainDetailDiv").hide();
	     $("#promptDiv").hide();
         component.find("confirmBtn").set("v.disabled",false);
    	 var evt = $A.get("e.c:ToolBoxListEvent");
       	 evt.fire();
	},
    test1: function(component,event,helper){
    	helper.serialTest1(component, event);
	},
    test2: function(component,event,helper){
    	helper.serialTest2(component, event);
	}
})