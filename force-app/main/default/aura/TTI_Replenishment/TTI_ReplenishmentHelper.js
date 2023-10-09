({
    COMPANY_CODE: {
        AU: 'BP01',
        NZ: 'NZ01'
    },
    createPayLoad: function (lstReplenishmentLineItem, objReplenishmentHeader, component) {
        var userType = component.get("v.userType");
        objReplenishmentHeader.TTI_Service_Agent__c = userType.AccountId;
        objReplenishmentHeader.TTI_Status__c = 'Pending';

    },
    resetProductSearch: function (component) {
        component.set("v.BillOfMaterials", null);
        component.set("v.selectedModel", null);
        var modelComp = component.find("ModelCompId");
        modelComp.set("v.SelectedItemName", null);
    },
    checkValidations: function (component) {
        var objReplenishmentHeader = component.get("v.objReplenishmentHeader");
        var lstReplenishmentLineItem = component.get("v.lstReplenishmentLineItem");

        if (objReplenishmentHeader.TTI_Purchase_Order_Reference__c == '' ||
            objReplenishmentHeader.TTI_Purchase_Order_Reference__c == null) {

            component.set("v.warnings", component.get("v.errProvidePurchaseOrderReference"));
            return false;
        } else {
            if (!lstReplenishmentLineItem || !lstReplenishmentLineItem.length || !lstReplenishmentLineItem) {
                component.set("v.warnings", component.get("v.errNoProductsForReplenishment"));
                return false;
            } else {
                for (var i = 0; i < lstReplenishmentLineItem.length; i++) {
                    if (lstReplenishmentLineItem[i].TTI_Quantity__c <= 0) {
                        component.set("v.warnings", component.get("v.errInvalidQuantityForReplenishment"));
                        return false;
                    }
                        if(lstReplenishmentLineItem[i].Description == null){
                            component.set("v.warnings","Please choose the correct SKU number from the list");
                            return false;
                        }
                }
            }
        }

        component.set("v.warnings", null);
        return true;
    },
    getStockOnHand: function(userType, product) {
        const { Company_Code__c } = userType;
        const { SAP_Material_Group__c, SOH_BP01__c, SOH_NZ01__c, SOH_SP01__c } = product;
        const isNZAgent = Company_Code__c === this.COMPANY_CODE.NZ;
        const spareParts = /-(SP)$/;
        const isSpareParts = spareParts.test(SAP_Material_Group__c);
        let stockOnHand = isNZAgent ? SOH_NZ01__c : SOH_BP01__c;
        
        if (isSpareParts) {
            stockOnHand = SOH_SP01__c;
        }

        return stockOnHand;
    }
})