public class GoogleAutocompleteComponents {
	public String street_number {get;set;}
	public String subpremise {get;set;}
	public String route {get;set;}
	public String locality {get;set;}
	public String administrative_area_level_1 {get;set;}
	public String country {get;set;}
	public String postal_code {get;set;}
	public String autocompleteId {get;set;}
	public String stateHiddenId {get;set;}

	public GoogleAutocompleteComponents(String street_numberParam, String subpremiseParam, String routeParam, String localityParam, String administrative_area_level_1Param, 
					String countryParam, String postal_codeParam, String autocompleteIdParam, String stateHiddenIdParam) {
		street_number = street_numberParam;
		subpremise = subpremiseParam;
		route = routeParam;
		locality = localityParam;
		administrative_area_level_1 = administrative_area_level_1Param;
		country = countryParam;
		postal_code = postal_codeParam;
		autocompleteId = autocompleteIdParam;
		stateHiddenId = stateHiddenIdParam;
	}
}