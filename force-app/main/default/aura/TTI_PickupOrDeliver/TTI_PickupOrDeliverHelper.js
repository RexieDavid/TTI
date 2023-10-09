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
        },
        'tti_inferred_route': {
            "name": 'tti_address',
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

    validateAddress: function(component, addressObj) {
        var allValid = component.find('addressField').reduce(function (validSoFar, inputCmp) {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        var validState = false;
        var inputCmp = component.find('fieldState');
        if (addressObj.Country && addressObj.State) {
            if (addressObj.Country == 'Australia'
                    && addressObj.State != 'VIC' && addressObj.State != 'QLD' 
                    && addressObj.State != 'NSW' && addressObj.State != 'SA'
                    && addressObj.State != 'WA' && addressObj.State != 'TAS' 
                    && addressObj.State != 'TAS' && addressObj.State != 'ACT'
                    && addressObj.State != 'NT') {

                inputCmp.setCustomValidity('The state for freight to Australia must be VIC, QLD, NSW, SA, WA, TAS, ACT or NT');                
            } else {
                validState = true;
                inputCmp.setCustomValidity('');
            }
        }
        return allValid && validState;
    },

    setPhoneNumberValidation: function(component, phoneNumber, country) {
        let phone = phoneNumber.replace(/[^0-9]/g, '');

        if (country === 'Australia' && (phone.startsWith('614') || phone.startsWith('04'))) {
            component.set('v.regexPhoneFormat', $A.get("$Label.c.UTIL_REGEX_AU_Phone_Format"));
            component.set('v.errPhoneNumberNotMatch', $A.get("$Label.c.Regex_AU_Phone_Format_Pattern_Mismatch"));
        } else if (country === 'New Zealand' && (phone.startsWith('642') || phone.startsWith('02'))) {
            component.set('v.regexPhoneFormat', $A.get("$Label.c.UTIL_REGEX_NZ_Phone_Format"));
            component.set('v.errPhoneNumberNotMatch', $A.get("$Label.c.Regex_NZ_Phone_Format_Pattern_Mismatch"));
        } else {
            component.set('v.regexPhoneFormat', $A.get("$Label.c.SP_REGEX_ANZ_RetailerPhone_Format"));
            if (country === 'New Zealand') {
                component.set('v.errPhoneNumberNotMatch', $A.get("$Label.c.SP_ERR_NZ_Landline_Format_Pattern_Mismatch"));
            } else {
                component.set('v.errPhoneNumberNotMatch', $A.get("$Label.c.SP_ERR_AU_Landline_Format_Pattern_Mismatch"));
            }
        }

        return phone.match(/^61|64/) ? '+' + phone : phone;
    },
})