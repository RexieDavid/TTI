({
    doInit: function(component, event, helper) {
        var action = component.get("c.getDummyObj");
        action.setCallback(this, function(response) {
            if (response.getState() == 'SUCCESS') {
                component.set("v.DummyObj", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    addRow: function(component, event, helper) {
        var ServiceReqLineItems = component.get("v.ServiceReqLineItems");
        var dummyObj = component.get("v.DummyObj");
        dummyObj.Quantity__c = 1;
        ServiceReqLineItems.push(JSON.parse(JSON.stringify(dummyObj)));
        component.set("v.ServiceReqLineItems", ServiceReqLineItems);
    },
    RemoveRow: function(component, event, helper) {
        var source = event.getSource();
        var value = source.get("v.value");
        var index = source.get("v.labelClass");
        var lstServiceReqLineItem = component.get("v.ServiceReqLineItems");
        lstServiceReqLineItem.splice(index, 1);
        component.set("v.ServiceReqLineItems", lstServiceReqLineItem);
        var ProductList = component.get("v.ProductList");
        ProductList.splice(index, 1);
        var hasHawa = false;
        if(ProductList.length != 0) {
            for(var i = 0; i < ProductList.length; i++) {
                if(ProductList[i].SAP_Material_Type__c == "HAWA") {
                    hasHawa = true;
                }
            }  
        }
        component.set("v.ProductList", ProductList);

        var serviceReqLineItemEvent = $A.get("e.c:ServiceReqLineItemsChanged");
        serviceReqLineItemEvent.setParams({ "hasHawa": hasHawa});
        serviceReqLineItemEvent.fire();      
    },
    populatePredictiveFields: function(component, event, helper) {
        var utilityMethods = component.find('utilityMethods');
        var selectedObj = event.getParam("sObject");
        var SobjectLabel = event.getParam("SobjectLabel");
        var index = event.getParam("objectIndexInList");
        var Service_Request_Case = component.get("v.Service_Request_Case");
        var lstServiceReqLineItem = component.get("v.ServiceReqLineItems");
        var userType = component.get("v.userType");

        // FNasalita Sept. 11, 2018
        // [SAL-429] - Check the product mrp type for discontinued then show error message
        var typesOfDiscontinuedProds = ['ND','ZL','ZR'];
        if((userType.Account.Company_Code__c == 'BP01' && typesOfDiscontinuedProds.includes(selectedObj.AU_MRPty__c)) ||
                userType.Account.Company_Code__c == 'NZ01' && typesOfDiscontinuedProds.includes(selectedObj.NZ_MRPty__c)) {

            utilityMethods.showToast(
                component.get("v.errToastTitleDiscontinuedProduct"), 
                component.get("v.errToastMessageDiscontinuedProduct"),
                'error', 
                'sticky',
                5000
            );

            var lstServiceReqLineItem = component.get("v.ServiceReqLineItems");
            lstServiceReqLineItem.splice(index, 1);
            component.set("v.ServiceReqLineItems", lstServiceReqLineItem);
            return false;
        }

        lstServiceReqLineItem[index].Part_Number__c = selectedObj.Id;
        lstServiceReqLineItem[index].Line_Item_Description__c = selectedObj.Description;
        lstServiceReqLineItem[index].SKU_Number__c = selectedObj.ProductCode;
        lstServiceReqLineItem[index].SKU_Number__c = selectedObj.ProductCode;
        var SOH_Units = selectedObj.SOH_BP01__c;
        console.log('TTI_OrderPartsNotBillController.js -> SOH_Units', SOH_Units);
        /*if (userType.Account.Internal_Service_Agent__c == false) {
            lstServiceReqLineItem[index].Bin = '';
            SOH_Units = selectedObj.SOH_BP01__c;
        } else {
            if (userType.Account.Delivery_Country__c == 'Australia' && userType.Account.Delivery_State__c == 'NSW') {
                lstServiceReqLineItem[index].Bin = selectedObj.BP05_Bin__c;
                SOH_Units = selectedObj.SOH_BP05__c;
            } else {
                lstServiceReqLineItem[index].Bin = selectedObj.BP06_Bin__c;
                SOH_Units = selectedObj.SOH_BP06__c;
            }
        }*/

        if (userType.Account.Delivery_Country__c == 'Australia' && userType.Account.Delivery_State__c == 'NSW') {
            lstServiceReqLineItem[index].Bin = selectedObj.BP05_Bin__c;
        } else if (userType.Account.Delivery_Country__c == 'New Zealand' && userType.Account.Delivery_State__c == 'AKL') {
            lstServiceReqLineItem[index].Bin = selectedObj.NZ02_Bin__c;
        } else {
            lstServiceReqLineItem[index].Bin = selectedObj.BP06_Bin__c;
        }

        if (userType.Account.Delivery_Country__c == 'Australia') {
            lstServiceReqLineItem[index].Unit_Cost__c = selectedObj.AU_Landed_Cost__c;
            lstServiceReqLineItem[index].Unit_List_Price__c = selectedObj.AU_ListPrice__c;

        } else {
            lstServiceReqLineItem[index].Unit_Cost__c = selectedObj.NZ_Landed_Cost__c;
            lstServiceReqLineItem[index].Unit_List_Price__c = selectedObj.NZ_ListPrice__c;
        }
        lstServiceReqLineItem[index].Total_Value__c = lstServiceReqLineItem[index].Unit_List_Price__c * lstServiceReqLineItem[index].Quantity__c;
        var ProductList = component.get("v.ProductList");
        ProductList.push(selectedObj);
        component.set("v.ProductList", ProductList);

        var SOHRAGStatusList = component.get("v.SOHRAGStatusList");

        for (var j = 0; j < SOHRAGStatusList.length; j++) {
            if (SOH_Units >= SOHRAGStatusList[j].MinSOHRange__c && SOH_Units <= SOHRAGStatusList[j].MaxSOHRange__c) {
                lstServiceReqLineItem[index].status = SOHRAGStatusList[j].Name;
            }
        }
        component.set("v.ServiceReqLineItems", lstServiceReqLineItem);
        
        var hasHawa = false;
        if(ProductList.length != 0) {
            for(var i = 0; i < ProductList.length; i++) {
                if(ProductList[i].SAP_Material_Type__c == "HAWA") {
                    hasHawa = true;
                }
            }      

            var serviceReqLineItemEvent = $A.get("e.c:ServiceReqLineItemsChanged");
            serviceReqLineItemEvent.setParams({ "hasHawa": hasHawa});
            serviceReqLineItemEvent.fire();      
        }        
    },
    quantityChanged: function(component, event, helper) {
        var ServiceReqLineItems = component.get("v.ServiceReqLineItems");
        var source = event.getSource();
        var index = source.get("v.labelClass");
        ServiceReqLineItems[index].Total_Value__c = ServiceReqLineItems[index].Quantity__c * ServiceReqLineItems[index].Unit_List_Price__c;
        component.set("v.ServiceReqLineItems", ServiceReqLineItems);
    },
    toggleSection: function(component, event, helper) {
        var acc = component.find("section");
        for (var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-hide');
        }
    }

})