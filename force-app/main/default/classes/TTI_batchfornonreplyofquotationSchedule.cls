global class TTI_batchfornonreplyofquotationSchedule implements Schedulable {

     global void execute(SchedulableContext SC) {
        TTI_batchfornonreplyofquotation obj = new TTI_batchfornonreplyofquotation(); 
        Database.executebatch(obj , 200);
     }
}