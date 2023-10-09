({
    hideComponent: function(component) {
        $A.util.removeClass(component, 'slds-show');
        $A.util.addClass(component, 'slds-hide');
    },
    
    showComponent: function(component) {
        $A.util.removeClass(component, 'slds-hide');
        $A.util.addClass(component, 'slds-show');
    },
    
    addHideCSS: function(component) {
        $A.util.addClass(component, 'slds-hide');
    },
    
    removeHideCSS: function(component) {
        $A.util.removeClass(component, 'slds-hide');
    },
    
    refreshTables: function(component) {
        var tableRefreshEvent = $A.get('e.c:TableRefreshEvent');
        tableRefreshEvent.fire();
    },
    
    toggleSpinner: function(component) {
        var toggleSpinner = $A.get("e.c:ToggleSpinner");
        toggleSpinner.fire();
    },
    
    navigateTo: function(component, target) {
        var navEvent = $A.get("e.c:NavigateEvent");
        navEvent.setParams({ "Target": target });
        navEvent.fire();
    },
    
    validateForm: function(component, inputProvince, inputPostalCode, inputStreet, inputCity) {
        self = this;
        var hasError = false;
        var errorMsg;
        var errorCounter = 0;
        
        if(inputStreet == null || inputStreet == '' || inputStreet == ' ') {
            errorMsg = 'Enter Address';
            hasError = true;
            errorCounter++;
        }
        
        if(inputCity == null || inputCity == '' || inputCity == ' ') {
            errorMsg = 'Enter Suburb';
            hasError = true;
            errorCounter++;
        }  
        
        if (inputProvince == '-- None --' || inputProvince == null) {
            errorMsg = 'Please choose a state.';
            hasError = true;
            errorCounter++;
        }
        
        if(inputPostalCode === '' || inputPostalCode === ' ' || inputPostalCode === null) {
            errorMsg = 'Enter Postcode.';
            hasError = true;
            errorCounter++;
        } else {
            if (isNaN(inputPostalCode)) {
                errorMsg = 'Number only for postcode.';
                hasError = true;
            }
            if(inputPostalCode.length > 4) {
                errorMsg = 'Maximum of 4 digits for postcode.';
                hasError = true;
            }
        }      
        
        if(hasError) {
            if(errorCounter == 4) {
                errorMsg = 'Enter Address';
            }
            component.set('v.errorMsg', errorMsg);
            self.toggleSpinner();
            return false;
        } else {
            return true;
        }        
    },
    displayPredictions: function (component, searchString) {
        
        var selectedCountry;
        var commName = component.get("v.siteSettings");   
        
        if(commName.Lead_Source__c == 'MYAEG'){
            selectedCountry = 'au';
        }
        if(commName.Lead_Source__c == 'MYAEGNZ') {
            selectedCountry = 'nz';
        }
        var action = component.get("c.getAddressAutoComplete");   
        action.setParams({   
            "input": searchString,
            "countryname": selectedCountry
        });
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var options = JSON.parse(response.getReturnValue());    
                var predictions = options.predictions;                
                var addresses = [];
                
                if (predictions.length > 0) {                    
                    for (var i = 0; i < predictions.length; i++) {                        
                        addresses.push(
                            {
                                value: predictions[i].types[0],
                                label: predictions[i].description,
                                PlaceId: predictions[i].place_id,
                            });
                    }
                    
                    component.set("v.predictions", addresses);
                    
                }
                
            }            
        });        
        $A.enqueueAction(action);
        
    },
    
    displaySelectionDetails: function(component, placeId) {
        
        var action = component.get("c.getAddressDetails");
        
        action.setParams({            
            "PlaceId": placeId            
        });
        
        action.setCallback(this, function (response) {
            
            var state = response.getState();
            
            
            if (state === "SUCCESS") {                
                
                var option = JSON.parse(response.getReturnValue());                
                var address = option.result;                
                var key = "address_components";                
                var selection = address[key]                  
                this.insertRecords(component, selection);                
            }            
        });
        $A.enqueueAction(action);
        
        
    },
    
    insertRecords:function(component, data, phone, company){        
        //	alert(component.get('v.'));
        var commName = component.get("v.siteSettings");
        var fullstreetname = '';
        for(var prop in data) {
            
            if(commName.Lead_Source__c == 'MYAEG'){
                if (data[prop].types[0] == "locality") {                
                    component.set("v.suburb", data[prop].long_name);
                }
            }
            if(commName.Lead_Source__c == 'MYAEGNZ') {
                if (data[prop].types[0] == "sublocality_level_1") {
                    component.set("v.suburb", data[prop].long_name);
                }
            }
            
            if (data[prop].types[0] == "postal_code") {
                component.set("v.postcode", data[prop].long_name);
            }
            
            if (data[prop].types[0] == "country") {
                component.set("v.country", data[prop].long_name);
            }
            
            if (data[prop].types[0] == "administrative_area_level_1") {
                component.set("v.state", data[prop].long_name);
            }
            
            
            if (data[prop].types[0] == "street_number") {
                fullstreetname += data[prop].long_name + " "; 
            }
            if (data[prop].types[0] == "route") {
                fullstreetname += data[prop].long_name;
            }
            
            
        }
        var strSearch = component.get('v.searchString');
        var strCheckStreet = strSearch.substring(0, strSearch.indexOf(fullstreetname)); 
        if(strCheckStreet != null && strCheckStreet != '' && strCheckStreet != undefined){
            fullstreetname = strCheckStreet+fullstreetname;
        }
        component.set('v.address',fullstreetname);
        
    },
    
    openListbox: function (component, searchString) {
        
        
        var searchLookup = component.find("searchLookup");
        
        if (typeof searchString === 'undefined' || searchString.length < 2)
        {
            
            $A.util.addClass(searchLookup, 'slds-combobox-lookup');            
            $A.util.removeClass(searchLookup, 'slds-is-open');
            return;
        }
        
        $A.util.addClass(searchLookup, 'slds-is-open');        
        $A.util.removeClass(searchLookup, 'slds-combobox-lookup');
        
    },
    
    clearComponentConfig: function (component) {
        
        var searchLookup = component.find("searchLookup");        
        var iconPosition = component.find("iconPosition");       
        $A.util.addClass(searchLookup, 'slds-combobox-lookup');
        
        component.set("v.selectedOption", null);        
        component.set("v.searchString", null);        
        component.set("v.address", null);
        component.set("v.suburb", null);        
        component.set("v.state", null); 
        component.set("v.postcode", null); 
        //component.set("v.country", null);        
        
        $A.util.removeClass(iconPosition, 'slds-input-has-icon_right');        
        $A.util.addClass(iconPosition, 'slds-input-has-icon_right');
        
    },
})