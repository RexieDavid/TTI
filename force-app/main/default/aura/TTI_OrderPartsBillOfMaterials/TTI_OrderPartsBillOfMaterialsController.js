({
    doInit: function(component, event, helper) {
        var companyCode = component.get("v.userType.Account.Company_Code__c");
        var action = component.get("c.getFieldDependencies");
        action.setParams({
            "objectName": 'Case',
            "controllingField": 'Product_Fault_Category__c',
            "dependentField": 'Fault_Codes__c'
        });
        action.setCallback(this, function(response) {
            if (response.getState() == 'SUCCESS') {
                component.set("v.FaultCodePicklistValuesMap", response.getReturnValue());

                var userType = component.get("v.userType");
                var SOHRAGStatusList = component.get("v.SOHRAGStatusList");
                var getProductPartsJS = component.get("c.getProductParts");

                getProductPartsJS.setParams({
                    "productTool": component.get("v.Service_Request_Case").Product_Name__c
                });
                getProductPartsJS.setCallback(this, function(response) {
                    if (response.getState() == 'SUCCESS' && response.getReturnValue() != null) {
                        component.populateFaultCodes();
                        var ProdPartWrapper = [];
                        var ProdPart = JSON.parse(response.getReturnValue());
                        var Service_Request_Case = component.get("v.Service_Request_Case");
                        
                        for (var i = 0; i < ProdPart.length; i++) {
                            ProdPart[i].Quantity__c = 1;
                            if (userType.Account.Delivery_Country__c == 'Australia') {
                                ProdPart[i].Unit_Cost__c = ProdPart[i].ProductPart__r.AU_Landed_Cost__c;
                                ProdPart[i].Unit_List_Price__c = ProdPart[i].ProductPart__r.AU_ListPrice__c;
                            } else {
                                ProdPart[i].Unit_Cost__c = ProdPart[i].ProductPart__r.NZ_Landed_Cost__c;
                                ProdPart[i].Unit_List_Price__c = ProdPart[i].ProductPart__r.NZ_ListPrice__c;
                            }
                            ProdPart[i].ListPrice = ProdPart[i].Unit_List_Price__c;
                            var Units = ProdPart[i].ProductPart__r.SOH_BP01__c;
                            /*if (userType.Account.Internal_Service_Agent__c == false) {
                                Units = ProdPart[i].ProductPart__r.SOH_BP01__c;
                            } else {
                                if (userType.Account.Delivery_Country__c == 'Australia' && userType.Account.Delivery_State__c == 'NSW') {
                                    Units = ProdPart[i].ProductPart__r.SOH_BP05__c;
                                } else {
                                    Units = ProdPart[i].ProductPart__r.SOH_BP06__c;
                                }
                            }*/
                            for (var j = 0; j < SOHRAGStatusList.length; j++) {
                                if (Units >= SOHRAGStatusList[j].MinSOHRange__c && Units <= SOHRAGStatusList[j].MaxSOHRange__c) {
                                    ProdPart[i].status = SOHRAGStatusList[j].Name;
                                    break;
                                }
                            }

                            // Francis Nasalita - April 4 2019
                            // Discontinued Products
                            var typesOfDiscontinuedProds = ['ND','ZL','ZR'];
                            var ProdPartWrapperItem = {};
                            ProdPartWrapperItem.ProdPart = ProdPart[i];
                            if(companyCode == 'BP01' && typesOfDiscontinuedProds.includes(ProdPart[i].ProductPart__r.AU_MRPty__c)) ProdPartWrapperItem.isDiscontinuedProduct = true;
                            if(companyCode == 'NZ01' && typesOfDiscontinuedProds.includes(ProdPart[i].ProductPart__r.NZ_MRPty__c)) ProdPartWrapperItem.isDiscontinuedProduct = true;
                            ProdPartWrapper.push(ProdPartWrapperItem);
                        }
                        component.set("v.ProductParts", ProdPart);
                        component.set("v.ProductPartsWrapper", ProdPartWrapper);
                    }
                });
                $A.enqueueAction(getProductPartsJS);
            }
        });
        $A.enqueueAction(action);
    },
    populateFaultCodesMethod: function(component, event, helper) {
        var FaultCodePicklistValuesMap = component.get("v.FaultCodePicklistValuesMap");
        var FaultCodePicklistValues = FaultCodePicklistValuesMap[component.get("v.Service_Request_Case.Product_Fault_Category__c")];
        component.set("v.FaultCodePicklistValues", FaultCodePicklistValues);
        component.set("v.FaultCodePicklistValuesActive", true);
    },
    populateProdPartsMethod: function(component, event, helper) {
        
    },
    toggleSection: function(component, event, helper) {
        var acc = component.find("section");
        for (var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-hide');
        }
    },
    quantityChanged: function(component, event, helper) {
        var ProductParts = component.get("v.ProductParts");
        var source = event.getSource();
        var index = source.get("v.labelClass");
        ProductParts[index].ListPrice = ProductParts[index].Quantity__c * ProductParts[index].Unit_List_Price__c;
        component.set("v.ProductParts", ProductParts);
    },
    // Francis C. Nasalita - [SP-840] - 2018/11/13
    faultCodeChanged: function(component) {
        $A.get("e.c:SP_FaultCodeChangeEvent").fire();
    },
})