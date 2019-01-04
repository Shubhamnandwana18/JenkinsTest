@isTest
public class EdmodScheduleRequestTest {
	@isTest static void excTest(){
        Test.startTest();
    	EdmodScheduleRequest scheduleRequest = new EdmodScheduleRequest();
        scheduleRequest.executeRequest('http://www.mocky.io/v2/5b9a67a23000004b00e7c0b5','TS','CODEHS');
        Test.stopTest();

    }
    @isTest static void executeTest(){
        String CRON_EXP = '0 0 0 15 3 ? 2022';
        Test.startTest();

        // Schedule the test job
        String jobId = System.schedule('EdmodScheduleRequest',
                                       CRON_EXP, 
                                       new EdmodScheduleRequest());
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                          NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);
        
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);

        // Verify the next time the job will run
        System.assertEquals('2022-03-15 00:00:00', String.valueOf(ct.NextFireTime));
        
        Test.stopTest();
    }
}