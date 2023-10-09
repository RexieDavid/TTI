({
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
            var kitProduct = (assetList[i].hasOwnProperty('KitProduct__r')) ? assetList[i].KitProduct__r.Customer_Facing_Name__c : '';
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
                $A.util.removeClass(ImageDisplay, 'slds-hide');
                $A.util.addClass(ImageDisplay, 'slds-show');
            }
        });

        $A.enqueueAction(action);
    },

    inializeRemove: function(component) {
        var action = component.get("c.getRemoveReason");

        action.setCallback(this, function(response) {
            this.initializeRemoveDetails(response, component);
        });
        $A.enqueueAction(action);
    },

    initializeRemoveDetails: function(response, component) {
        var reasonList = response.getReturnValue();
        component.set("v.removeReasonList", reasonList);
        component.set("v.removeReason", reasonList[0]);
    },

    //arjen added function for initialize custom settings
    initializeCustomSettings: function(component) {
        var action = component.get("c.getCommunitySettings");
        action.setCallback(this, function(response) {
            this.getCustomSettingsValues(response, component);
        });
        $A.enqueueAction(action);


    },

    getCustomSettingsValues: function(response, component) {
        var customSettingValues = response.getReturnValue();
        component.set("v.siteSettings", customSettingValues);
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
            ;
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
        if (res != '') {
            component.set("v.removeErrorMessage", res);
            $A.util.removeClass(removeDiv, 'slds-show');
            $A.util.addClass(removeDiv, 'slds-hide');
            $A.util.removeClass(errorDiv, 'slds-hide');
            $A.util.addClass(errorDiv, 'slds-show');
        } else {
            $A.util.removeClass(removeDiv, 'slds-show');
            $A.util.addClass(removeDiv, 'slds-hide');
            $A.util.removeClass(successDiv, 'slds-hide');
            $A.util.addClass(successDiv, 'slds-show');
        }
    },

    /*  Sorting and Pagination Methods  */
    sortBy: function(component, field) {
        var sortAsc = component.get("v.sortAsc"),
            sortField = component.get("v.sortField"),
            records = component.get("v.assetList");

        sortAsc = sortField != field || !sortAsc;

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

            if (sortAsc) {
                return x < y ? -1 : x > y ? 1 : 0;
            } else {
                return x > y ? -1 : x < y ? 1 : 0;
            }
        });
        component.set("v.sortAsc", sortAsc);
        component.set("v.sortField", field);
        component.set("v.assetList", records);
        this.renderPage(component);
    },

    renderPage: function(component) {
        var records = component.get("v.assetList"),
            pageNumber = component.get("v.pageNumber"),
            pageRecords = records.slice((pageNumber - 1) * 10, pageNumber * 10);
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
        var pageNumber = component.get("v.pageNumber"),
            pageRecords = records.slice((pageNumber - 1) * 10, pageNumber * 10);

        component.set("v.maxPage", Math.floor((records.length + 9) / 10));
        component.set("v.currentList", pageRecords);
        component.set("v.assetList", records);
    },

    trimString: function(s) {
        var l = 0, r = s.length - 1;
        while (l < s.length && s[l] === ' ') l++;
        while (r > l && s[r] === ' ') r -= 1;
        return s.substring(l, r + 1);
    },

    compareObjects: function(o1, o2) {
        var k = '';
        for (k in o1) if (o1[k] != o2[k]) return false;
        for (k in o2) if (o1[k] != o2[k]) return false;
        return true;
    },

    itemExists: function(haystack, needle) {
        for (var i = 0; i < haystack.length; i++) if (this.compareObjects(haystack[i], needle)) return true;
        return false;
    },

    searchFor: function(component, toSearch, objects) {
        var results = [];
        var blacklistFields = ["Total_Warranty_Years__c"];
        toSearch = this.trimString(toSearch).toLowerCase(); // trim it

        for (var i = 0; i < objects.length; i++) {
            for (var key in objects[i]) {
                if (this.isObject(objects[i][key])) {
                    var isExist = false;

                    for (var key2 in objects[i][key]) {
                        if (blacklistFields.indexOf(key2) == -1) {
                            if (objects[i][key][key2].toLowerCase().indexOf(toSearch) != -1) {
                                if (!this.itemExists(results, objects[i])) {
                                    results.push(objects[i]);
                                    isExist = true;
                                    break;
                                }
                            }
                        }
                    }
                    if (isExist) break;
                } else {
                    if (blacklistFields.indexOf(key) == -1) {
                        if (objects[i][key].toLowerCase().indexOf(toSearch) != -1) {
                            if (!this.itemExists(results, objects[i])) {
                                results.push(objects[i]);
                                break;
                            }
                        }
                    }
                }
            }
        }

        return results;
    },

    hideComponent: function(component) {
        $A.util.removeClass(component, 'slds-show');
        $A.util.addClass(component, 'slds-hide');
    },

    showComponent: function(component) {
        $A.util.removeClass(component, 'slds-hide');
        $A.util.addClass(component, 'slds-show');
    },

    isObject: function(val) {
        if (val === null) { return false; }
        return ((typeof val === 'function') || (typeof val === 'object'));
    },

    parseQueryString: function(query) {
        var vars = query.split("&");
        var query_string = {};
        for (var i = 0; i < vars.length; i++) {
            var pair = vars[i].split("=");
            // If first entry with this name
            if (typeof query_string[pair[0]] === "undefined") {
                query_string[pair[0]] = decodeURIComponent(pair[1]);
                // If second entry with this name
            } else if (typeof query_string[pair[0]] === "string") {
                var arr = [query_string[pair[0]], decodeURIComponent(pair[1])];
                query_string[pair[0]] = arr;
                // If third or later entry with this name
            } else {
                query_string[pair[0]].push(decodeURIComponent(pair[1]));
            }
        }
        return query_string;
    },

    initializeView: function(component) {
        var urlParams = window.location.search.substring(1);
        if (urlParams != '') {
            var params = this.parseQueryString(urlParams);
            if (!$A.util.isUndefined(params['toolbagview'])) {
                component.set("v.toolbagView", params['toolbagview']);
            }
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