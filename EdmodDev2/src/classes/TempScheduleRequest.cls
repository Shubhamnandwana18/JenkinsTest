/*
 * EdmodScheduleRequest class schedule the requests. Schedulable interface is implemeneted to schedule run at different intervals.
 */
global class TempScheduleRequest implements Schedulable {

    List < String > url = new List < String > ();
    List < String > programType = new List < String > ();
    List < String > platform = new List < String > ();

    /*
     * getDataURLList
     * @description update url, programType, platform lists
     */
    public void getDataURLList() {
        url.add('http://www.mocky.io/v2/5b98fe443200007c0013fb16');
        programType.add('TS');
        platform.add('CODEHS');
    }
    
    /*
     * runDemoURL
     * @description method use to fire demo URLs.
     * @param URL: demo URL
     * @programType: TS/EFTW
     * @platform: CODEHS/KHAN_ACADEMY
     * 
     */
	public void runDemoURL(String URL,String programType,String platform){
         EdmodWebCallout web = new EdmodWebCallout();
         web.getWebURLResponse(url,programType, platform);        
    }      

    /*
     * execute
     * @description Executes the scheduled Apex job.
     */
    global void execute(SchedulableContext sc) {
        getDataURLList();
        EdmodWebCallout web = new EdmodWebCallout();
        for (Integer i = 0; i < url.size(); i++) {
            web.getWebURLResponse(url.get(i), programType.get(i), platform.get(i));
        }
    }
}