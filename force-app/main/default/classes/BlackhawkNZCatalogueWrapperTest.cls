@IsTest
public class BlackhawkNZCatalogueWrapperTest {
	
	// This test method should give 100% coverage
	static testMethod void testParse() {
		String json = '{'+
		'    \"Result\": 0,'+
		'    \"Response\": {'+
		'        \"DigitalStoreCards\": ['+
		'            {'+
		'                \"RedemptionInformation\": null,'+
		'                \"Identifier\": 795,'+
		'                \"SKU\": \"AUJBHJNZC003\",'+
		'                \"ProductName\": \"JB Hifi NZ Store Card\",'+
		'                \"ProductDescription\": \"JB Hi-Fi is one of Australasia\'s fastest growing and largest retailers of home entertainment.\\r\\n\",'+
		'                \"SupplierCode\": \"JNZ\",'+
		'                \"ProductThumbnailUrl\": \"https://d2gktdeiupfo4o.cloudfront.net/images/deis/products/JBHiFi.png\",'+
		'                \"IsActive\": true,'+
		'                \"IsFixedValue\": false,'+
		'                \"ProductValue\": 0.0,'+
		'                \"TermsAndConditions\": \"Gift Card Terms and ConditionsGift Cards entitle the holder to goods/services equal to the value stated on the card or remaining after partial redemption.Gift Cards only redeemable within any JB Hi-Fi Store in Australia and online retail stores but are not redeemable for JB Hi-Fi Direct Import goods or goods purchased from JB Hi-Fi Solutions (including goods purchased from JB Hi-Fi Solutions websites).Gift Cards may not be exchanged (wholly or partly) for cash.The value shown on this card includes GST.Gift Cards are partially redeemable and any unused balance will remain on the Card and cannot be redeemed for cash. If the Card holders order exceeds the amount of the Gift Card, the Card holder will be required to pay for the difference in price between the value of the Gift Card and the retail price of the goods or services.Gift Cards will not expire.Should JB Hi-Fi suspect any fraud relating to a Gift Card, JB Hi-Fi may refuse to redeem the Card until JB Hi-Fi is satisfied that no fraud has occurred.JB Hi-Fi is not liable for any lost/stolen Gift Cards. Please contact a JB Hi-Fi store immediately if your Card has been lost/stolen. Lost/stolen Cards can only be replaced if satisfactory proof of purchase is provided and the Card has not been redeemed.Gift cards are not sold and are unable to be redeemed at the Sydney Airport store\",'+
		'                \"ValidityPeriod\": \"no expiry\",'+
		'                \"IsPresetExpiry\": false,'+
		'                \"VariableMinValue\": 10.0,'+
		'                \"VariableMaxValue\": 1000.0,'+
		'                \"Categories\": null,'+
		'                \"Language\": \"en_AU\",'+
		'                \"LastUpdated\": \"2023-11-17T15:49:40.777\",'+
		'                \"ValueCostPerUnit\": 1.0,'+
		'                \"PercentageCostPerUnit\": 100.0'+
		'            }'+
		'        ]'+
		'    },'+
		'    \"Errors\": []'+
		'}';
		BlackhawkNZCatalogueWrapper r = BlackhawkNZCatalogueWrapper.parse(json);
		System.assert(r != null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		BlackhawkNZCatalogueWrapper.Response objResponse = new BlackhawkNZCatalogueWrapper.Response(System.JSON.createParser(json));
		System.assert(objResponse != null);
		System.assert(objResponse.DigitalStoreCards == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		BlackhawkNZCatalogueWrapper.Errors objErrors = new BlackhawkNZCatalogueWrapper.Errors(System.JSON.createParser(json));
		System.assert(objErrors != null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		BlackhawkNZCatalogueWrapper.DigitalStoreCards objDigitalStoreCards = new BlackhawkNZCatalogueWrapper.DigitalStoreCards(System.JSON.createParser(json));
		System.assert(objDigitalStoreCards != null);
		System.assert(objDigitalStoreCards.RedemptionInformation == null);
		System.assert(objDigitalStoreCards.Identifier == null);
		System.assert(objDigitalStoreCards.SKU == null);
		System.assert(objDigitalStoreCards.ProductName == null);
		System.assert(objDigitalStoreCards.ProductDescription == null);
		System.assert(objDigitalStoreCards.SupplierCode == null);
		System.assert(objDigitalStoreCards.ProductThumbnailUrl == null);
		System.assert(objDigitalStoreCards.IsActive == null);
		System.assert(objDigitalStoreCards.IsFixedValue == null);
		System.assert(objDigitalStoreCards.ProductValue == null);
		System.assert(objDigitalStoreCards.TermsAndConditions == null);
		System.assert(objDigitalStoreCards.ValidityPeriod == null);
		System.assert(objDigitalStoreCards.IsPresetExpiry == null);
		System.assert(objDigitalStoreCards.VariableMinValue == null);
		System.assert(objDigitalStoreCards.VariableMaxValue == null);
		System.assert(objDigitalStoreCards.Categories == null);
		System.assert(objDigitalStoreCards.Language == null);
		System.assert(objDigitalStoreCards.LastUpdated == null);
		System.assert(objDigitalStoreCards.ValueCostPerUnit == null);
		System.assert(objDigitalStoreCards.PercentageCostPerUnit == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		BlackhawkNZCatalogueWrapper objBlackhawkNZCatalogueWrapper = new BlackhawkNZCatalogueWrapper(System.JSON.createParser(json));
		System.assert(objBlackhawkNZCatalogueWrapper != null);
		System.assert(objBlackhawkNZCatalogueWrapper.Result == null);
		System.assert(objBlackhawkNZCatalogueWrapper.Response == null);
		System.assert(objBlackhawkNZCatalogueWrapper.Errors == null);
	}
}