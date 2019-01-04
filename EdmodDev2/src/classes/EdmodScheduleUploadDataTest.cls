@isTest
public class EdmodScheduleUploadDataTest {
    
    /* @Test:excTest
     * @Description:This function calls the exc function of class EdmodScheduleRequest
     */
    @isTest static void excTest() {
        Test.startTest();
        EdmodScheduleUploadData scheduleUploadData = new EdmodScheduleUploadData();
        String platform = 'CodeHS';
        String programType = 'TS';
        String URL = 'http://www.mocky.io/v2/5b98fe443200007c0013fb16';
        scheduleUploadData.runDemoURL(programType, platform);
        scheduleUploadData.getDataURLList();
        Test.stopTest();
    }
    
    /* @Test:executeTest
     * @Description: This function tests the execute function of class EdmodScheduleRequest, 
     * which is used to schedule Apex job.
     */    
    @isTest static void executeTest() {
        String CRON_EXP = '0 0 0 15 3 ? 2022';
        Test.startTest();

        // Schedule the test job
        String jobId = System.schedule('EdmodScheduleUploadData',
            CRON_EXP,
            new EdmodScheduleUploadData());

        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,
            NextFireTime
            FROM CronTrigger WHERE id =: jobId
        ];

        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);

        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);

        // Verify the next time the job will run
        System.assertEquals('2022-03-15 00:00:00', String.valueOf(ct.NextFireTime));

        Test.stopTest();
    }
}