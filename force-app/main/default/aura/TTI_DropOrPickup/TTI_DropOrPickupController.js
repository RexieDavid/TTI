({  
    populateAddress : function(component, event, helper) {
        
        var selectedObj = event.getParam("sObject");
        var shippingAddressObj=selectedObj.ShippingAddress;
        var shippingCourierComapny = selectedObj.Freight_Company__c;
        var serviceAgentName =selectedObj.Id;
        var address='';
        if(!$A.util.isUndefinedOrNull(selectedObj))
        {
            component.set("v.ShippingAddObj",shippingAddressObj);
            var street='';
            var city='';
            var state='';
            var postalCode='';
            var country='';
            if(!$A.util.isUndefinedOrNull(selectedObj.Delivery_Street__c)) {
                component.set("v.claim.TTI_Freight_In_Delivery_Address__c",selectedObj.Delivery_Street__c);
                street = selectedObj.Delivery_Street__c;
            }
            if(!$A.util.isUndefinedOrNull(selectedObj.Delivery_Suburb__c)) {
                component.set("v.claim.TTI_Freight_In_Delivery_Suburb__c",selectedObj.Delivery_Suburb__c);
                city = selectedObj.Delivery_Suburb__c;
            }
            if(!$A.util.isUndefinedOrNull(selectedObj.Delivery_State__c)) {
                state = selectedObj.Delivery_State__c;
                component.set("v.claim.TTI_Freight_In_Delivery_State__c",selectedObj.Delivery_State__c);
            }
            if(!$A.util.isUndefinedOrNull(selectedObj.Delivery_Postcode__c)) {
                component.set("v.claim.TTI_Freight_In_Delivery_Postcode__c",selectedObj.Delivery_Postcode__c);
                postalCode = selectedObj.Delivery_Postcode__c;
            }
            if(!$A.util.isUndefinedOrNull(selectedObj.Delivery_Country__c)) {
                component.set("v.claim.TTI_Freight_In_Delivery_Country__c",selectedObj.Delivery_Country__c);
                country = selectedObj.Delivery_Country__c;
            }
            address=street+' '+city+' '+state+' '+postalCode+' '+country;
            component.set("v.ServiceAgentAdd",address);
            
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
        var droporPickup = component.get("v.claim.TTI_Service_Agent_Delivery_Method__c");
        
        if(!$A.util.isUndefinedOrNull(droporPickup) && droporPickup == 'Drop off')
        {
            
            var serviceAgentN = component.get("v.claim.Service_Agent__c");
            var compEvent = $A.get("e.c:TTI_ValidateServiceAgent");
            compEvent.fire();
            
            
            if(!$A.util.isUndefinedOrNull(serviceAgentN))
            {
                component.set("v.claim.TTI_Freight_In_Pickup_Country__c",null);
                component.set("v.activeScreenId","6");
            }
        }
        
        if(!$A.util.isUndefinedOrNull(droporPickup) && droporPickup == 'Pickup from nominated address'){
            var addres1 = component.get("v.address1"); 
            var addres2 = component.get("v.address2"); 
            var postcode = component.get("v.postalCode");
            var state = component.get("v.state");
            var suburb = component.get("v.suburb");
            var country = component.get("v.claim.TTI_Freight_In_Pickup_Country__c");
            //component.set("v.claim.TTI_Freight_In_Required__c",true);
            helper.Area1validation(component);
            helper.pincodevalidation(component);
            helper.suburbvalidation(component);
            helper.pincodevalidation(component);
            helper.countryvalidation(component);
            var stateValidation=helper.statevalidation(component);
            var Phonevalidation = helper.Phonevalidation(component);
            var blurMobileFormat = helper.blurMobileFormat(component);
            if(!$A.util.isUndefinedOrNull(droporPickup) && droporPickup != '' && !$A.util.isUndefinedOrNull(addres1) && addres1 !='' &&
               !$A.util.isUndefinedOrNull(postcode) && postcode != '' && stateValidation && !$A.util.isUndefinedOrNull(suburb) && suburb !='' && !$A.util.isUndefinedOrNull(country) && Phonevalidation && blurMobileFormat)
            {
                if(!$A.util.isUndefinedOrNull(addres2))
                {
                    var addressObj=addres1 +' '+addres2;
                }
                else
                {
                    var addressObj=addres1;
                }
                
                component.set("v.claim.TTI_Freight_In_Pickup_Suburb__c",suburb);
                component.set("v.claim.TTI_Freight_In_Pickup_Postcode__c",postcode);
                component.set("v.claim.TTI_Freight_In_Pickup_State__c",state);
                component.set("v.claim.TTI_Freight_In_PickUp_Address__c",addressObj );
                
                var address123 = component.get("v.claim.TTI_Freight_In_PickUp_Address__c");
                component.set("v.activeScreenId","10");
            }
            
            
            
        }
        
        
    },
    picklistChange:function(component,event,helper){
        var picklistBox= component.find("InputSelectDroporPickup");
        if(picklistBox.get("v.value") == 'Drop off'){
            component.set("v.claim.TTI_Freight_In_PickUp_Address__c",null);
            component.set("v.claim.TTI_Freight_In_Pickup_Suburb__c",null);
            component.set("v.claim.TTI_Freight_In_Pickup_Postcode__c",null);
            component.set("v.claim.TTI_Freight_In_Pickup_State__c",null);
            component.set("v.claim.TTI_Freight_In_Pickup_Country__c",null);
           
        }else{
            var retailerAccountState = component.get("v.claim.Retailer_Account__c.Delivery_State__c");
            var retailerAccountStreet = component.get("v.claim.Retailer_Account__c.Delivery_Street__c");
            var retailerAccountSuburb = component.get("v.claim.Retailer_Account__c.Delivery_Suburb__c");
            var retailerAccountPostCode = component.get("v.claim.Retailer_Account__c.Delivery_Postcode__c");
            var retailerAccountCountry = component.get("v.claim.Retailer_Account__c.Delivery_Country__c");
            
            component.set("v.address1",retailerAccountStreet);
            component.set("v.suburb",retailerAccountSuburb);
            component.set("v.postalCode",retailerAccountPostCode);
            component.set("v.state",retailerAccountState);
            if(retailerAccountCountry=='NZ'){
                retailerAccountCountry='New Zealand';
            }
            if(retailerAccountCountry=='AU'){
                retailerAccountCountry='Australia';
            }
            component.set("v.claim.TTI_Freight_In_Pickup_Country__c",retailerAccountCountry);
            
            component.set("v.claim.TTI_Freight_In_Delivery_Address__c",null);
            component.set("v.claim.TTI_Freight_In_Delivery_Suburb__c",null);
            component.set("v.claim.TTI_Freight_In_Delivery_State__c",null);
            component.set("v.claim.TTI_Freight_In_Delivery_Postcode__c",null);
            component.set("v.claim.TTI_Freight_In_Delivery_Country__c",null);
            component.set("v.ServiceAgentAdd",'');
        }
    },
    goToPrevious : function(component, event, helper) {
        component.set("v.activeScreenId","4");
    },
    getSelectedServiceAgent: function (component, event) {
        var selectedRows = event.getParam('selectedRows');
        
        // Display that fieldName of the selected rows
        for (var i = 0; i < selectedRows.length; i++){
            component.set("v.claim.Service_Agent__c",selectedRows[i]);
            component.set("v.ServiceAgentAdd",selectedRows[i].DeliveryAddress);
            
        }
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
                        var address ='';
                        if(!$A.util.isUndefinedOrNull(lstAcc[i].Delivery_Street__c))
                          address = address +'' +lstAcc[i].Delivery_Street__c+ ' ' ;
                        if(!$A.util.isUndefinedOrNull(lstAcc[i].Delivery_Suburb__c))
                              address = address +'' +lstAcc[i].Delivery_Suburb__c+ ' ';
                        if(!$A.util.isUndefinedOrNull(lstAcc[i].Delivery_State__c))
                              address = address +'' +lstAcc[i].Delivery_State__c+ ' ';
                        if(!$A.util.isUndefinedOrNull(lstAcc[i].Delivery_Postcode__c))
                              address = address +'' +lstAcc[i].Delivery_Postcode__c+ ' ';
                        if(!$A.util.isUndefinedOrNull(lstAcc[i].Delivery_Country__c))
                              address = address +'' +lstAcc[i].Delivery_Country__c;
                        lstAcc[i].DeliveryAddress=address;
                        //mydata.push(tempObj);
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
    selectServiceAgent:function(component,event,helper){
        component.set("v.searchNearByActive",false);  
        
    },
    blurMobileFormat : function(component, event, helper) {
         helper.blurMobileFormat(component);
    },
    disableNextButton: function(component, event, helper) {
        // Francis Nasalita - [SP-871] November 7, 2018
        // This will only executed if this component is active
        if(component.get("v.activeScreenId") == component.get("v.myId")) {
            var isDisabled = event.getParam("isDisabled");
            component.set("v.isNextButtonDisabled", isDisabled);
            var isNextButtonDisabled = component.get("v.isNextButtonDisabled");
            var removeHide = component.find('nextBtn');

            if(!isNextButtonDisabled){
                $A.util.removeClass(removeHide, 'slds-hide');
                document.getElementById("nextButton").style.visibility = "visible";
            } else{
                document.getElementById("nextButton").style.visibility = "hidden";
            }
        }            
    }
})