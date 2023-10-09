@isTest
private class GoogleAutocompleteComponentsTest {

	private static testMethod void test() {
        GoogleAutocompleteComponents googleCmps = new GoogleAutocompleteComponents(
            'street_number', //street_number
            'street_number', //subpremise
            'route', //route
            'locality', //locality
            'inputState', //administrative_area_level_1
            '', //country
            'inputPostcode', //postal_code
            'googleApiAddress', //autocompleteId
            'inputStateHidden' //stateHiddenId
        );
        
	}

}