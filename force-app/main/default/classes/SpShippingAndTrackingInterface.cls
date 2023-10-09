public interface SpShippingAndTrackingInterface {

    List<SpShipment> createShipments(String accountNumber, String jsonRequest);
    List<SpLabel> createLabels(String accountNumber, String jsonRequest);
    SpLabel getLabel(String accountNumber, String requestId);
    SpShipment updateShipment(String accountNumber, String shipmentId, String jsonRequest);
}