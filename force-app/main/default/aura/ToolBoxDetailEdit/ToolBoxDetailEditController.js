({
	handleNavigateFromSelectionEvent : function(component, event, helper) {
        var url = window.location.href;    
           url += '#!'
        window.location.href = url;
       	// set the handler attributes based on event data
        var asset = event.getParam("selectedAsset");
        component.set("v.asset", asset);
        component.set("v.assetImageURL", asset.Image_URL__c);
        component.set("v.assetProductCode", asset.ProductCode);
        
        
        console.log("asset passed in", asset);
       
        helper.updateLocationList(component);
        helper.populateForEdit(component);
        //helper.initializeSerialNumber(component);
        
        $("#mainDetailDiv").show(); 
   	},
    
    onGroupP: function(cmp, evt) {
    	var selected = cmp.get("v.locationP");
       
        if(selected === "Bunnings"){
            $A.util.addClass(cmp.find("otherLocP"), 'hidden');

        }else if(selected === "Others"){
    		$A.util.removeClass(cmp.find("otherLocP"), 'hidden');
        }
    },
    afterScriptsLoaded : function(component, event, helper) {
    },
    
    fileUploaded : function(component, event, helper) {        
        console.log("fileUploaded start");
        helper.fileUploaded(component);          
        console.log("fileUploaded end");
    },
    
    confirmAndEdit : function(component,event,helper) {
        event.getSource().set("v.disabled",true);
        helper.checkPopulatedFields(component);
	},
    
    goBackToSelection : function(component,event,helper) {
	     $("#mainDetailDiv").hide();
	     $("#promptDiv").hide();
         $("#editError").hide();

        component.find("confirmBtn").set("v.disabled",false);
    	 var evt = $A.get("e.c:ProductDetailConfirmEvent");
       	 evt.fire();
	},
    test1: function(component,event,helper){
    	helper.serialTest1(component, event);
	},
    test2: function(component,event,helper){
    	helper.serialTest2(component, event);
	},
    
    display : function(component, event, helper) {
    helper.toggleHelper(component, event);
    },
    
    displayOut : function(component, event, helper) {
        helper.toggleHelper(component, event);
    }
})