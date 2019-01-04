/*
 * EdmodImportJobScheduler class can schedule webcallout/upload job. 
 * 
 */
public class EdmodImportJobScheduler
{
    public void EdmodImportJobScheduler() {}
    /*
     * @description schedules cron jobs
     *      
     */
    public static void start()
    {
        //Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        System.schedule('Webcallout Job', '0 42 * * * ? 2018', new EdmodScheduleRequest()); 
    }
}