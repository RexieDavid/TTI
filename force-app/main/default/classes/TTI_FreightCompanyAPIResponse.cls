public class TTI_FreightCompanyAPIResponse {
    
    public Boolean Success;
    public string Tracking_references;
    public string Error_message;
    public string Error_code;
    public string inputRequest;
    public string Reject_code;
    public CourierPostResponse objCourierPostResponse;
    
    public class CourierPostResponse{
        public boolean success;
        public String message_id;	//6d1c28d0-0598-11e8-a66e-06ef5e538d28
        public cls_results results;
        
    }
    public class cls_results {
        public String response_type;	//AP
        public String job_id;	//27268347
        public String job_number;	//6643725
        public String customer_reference;	//91903017
        public String reject_code;	//0
        public cls_tracking_references[] tracking_references;
    }
    public class cls_tracking_references {
        public String tracking_reference;	//FF147685323NZ
    }
    
}