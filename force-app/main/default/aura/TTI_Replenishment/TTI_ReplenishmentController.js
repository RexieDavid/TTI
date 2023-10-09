({
    doInit: function (component, event, helper) {
        //Update Order Parts predictive filter
        let orderPartsSOQLFilter = 'Kit__c = FALSE AND IsActive=true AND ProductCode LIKE :searchString';
        var mySpinner = component.find("mySpinner");
        $A.util.removeClass(mySpinner, "slds-hide");
        var objReplenishmentHeader = component.get("v.objReplenishmentHeader");
        objReplenishmentHeader = {};
        objReplenishmentHeader.sobjectType = 'TTI_Replenishment_Header__c';
        objReplenishmentHeader.TTI_Status__c = 'Pending';
        component.set("v.objReplenishmentHeader", objReplenishmentHeader);
        var action = component.get("c.getSOHRAGStatusCustomSetting");
        action.setCallback(this, function (response) {
            if (response != null && response.getState() == 'SUCCESS') {
                component.set("v.SOHRAGStatusList", JSON.parse(response.getReturnValue()));
                $A.enqueueAction(action1);
            }
        });

        var action1 = component.get("c.getUserType");
        action1.setParams({
            "userId": $A.get("$SObjectType.CurrentUser.Id")
        })
        action1.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS') {
                let userType = response.getReturnValue();
                if (userType.Account.Company_Code__c) {
                    orderPartsSOQLFilter += (' AND ' + (userType.Account.Company_Code__c === 'NZ01' ? 'NZ_MRPty__c' : 'AU_MRPty__c') + " NOT IN ('ZP', 'ZN', 'ND', 'ZL', 'ZR')");
                }
                if (component.get("v.recordId")) {
                    $A.enqueueAction(action2);
                } else {
                    $A.util.addClass(mySpinner, "slds-hide");
                }
                component.set("v.userType", userType);
                component.set('v.orderPartsSOQLFilter', orderPartsSOQLFilter);
            }
        });

        var action2 = component.get("c.fetchReplenishmentRecord");
        action2.setParams({
            "recordId": component.get("v.recordId")
        })
        action2.setCallback(this, function (response) {
            let result = response.getReturnValue();
            var listLineItems = result.Replenishment_Line_Items__r;
            var SOHRAGStatusList = component.get("v.SOHRAGStatusList");
            const userType = component.get("v.userType");

            if (listLineItems != null && listLineItems.length > 0) {
                for (var i = 0; i < listLineItems.length; i++) {
                    if (listLineItems[i].TTI_Product_Number__r) {
                        listLineItems[i].Description = listLineItems[i].TTI_Product_Number__r.Description;
                        // var SOH_Units = listLineItems[i].TTI_Product_Number__r.SOH_BP01__c;
                        var SOH_Units = helper.getStockOnHand(userType, listLineItems[i].TTI_Product_Number__r);
                        if (SOHRAGStatusList != null) {
                            if (SOHRAGStatusList.length > 0) {
                                for (var j = 0; j < SOHRAGStatusList.length; j++) {
                                    if (SOH_Units >= SOHRAGStatusList[j].MinSOHRange__c && SOH_Units <= SOHRAGStatusList[j].MaxSOHRange__c) {
                                        listLineItems[i].status = SOHRAGStatusList[j].Name;
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }
            }

            component.set("v.objReplenishmentHeader", result);
            component.set("v.lstReplenishmentLineItem", listLineItems);
            $A.util.addClass(mySpinner, "slds-hide");
        });

        $A.enqueueAction(action);
    },
    addRowInOrderPartsTable: function (component, event, helper) {
        var lstReplenishmentLineItem = component.get("v.lstReplenishmentLineItem");
        var objReplenishment = {};
        objReplenishment.sobjectType = 'TTI_Replenishment_Line_Item__c';
        objReplenishment.TTI_Quantity__c = 1;
        objReplenishment.TTI_Total_Cost__c = 0;
        lstReplenishmentLineItem.push(objReplenishment);
        component.set("v.lstReplenishmentLineItem", lstReplenishmentLineItem);
    },
    removeRowInOrderPartsTable: function (component, event, helper) {
        var lstReplenishmentLineItem = component.get("v.lstReplenishmentLineItem");
        var source = event.getSource();
        var index = source.get("v.labelClass");
        var lstRemoveReplenishmentLineItem = component.get("v.lstRemoveReplenishmentLineItem");
        lstRemoveReplenishmentLineItem.push(lstReplenishmentLineItem[index]);
        component.set("v.lstRemoveReplenishmentLineItem", lstRemoveReplenishmentLineItem);
        lstReplenishmentLineItem.splice(index, 1);
        component.set("v.lstReplenishmentLineItem", lstReplenishmentLineItem);
    },
    populatePredictiveFields: function (component, event, helper) {
        var selectedObj = event.getParam("sObject");
        var SobjectLabel = event.getParam("SobjectLabel");
        var userType = component.get("v.userType");
        if (SobjectLabel == 'SKU') {
            var index = event.getParam("objectIndexInList");
            var lstReplenishmentLineItem = component.get("v.lstReplenishmentLineItem");
            lstReplenishmentLineItem[index].Description = selectedObj.Description;
            lstReplenishmentLineItem[index].TTI_Quantity__c = 1;
            // var SOH_Units = selectedObj.SOH_BP01__c;
            var SOH_Units = helper.getStockOnHand(userType, selectedObj);
            var deliveryCountry = userType.Account.Delivery_Country__c;
            deliveryCountry = deliveryCountry.toLowerCase();
            if (deliveryCountry == 'australia') {
                lstReplenishmentLineItem[index].TTI_Unit_Cost__c = selectedObj.AU_ListPrice__c;
            } else if (deliveryCountry == 'new zealand') {
                lstReplenishmentLineItem[index].TTI_Unit_Cost__c = selectedObj.NZ_ListPrice__c;
            } else {
                lstReplenishmentLineItem[index].TTI_Unit_Cost__c = 0;
            }
            lstReplenishmentLineItem[index].TTI_Total_Cost__c = lstReplenishmentLineItem[index].TTI_Unit_Cost__c * lstReplenishmentLineItem[index].TTI_Quantity__c;
            lstReplenishmentLineItem[index].TTI_Product_Number__c = selectedObj.Id;
            lstReplenishmentLineItem[index].TTI_SKU_Number__c = selectedObj.ProductCode;

            var SOHRAGStatusList = component.get("v.SOHRAGStatusList");

            for (var j = 0; j < SOHRAGStatusList.length; j++) {
                if (SOH_Units >= SOHRAGStatusList[j].MinSOHRange__c && SOH_Units <= SOHRAGStatusList[j].MaxSOHRange__c) {
                    lstReplenishmentLineItem[index].status = SOHRAGStatusList[j].Name;
                    break;
                }
            }
            component.set("v.lstReplenishmentLineItem", lstReplenishmentLineItem);
        } else if (SobjectLabel == 'Model') {
            component.set("v.selectedModel", selectedObj);
            component.set("v.technicalDrawingURL", selectedObj.Technical_Drawing_URL__c)
        }
    },
    quantityChanged: function (component, event, helper) {
        var source = event.getSource();
        var value = source.get("v.value");
        var index = source.get("v.labelClass");
        var lstReplenishmentLineItem = component.get("v.lstReplenishmentLineItem");
        lstReplenishmentLineItem[index].TTI_Total_Cost__c = lstReplenishmentLineItem[index].TTI_Unit_Cost__c * lstReplenishmentLineItem[index].TTI_Quantity__c;
        lstReplenishmentLineItem[index].TTI_Total_Cost__c = lstReplenishmentLineItem[index].TTI_Total_Cost__c.toFixed(2);
        component.set("v.lstReplenishmentLineItem", lstReplenishmentLineItem);
    },
    saveClicked: function (component, event, helper) {
        if (!helper.checkValidations(component)) {
            return;
        }

        var mySpinner = component.find("mySpinner");
        $A.util.removeClass(mySpinner, "slds-hide");
        var lstReplenishmentLineItem = component.get("v.lstReplenishmentLineItem");
        var objReplenishmentHeader = component.get("v.objReplenishmentHeader");

        delete objReplenishmentHeader.Replenishment_Line_Items__r;
        helper.createPayLoad(lstReplenishmentLineItem, objReplenishmentHeader, component);
        var source = event.getSource();
        var buttonName = source.get("v.label");
        if (buttonName == 'SUBMIT') {
            objReplenishmentHeader.TTI_Status__c = 'Submitted';
        }
        var saveAction = component.get("c.saveReplishmentHeaderAndItsLineItem");
        saveAction.setParams({
            "objReplenishmentHeaderStr": JSON.stringify(objReplenishmentHeader),
            "lstReplenishmentLineItemStr": JSON.stringify(lstReplenishmentLineItem),
            "lstRemoveReplenishmentLineItemStr": JSON.stringify(component.get("v.lstRemoveReplenishmentLineItem"))

        });
        saveAction.setCallback(this, function (response) {
            var utilityMethods = component.find("utilityMethods");
            if (buttonName == 'SUBMIT') {
                utilityMethods.showToast(
                    '',
                    component.get("v.toastMessageSuccessSubmitReplenishment"),
                    'Success',
                    '',
                    5000
                );
            } else {
                utilityMethods.showToast(
                    '',
                    component.get("v.toastMessageSuccessSavedReplenishment"),
                    'Success',
                    '',
                    5000
                );
            }
            $A.util.addClass(mySpinner, "slds-hide");
            component.set("v.recordId", response.getReturnValue());

            component.find("navigationService").navigate({    
                type: "standard__objectPage",
                attributes: {
                    objectApiName: "TTI_Replenishment_Header__c",
                    actionName: "list"
                },
                state: {
                    filterName: "00B9000000AMyQF" // This list view has the same Id accross different environments
                }
            });
        });
        if (buttonName == 'SUBMIT') {
            if (window.confirm(component.get("v.confirmMessageReplenishmentOrder"))) {
                $A.enqueueAction(saveAction);
            } else {
                $A.util.addClass(mySpinner, "slds-hide");
            }
        } else {
            $A.enqueueAction(saveAction);
        }
    },
    searchClicked: function (component, event, helper) {
        var mySpinner = component.find("mySpinner");
        var userType = component.get("v.userType");
        var selectedModel = component.get("v.selectedModel");
        $A.util.removeClass(mySpinner, "slds-hide");
        var action = component.get("c.fetchBillOfMaterials");
        action.setParams({
            "productToolId": (selectedModel ? selectedModel.Id : '')
        });
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS' && response.getReturnValue() != null) {
                var billOfMaterials = response.getReturnValue();

                var SOHRAGStatusList = component.get("v.SOHRAGStatusList");
                for (var i = 0; i < billOfMaterials.length; i++) {
                    var SOH_Units = billOfMaterials[i].ProductPart__r.SOH_SP01__c || 0;
                    for (var j = 0; j < SOHRAGStatusList.length; j++) {
                        if (SOH_Units >= SOHRAGStatusList[j].MinSOHRange__c && SOH_Units <= SOHRAGStatusList[j].MaxSOHRange__c) {
                            billOfMaterials[i].status = SOHRAGStatusList[j].Name;
                            break;
                        }
                    }
                }
                component.set("v.BillOfMaterials", billOfMaterials);
                $A.util.addClass(mySpinner, "slds-hide");
            }
        });
        if (selectedModel != null && selectedModel != undefined) {
            component.set("v.warnings", null);
            $A.enqueueAction(action);
        }
    },
    addBillOfMaterials: function (component, event, helper) {
        var mySpinner = component.find("mySpinner");
        $A.util.removeClass(mySpinner, "slds-hide");
        var lstReplenishmentLineItem = component.get("v.lstReplenishmentLineItem");
        var billOfMaterials = component.get("v.BillOfMaterials");
        if (billOfMaterials.length == 0) {
            $A.util.addClass(mySpinner, "slds-hide");
            return;
        }
        var userType = component.get("v.userType");
        var hasSelectedPart = false;
        for (var i = 0; i < billOfMaterials.length; i++) {
            if (billOfMaterials[i].checked) {
                var objReplenishment = {};
                objReplenishment.sobjectType = 'TTI_Replenishment_Line_Item__c';
                objReplenishment.Bin = billOfMaterials[i].Bin;
                objReplenishment.Description = billOfMaterials[i].ProductPart__r.Description;
                var deliveryCountry = userType.Account.Delivery_Country__c;
                if (deliveryCountry == 'Australia') {
                    objReplenishment.TTI_Unit_Cost__c = billOfMaterials[i].ProductPart__r.AU_ListPrice__c;
                } else if (deliveryCountry == 'New Zealand') {
                    objReplenishment.TTI_Unit_Cost__c = billOfMaterials[i].ProductPart__r.NZ_ListPrice__c;
                } else {
                    objReplenishment.TTI_Unit_Cost__c = 0;
                }
                objReplenishment.TTI_Product_Number__c = billOfMaterials[i].ProductPart__c;
                objReplenishment.TTI_SKU_Number__c = billOfMaterials[i].ProductPart__r.ProductCode;
                objReplenishment.status = billOfMaterials[i].status;
                objReplenishment.TTI_Quantity__c = billOfMaterials[i].Quantity__c;
                objReplenishment.TTI_Total_Cost__c = objReplenishment.TTI_Unit_Cost__c * objReplenishment.TTI_Quantity__c;
                lstReplenishmentLineItem.push(objReplenishment);
                hasSelectedPart = true;

            }
        }
        component.set("v.lstReplenishmentLineItem", lstReplenishmentLineItem);
        helper.resetProductSearch(component);
        $A.util.addClass(mySpinner, "slds-hide");
        window.scrollTo(0, 0);

        if (hasSelectedPart) {
            var utilityMethods = component.find("utilityMethods");
            utilityMethods.showToast(
                "Success!",
                component.get("v.toastMessagePartsSuccessAddedToOrder"),
                "Success",
                '',
                5000
            );
        }
    },
    updateTotalValueOrder: function (component, event, helper) {
        var lstItems = event.getParam("value");
        var totalCost = 0;
        for (var i = 0; i < lstItems.length; i++) {
            totalCost = parseFloat(totalCost) + parseFloat(lstItems[i].TTI_Total_Cost__c);
        }
        totalCost = totalCost.toFixed(2);
        component.set("v.totalValueOfOrder", totalCost);
    },
    cancelClicked: function () {
        if (window.confirm(component.get("v.confirmLeaveWithoutSavingChanges"))) {
            var homeEvent = $A.get("e.force:navigateToObjectHome");
            homeEvent.setParams({
                "scope": "TTI_Replenishment_Header__c"
            });
            homeEvent.fire();
        }
    },
    toggleSection: function (component, event, helper) {
        var acc = component.find("section");
        for (var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-hide');
        }
    }
})