/*
 * EdmodScheduleImportURLData class schedule the requests to import URL data. 
 * Schedulable interface is implemeneted to schedule run at different intervals.
 */
public class EdmodScheduleImportURLData implements Schedulable {

    List < String > url = new List < String > ();
    List < String > programType = new List < String > ();
    List < String > platform = new List < String > ();
    
    /*
     * @description Add url, programType, platform to list.
     * @param URL: 	demo URL
     * @param programType TS/EFTW
     * @param platform 	CODEHS/KHAN_ACADEMY
     */
   
    public  void getDataURLList() {
        url.add('https://codehs.com/techstart/csv/csv?secret=pOZPHxiYCHm59lR0ndGJfSLEf0eLpEF6');
        programType.add('TS');
        platform.add('CODEHS');
    }

    /*
     * @description method used to fire demo URLs.
     * @param URL: 	demo URL
     * @param programType TS/EFTW
     * @param platform 	CODEHS/KHAN_ACADEMY
     * 
     */
    public void runDemoURL(String URL, String programType, String platform) {
        EdmodWebCallout.getWebURLResponse(url, programType, platform);
    }

    /*
     * @description Executes the scheduled Apex job.
     */
    public void execute(SchedulableContext sc) {
        getDataURLList(); 
        for (Integer i = 0; i < url.size(); i++) {
            EdmodWebCallout.getWebURLResponse(url.get(i), programType.get(i), platform.get(i));
        }
        
    }
}