({  
    getSelectedServiceAgent: function (component, event,helper) {
        var selectedRows = event.getParam('selectedRows');
        
        // Display that fieldName of the selected rows
        for (var i = 0; i < selectedRows.length; i++){
            component.set("v.claim.Service_Agent__c",selectedRows[i]);
            component.set("v.selectedServiceAgentObject",selectedRows[i]);
            component.set("v.claim.Service_Agent__c",selectedRows[i]);
            component.set("v.ServiceAgentAdd",helper.getSelectedObjDeliveryAddress(component,selectedRows[i]));
            
        }
    }, 
    populateAddress : function(component, event, helper) {
        
        var selectedObj = event.getParam("sObject");
        var address='';
        if(!$A.util.isUndefinedOrNull(selectedObj))
        {
            component.set("v.ServiceAgentAdd",helper.getSelectedObjDeliveryAddress(component,selectedObj));
        }
        component.set("v.claim.Service_Agent__c",selectedObj);
        event.stopPropagation(); 
    },
    goToNext : function(component, event, helper) {
        
        	var GetChildComponent = component.find("serviceagensearchId");
            if(!$A.util.isUndefinedOrNull(GetChildComponent)){
                var lookupIdValue = GetChildComponent.find("lookup");
                if(!$A.util.isUndefinedOrNull(lookupIdValue)){
                    
                    var SerAgentFromChild = GetChildComponent.get("v.SelectedItemName");
                    if($A.util.isUndefinedOrNull(SerAgentFromChild) || SerAgentFromChild == '')
                       {
                            lookupIdValue.set("v.errors",[{message:"This field is mandatory"}]);
                            return false;
                       }
                    
                }    
        }
        	var serviceAgentN = component.get("v.claim.Service_Agent__c");
            var compEvent = $A.get("e.c:TTI_ValidateServiceAgent");
            compEvent.fire();
            
            
            if(!$A.util.isUndefinedOrNull(serviceAgentN))
            {
                component.set("v.activeScreenId","6");
            }
    },
    
    goToPrevious : function(component, event, helper) {
        component.set("v.activeScreenId","5");
    },
    searchNearby:function(component,event,helper)
    {
        var PostCodeForNearBySearch=component.get("v.PostCodeForNearBySearch");
        var serviceAgentCategory = component.get("v.serviceagentype");
        var radiusval = component.get("v.radiusval");
        var radiuscountry = component.get("v.radiusCountry");
        if($A.util.isUndefinedOrNull(PostCodeForNearBySearch) || $A.util.isEmpty(PostCodeForNearBySearch))
        {
            var fieldauraID = component.find("PostCodeForNearBySearchId");
            fieldauraID.set("v.errors",[{message:"This field is mandatory"}]);
            return false;
        }
        else{
            var mySpinner=component.find("mySpinner");
            $A.util.removeClass(mySpinner,"slds-hide");
            var action=component.get("c.searchNearByLocation");
            action.setParams({
                "strPincode":component.get("v.PostCodeForNearBySearch"),
                "brand":component.get("v.claim.Brand__c"),
                "objProduct":component.get("v.claim.Product_Name__c"),
                "radiusCountry":component.get("v.radiusCountry"),
                "TypeofSA":component.get("v.serviceagentype"),
                "radiusofSearch":component.get("v.radiusval")
            });
            action.setCallback(this,function(response){
                if(response.getState()=='SUCCESS')
                {
                    var lstAcc=JSON.parse(response.getReturnValue());
                    var mydata=component.get("v.mydata");
                    component.set("v.searchNearByActive",true);
                    component.set('v.mycolumns', [
                        {label: 'Business Name', fieldName: 'Name', type: 'text'},
                        {label: 'Address', fieldName: 'DeliveryAddress', type: 'text'}
                    ]);
                    for(var i=0;i<lstAcc.length;i++)
                    {
                        lstAcc[i].DeliveryAddress=helper.getSelectedObjDeliveryAddress(component,lstAcc[i]);
                    }
                    component.set("v.mydata",lstAcc);
                    $A.util.addClass(mySpinner,"slds-hide");
                    
                }
                else
                {
                    $A.util.addClass(mySpinner,"slds-hide");
                }
            });
            $A.enqueueAction(action);
        }
    },
    closeSearchNearBy:function(component,event,helper)
    {
    	component.set("v.searchNearByActive",false);   
    },
    selectServiceAgent:function(component,event,helper)
    {
        component.set("v.searchNearByActive",false);  
        
    },
    blurMobileFormat : function(component, event, helper) {
         helper.Phonevalidation(component);
    }
})