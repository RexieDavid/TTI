({
    getProductCategoryImages: function(component) {
        let action = component.get("c.getCategoryImages");
        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                let categoryImageMap = {};
                let categoryOrderMap = {};
                let categoryImagesList = response.getReturnValue();
                categoryImagesList.forEach(el => {
                    categoryImageMap[el.External_Id__c] = el.Image_URL__c;
                    categoryOrderMap[el.External_Id__c] = el.Display_Order__c;
                });

                component.set("v.categoryImageMap", categoryImageMap);
                component.set("v.categoryOrderMap", categoryOrderMap);
            }
        });
        $A.enqueueAction(action);
    },

    getDefaultSNDisplay: function(component) {
        let action = component.get("c.getDefaultSerialNumerDisplay");
        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                component.set("v.defaultSerialNumberDisplay", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },

    getSiteBrand: function(component) {
        let action = component.get("c.getSiteBrand");
        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                component.set('v.siteBrand', response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },

    //call the apex controlled method to retrieve the applicable products from the database
    getProducts: function(component) {
        var action = component.get("c.getProducts");
        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                let result = response.getReturnValue();
                result.forEach(element => {
                    element.custom = {
                        label: element.Customer_Facing_Name__c + ' - ' + element.ProductCode
                    };

                    if (element.Kit_Products__r) {
                        element.Kit_Products__r.forEach(el => {
                            el.custom = {
                                label: `${el.Quantity__c} X ${el.Kit_Tool__r.Customer_Facing_Name__c} - ${el.Kit_Tool__r.ProductCode}`
                            }
                        });
                    }
                });
                component.set('v.hasResult', result && result.length > 0);
                component.set('v.productsList', result);
                component.set('v.payload', result);
                this.setupProducts(component, '', 1);
            }
        });
        $A.enqueueAction(action);
    },

    setupProducts: function(component, selectedCategory, newLevel) {
        const siteBrand = component.get('v.siteBrand')
        let productsCategoriesList = {};
        let categoryLevelsList = component.get('v.categoryLevelsList');
        let categoryLevel = `${siteBrand}_LVL${newLevel}`;
        let payload = component.get('v.payload');
        let categoryImageMap = component.get('v.categoryImageMap');
        let categoryOrderMap = component.get('v.categoryOrderMap');
        payload = payload.filter(el => newLevel === 1 ? true : el[`Category_Customer_Level${newLevel - 1}__c`].indexOf(selectedCategory) != -1);
        payload = payload.forEach(el => {
            let isValid = !!(newLevel === 2 ? el.Category_Customer_Level1__c :
                                newLevel === 3 ? el.Category_Customer_Level1__c && el.Category_Customer_Level2__c : true);

            let fieldValue = el[`Category_Customer_Level${newLevel}__c`];
            if (isValid) {
                if (newLevel < 3 && fieldValue) {
                    fieldValue.split(';').forEach(cat => {
                        if (!productsCategoriesList[`${categoryLevel}_${cat}`]) {
                            productsCategoriesList[`${categoryLevel}_${cat}`] = {
                                name: cat,
                                imageUrl: categoryImageMap[`${categoryLevel}_${cat}`],
                                displayOrder: categoryOrderMap[`${categoryLevel}_${cat}`]
                            };
                        }
                    });
                } else {
                    productsCategoriesList[el.Customer_Facing_Name__c] = {
                        Id: el.Id,
                        name: el.Customer_Facing_Name__c,
                        imageUrl: el.Image_URL__c
                    };
                }

            }
        });
        productsCategoriesList = Object.values(productsCategoriesList).sort((a, b) => !a.displayOrder ? 1 :
                                                                                !b.displayOrder ? -1 :
                                                                                    a.displayOrder > b.displayOrder ? 1 :
                                                                                        a.displayOrder < b.displayOrder ? -1 : 0);
        
        if (selectedCategory) {
            categoryLevelsList = [...categoryLevelsList, selectedCategory];
            component.set('v.categoryLevel', newLevel);
            component.set('v.isLastCategory', newLevel === 3);
            component.set('v.categoryLevelsList', categoryLevelsList.splice(0, newLevel));
        }
        
        component.set('v.productsCategoriesList', productsCategoriesList);
        component.set('v.isLoaded', true);
    },

    closeDropdown: function(component, event) {
        let listbox = component.find('productsList');
        $A.util.addClass(listbox, 'slds-hide');
    }
})