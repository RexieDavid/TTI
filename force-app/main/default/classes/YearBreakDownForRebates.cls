public with sharing class YearBreakDownForRebates {

    public static Map<String, List<YearlyBreakDown>> getYearlyBreakDown(Set<String> cIds){
        List<Contract> con = [SELECt Id, StartDate, EndDate, ContractTerm FROM Contract WHERE Id IN: cIds];

        List<YearlyBreakDown> years;
        Map<String, List<YearlyBreakDown>> contractYearsBreakDown = new Map<String, List<YearlyBreakDown>>();
        Date sd, ed;
        Boolean f;

        for(Contract c : con){
            Integer cYears =  c.ContractTerm/12;
            years = new List<YearlyBreakDown>();
            for(Integer i=0; i<cYears; i++){
                sd = i==0 ? c.StartDate : sd.addMonths(12);
                ed = sd.addMonths(12).addDays(-1);
                f  = Date.today()>=sd && Date.today()<=ed ? TRUE : FALSE;
                years.add(new YearlyBreakDown(sd, ed, f, c.Id));
            }
            contractYearsBreakDown.put(c.Id, years);
        }

        return contractYearsBreakDown;        
    }

	public static YearlyBreakDown getCurrentYear(List<YearlyBreakDown> yrBreakDowns, Date dt){
	    YearlyBreakDown currentBreakDown;
	    for(YearlyBreakDown yr : yrBreakDowns){
	        if(dt >= yr.StartDate && dt <= yr.EndDate){
	            currentBreakDown = yr;
	            break;
	        }
	    }        
	    return currentBreakDown==null ? null : currentBreakDown;
	}    


    public Class YearlyBreakDown{
        public Date StartDate{get; set;}
        public Date EndDate{get; set;}
        public Boolean isCurrent{get; set;}
        public String contractId{get; set;}
        public YearlyBreakDown(Date s, Date e, Boolean c, String cId){
            StartDate = s;
            EndDate   = e;
            isCurrent = c;
            contractId= cId;
        }
    }

}