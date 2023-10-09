({
    submitClaimHelper: function(component, event, helper) {
        var spinner = component.find('mySpinner');
        $A.util.toggleClass(spinner, 'slds-hide');
        var asset = component.get('v.objAsset');
        var claim = component.get('v.claim');

        var userType = component.get('v.userType');
        var serviceAgentFreightCompany = null;
        if (!$A.util.isUndefinedOrNull(claim.Service_Agent__c) &&
            !$A.util.isUndefinedOrNull(claim.Service_Agent__c.Freight_Company__c) &&
            claim.Service_Agent__c.Freight_Company__c != '') {
            serviceAgentFreightCompany = claim.Service_Agent__c.Freight_Company__c;
        }
        claim.SuppliedEmail = claim.TTI_Customer_Contact__c.Email;
        if (claim.TTI_Email_Notification_Opt_In__c) {
            claim.TTI_Send_Receipt__c = true;

        }
        var warrantyMonths = null;
        if ($A.util.isUndefinedOrNull(asset)) {
            asset = {};
            this.createAsset(component, asset, claim);
            warrantyMonths = claim.Product_Name__c.Standard_Warranty_Months__c;
        }
        var contactObj = claim.TTI_Customer_Contact__c;

        console.log('RDAVID >>> claim >>> '+ JSON.parse(JSON.stringify(claim)));
        console.log('RDAVID >>> contactObj >>> '+ JSON.parse(JSON.stringify(contactObj)));

        this.createPayload(component, claim);
        if (claim.TTI_Customer_Contact__c != undefined || claim.TTI_Customer_Contact__c != null) {
            component.set('v.customer', claim.TTI_Customer_Contact__c);
            if (claim.TTI_Customer_Contact__c.Id != null || claim.TTI_Customer_Contact__c.Id != undefined) {
                claim.TTI_Customer_Name__c = claim.TTI_Customer_Contact__c.FirstName + ' ' + claim.TTI_Customer_Contact__c.LastName;
                claim.TTI_Customer_Contact__c = claim.TTI_Customer_Contact__c.Id;
            }
        }

        if (claim.TTI_Freight_Out_Required__c && !$A.util.isUndefinedOrNull(serviceAgentFreightCompany)) {
            claim.TTI_Freight_Out_Courier__c = serviceAgentFreightCompany;
        }

        if (claim.TTI_Freight_In_Required__c && !$A.util.isUndefinedOrNull(serviceAgentFreightCompany)) {
            claim.TTI_Freight_In_Courier__c = serviceAgentFreightCompany;
        }

        claim.Product_Name__c = claim.Product_Name__c.Id;
        claim.Retailer_Account__c = claim.Retailer_Account__c.Id;
        if ((claim.Service_Agent__c != null && claim.Service_Agent__c != undefined) 
                && (claim.Service_Agent__c.Id != undefined && claim.Service_Agent__c.Id != null)) {
            claim.Service_Agent__c = claim.Service_Agent__c.Id;
        }

        var mobilePhoneNo = contactObj.MobilePhone;
        if (!$A.util.isUndefinedOrNull(mobilePhoneNo) && mobilePhoneNo !== '') {
            if (mobilePhoneNo.substring(0, 2) === '02' || mobilePhoneNo.substring(0, 3) === '+64') {
                contactObj.Country__c = 'New Zealand';
            }
            if (mobilePhoneNo.substring(0, 2) === '04' || mobilePhoneNo.substring(0, 3) === '+61') {
                contactObj.Country__c = 'Australia';
            }
        }

        var homePhoneNo = contactObj.HomePhone;
        if (contactObj.MobilePhone == '' && contactObj.Email == '' && homePhoneNo == '') {
            claim.TTI_Customer_Name__c = contactObj.FirstName + ' ' + contactObj.LastName;
            contactObj = null;
            claim.TTI_Customer_Contact__c = '';
            claim.TTI_Customer_Account__c = '';
        }

        var searchAction = component.get('c.saveClaimDetails');
        searchAction.setParams({
            'objcase': claim,
            'objAsset': asset,
            'warrantyMonths': warrantyMonths,
            'objCon': contactObj,
            'isNewContactCreated': component.get('v.newcustomer')
        });
        searchAction.setCallback(this, function(response) {
            if (response.getState() == 'SUCCESS' && response.getReturnValue() != null) {
                component.set('v.claim', JSON.parse(response.getReturnValue()));
                component.set('v.activeScreenId', '8');
                $A.util.toggleClass(spinner, 'slds-hide');
                this.doEmailPart(component, component.get('v.claim').Id);
            } else {
            }
        });
        $A.enqueueAction(searchAction);


    },

    doEmailPart: function(component, caseId) {
        var action = component.get('c.handleEmailAndAttachment');
        action.setParams({
            'CaseId': caseId
        });
        $A.enqueueAction(action);
    },

    doFreightCompanyAPI: function(component, event, spinner) {
        var claim = component.get('v.claim');
        var apiAction = component.get('c.sendFreightCompanyRequest');
        apiAction.setParams({
            'caseId': claim.Id,
            'TriggerPoint': 'SubmitClaim'
        });
        apiAction.setCallback(this, function(response) {
            component.set('v.activeScreenId', '8');
            $A.util.toggleClass(spinner, 'slds-hide');
            if (response.getState() == 'SUCCESS') {
                var objAPIResponse = JSON.parse(response.getReturnValue());
                component.set('v.objAPIResponse', objAPIResponse);

            }
        });
        $A.enqueueAction(apiAction);
    },

    createAsset: function(component, asset, claim) {
        var contactObj = claim.TTI_Customer_Contact__c;
        if (!(contactObj.MobilePhone == '' && contactObj.Email == '' && contactObj.HomePhone == '')) {
            this.assetCreate(component, asset, claim);
        }

    },

    assetCreate: function(component, asset, claim) {

        var userObject = component.get('v.userObject');
        var userType = component.get('v.userType');
        var serialNumberWeek = component.get('v.serialNumberWeek');
        var serialNumberYear = component.get('v.serialNumberYear');
        asset.Product2Id = claim.Product_Name__c.Id;
        asset.ProductCode = claim.Product_Name__c.ProductCode;
        var serialnumber = claim.Serial_Number__c;
        asset.SerialNumber = serialnumber;
        
        if (claim.Product_Name__c.SerialNumberDisplayType__r != undefined || claim.Product_Name__c.SerialNumberDisplayType__r != null) {
            var serialnumberlength = claim.Product_Name__c.SerialNumberDisplayType__r.Serial_Number_Length__c;
            asset.EnforceLength__c = claim.Product_Name__c.SerialNumberDisplayType__r.EnforceLength__c;
            asset.Allow_Numbers_Only__c = claim.Product_Name__c.SerialNumberDisplayType__r.Allow_Numbers_Only__c;
            asset.HelpText__c = claim.Product_Name__c.SerialNumberDisplayType__r.HelpText__c;
            asset.Helper_Image_URL__c = claim.Product_Name__c.SerialNumberDisplayType__r.HelperImageURL__c;
            asset.Regexpression_Validator__c = claim.Product_Name__c.SerialNumberDisplayType__r.Regexpression_Validator__c;
            asset.SerialNumber = serialnumber.substring(0, serialnumberlength);
            asset.Display_Week__c = claim.Product_Name__c.SerialNumberDisplayType__r.Display_Week__c;
            asset.Display_Year__c = claim.Product_Name__c.SerialNumberDisplayType__r.Display_Year__c;
            if (asset.Display_Week__c) {
                asset.SerialNumberWeek__c = serialNumberWeek;
            }

            if (asset.Display_Year__c) {
                asset.SerialNumberYear__c = serialNumberYear;
            }
            asset.Serial_Number_Length__c = claim.Product_Name__c.SerialNumberDisplayType__r.Serial_Number_Length__c;

        }
        asset.sap_Material_Number__c = claim.Product_Name__c.SAP_MaterialNumber__c;
        asset.Brand__c = claim.Product_Name__c.Brand__c;
        asset.ProductDescription = claim.Product_Name__c.Description;
        asset.Receipt_No__c = claim.Receipt_No__c;
        asset.ProductFamily = claim.Product_Name__c.Family;
        asset.StockKeepingUnit = claim.Product_Name__c.StockKeepingUnit;
        asset.PurchaseDate = claim.Purchase_Date__c;
        asset.Quantity = 1;
        asset.Status = 'Not Confirmed';
        var AccountId = null;
        if (!$A.util.isUndefinedOrNull(userObject)) {
            AccountId = userObject.AccountId;
        }
        asset.AEG_CMS_REG_ID__c = AccountId;
        asset.AssetSource__c = 'Other';
        if (userType == 'SA' || userType == 'SAAD') {
            asset.Asset_Source_Other__c = 'Service Agent';
        } else if (userType == 'CS') {
            asset.Asset_Source_Other__c = 'Customer Service Agent';
        }
        asset.AccountId = claim.TTI_Customer_Account__c;
        asset.Extended_Warranty_Months__c = 0;
        asset.Standard_Warranty_Months__c = claim.Product_Name__c.Standard_Warranty_Months__c;
        asset.WarrantyStatus__c = 'Validated';
        asset.Name = claim.Product_Name__c.ProductCode + ' : ' + claim.Product_Name__c.Description;

        asset.IdentifiedBy__c = 'Service Request';
    },

    createPayload: function(component, claim) {
        var toolComeFromRetailer = component.get('v.toolComeFromRetailer');
        if (toolComeFromRetailer) {
            this.retailerYesAndCustomerYes(component, claim);
        }
        else if (!toolComeFromRetailer) {
            this.retailerNoAndCustomerYes(component, claim);
        }
    },
    
    retailerNoAndCustomerYes: function(component, claim) {
        var userType = component.get('v.userType');
        var userObject = component.get('v.userObject');
        var AccountId = null;
        if (!$A.util.isUndefinedOrNull(userObject)) {
            AccountId = userObject.AccountId;
        }
        claim.AccountId = AccountId;
        if (userType == 'CS') {
            if (claim.Service_Agent__c) {
                claim.AccountId = claim.Service_Agent__c.Id;
            } else {
                claim.AccountId = null;
            }

        }
        claim.Subject = 'Service Request for ' + claim.Product_Name__c.ProductCode + ' : ' + claim.Product_Name__c.Name;
        claim.Product_Fault_Category__c = claim.Product_Name__c.Fault_Code_Category__c;
        claim.Product_Size_Category__c = claim.Product_Name__c.Size_Category__c;
        claim.Product_Payment_Category__c = claim.Product_Name__c.Payment_Category__c;
        claim.Priority = 'Low';
        claim.Status = 'New';
        claim.Service_Request_Milestone__c = 'New';
        if (userType == 'SA' || userType == 'SAAD') {
            var today = new Date();
            claim.SLA_Start_Date__c = today;
            claim.Owner = userObject.Id;
        }

        if (userType == 'SA' || userType == 'SAAD') {
            claim.Origin = 'Service Agent';
        } else {
            claim.Origin = 'Customer Service Agent';
        }
        claim.Number_of_Interactions__c = 1;
        var serviceAgent = claim.Service_Agent__c;
        if (userType == 'SA' || userType == 'SAAD') {
            claim.TTI_Freight_In_Required__c = false;
        } else if (userType == 'CS' && claim.TTI_Service_Agent_Delivery_Method__c == 'Pickup from nominated address') {
            claim.TTI_Freight_In_Required__c = true;
        } else if (userType == 'CS' && claim.TTI_Service_Agent_Delivery_Method__c == 'Drop off') {
            claim.TTI_Freight_In_Required__c = false;
            claim.Service_Agent__c = null;
            claim.AccountId = null;
        }

        if (userType == 'SA') {
            claim.TTI_Freight_Out_Required__c = false;
        } else if (userType == 'SAAD' && claim.TTI_Customer_Delivery_Method__c == 'Deliver') {
            claim.TTI_Freight_Out_Required__c = true;
        } else if (userType == 'SAAD' && claim.TTI_Customer_Delivery_Method__c == 'Pickup from Service Agent') {
            claim.TTI_Freight_Out_Required__c = false;
        } else if (userType == 'CS' && claim.TTI_Customer_Delivery_Method__c == 'Deliver') {
            claim.TTI_Freight_Out_Required__c = true;
        } else if (userType == 'CS' && claim.TTI_Customer_Delivery_Method__c == 'Pickup from Service Agent') {
            claim.TTI_Freight_Out_Required__c = false;
        }
        if (userType == 'SA' || userType == 'SAAD') {
            this.copyServiceAgentDeliverAddress(component, claim, userObject);
            if (claim.TTI_Freight_Out_Required__c && !$A.util.isUndefinedOrNull(userObject) 
                    && !$A.util.isUndefinedOrNull(userObject.AccountId) && !$A.util.isUndefinedOrNull(userObject.Account.Freight_Company__c) 
                    && userObject.Account.Freight_Company__c != '') {
                claim.TTI_Freight_Out_Courier__c = userObject.Account.Freight_Company__c;
            } else {
                claim.TTI_Freight_Out_Courier__c = null;
            }
        }

    },

    retailerYesAndCustomerYes: function(component, claim) {
        var userType = component.get('v.userType');
        var userObject = component.get('v.userObject');
        var AccountId = null;
        if (!$A.util.isUndefinedOrNull(userObject)) {
            AccountId = userObject.AccountId;
        }
        claim.AccountId = AccountId;
        if (userType == 'CS') {
            if (claim.Service_Agent__c) {
                claim.AccountId = claim.Service_Agent__c.Id;
            } else {
                claim.AccountId = null;
            }
        }
        if (userType == 'SA' || userType == 'SAAD') {
            var today = new Date();
            claim.SLA_Start_Date__c = today;

        }
        claim.Subject = 'Service Request for ' + claim.Product_Name__c.ProductCode + ' : ' + claim.Product_Name__c.Name;
        claim.Priority = 'Low';
        claim.Product_Fault_Category__c = claim.Product_Name__c.Fault_Code_Category__c;
        claim.Product_Size_Category__c = claim.Product_Name__c.Size_Category__c;
        claim.Product_Payment_Category__c = claim.Product_Name__c.Payment_Category__c;
        claim.Status = 'New';
        claim.Service_Request_Milestone__c = 'New';
        claim.Origin = 'Retailer';
        claim.Number_of_Interactions__c = 1;
        var serviceAgent = claim.Service_Agent__c;
        if (userType == 'SA' || userType == 'SAAD') {
            claim.TTI_Freight_In_Required__c = false;
        } else if (userType == 'CS' && claim.TTI_Service_Agent_Delivery_Method__c == 'Pickup from nominated address') {
            claim.TTI_Freight_In_Required__c = true;
        } else if (userType == 'CS' && claim.TTI_Service_Agent_Delivery_Method__c == 'Drop off') {
            claim.TTI_Freight_In_Required__c = false;
            claim.Service_Agent__c = null;
            claim.AccountId = null;
        }

        if (userType == 'SA') {
            claim.TTI_Freight_Out_Required__c = false;
        } else if (userType == 'SAAD' && claim.TTI_Customer_Delivery_Method__c == 'Deliver') {
            claim.TTI_Freight_Out_Required__c = true;

        } else if (userType == 'SAAD' && claim.TTI_Customer_Delivery_Method__c == 'Pickup from Service Agent') {
            claim.TTI_Freight_Out_Required__c = false;
        } else if (userType == 'CS' && claim.TTI_Customer_Delivery_Method__c == 'Deliver') {
            claim.TTI_Freight_Out_Required__c = true;
        } else if (userType == 'CS' && claim.TTI_Customer_Delivery_Method__c == 'Pickup from Service Agent') {
            claim.TTI_Freight_Out_Required__c = false;
        }

        if (userType == 'SA' || userType == 'SAAD') {
            this.copyServiceAgentDeliverAddress(component, claim, userObject);
            if (claim.TTI_Freight_Out_Required__c && !$A.util.isUndefinedOrNull(userObject) && !$A.util.isUndefinedOrNull(userObject.AccountId) 
                    && !$A.util.isUndefinedOrNull(userObject.Account.Freight_Company__c) && userObject.Account.Freight_Company__c != '') {
                claim.TTI_Freight_Out_Courier__c = userObject.Account.Freight_Company__c;
            } else {
                claim.TTI_Freight_Out_Courier__c = null;
            }
        }

    },
    
    copyServiceAgentDeliverAddress: function(component, claim, userObject) {

        if (!$A.util.isUndefinedOrNull(userObject) && !$A.util.isUndefinedOrNull(userObject.AccountId)) {
            claim.Service_Agent__c = userObject.AccountId;

        }

        if (!$A.util.isUndefinedOrNull(userObject) && !$A.util.isUndefinedOrNull(userObject.Account.Delivery_Suburb__c)) {
            claim.TTI_Freight_Out_Pickup_Suburb__c = userObject.Account.Delivery_Suburb__c;

        }
        if (!$A.util.isUndefinedOrNull(userObject) && !$A.util.isUndefinedOrNull(userObject.Account.Delivery_State__c)) {
            claim.TTI_Freight_Out_Pickup_State__c = userObject.Account.Delivery_State__c;

        }
        if (!$A.util.isUndefinedOrNull(userObject) && !$A.util.isUndefinedOrNull(userObject.Account.Delivery_Postcode__c)) {
            claim.TTI_Freight_Out_Pickup_Postcode__c = userObject.Account.Delivery_Postcode__c;

        }
        if (!$A.util.isUndefinedOrNull(userObject) && !$A.util.isUndefinedOrNull(userObject.Account.Delivery_Country__c)) {
            claim.TTI_Freight_Out_Pickup_Country__c = userObject.Account.Delivery_Country__c;

        }
        if (!$A.util.isUndefinedOrNull(userObject) && !$A.util.isUndefinedOrNull(userObject.Account.Delivery_Street__c)) {
            claim.TTI_Freight_Out_PickUp_Address__c = userObject.Account.Delivery_Street__c;

        }
    },

    getCountry: function(companyCode) {
        // set au as default value in case service agent account doesn't have company code
        let country = 'au';
        if (companyCode) {
            if (companyCode === 'BP01') {
                country = 'au';
            }
            if (companyCode === 'NZ01') {
                country = 'nz';
            }
        }
        return country;
    }

})