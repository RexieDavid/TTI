/**
 * @File Name          : TTI_SubmitClaimPageComponentController.js
 * @Description        : 
 * @Author             : Francis Nasalita
 * @Group              : 
 * @Last Modified By   : Francis Nasalita
 * @Last Modified On   : 06/08/2019, 10:10:21 am
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    06/08/2019, 9:39:29 am   Francis Nasalita     Initial Version
**/
({
    doInit: function(component, event, helper) {
        let claim = component.get('v.claim');
        claim = {
            'Brand__c': '',
            'Product': '',
            'Serial_Number__c': '',
            'Serial_Number_not_found__c': '',
            'Purchase_Date__c': '',
            'Receipt_No__c': '',
            'Fault__Description__c': '',
            'TTI_Email_Notification_Opt_In__c': 'false',
            'TTI_Customer_Delivery_Method__c': '',
            'TTI_Service_Agent_Delivery_Method__c': ''
        } 
        claim.TTI_Email_Notification_Opt_In__c = false;
        component.set('v.claim', claim);
        component.set('v.activeScreenId', '1');
        let action = component.get('c.getUserType');
        
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === 'SUCCESS') {
                
                component.set('v.userObject', response.getReturnValue());
                let userObject = component.get('v.userObject');
                component.set('v.countryRestrict', helper.getCountry(userObject.Account.Company_Code__c));
                
                let userType = component.get('v.userType');
                if (!$A.util.isUndefinedOrNull(userObject.Account) && userObject.Account.RecordType.Name == 'Service Agent') {
                    if (userObject.Account.Allow_Delivery_to_Customers__c) {
                        userType = 'SAAD';
                    } else {
                        userType = 'SA';
                    }
                } else {
                        userType = 'CS';
                }
                component.set('v.userType', userType);
            }
        });
        $A.enqueueAction(action); 
        let action2 = component.get('c.getFreightAccountDetailsCustmSetting');
        action2.setCallback(this, function(response) {
            if (response.getState() == 'SUCCESS') {
                component.set('v.freightAccountDetails',JSON.parse(response.getReturnValue()));
            }
        });
        $A.enqueueAction(action2);
    },
    
    clearRetailerAddressConsignment: function(component, event, helper) {
        let removeHide = component.find('nextBtn');
        let errorBox=component.find('ErrorBox');
        if (!event.getSource().get('v.value')) {
           component.set('v.isNextButtonDisabled', false);
           document.getElementById('nextButton').style.visibility = 'visible';
           $A.util.removeClass(removeHide, 'slds-hide');
        } else {
            component.set('v.isNextButtonDisabled', true);
            document.getElementById('nextButton').style.visibility = 'hidden';
        }
        
        component.set('v.retailerAdd', null);
        component.set('v.claim.Retailer_Account__c.Name', '');
        component.set('v.claim.Freight_in_consignment_number__c', '');
        component.set('v.claim.Retailer_Account__c', []);
        component.set('v.claim.TTI_Retailer_Job_Number__c', '');
        component.set('v.claim.DateRetailerReceivedTool__c', null);
        errorBox.set('v.value', null);
    },
    
    nextClicked: function(component, event, helper) {
        let errorBox=component.find('ErrorBox');
        let toolComeFromRetailer = component.get('v.toolComeFromRetailer');
        let hasCustomerDetails = component.get('v.hasCustomerDetails');
        let inputDateString = component.get('v.claim.DateRetailerReceivedTool__c');
        let inputDate = new Date(inputDateString);
        let inputDateMonth = inputDate.getMonth();
        let inputDateDay = inputDate.getDate();
        let inputDateYear = inputDate.getFullYear();
        let checkDate = new Date(inputDateYear, inputDateMonth, inputDateDay);
        let date = new Date();
        let month = date.getMonth();
        let day = date.getDate();
        let year = date.getFullYear();
        let dateToday = new Date(year, month, day);

        if (!toolComeFromRetailer && !hasCustomerDetails) {
            errorBox.set('v.value', 'You cannot proceed to the next step because either the Retailer or Customer must be specified');
            return false;
        } else {
            errorBox.set('v.value', null);
        }

        if (toolComeFromRetailer && $A.util.isUndefinedOrNull(component.get('v.claim.DateRetailerReceivedTool__c'))) {
            errorBox.set('v.value', 'You cannot proceed to the next step because the Date Customer Dropped Tool must be specified');
            return false;
        } else if (checkDate > dateToday) {
            errorBox.set('v.value', 'You cannot proceed to the next step because the Date Customer Dropped Tool cannot be in the future');
            return false;
        } else {
            errorBox.set('v.value', null);
        }

        if (!toolComeFromRetailer || (toolComeFromRetailer 
                && component.get('v.claim.Retailer_Account__c')
                && !$A.util.isUndefinedOrNull(component.get('v.claim.Retailer_Account__c.Name'))
                && !$A.util.isEmpty(component.get('v.claim.Retailer_Account__c.Name')))) {
            errorBox.set('v.value', null);
            if (component.get('v.hasCustomerDetails')) {
                component.set('v.activeScreenId', '2');
            } else {
                component.set('v.activeScreenId', '4');
            }
        } else {
            errorBox.set('v.value', 'You cannot proceed to the next step because the Retailer must be specified');     
        }
    },

    populateAddress: function(component, event, helper) {
        let selectedObj = event.getParam('sObject');
        let address = '';
        
        if (selectedObj) {
            let ErrorBox = component.find('ErrorBox');
            ErrorBox.set('v.value', null);
            let street = '';
            let city = '';
            let state = '';
            let postalCode = '';
            let country = '';
            if (selectedObj.Delivery_Street__c) {
                street = selectedObj.Delivery_Street__c;
            }
            if (selectedObj.Delivery_Suburb__c) {
                city = selectedObj.Delivery_Suburb__c;
            }
            if (selectedObj.Delivery_State__c) {
                state = selectedObj.Delivery_State__c;
            }
            if (selectedObj.Delivery_Postcode__c) {
                postalCode = selectedObj.Delivery_Postcode__c;
            }
            if (selectedObj.Delivery_Country__c) {
                country = selectedObj.Delivery_Country__c;
            }
            
            address = `${street} ${city} ${state} ${postalCode} ${country}`;
            component.set('v.claim.SuppliedPhone', selectedObj.Phone);
            component.set('v.claim.Retailer_Account__c', selectedObj);

            component.set('v.retailerAdd', address);
            component.set('v.hasRetailer', true);
        } else {
            component.set('v.hasRetailer', false);
        }
        
        event.stopPropagation();
    },

    clearRetailAdd: function(component, event, helper) {
        if (!event.getParam('value')) {
            component.set('v.retailerAdd', '');
        }
    },

    submitClaim: function(component, event, helper) {
        event.stopPropagation();
        helper.submitClaimHelper(component, event, helper);
    },
    
    disableNextButton: function(component, event, helper) {
        if (component.get('v.activeScreenId') == component.get('v.myId')) {
            let isDisabled = event.getParam('isDisabled');
            component.set('v.isNextButtonDisabled', isDisabled);
            let isNextButtonDisabled = component.get('v.isNextButtonDisabled');
            let removeHide = component.find('nextBtn');

            if (!isNextButtonDisabled) {
                $A.util.removeClass(removeHide, 'slds-hide');
                $A.util.addClass(removeHide, 'slds-show');
                document.getElementById('nextButton').style.visibility = 'visible';
            } else {
                $A.util.removeClass(removeHide, 'slds-show');
                $A.util.addClass(removeHide, 'slds-hide');
                document.getElementById('nextButton').style.visibility = 'hidden';
            }
        }
    }
})