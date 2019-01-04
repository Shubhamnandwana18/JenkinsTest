public class TestScheduleClass implements Schedulable {

    List < String > url = new List < String > ();
    List < String > programType = new List < String > ();
    List < String > platform = new List < String > ();

    /*
     * initialiseRequests
     * @description update url, programType, platform lists
     */
    public void initialiseRequests() {
        url.add('https://codehs.com/techstart/csv/csv?secret=pOZPHxiYCHm59lR0ndGJfSLEf0eLpEF6');
        programType.add('TS');
        platform.add('CODEHS');
    }
    
    /*
     * executeRequest
     * @description method use to execute demo URLs.
     * @param URL: demo URL
     * @programType: TS/EFTW
     * @platform: CODEHS/KHAN_ACADEMY
     * 
     */
	public void executeRequest(String URL,String programType,String platform){
        EdmodExecuteBatches executeBatches = new EdmodExecuteBatches(URL, platform,programType);           
        Database.executeBatch(executeBatches);
    }      

    /*
     * execute
     * @description Executes the scheduled Apex job.
     */
    public void execute(SchedulableContext sc) {
        initialiseRequests();
        for (Integer i = 0; i < url.size(); i++) {
            EdmodExecuteBatches executeBatches = new EdmodExecuteBatches(url.get(i),platform.get(i),programType.get(i));           
            Database.executeBatch(executeBatches);
        }
        
    }
}