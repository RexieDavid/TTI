({
    initializeView: function(component) {
        const urlParams = window.location.search.substring(1);
        if(urlParams) {
            var params = this.parseQueryString(urlParams);
            if (!$A.util.isUndefined(params['toolbagview'])) {
                component.set("v.toolbagView", params['toolbagview']);
            }
        }
    },
    
    inializeList: function(component) {
        var action = component.get("c.getRunningContactId");
        action.setCallback(this, function(response) {
            this.getAssetList(response, component);
        });
        $A.enqueueAction(action);
    },

    getAssetList: function(response, component) {
        var contactId = response.getReturnValue();
        var action = component.get("c.getAssets");
        action.setParams({
            "contactId": contactId
        });
        action.setCallback(this, function(response) {
            this.populateAssetList(response, component);
        });
        $A.enqueueAction(action);
    },

    populateAssetList: function(response, component) {
        var assetList = response.getReturnValue();
        var allAsset = [];
        for (var i = 0; i < assetList.length; i++) {
            assetList[i].Registered_Date_Formula__c = assetList[i].Registered_Date_Formula__c.substring(0, 10);
            if (assetList[i].hasOwnProperty('KitProduct__r')) {
                var kitProduct = assetList[i].KitProduct__r.Customer_Facing_Name__c;
            }
            var asset = {
                "Product2": {
                    "ProductCode": assetList[i].Product2.ProductCode,
                    "Customer_Facing_Name__c": assetList[i].Product2.Customer_Facing_Name__c
                },
                "KitProduct__r": {
                    "Customer_Facing_Name__c": kitProduct
                },
                "PurchaseDate": assetList[i].PurchaseDate,
                "FullSerialNumber__c": assetList[i].FullSerialNumber__c,
                "Total_Warranty_Years__c": assetList[i].Total_Warranty_Years__c
            };
            allAsset.push(asset);
        }
        component.set("v.assetList", assetList);
        component.set("v.allAsset", allAsset);
        component.set("v.maxPage", Math.floor((assetList.length + 9) / 10));
        this.sortBy(component, "Product2.ProductCode");
    },

    inializeRemove: function(component) {
        var action = component.get("c.getRemoveReason");
        action.setCallback(this, function(response) {
            var reasonList = response.getReturnValue();
            component.set("v.removeReasonList", reasonList);
            component.set("v.removeReason", reasonList[0]);
        });
        $A.enqueueAction(action);
    },

    initializeCustomSettings: function(component) {
        var action = component.get("c.getCommunitySettings");
        action.setCallback(this, function(response) {
            component.set("v.siteSettings", response.getReturnValue());
        });
        $A.enqueueAction(action);
    },

    setAttachment: function(component, asset) {
        var action = component.get("c.getFileId");
        var receiptId = asset.Receipt__c;
        action.setParams({
            receiptId: receiptId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var link = response.getReturnValue();
                component.set("v.attachmentLink", link);
                var ImageDisplay = component.find('ImageDisplay');
                this.toggleClasses(ImageDisplay);
            }
        });
        $A.enqueueAction(action);
    },

    removeAst: function(asset, component) {
        var removeReason = component.get("v.removeReason");
        var removeComment = component.get("v.removeComment");
        var action = component.get("c.removeUpdate");
        action.setParams({
            assets: asset,
            reason: removeReason,
            comment: removeComment
        });
        action.setCallback(this, function(response) {
            this.removeSuccessful(response, component);
        });
        $A.enqueueAction(action);
    },

    removeSuccessful: function(response, component) {
        component.set("v.removeReason", component.get("v.removeReasonList")[0]);
        component.set("v.removeComment", "");
        var res = response.getReturnValue();
        var errorDiv = component.find('errorDiv');
        var successDiv = component.find('successDiv');
        var removeDiv = component.find('removeDiv');
        let arr = [];
        if (res) {
            component.set("v.removeErrorMessage", res);
            arr.push(removeDiv, errorDiv);
        } else {
            arr.push(removeDiv, successDiv);
        }
        this.toggleClasses(arr);
    },

    sortBy: function(component, field) {
        
        var sortAsc = component.get("v.sortAsc");
        var sortField = component.get("v.sortField");
        var records = component.get("v.assetList");
        var fromNavi = component.get("v.fromNavigation"); 
        if(!fromNavi){ //RD INC0020163 12/20 Fix for List Ordering after viewing the product
            sortAsc = sortField !== field || !sortAsc;
        }

        records.sort(function(a, b) {
            var x, y;
            if (field.includes(".")) {
                var field0 = field.split(".")[0];
                var field1 = field.split(".")[1];
                x = ($A.util.isUndefinedOrNull(a[field0])) ? '' : typeof a[field0][field1] === String ? (a[field0][field1]).toLowerCase() : a[field0][field1],
                    y = ($A.util.isUndefinedOrNull(b[field0])) ? '' : typeof b[field0][field1] === String ? (b[field0][field1]).toLowerCase() : b[field0][field1];
            } else {
                x = ($A.util.isUndefinedOrNull(a[field])) ? '' : typeof a[field] === String ? a[field].toLowerCase() : a[field],
                    y = ($A.util.isUndefinedOrNull(b[field])) ? '' : typeof b[field] === String ? b[field].toLowerCase() : b[field];
            }
            if (sortAsc) {
                return x < y ? -1 : x > y ? 1 : 0;
            } else {
                return x > y ? -1 : x < y ? 1 : 0;
            }
        });
        
        component.set("v.sortAsc", sortAsc);
        component.set("v.sortField", field);
        component.set("v.assetList", records);
        component.set("v.fromNavigation", false);

        if (field === 'Product2.ProductCode') {
            component.set("v.sortFieldCode", true);
            component.set("v.sortFieldFaceName", false);
            component.set("v.sortFieldDate", false);
            component.set("v.sortFieldWarrantyYears", false);
            component.set("v.sortFieldKitFaceName", false);
        } else if (field === 'Product2.Customer_Facing_Name__c') {
            component.set("v.sortFieldFaceName", true);
            component.set("v.sortFieldKitFaceName", false);
            component.set("v.sortFieldCode", false);
            component.set("v.sortFieldDate", false);
            component.set("v.sortFieldWarrantyYears", false);
        } else if (field === 'PurchaseDate') {
            component.set("v.sortFieldDate", true);
            component.set("v.sortFieldWarrantyYears", false);
            component.set("v.sortFieldCode", false);
            component.set("v.sortFieldKitFaceName", false);
            component.set("v.sortFieldFaceName", false);
        } else if (field === 'Total_Warranty_Years__c') {
            component.set("v.sortFieldWarrantyYears", true);
            component.set("v.sortFieldDate", false);
            component.set("v.sortFieldCode", false);
            component.set("v.sortFieldKitFaceName", false);
            component.set("v.sortFieldFaceName", false);
        } else if (field === 'KitProduct__r.Customer_Facing_Name__c') {
            component.set("v.sortFieldKitFaceName", true);
            component.set("v.sortFieldDate", false);
            component.set("v.sortFieldFaceName", false);
            component.set("v.sortFieldCode", false);
            component.set("v.sortFieldWarrantyYears", false);
        }
        this.renderPage(component);
    },

    renderPage: function(component) {
        var records = component.get("v.assetList");
        var pageNumber = component.get("v.pageNumber");
        var pageRecords = records.slice((pageNumber - 1) * 10, pageNumber * 10);
        component.set("v.currentList", pageRecords);
    },

    sortBySearch: function(component, field, records) {
        records.sort(function(a, b) {
            var x, y;
            if (field.includes(".")) {
                var field0 = field.split(".")[0],
                    field1 = field.split(".")[1];
                x = ($A.util.isUndefinedOrNull(a[field0])) ? '' : typeof a[field0][field1] === String ? (a[field0][field1]).toLowerCase() : a[field0][field1],
                    y = ($A.util.isUndefinedOrNull(b[field0])) ? '' : typeof b[field0][field1] === String ? (b[field0][field1]).toLowerCase() : b[field0][field1];
            } else {
                x = ($A.util.isUndefinedOrNull(a[field])) ? '' : typeof a[field] === String ? a[field].toLowerCase() : a[field],
                    y = ($A.util.isUndefinedOrNull(b[field])) ? '' : typeof b[field] === String ? b[field].toLowerCase() : b[field];
            }
            return x < y ? -1 : x > y ? 1 : 0;
        });
        component.set("v.sortAsc", true);
        component.set("v.sortField", field);
        this.renderPageBySearch(component, records);
    },

    renderPageBySearch: function(component, records) {
        var pageNumber = component.get("v.pageNumber");
        var pageRecords = records.slice((pageNumber - 1) * 10, pageNumber * 10);
        component.set("v.maxPage", Math.floor((records.length + 9) / 10));
        component.set("v.currentList", pageRecords);
        component.set("v.assetList", records);
    },

    searchFor: function(component, toSearch, objects) {
        var results = [];
        var blacklistFields = ["Total_Warranty_Years__c"];

        if (toSearch) {
            toSearch = toSearch.toLowerCase();
            results = objects.filter(el => {
                let isFound = false;
                Object.keys(el).forEach(key => {
                    if (blacklistFields.indexOf(key) === -1) {
                        if (key.indexOf('__r') !== -1 || key === 'Product2') {
                            Object.keys(el[key]).forEach(subKey => {
                                if (el[key][subKey] && el[key][subKey].toLowerCase().indexOf(toSearch) !== -1) {
                                    isFound = true;
                                }
                            });
                        } else {
                            if (el[key] && el[key].toLowerCase().indexOf(toSearch) !== -1) {
                                isFound = true;
                            }
                        }
                    } 
                });
                return isFound;
            });
        } else {
            results = objects;
        }
        return results;
    },

    trimString: function(s) {
        var l = 0, r = s.length - 1;
        while (l < s.length && s[l] === ' ') l++;
        while (r > l && s[r] === ' ') r -= 1;
        return s.substring(l, r + 1);
    },

    itemExists: function(haystack, needle) {
        for (var i = 0; i < haystack.length; i++) {
            if (this.compareObjects(haystack[i], needle)) {
                return true;
            }
        }
        return false;
    },

    compareObjects: function(o1, o2) {
        var k = '';
        for (k in o1) {
            if (o1[k] !== o2[k]) {
                return false;
            }
        }
        for (k in o2) {
            if (o1[k] !== o2[k]) {
                return false;
            }
        }
        return true;
    },

    isObject: function(val) {
        if (!val) {
            return false;
        }
        return ((typeof val === 'function') || (typeof val === 'object'));
    },

    parseQueryString: function(query) {
        var vars = query.split("&");
        var query_string = {};
        for (var i = 0; i < vars.length; i++) {
            var pair = vars[i].split("=");
            if (typeof query_string[pair[0]] === "undefined") {
                query_string[pair[0]] = decodeURIComponent(pair[1]);
            } else if (typeof query_string[pair[0]] === "string") {
                var arr = [query_string[pair[0]], decodeURIComponent(pair[1])];
                query_string[pair[0]] = arr;
            } else {
                query_string[pair[0]].push(decodeURIComponent(pair[1]));
            }
        }
        return query_string;
    },

    toggleClasses: function(arr) {
        for(let cmp in arr) {
            $A.util.toggleClass(arr[cmp], 'slds-hide');
        }
    },

    navigateTo: function(page) {
        const urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": page,
            "isredirect": false
        });
        urlEvent.fire();
    }
})