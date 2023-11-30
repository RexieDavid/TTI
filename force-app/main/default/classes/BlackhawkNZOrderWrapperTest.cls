@IsTest
public class BlackhawkNZOrderWrapperTest {
	
	// This test method should give 100% coverage
	static testMethod void testParse() {
		String json = '{'+
		'    \"Result\": 0,'+
		'    \"Response\": {'+
		'        \"OrderReferenceNumber\": \"Test0004\",'+
		'        \"StatusCode\": \"000\",'+
		'        \"RecievedOn\": \"2023-11-30T15:13:46.447\",'+
		'        \"DigitalStoreCardOrder\": {'+
		'            \"OrderItems\": ['+
		'                {'+
		'                    \"Quantity\": 1,'+
		'                    \"StoreCardUrls\": ['+
		'                        \"https://jbhifivii.dgenginesuat.com.au/StoreCards/List/8b9a565a4e0d4da79b974960a9e5cb27/517b418f49b64f72ade19dd405990740\"'+
		'                    ],'+
		'                    \"StatusCode\": \"000\",'+
		'                    \"Metadata\": ['+
		'                        {'+
		'                            \"Barcode\": \"502904010016569833\",'+
		'                            \"Pin\": \"4109\",'+
		'                            \"ExpiryDate\": \"2025-11-30T00:00:00\",'+
		'                            \"BarcodeType\": \"Code 128\",'+
		'                            \"Balance\": 10.0,'+
		'                            \"LastBalanceCheckedDate\": \"2023-11-30T15:13:47\",'+
		'                            \"Status\": \"Allocated\",'+
		'                            \"LastStatusChangedDate\": null,'+
		'                            \"IsBonusCard\": false,'+
		'                            \"CardValue\": 10.0,'+
		'                            \"CardUrl\": \"https://jbhifivii.dgenginesuat.com.au/StoreCards/List/8b9a565a4e0d4da79b974960a9e5cb27/517b418f49b64f72ade19dd405990740\",'+
		'                            \"SupportsBalanceCheck\": true,'+
		'                            \"BalanceCheckUrl\": \"\"'+
		'                        }'+
		'                    ],'+
		'                    \"SKU\": \"AUJBHJNZC003\",'+
		'                    \"ReferenceNumber\": \"t0004\",'+
		'                    \"StatusMessage\": \"Order item is Sent.\",'+
		'                    \"ReceiptNumber\": \"TZBT9UTWMH\",'+
		'                    \"Amount\": 10.0,'+
		'                    \"CostPerUnit\": 10.0,'+
		'                    \"RRPPerUnit\": 10.0,'+
		'                    \"IncludesGst\": false'+
		'                }'+
		'            ]'+
		'        }'+
		'    },'+
		'    \"Errors\": ['+
		'        \"Invalid amount for Reference Number - t0005.\"'+
		'    ]'+
		'}';
		BlackhawkNZOrderWrapper r = BlackhawkNZOrderWrapper.parse(json);
		System.assert(r != null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		BlackhawkNZOrderWrapper.Response objResponse = new BlackhawkNZOrderWrapper.Response(System.JSON.createParser(json));
		System.assert(objResponse != null);
		System.assert(objResponse.OrderReferenceNumber == null);
		System.assert(objResponse.StatusCode == null);
		System.assert(objResponse.RecievedOn == null);
		System.assert(objResponse.DigitalStoreCardOrder == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		BlackhawkNZOrderWrapper.DigitalStoreCardOrder objDigitalStoreCardOrder = new BlackhawkNZOrderWrapper.DigitalStoreCardOrder(System.JSON.createParser(json));
		System.assert(objDigitalStoreCardOrder != null);
		System.assert(objDigitalStoreCardOrder.OrderItems == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		BlackhawkNZOrderWrapper objBlackhawkNZOrderWrapper = new BlackhawkNZOrderWrapper(System.JSON.createParser(json));
		System.assert(objBlackhawkNZOrderWrapper != null);
		System.assert(objBlackhawkNZOrderWrapper.Result == null);
		System.assert(objBlackhawkNZOrderWrapper.Response == null);
		System.assert(objBlackhawkNZOrderWrapper.Errors == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		BlackhawkNZOrderWrapper.OrderItems objOrderItems = new BlackhawkNZOrderWrapper.OrderItems(System.JSON.createParser(json));
		System.assert(objOrderItems != null);
		System.assert(objOrderItems.Quantity == null);
		System.assert(objOrderItems.StoreCardUrls == null);
		System.assert(objOrderItems.StatusCode == null);
		System.assert(objOrderItems.Metadata == null);
		System.assert(objOrderItems.SKU == null);
		System.assert(objOrderItems.ReferenceNumber == null);
		System.assert(objOrderItems.StatusMessage == null);
		System.assert(objOrderItems.ReceiptNumber == null);
		System.assert(objOrderItems.Amount == null);
		System.assert(objOrderItems.CostPerUnit == null);
		System.assert(objOrderItems.RRPPerUnit == null);
		System.assert(objOrderItems.IncludesGst == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		BlackhawkNZOrderWrapper.Metadata objMetadata = new BlackhawkNZOrderWrapper.Metadata(System.JSON.createParser(json));
		System.assert(objMetadata != null);
		System.assert(objMetadata.Barcode == null);
		System.assert(objMetadata.Pin == null);
		System.assert(objMetadata.ExpiryDate == null);
		System.assert(objMetadata.BarcodeType == null);
		System.assert(objMetadata.Balance == null);
		System.assert(objMetadata.LastBalanceCheckedDate == null);
		System.assert(objMetadata.Status == null);
		System.assert(objMetadata.LastStatusChangedDate == null);
		System.assert(objMetadata.IsBonusCard == null);
		System.assert(objMetadata.CardValue == null);
		System.assert(objMetadata.CardUrl == null);
		System.assert(objMetadata.SupportsBalanceCheck == null);
		System.assert(objMetadata.BalanceCheckUrl == null);
	}
}