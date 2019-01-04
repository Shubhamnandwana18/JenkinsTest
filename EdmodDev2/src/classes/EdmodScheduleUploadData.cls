/*
 * EdmodScheduleUploadData class schedule the data upload requests. 
 * Schedulable interface is implemeneted to schedule run at different intervals.
 */
global class EdmodScheduleUploadData implements Schedulable {

    List < String > programType = new List < String > ();
    List < String > platform = new List < String > ();

    /*
     * @description  programType, platform to list.
     * @param programType TS/EFTW
     * @param platform 	CODEHS/KHAN_ACADEMY
     */
   
    public  void getDataURLList() {
        programType.add('TS');
        platform.add('CODEHS');
    }

    /*
     * @description method used to upload demo data.
   	 * @param programType TS/EFTW
     * @param platform 	CODEHS/KHAN_ACADEMY
     * 
     */
    public void runDemoURL(String programType, String platform) {
        EdmodCSVParser csvparser = new EdmodCSVParser();
        csvparser.parseHttpResponse(programType, platform);
    }

    /*
     * @description Executes the scheduled Apex job.
     */
    global void execute(SchedulableContext sc) {
        getDataURLList();
        EdmodCSVParser csvparser = new EdmodCSVParser();
        for (Integer i = 0; i < programType.size(); i++) {
            csvparser.parseHttpResponse(programType.get(i), platform.get(i));
        }
        
    }
   
}