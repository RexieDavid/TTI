({
    populatePartsOrderedMethod: function(component, event, helper) {
        var SOHRAGStatusList = component.get("v.SOHRAGStatusList");
        var Service_Request_Case = component.get("v.Service_Request_Case");
        var SOH_Units = Service_Request_Case.Product_Name__r.SOH_BP01__c;
        var userType = component.get("v.userType");
        var action = component.get("c.getServiceReqLineItem");
        action.setParams({
            "caseNumber": component.get("v.Service_Request_Case").Id
        })
        action.setCallback(this, function(response) {
            if (response.getState() == 'SUCCESS' && response.getReturnValue() != null) {
                var serviceReqLineItm = JSON.parse(response.getReturnValue());
                debugger;
                
                for (var i = 0; i < serviceReqLineItm.length; i++) {
                    var SOH_Units;
                    SOH_Units = serviceReqLineItm[i].Part_Number__r.SOH_BP01__c;
                    console.log('TTI_PartsOrderedController.js -> SOH_Units', SOH_Units);
                    /*if (userType.Account.Internal_Service_Agent__c == false) {
                        SOH_Units = serviceReqLineItm[i].Part_Number__r.SOH_BP01__c;
                        console.log('EXTERNAL SERVICE AGENT DETECTED!!!');
                        console.log('SOH_Units = serviceReqLineItm[' + i + '].Part_Number__r.SOH_BP01__c -> ' + SOH_Units);
                    } else {
                        console.log('INTERNAL SERVICE AGENT DETECTED!!!');
                        if (userType.Account.Delivery_Country__c == 'Australia' && userType.Account.Delivery_State__c == 'NSW') {
                            SOH_Units = serviceReqLineItm[i].Part_Number__r.SOH_BP05__c;
                            console.log('SOH_Units = serviceReqLineItm[' + i + '].Part_Number__r.SOH_BP05__c -> ' + SOH_Units);
                        } else {
                            SOH_Units = serviceReqLineItm[i].Part_Number__r.SOH_BP06__c;
                            console.log('SOH_Units = serviceReqLineItm[' + i + '].Part_Number__r.SOH_BP06__c -> ' + SOH_Units);
                        }
                    }*/
                    for (var j = 0; j < SOHRAGStatusList.length; j++) {
                        if (SOH_Units > SOHRAGStatusList[j].MinSOHRange__c && SOH_Units <= SOHRAGStatusList[j].MaxSOHRange__c) {
                            serviceReqLineItm[i].status = SOHRAGStatusList[j].Name;
                            console.log('serviceReqLineItm[' + i + '].status -> ' + serviceReqLineItm[i].status);
                            break;
                        }
                    }
                }
                component.set("v.Service_Request_Line_Item", serviceReqLineItm);
            }
        });
        $A.enqueueAction(action);
    },
    quantityChanged: function(component, event, helper) {
        var source = event.getSource();
        var value = source.get("v.value");
        var index = source.get("v.labelClass");
        var lstServiceReqLineItem = component.get("v.Service_Request_Line_Item");
        lstServiceReqLineItem[index].Total_Value__c = lstServiceReqLineItem[index].Unit_Cost__c * lstServiceReqLineItem[index].Quantity__c;
        component.set("v.Service_Request_Line_Item", lstServiceReqLineItem);
    },
    RemoveRow: function(component, event, helper) {
        var source = event.getSource();
        var value = source.get("v.value");
        var index = source.get("v.labelClass");
        var lstServiceReqLineItem = component.get("v.Service_Request_Line_Item");
        var partsOrderedListToRemove = component.get("v.partsOrderedListToRemove");
        partsOrderedListToRemove.push(lstServiceReqLineItem[index]);
        component.set("v.partsOrderedListToRemove", partsOrderedListToRemove);
        lstServiceReqLineItem.splice(index, 1);
        component.set("v.Service_Request_Line_Item", lstServiceReqLineItem);
    },
    toggleSection: function(component, event, helper) {
        var acc = component.find("section");
        for (var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-hide');
        }
    }
})