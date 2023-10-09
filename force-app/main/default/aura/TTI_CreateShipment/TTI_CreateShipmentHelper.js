({
    ADDRESS_MAP: {
        'street_number': {
            "name": 'Street1',
            "value": "long_name"
        },
        'route': {
            "name": 'Street2',
            "value": "long_name"
        },
        'locality': {
            "name": 'City',
            "value": "long_name"
        },
        'postal_code': {
            "name": 'PostalCode',
            "value": "long_name"
        },
        'administrative_area_level_1': {
            "name": 'State',
            "value": "short_name"
        },
        'country': {
            "name": 'Country',
            "value": "long_name"
        }
    },

    constructAddressObj: function(address_components) {
        let addressObj = [];
        address_components.forEach( el => {
            if (this.ADDRESS_MAP[el.types[0]]) {
                addressObj[this.ADDRESS_MAP[el.types[0]].name] = el[this.ADDRESS_MAP[el.types[0]].value];
            } else {
                addressObj[el.types[0]] = el.long_name;
            }
        });
    
        return addressObj;
    },

    getPhoneRegexPattern: function(phoneNumber, country) {
        let phone = phoneNumber.replace(/[^0-9]/g, '');
        let mobileRegex = $A.get("$Label.c.UTIL_REGEX_AU_Phone_Format");
        let landlineRegex = $A.get("$Label.c.SP_REGEX_ANZ_RetailerPhone_Format");
        let mobilePrefix = new RegExp(/^(04|02|614|642)/g);

        if (country === 'New Zealand') {
            mobileRegex = $A.get("$Label.c.UTIL_REGEX_NZ_Phone_Format");
        }

        return mobilePrefix.test(phone) ? mobileRegex : landlineRegex;
    },

    getErrorPhonePatternMismatch: function(phoneNumber, country) {
        let phone = phoneNumber.replace(/[^0-9]/g, '');
        let mobileErrMismatch = $A.get("$Label.c.Regex_AU_Phone_Format_Pattern_Mismatch");
        let landlineErrMismatch = $A.get("$Label.c.SP_ERR_AU_Landline_Format_Pattern_Mismatch");
        let mobilePrefix = new RegExp(/^(04|02|614|642)/g);

        if (country === 'New Zealand') {
            mobileErrMismatch = $A.get("$Label.c.Regex_NZ_Phone_Format_Pattern_Mismatch");
            landlineErrMismatch = $A.get("$Label.c.SP_ERR_NZ_Landline_Format_Pattern_Mismatch");
        }

        return mobilePrefix.test(phone) ? mobileErrMismatch : landlineErrMismatch;
    },

    validateForm: function(component) {
        let receiverPhone = component.find("receiverPhone");
        let deliveryAddress = component.find("deliveryAddress");
        let formValidity = receiverPhone.get('v.validity').valid && deliveryAddress.get('v.validity').valid;

        receiverPhone.reportValidity();
        deliveryAddress.reportValidity();

        component.set('v.hasFormError', !formValidity);

        return formValidity;
    },
})