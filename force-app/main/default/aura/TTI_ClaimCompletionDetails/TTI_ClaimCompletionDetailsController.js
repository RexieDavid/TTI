({
    doInit : function(component, event, helper) {
        var action=component.get("c.getFieldDependencies");
        action.setParams({
            "objectName":'Case',
            "controllingField":'Product_Payment_Category__c',
            "dependentField":'Repair_Type__c'
        });
        action.setCallback(this,function(response){
            if(response.getState()=='SUCCESS')
            {
                component.set("v.RepairTypePicklistValuesMap",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);


    },
    populateRepairTypeMethod:function(component,event,helper)
    {  
        // Francis C. Nasalita - [SP-840] - 2018/11/13
        helper.populateRepairType(component);

        var ServiceReqCase = component.get("v.Service_Request_Case");
        var serviceRequestHasHAWAProductsJS = component.get("c.serviceRequestHasHAWAProducts");
        serviceRequestHasHAWAProductsJS.setParams({
            "caseNumber": ServiceReqCase.CaseNumber
        });
        serviceRequestHasHAWAProductsJS.setCallback(this, function(response) {
            if (response.getState() == 'SUCCESS') {
                if(response.getReturnValue() == true) {

                    var RepairTypePicklistValues = component.get("v.RepairTypePicklistValues");
                    debugger;
                    if(RepairTypePicklistValues.length > 0) {
                        for(var i = 0; i < RepairTypePicklistValues.length; i++) {
                            if(RepairTypePicklistValues[i] == 'Repair') {
                                RepairTypePicklistValues.splice(i, 1);
                            }
                        }

                        component.set("v.RepairTypePicklistValues",RepairTypePicklistValues);
                    }
                }
            }
        }); 

        $A.enqueueAction(serviceRequestHasHAWAProductsJS);       
    },
    
    // Francis C. Nasalita - [SP-840] - 2018/11/13
    faultCodeChangeMethod: function(component, event, helper) {
        helper.populateRepairType(component);
    },

    deliveryPicklistChange : function(component, event, helper) {
        var source=event.getSource();
        var val=source.get("v.value");
        
        if(val=='Pickup from Service Agent')
        {
            component.set("v.Service_Request_Case.TTI_Freight_Out_Delivery_Address__c",'');
            component.set("v.Service_Request_Case.TTI_Freight_Out_Delivery_Suburb__c",'');
            component.set("v.Service_Request_Case.TTI_Freight_Out_Delivery_Postcode__c",'');
            component.set("v.Service_Request_Case.TTI_Freight_Out_Delivery_State__c",'');
            component.set("v.Service_Request_Case.TTI_Freight_Out_Delivery_Country__c",'');
        }
        
    },
    toggleSection:function(component,event,helper)
    {
        var acc = component.find("section");
        for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-hide');  
        }
    },

    checkServiceReqLineItems : function(component, event, helper) {
        var hasHawa = event.getParam('hasHawa');
        debugger

        if(hasHawa == true) {
            var RepairTypePicklistValues = component.get("v.RepairTypePicklistValues");

            if(RepairTypePicklistValues.length > 0) {
                for(var i = 0; i < RepairTypePicklistValues.length; i++) {
                    if(RepairTypePicklistValues[i] == 'Repair') {
                        RepairTypePicklistValues.splice(i, 1);
                    }
                }

                component.set("v.RepairTypePicklistValues",RepairTypePicklistValues);
            }
        } else {
            var RepairTypePicklistValuesMap=component.get("v.RepairTypePicklistValuesMap");
            var RepairTypePicklistValues=RepairTypePicklistValuesMap[component.get("v.Service_Request_Case.Product_Payment_Category__c")];
            debugger
            component.set("v.RepairTypePicklistValues",RepairTypePicklistValues);
        }
    }
})