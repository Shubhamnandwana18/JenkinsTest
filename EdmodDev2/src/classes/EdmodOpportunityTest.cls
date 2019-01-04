@isTest
public class EdmodOpportunityTest {
    
    /* @Test:opportunityCompleteFlowTest
     * @Description:This function test complete flow for opportunity, it includes different stages test and time updation test
     * Below tests are done in sequence
     * 
     * 1.Only onboarding stage S1 (0,0,0)                                                             
     * 2.Only onboarding  stage S1, S2(4,0,0)                                                         
     * 3.Only onboarding  stage S1, S2, S3 (4,1,0)                                                    
     * 4.Move backward  to Onboarding S1, S2 (4,0,0)                                                  
     * 5.Move Forward to onboarding S1, S2, S3, S4 and nurturing S1 (14,1,1)                           
     * 6.Increase % (14,7,7)                                                 
     * 7.Move backward to onboarding S1, S2  (4,0,0)                                                  
     * 8.More than 75 % of students completed the projects(14,11,11)                                   
     * 9.Move forward to onboarding stage S1, S2, S3, S4 and nurturing stages to S1, S2, S3, S4(14,14,14)
     */
    
    Static List <String> headers = new List< String >{'ID', 'First Name', 
        'Last Name','Email','Phone','Date Joined',
        'LastLogin','Class Code', 'School','School NCES ID','District','District NCES ID',
        'City', 'State','Country','Num Sections','Num Students', 
        'Num Students Who Completed A Project', 'Num Student Program Shares',  
        'Teacher Checklist Completed 1','Teacher Checklist Completed 2', 
        'Teacher Checklist Completed 3','Teacher Checklist Completed 4',     
        'Teacher Checklist Completed 5','Students Completed Music 1 Hour', 
        'Students Completed Music 10 Hour','Students Completed Art 1 Hour',      
        'Students Completed Art 10 Hour','Students Completed Sports 1 Hour','Students Completed Sports 10 Hour', 
        'Students Started Music 1 Hour','Students Started Art 1 Hour', 
        'Students Started Sports 1 Hour','Students Started Music 10 Hour', 
        'Students Started Art 10 Hour','Students Started Sports 10 Hour','Num Students Who Started A Project'};
    
    @isTest static void opportunityCompleteFlowTest() {
        Test.startTest();
        List < List < String >> csvData = getCSVDataOnboardingStage_S1();
        insertProgramTest();
        Id jobId = '7074D00000OOhstQAD';
        DateTime OS1;
        DateTime OS2;
        DateTime OS3;
        DateTime OS4;
        DateTime NS1;
        DateTime NS2;
        DateTime NS3;
        DateTime NS4;
        
        //Only onboarding stage S1 (0,0,0) 
        EdmodUploadCSVRecords uploadCSVRecordsInitial = new EdmodUploadCSVRecords(csvData, 'TS', 'CODEHS',jobId);
        uploadCSVRecordsInitial.processAccounts();
        List < Opportunity > onboardingOpportunityResultList = [Select ID, Name, Type,StageName, S1__c, S2__c, S3__c, S4__c from Opportunity 
                                                                where Type='ONBOARDING'];
        List < Opportunity > nurturingOpportunityResultList = [Select ID, Name, Type,StageName, S1__c, S2__c, S3__c, S4__c from Opportunity 
                                                               where Type='NURTURING'];
        
        OS1=DateTime.valueOf(onboardingOpportunityResultList.get(0).S1__c);
        System.assertEquals('S1: TEACHER_SIGNED_UP', onboardingOpportunityResultList.get(0).StageName);
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S1__c)));
        System.assertEquals(true,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S2__c)));
        System.assertEquals(true, string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S3__c)));
        System.assertEquals(true, string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S4__c)));
        
        if(!nurturingOpportunityResultList.isEmpty()){
            System.assertEquals(true,string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S1__c)));
            System.assertEquals(true,string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S2__c)));
            System.assertEquals(true, string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S3__c)));
            System.assertEquals(true, string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S4__c)));
        }
        
        //Only onboarding  stage S1, S2(4,0,0)
        sleep(1000);
        csvData= getCSVDataOnboardingStage_S1_S2();
        
        uploadCSVRecordsInitial = new EdmodUploadCSVRecords(csvData, 'TS', 'CODEHS',jobId);
        uploadCSVRecordsInitial.processAccounts();
        onboardingOpportunityResultList = [Select ID, Name, Type,StageName, S1__c, S2__c, S3__c, S4__c from Opportunity 
                                           where Type='ONBOARDING'];
        nurturingOpportunityResultList = [Select ID, Name, Type,StageName, S1__c, S2__c, S3__c, S4__c from Opportunity 
                                          where Type='NURTURING'];
        
        OS2=DateTime.valueOf(onboardingOpportunityResultList.get(0).S2__c);
        System.assertEquals('S2: ATLEAST_ONE_STUDENT_SIGNEDUP', onboardingOpportunityResultList.get(0).StageName);
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S1__c)));
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S2__c)));
        System.assertEquals(true, string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S3__c)));
        System.assertEquals(true, string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S4__c)));
        System.assertEquals(true, OS1==DateTime.valueOf(onboardingOpportunityResultList.get(0).S1__c));
        
        if(!nurturingOpportunityResultList.isEmpty()){
            System.assertEquals(true,string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S1__c)));
            System.assertEquals(true,string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S2__c)));
            System.assertEquals(true, string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S3__c)));
            System.assertEquals(true, string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S4__c)));
        }
        
        System.assertEquals(false, OS1==OS2);
        
        //onboard s1,s2,s3
        sleep(1000);
        csvData= getCSVDataOnboardingStage_S1_S2_S3();
        
        uploadCSVRecordsInitial = new EdmodUploadCSVRecords(csvData, 'TS', 'CODEHS',jobId);
        uploadCSVRecordsInitial.processAccounts();
        onboardingOpportunityResultList = [Select ID, Name, Type,StageName, S1__c, S2__c, S3__c, S4__c from Opportunity 
                                           where Type='ONBOARDING'];
        nurturingOpportunityResultList = [Select ID, Name, Type,StageName, S1__c, S2__c, S3__c, S4__c from Opportunity 
                                          where Type='NURTURING'];
        
        OS3=DateTime.valueOf(onboardingOpportunityResultList.get(0).S3__c);
        System.assertEquals('S3: ATLEAST_ONE_STUDENT_STARTED_PROJECT', onboardingOpportunityResultList.get(0).StageName);
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S1__c)));
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S2__c)));
        System.assertEquals(false, string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S3__c)));
        System.assertEquals(true, string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S4__c)));
        System.assertEquals(true, OS1==DateTime.valueOf(onboardingOpportunityResultList.get(0).S1__c));
        System.assertEquals(true, OS2==DateTime.valueOf(onboardingOpportunityResultList.get(0).S2__c));
        
        if(!nurturingOpportunityResultList.isEmpty()){
            System.assertEquals(true,string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S1__c)));
            System.assertEquals(true,string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S2__c)));
            System.assertEquals(true, string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S3__c)));
            System.assertEquals(true, string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S4__c)));
        }
        
        System.assertEquals(false, OS1==OS2);
        System.assertEquals(false, OS2==OS3);
        
        
        //Move backward  to Onboarding S1, S2 (4,0,0)
        sleep(1000);
        csvData= getCSVDataOnboardingStage_S1_S2();
        
        uploadCSVRecordsInitial = new EdmodUploadCSVRecords(csvData, 'TS', 'CODEHS',jobId);
        uploadCSVRecordsInitial.processAccounts();
        onboardingOpportunityResultList = [Select ID, Name, Type,StageName, S1__c, S2__c, S3__c, S4__c from Opportunity 
                                           where Type='ONBOARDING'];
        nurturingOpportunityResultList = [Select ID, Name, Type,StageName, S1__c, S2__c, S3__c, S4__c from Opportunity 
                                          where Type='NURTURING'];
        
        System.assertEquals('S2: ATLEAST_ONE_STUDENT_SIGNEDUP', onboardingOpportunityResultList.get(0).StageName);
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S1__c)));
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S2__c)));
        System.assertEquals(false, string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S3__c)));
        System.assertEquals(true, string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S4__c)));
        System.assertEquals(true, OS1==DateTime.valueOf(onboardingOpportunityResultList.get(0).S1__c));
        System.assertEquals(true, OS2==DateTime.valueOf(onboardingOpportunityResultList.get(0).S2__c));
        System.assertEquals(true, OS3==DateTime.valueOf(onboardingOpportunityResultList.get(0).S3__c));
        
        if(!nurturingOpportunityResultList.isEmpty()){
            System.assertEquals(true,string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S1__c)));
            System.assertEquals(true,string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S2__c)));
            System.assertEquals(true, string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S3__c)));
            System.assertEquals(true, string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S4__c)));
        }
        
        System.assertEquals(false, OS1==OS2);
        System.assertEquals(false, OS2==OS3);
        
        
        // Move Forward to onboarding S1, S2, S3, S4 and nurturing S1 (14,1,1)
        sleep(1000);
        csvData= getCSVDataStage_S1_S2_S3_S4_NS1();
        
        uploadCSVRecordsInitial = new EdmodUploadCSVRecords(csvData, 'TS', 'CODEHS',jobId);
        uploadCSVRecordsInitial.processAccounts();
        onboardingOpportunityResultList = [Select ID, Name, Type,StageName, S1__c, S2__c, S3__c, S4__c from Opportunity 
                                           where Type='ONBOARDING'];
        nurturingOpportunityResultList = [Select ID, Name, Type,StageName, S1__c, S2__c, S3__c, S4__c from Opportunity 
                                          where Type='NURTURING'];
        
        OS4=DateTime.valueOf(onboardingOpportunityResultList.get(0).S4__c);
        NS1=DateTime.valueOf(nurturingOpportunityResultList.get(0).S1__c);
        
        System.assertEquals('S4: ATLEAST_ONE_STUDENT_COMPLETED_PROJECT', onboardingOpportunityResultList.get(0).StageName);
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S1__c)));
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S2__c)));
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S3__c)));
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S4__c)));
        System.assertEquals(true, OS1==DateTime.valueOf(onboardingOpportunityResultList.get(0).S1__c));
        System.assertEquals(true, OS2==DateTime.valueOf(onboardingOpportunityResultList.get(0).S2__c));
        System.assertEquals(true, OS3==DateTime.valueOf(onboardingOpportunityResultList.get(0).S3__c));
        
        if(!nurturingOpportunityResultList.isEmpty()){
            System.assertEquals('S1: UPTO_50%_STUDENTS_COMPLETED_PROJECT', nurturingOpportunityResultList.get(0).StageName);
            System.assertEquals(false,string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S1__c)));
            System.assertEquals(true,string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S2__c)));
            System.assertEquals(true, string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S3__c)));
            System.assertEquals(true, string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S4__c)));
        }else{
            System.assert(false, 'Error has occured while testing Nurturing Opportunity Insertion');
        }
        
        System.assertEquals(false, OS1==OS2);
        System.assertEquals(false, OS2==OS3);
        System.assertEquals(false, OS3==OS4);
        System.assertEquals(true, OS4==NS1);
        
        //Increase % (14,7,7)
        sleep(1000);
        csvData= getCSVDataStage_S1_S2_S3_S4_NS1_NS2();
        
        uploadCSVRecordsInitial = new EdmodUploadCSVRecords(csvData, 'TS', 'CODEHS',jobId);
        uploadCSVRecordsInitial.processAccounts();
        onboardingOpportunityResultList = [Select ID, Name, Type,StageName, S1__c, S2__c, S3__c, S4__c from Opportunity 
                                           where Type='ONBOARDING'];
        nurturingOpportunityResultList = [Select ID, Name, Type,StageName, S1__c, S2__c, S3__c, S4__c from Opportunity 
                                          where Type='NURTURING'];
        
        NS2=DateTime.valueOf(nurturingOpportunityResultList.get(0).S2__c);
        
        System.assertEquals('S4: ATLEAST_ONE_STUDENT_COMPLETED_PROJECT', onboardingOpportunityResultList.get(0).StageName);
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S1__c)));
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S2__c)));
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S3__c)));
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S4__c)));
        System.assertEquals(true, OS1==DateTime.valueOf(onboardingOpportunityResultList.get(0).S1__c));
        System.assertEquals(true, OS2==DateTime.valueOf(onboardingOpportunityResultList.get(0).S2__c));
        System.assertEquals(true, OS3==DateTime.valueOf(onboardingOpportunityResultList.get(0).S3__c));
        System.assertEquals(true, OS4==DateTime.valueOf(onboardingOpportunityResultList.get(0).S4__c));            
        
        if(!nurturingOpportunityResultList.isEmpty()){
            System.assertEquals('S2: UPTO_75%_STUDENTS_COMPLETED_PROJECT', nurturingOpportunityResultList.get(0).StageName);
            System.assertEquals(false,string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S1__c)));
            System.assertEquals(false,string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S2__c)));
            System.assertEquals(true, string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S3__c)));
            System.assertEquals(true, string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S4__c)));
            System.assertEquals(true, NS1==DateTime.valueOf(nurturingOpportunityResultList.get(0).S1__c)); 
        }else{
            System.assert(false, 'Error has occured while testing Nurturing Opportunity Insertion');
        }
        
        System.assertEquals(false, OS1==OS2);
        System.assertEquals(false, OS2==OS3);
        System.assertEquals(false, OS3==OS4);
        System.assertEquals(true, OS4==NS1);
        System.assertEquals(false, NS1==NS2);
        
        //Move backward to onboarding S1, S2  (4,0,0)
        sleep(1000);
        csvData= getCSVDataOnboardingStage_S1_S2(); 
        
        uploadCSVRecordsInitial = new EdmodUploadCSVRecords(csvData, 'TS', 'CODEHS',jobId);
        uploadCSVRecordsInitial.processAccounts();
        onboardingOpportunityResultList = [Select ID, Name, Type,StageName, S1__c, S2__c, S3__c, S4__c from Opportunity 
                                           where Type='ONBOARDING'];
        nurturingOpportunityResultList = [Select ID, Name, Type,StageName, S1__c, S2__c, S3__c, S4__c from Opportunity 
                                          where Type='NURTURING'];
        
        System.assertEquals('S2: ATLEAST_ONE_STUDENT_SIGNEDUP', onboardingOpportunityResultList.get(0).StageName);
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S1__c)));
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S2__c)));
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S3__c)));
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S4__c)));
        System.assertEquals(true, OS1==DateTime.valueOf(onboardingOpportunityResultList.get(0).S1__c));
        System.assertEquals(true, OS2==DateTime.valueOf(onboardingOpportunityResultList.get(0).S2__c));
        System.assertEquals(true, OS3==DateTime.valueOf(onboardingOpportunityResultList.get(0).S3__c));
        System.assertEquals(true, OS4==DateTime.valueOf(onboardingOpportunityResultList.get(0).S4__c));
        
        if(!nurturingOpportunityResultList.isEmpty()){
            System.assertEquals('S1: UPTO_50%_STUDENTS_COMPLETED_PROJECT', nurturingOpportunityResultList.get(0).StageName);
            System.assertEquals(false,string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S1__c)));
            System.assertEquals(false,string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S2__c)));
            System.assertEquals(true, string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S3__c)));
            System.assertEquals(true, string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S4__c)));
            System.assertEquals(true, NS1==DateTime.valueOf(nurturingOpportunityResultList.get(0).S1__c));
            System.assertEquals(true, NS2==DateTime.valueOf(nurturingOpportunityResultList.get(0).S2__c));
            
        }else{
            System.assert(false, 'Error has occured while testing Nurturing Opportunity Insertion');
        }
        
        System.assertEquals(false, OS1==OS2);
        System.assertEquals(false, OS2==OS3);
        System.assertEquals(false, OS3==OS4);
        System.assertEquals(true, OS4==NS1);
        System.assertEquals(false, NS1==NS2);
        
        //More than 75 % of students completed the projects(14,11,11) 
        sleep(1000);
        csvData= getCSVDataStage_S1_S2_S3_S4_NS1_NS2_NS3();
        
        uploadCSVRecordsInitial = new EdmodUploadCSVRecords(csvData, 'TS', 'CODEHS',jobId);
        uploadCSVRecordsInitial.processAccounts();
        onboardingOpportunityResultList = [Select ID, Name, Type,StageName, S1__c, S2__c, S3__c, S4__c from Opportunity 
                                           where Type='ONBOARDING'];
        nurturingOpportunityResultList = [Select ID, Name, Type,StageName, S1__c, S2__c, S3__c, S4__c from Opportunity 
                                          where Type='NURTURING'];
        
        NS3=DateTime.valueOf(nurturingOpportunityResultList.get(0).S3__c);
        
        System.assertEquals('S4: ATLEAST_ONE_STUDENT_COMPLETED_PROJECT', onboardingOpportunityResultList.get(0).StageName);
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S1__c)));
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S2__c)));
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S3__c)));
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S4__c)));
        System.assertEquals(true, OS1==DateTime.valueOf(onboardingOpportunityResultList.get(0).S1__c));
        System.assertEquals(true, OS2==DateTime.valueOf(onboardingOpportunityResultList.get(0).S2__c));
        System.assertEquals(true, OS3==DateTime.valueOf(onboardingOpportunityResultList.get(0).S3__c));
        System.assertEquals(true, OS4==DateTime.valueOf(onboardingOpportunityResultList.get(0).S4__c));
        
        if(!nurturingOpportunityResultList.isEmpty()){
            System.assertEquals('S3: UPTO_100%_STUDENTS_COMPLETED_PROJECT', nurturingOpportunityResultList.get(0).StageName);
            System.assertEquals(false,string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S1__c)));
            System.assertEquals(false,string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S2__c)));
            System.assertEquals(false, string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S3__c)));
            System.assertEquals(true, string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S4__c)));
            System.assertEquals(true, NS1==DateTime.valueOf(nurturingOpportunityResultList.get(0).S1__c));
            System.assertEquals(true, NS2==DateTime.valueOf(nurturingOpportunityResultList.get(0).S2__c));
        }else{
            System.assert(false, 'Error has occured while testing Nurturing Opportunity Insertion');
        }
        
        System.assertEquals(false, OS3==OS4);
        System.assertEquals(false, OS3==NS1);
        System.assertEquals(true, OS4==NS1);
        System.assertEquals(false, NS1==NS2);
        System.assertEquals(false, NS2==NS3);
        
        //Move forward to onboarding stage S1, S2, S3, S4 and nurturing stages to S1, S2, S3, S4(14,14,14)
        sleep(1000);
        csvData= getCSVDataStage_S1_S2_S3_S4_NS1_NS2_NS3_NS4();
        
        uploadCSVRecordsInitial = new EdmodUploadCSVRecords(csvData, 'TS', 'CODEHS',jobId);
        uploadCSVRecordsInitial.processAccounts();
        onboardingOpportunityResultList = [Select ID, Name, Type,StageName, S1__c, S2__c, S3__c, S4__c from Opportunity 
                                           where Type='ONBOARDING'];
        nurturingOpportunityResultList = [Select ID, Name, Type,StageName, S1__c, S2__c, S3__c, S4__c from Opportunity 
                                          where Type='NURTURING'];
        
        NS4=DateTime.valueOf(nurturingOpportunityResultList.get(0).S4__c);
        
        System.assertEquals('S4: ATLEAST_ONE_STUDENT_COMPLETED_PROJECT', onboardingOpportunityResultList.get(0).StageName);
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S1__c)));
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S2__c)));
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S3__c)));
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S4__c)));
        System.assertEquals(true, OS1==DateTime.valueOf(onboardingOpportunityResultList.get(0).S1__c));
        System.assertEquals(true, OS2==DateTime.valueOf(onboardingOpportunityResultList.get(0).S2__c));
        System.assertEquals(true, OS3==DateTime.valueOf(onboardingOpportunityResultList.get(0).S3__c));
        System.assertEquals(true, OS4==DateTime.valueOf(onboardingOpportunityResultList.get(0).S4__c));
        
        if(!nurturingOpportunityResultList.isEmpty()){
            System.assertEquals('S4: 100%_STUDENTS_COMPLETED_PROJECT', nurturingOpportunityResultList.get(0).StageName);
            System.assertEquals(false,string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S1__c)));
            System.assertEquals(false,string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S2__c)));
            System.assertEquals(false, string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S3__c)));
            System.assertEquals(false, string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S4__c)));
            System.assertEquals(true, NS1==DateTime.valueOf(nurturingOpportunityResultList.get(0).S1__c));
            System.assertEquals(true, NS2==DateTime.valueOf(nurturingOpportunityResultList.get(0).S2__c));
            System.assertEquals(true, NS3==DateTime.valueOf(nurturingOpportunityResultList.get(0).S3__c));
        }else{
            System.assert(false, 'Error has occured while testing Nurturing Opportunity Insertion');
        }
        
        System.assertEquals(false, OS3==OS4);
        System.assertEquals(false, OS3==NS1);
        System.assertEquals(true,  OS4==NS1);
        System.assertEquals(false, NS1==NS2);
        System.assertEquals(false, NS2==NS3);
        System.assertEquals(false, NS3==NS4);
        
        Test.stopTest();
    }

    /*@Test 
     *@Description: No nurturing is triggered till all stages of onboarding opportunity are achieved.
     */
    @isTest static void do_not_trigger_nurturingStage() {
        Test.startTest();
        List < List < String >> csvData= getCSVDataOnboardingStage_S1_S2_S3();
        insertProgramTest();
        Id jobId = '7074D00000OOhstQAD';
        EdmodUploadCSVRecords uploadCSVRecordsInitial = new EdmodUploadCSVRecords(csvData, 'TS', 'CODEHS',jobId);
        uploadCSVRecordsInitial.processAccounts();
        List < Opportunity > onboardingOpportunityResultList = [Select ID, Name, Type,StageName, S1__c, S2__c, S3__c, S4__c from Opportunity 
                                           where Type='ONBOARDING'];
        List < Opportunity > nurturingOpportunityResultList = [Select ID, Name, Type,StageName, S1__c, S2__c, S3__c, S4__c from Opportunity 
                                          where Type='NURTURING'];
        System.assertEquals('S3: ATLEAST_ONE_STUDENT_STARTED_PROJECT', onboardingOpportunityResultList.get(0).StageName);
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S1__c)));
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S2__c)));
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S3__c)));
        System.assertEquals(true, string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S4__c)));
        if(!nurturingOpportunityResultList.isEmpty()){
            System.assertEquals(true,string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S1__c)));
            System.assertEquals(true,string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S2__c)));
            System.assertEquals(true, string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S3__c)));
            System.assertEquals(true, string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S4__c)));
        }
        Test.stopTest();
    }
    
    /*@Test 
     *@Description: Nurturing First Stage achieved when all Onboarding stages are completed.
     */
    @isTest static void trigger_nurturingStage() {
        Test.startTest();
        List < List < String >> csvData= getCSVDataStage_S1_S2_S3_S4_NS1();
        insertProgramTest();
        Id jobId = '7074D00000OOhstQAD';
        EdmodUploadCSVRecords uploadCSVRecordsInitial = new EdmodUploadCSVRecords(csvData, 'TS', 'CODEHS',jobId);
        uploadCSVRecordsInitial.processAccounts();
        List < Opportunity > onboardingOpportunityResultList = [Select ID, Name, Type,StageName, S1__c, S2__c, S3__c, S4__c from Opportunity 
                                           where Type='ONBOARDING'];
        List < Opportunity > nurturingOpportunityResultList = [Select ID, Name, Type,StageName, S1__c, S2__c, S3__c, S4__c from Opportunity 
                                          where Type='NURTURING'];
        System.assertEquals('S4: ATLEAST_ONE_STUDENT_COMPLETED_PROJECT', onboardingOpportunityResultList.get(0).StageName);
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S1__c)));
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S2__c)));
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S3__c)));
        System.assertEquals(false, string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S4__c)));
        if(!nurturingOpportunityResultList.isEmpty()){
            System.assertEquals('S1: UPTO_50%_STUDENTS_COMPLETED_PROJECT', nurturingOpportunityResultList.get(0).StageName);
            System.assertEquals(false,string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S1__c)));
            System.assertEquals(true,string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S2__c)));
            System.assertEquals(true, string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S3__c)));
            System.assertEquals(true, string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S4__c)));
        }
        Test.stopTest();
    }
    
    /*@Test 
     *@Description: All Onboarding and Nurturing stages are achived in one go.
     */
    @isTest static void all_stages_triggered() {
        Test.startTest();
        List < List < String >> csvData= getCSVDataStage_S1_S2_S3_S4_NS1_NS2_NS3_NS4();
        insertProgramTest();
        Id jobId = '7074D00000OOhstQAD';
        EdmodUploadCSVRecords uploadCSVRecordsInitial = new EdmodUploadCSVRecords(csvData, 'TS', 'CODEHS',jobId);
        uploadCSVRecordsInitial.processAccounts();
        List < Opportunity > onboardingOpportunityResultList = [Select ID, Name, Type,StageName, S1__c, S2__c, S3__c, S4__c from Opportunity 
                                           where Type='ONBOARDING'];
        List < Opportunity > nurturingOpportunityResultList = [Select ID, Name, Type,StageName, S1__c, S2__c, S3__c, S4__c from Opportunity 
                                          where Type='NURTURING'];
        System.assertEquals('S4: ATLEAST_ONE_STUDENT_COMPLETED_PROJECT', onboardingOpportunityResultList.get(0).StageName);
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S1__c)));
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S2__c)));
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S3__c)));
        System.assertEquals(false, string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S4__c)));
        if(!nurturingOpportunityResultList.isEmpty()){
            System.assertEquals('S4: 100%_STUDENTS_COMPLETED_PROJECT', nurturingOpportunityResultList.get(0).StageName);
            System.assertEquals(false,string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S1__c)));
            System.assertEquals(false,string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S2__c)));
            System.assertEquals(false, string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S3__c)));
            System.assertEquals(false, string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S4__c)));
        }
        Test.stopTest();
    }
    
    /*@Test 
     *@Description: All stdudents left  after achiving all stages.
     */
    @isTest static void all_students_left() {
        Test.startTest();
        List < List < String >> csvData= getCSVDataStage_S1_S2_S3_S4_NS1_NS2_NS3_NS4();
        insertProgramTest();
        Id jobId = '7074D00000OOhstQAD';
        DateTime OS1;
        DateTime OS2;
        DateTime OS3;
        DateTime OS4;
        DateTime NS1;
        DateTime NS2;
        DateTime NS3;
        DateTime NS4;
        EdmodUploadCSVRecords uploadCSVRecordsInitial = new EdmodUploadCSVRecords(csvData, 'TS', 'CODEHS',jobId);
        uploadCSVRecordsInitial.processAccounts();
        List < Opportunity > onboardingOpportunityResultList = [Select ID, Name, Type,StageName, S1__c, S2__c, S3__c, S4__c from Opportunity 
                                                                where Type='ONBOARDING'];
        List < Opportunity > nurturingOpportunityResultList = [Select ID, Name, Type,StageName, S1__c, S2__c, S3__c, S4__c from Opportunity 
                                          where Type='NURTURING'];
        System.assertEquals('S4: ATLEAST_ONE_STUDENT_COMPLETED_PROJECT', onboardingOpportunityResultList.get(0).StageName);
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S1__c)));
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S2__c)));
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S3__c)));
        System.assertEquals(false, string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S4__c)));
        if(!nurturingOpportunityResultList.isEmpty()){
            System.assertEquals('S4: 100%_STUDENTS_COMPLETED_PROJECT', nurturingOpportunityResultList.get(0).StageName);
            System.assertEquals(false,string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S1__c)));
            System.assertEquals(false,string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S2__c)));
            System.assertEquals(false, string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S3__c)));
            System.assertEquals(false, string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S4__c)));
        }
        System.debug('nurturingOpportunityResultList.isEmpty():'+nurturingOpportunityResultList.isEmpty());
        
        
        OS1=DateTime.valueOf(onboardingOpportunityResultList.get(0).S1__c);
        OS2=DateTime.valueOf(onboardingOpportunityResultList.get(0).S2__c);
        OS3=DateTime.valueOf(onboardingOpportunityResultList.get(0).S3__c);
        OS4=DateTime.valueOf(onboardingOpportunityResultList.get(0).S4__c);
        NS1=DateTime.valueOf(nurturingOpportunityResultList.get(0).S1__c);
        NS2=DateTime.valueOf(nurturingOpportunityResultList.get(0).S2__c);
        NS3=DateTime.valueOf(nurturingOpportunityResultList.get(0).S3__c);
        NS4=DateTime.valueOf(nurturingOpportunityResultList.get(0).S4__c);
        
        sleep(1000);
        csvData= getCSVDataOnboardingStage_S1();
        uploadCSVRecordsInitial = new EdmodUploadCSVRecords(csvData, 'TS', 'CODEHS',jobId);
        uploadCSVRecordsInitial.processAccounts();
        onboardingOpportunityResultList = [Select ID, Name, Type,StageName, S1__c, S2__c, S3__c, S4__c from Opportunity 
                                           where Type='ONBOARDING'];
        nurturingOpportunityResultList = [Select ID, Name, Type,StageName, S1__c, S2__c, S3__c, S4__c from Opportunity 
                                          where Type='NURTURING'];
        System.assertEquals('S1: TEACHER_SIGNED_UP', onboardingOpportunityResultList.get(0).StageName);
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S1__c)));
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S2__c)));
        System.assertEquals(false, string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S3__c)));
        System.assertEquals(false, string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S4__c)));
        if(!nurturingOpportunityResultList.isEmpty()){
            System.assertEquals('S1: UPTO_50%_STUDENTS_COMPLETED_PROJECT', nurturingOpportunityResultList.get(0).StageName);
            System.assertEquals(false,string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S1__c)));
            System.assertEquals(false,string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S2__c)));
            System.assertEquals(false, string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S3__c)));
            System.assertEquals(false, string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S4__c)));
        }
        
        System.assertEquals(true, OS1==DateTime.valueOf(onboardingOpportunityResultList.get(0).S1__c));
        System.assertEquals(true, OS2==DateTime.valueOf(onboardingOpportunityResultList.get(0).S2__c));
        System.assertEquals(true, OS3==DateTime.valueOf(onboardingOpportunityResultList.get(0).S3__c));
        System.assertEquals(true, OS4==DateTime.valueOf(onboardingOpportunityResultList.get(0).S4__c));
        System.assertEquals(true, NS1==DateTime.valueOf(nurturingOpportunityResultList.get(0).S1__c));
        System.assertEquals(true, NS2==DateTime.valueOf(nurturingOpportunityResultList.get(0).S2__c));
        System.assertEquals(true, NS3==DateTime.valueOf(nurturingOpportunityResultList.get(0).S3__c));
        System.assertEquals(true, NS4==DateTime.valueOf(nurturingOpportunityResultList.get(0).S4__c));
        
        Test.stopTest();
    }
    
    /*@Test 
     *@Description: Nurturing stages NS2, NS3, NS4 are only achieved when at least 14 students signed up.
     */
    @isTest static void min_students_for_nurturing_NS2() {
        Test.startTest();
        //Initial (4,1,1)
        List < List < String >> csvData= getSmallCSVDataStage_S1_S2_S3_S4_NS1();
        insertProgramTest();
        Id jobId = '7074D00000OOhstQAD';
        
        DateTime OS4;
        DateTime NS1;
        DateTime NS2;
        EdmodUploadCSVRecords uploadCSVRecordsInitial = new EdmodUploadCSVRecords(csvData, 'TS', 'CODEHS',jobId);
        uploadCSVRecordsInitial.processAccounts();
        List < Opportunity > onboardingOpportunityResultList = [Select ID, Name, Type,StageName, S1__c, S2__c, S3__c, S4__c from Opportunity 
                                                                where Type='ONBOARDING'];
        List < Opportunity > nurturingOpportunityResultList = [Select ID, Name, Type,StageName, S1__c, S2__c, S3__c, S4__c from Opportunity 
                                                               where Type='NURTURING'];
        
        OS4=DateTime.valueOf(onboardingOpportunityResultList.get(0).S4__c);
        NS1=DateTime.valueOf(nurturingOpportunityResultList.get(0).S1__c);
        
        System.assertEquals('S4: ATLEAST_ONE_STUDENT_COMPLETED_PROJECT', onboardingOpportunityResultList.get(0).StageName);
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S1__c)));
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S2__c)));
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S3__c)));
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S4__c)));
        
        if(!nurturingOpportunityResultList.isEmpty()){
            System.assertEquals('S1: UPTO_50%_STUDENTS_COMPLETED_PROJECT', nurturingOpportunityResultList.get(0).StageName);
            System.assertEquals(false,string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S1__c)));
            System.assertEquals(true,string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S2__c)));
            System.assertEquals(true, string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S3__c)));
            System.assertEquals(true, string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S4__c)));
        }else{
            System.assert(false, 'Error has occured while testing Nurturing Opportunity Insertion');
        }
        
        System.assertEquals(true, OS4==NS1);
        //Increase % (4,3,3) should be invalid
        sleep(1000);
        csvData= getSmallCSVDataStage_S1_S2_S3_S4_NS1_NS2();
        
        uploadCSVRecordsInitial = new EdmodUploadCSVRecords(csvData, 'TS', 'CODEHS',jobId);
        uploadCSVRecordsInitial.processAccounts();
        onboardingOpportunityResultList = [Select ID, Name, Type,StageName, S1__c, S2__c, S3__c, S4__c from Opportunity 
                                           where Type='ONBOARDING'];
        nurturingOpportunityResultList = [Select ID, Name, Type,StageName, S1__c, S2__c, S3__c, S4__c from Opportunity 
                                          where Type='NURTURING'];
        
        NS2=DateTime.valueOf(nurturingOpportunityResultList.get(0).S2__c);
        
        System.assertEquals('S4: ATLEAST_ONE_STUDENT_COMPLETED_PROJECT', onboardingOpportunityResultList.get(0).StageName);
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S1__c)));
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S2__c)));
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S3__c)));
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S4__c)));           
        
        if(!nurturingOpportunityResultList.isEmpty()){
            System.assertEquals('S1: UPTO_50%_STUDENTS_COMPLETED_PROJECT', nurturingOpportunityResultList.get(0).StageName);
            System.assertEquals(false,string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S1__c)));
            System.assertEquals(true,string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S2__c)));
            System.assertEquals(true, string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S3__c)));
            System.assertEquals(true, string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S4__c)));
        }else{
            System.assert(false, 'Error has occured while testing Nurturing Opportunity Insertion');
        }
        
        //Increase number of students (14,7,7), should be valid
        sleep(1000);
        csvData= getCSVDataStage_S1_S2_S3_S4_NS1_NS2();
        
        uploadCSVRecordsInitial = new EdmodUploadCSVRecords(csvData, 'TS', 'CODEHS',jobId);
        uploadCSVRecordsInitial.processAccounts();
        onboardingOpportunityResultList = [Select ID, Name, Type,StageName, S1__c, S2__c, S3__c, S4__c from Opportunity 
                                           where Type='ONBOARDING'];
        nurturingOpportunityResultList = [Select ID, Name, Type,StageName, S1__c, S2__c, S3__c, S4__c from Opportunity 
                                          where Type='NURTURING'];
        
        
        System.assertEquals('S4: ATLEAST_ONE_STUDENT_COMPLETED_PROJECT', onboardingOpportunityResultList.get(0).StageName);
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S1__c)));
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S2__c)));
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S3__c)));
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S4__c)));           
        
        if(!nurturingOpportunityResultList.isEmpty()){
            System.assertEquals('S2: UPTO_75%_STUDENTS_COMPLETED_PROJECT', nurturingOpportunityResultList.get(0).StageName);
            System.assertEquals(false,string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S1__c)));
            System.assertEquals(false,string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S2__c)));
            System.assertEquals(true, string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S3__c)));
            System.assertEquals(true, string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S4__c))); 
            NS2=DateTime.valueOf(nurturingOpportunityResultList.get(0).S2__c);
        }else{
            System.assert(false, 'Error has occured while testing Nurturing Opportunity Insertion');
        }
        //Increase number of students (4,3,3), should be invalid
        sleep(1000);
        csvData= getSmallCSVDataStage_S1_S2_S3_S4_NS1_NS2_NS3();
        
        uploadCSVRecordsInitial = new EdmodUploadCSVRecords(csvData, 'TS', 'CODEHS',jobId);
        uploadCSVRecordsInitial.processAccounts();
        onboardingOpportunityResultList = [Select ID, Name, Type,StageName, S1__c, S2__c, S3__c, S4__c from Opportunity 
                                           where Type='ONBOARDING'];
        nurturingOpportunityResultList = [Select ID, Name, Type,StageName, S1__c, S2__c, S3__c, S4__c from Opportunity 
                                          where Type='NURTURING'];
        
        
        System.assertEquals('S4: ATLEAST_ONE_STUDENT_COMPLETED_PROJECT', onboardingOpportunityResultList.get(0).StageName);
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S1__c)));
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S2__c)));
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S3__c)));
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S4__c)));           
        
        if(!nurturingOpportunityResultList.isEmpty()){
            System.assertEquals('S2: UPTO_75%_STUDENTS_COMPLETED_PROJECT', nurturingOpportunityResultList.get(0).StageName);
            System.assertEquals(false,string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S1__c)));
            System.assertEquals(false,string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S2__c)));
            System.assertEquals(true, string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S3__c)));
            System.assertEquals(true, string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S4__c)));
            System.assertEquals(NS2,DateTime.valueOf(nurturingOpportunityResultList.get(0).S2__c));
            NS2=DateTime.valueOf(nurturingOpportunityResultList.get(0).S2__c);
        }else{
            System.assert(false, 'Error has occured while testing Nurturing Opportunity Insertion');
        }
        //Decrease number of students (4,4,4), StageName for nurturing should not change.
        sleep(1000);
        csvData= getSmallCSVDataStage_S1_S2_S3_S4_NS1_NS2_NS3_NS4();
        
        uploadCSVRecordsInitial = new EdmodUploadCSVRecords(csvData, 'TS', 'CODEHS',jobId);
        uploadCSVRecordsInitial.processAccounts();
        onboardingOpportunityResultList = [Select ID, Name, Type,StageName, S1__c, S2__c, S3__c, S4__c from Opportunity 
                                           where Type='ONBOARDING'];
        nurturingOpportunityResultList = [Select ID, Name, Type,StageName, S1__c, S2__c, S3__c, S4__c from Opportunity 
                                          where Type='NURTURING'];
        
        
        System.assertEquals('S4: ATLEAST_ONE_STUDENT_COMPLETED_PROJECT', onboardingOpportunityResultList.get(0).StageName);
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S1__c)));
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S2__c)));
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S3__c)));
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S4__c)));           
        
        if(!nurturingOpportunityResultList.isEmpty()){
            System.assertEquals('S2: UPTO_75%_STUDENTS_COMPLETED_PROJECT', nurturingOpportunityResultList.get(0).StageName);
            System.assertEquals(false,string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S1__c)));
            System.assertEquals(false,string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S2__c)));
            System.assertEquals(true, string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S3__c)));
            System.assertEquals(true, string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S4__c)));
            NS1=DateTime.valueOf(nurturingOpportunityResultList.get(0).S1__c);
            System.assertEquals(NS2,DateTime.valueOf(nurturingOpportunityResultList.get(0).S2__c));
            NS2=DateTime.valueOf(nurturingOpportunityResultList.get(0).S2__c);
        }else{
            System.assert(false, 'Error has occured while testing Nurturing Opportunity Insertion');
        }
        
        // Decrease number of students (14,1,1), StageName for nurturing should change.
        sleep(1000);
        csvData= getCSVDataStage_S1_S2_S3_S4_NS1();
        
        uploadCSVRecordsInitial = new EdmodUploadCSVRecords(csvData, 'TS', 'CODEHS',jobId);
        uploadCSVRecordsInitial.processAccounts();
        onboardingOpportunityResultList = [Select ID, Name, Type,StageName, S1__c, S2__c, S3__c, S4__c from Opportunity 
                                           where Type='ONBOARDING'];
        nurturingOpportunityResultList = [Select ID, Name, Type,StageName, S1__c, S2__c, S3__c, S4__c from Opportunity 
                                          where Type='NURTURING'];
        
        
        System.assertEquals('S4: ATLEAST_ONE_STUDENT_COMPLETED_PROJECT', onboardingOpportunityResultList.get(0).StageName);
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S1__c)));
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S2__c)));
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S3__c)));
        System.assertEquals(false,string.isBlank(String.valueOf(onboardingOpportunityResultList.get(0).S4__c)));
        
        if(!nurturingOpportunityResultList.isEmpty()){
            System.assertEquals('S1: UPTO_50%_STUDENTS_COMPLETED_PROJECT', nurturingOpportunityResultList.get(0).StageName);
            System.assertEquals(false,string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S1__c)));
            System.assertEquals(false,string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S2__c)));
            System.assertEquals(true, string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S3__c)));
            System.assertEquals(true, string.isBlank(String.valueOf(nurturingOpportunityResultList.get(0).S4__c)));
            System.assertEquals(true, NS1 == DateTime.valueOf(nurturingOpportunityResultList.get(0).S1__c));
            System.assertEquals(true, NS2 == DateTime.valueOf(nurturingOpportunityResultList.get(0).S2__c));
            
        }else{
            System.assert(false, 'Error has occured while testing Nurturing Opportunity Insertion');
        }
        
        Test.stopTest();
    }
    //Test data functions for opportunity

    static List< List< String >> getCSVDataOnboardingStage_S1(){
        List < List < String >> csvData = new List < List < String >> {headers,
            new List < String > {'760545',' Mahendra',' Patel',
                'mahendra@codehs.com','1231231234',' 2018-08-16 10:08:22',' 2018-08-22 11:08:40',
                '889AD',' DEERFIELD HIGH SCHOOL','1.72E+11',' TWP HSD 113','1719080',
                'DEERFIELD',' IL',' USA','1','0','0','8',' True',' True',' True',' False',
                'False','6','3','3','2','1','0','8','6','5','4','5','2','0'}
        };   
        return csvData;
    }
    
    static List< List< String >> getCSVDataOnboardingStage_S1_S2(){
        List < List < String >> csvData = new List < List < String >> {headers,
            new List < String > {'760545',' Mahendra',' Patel',
                ' mahendra@codehs.com','1231231234',' 2018-08-16 10:08:22',' 2018-08-22 11:08:40',
                '889AD',' DEERFIELD HIGH SCHOOL','1.72E+11',' TWP HSD 113','1719080',
                'DEERFIELD',' IL',' USA','1','4','0','8',' True',' True',' True',' False',
                'False','6','3','3','2','1','0','8','6','5','4','5','2','0'}  
        };    
        return csvData;
    }

    static List< List< String >> getCSVDataOnboardingStage_S1_S2_S3(){
        List < List < String >> csvData = new List < List < String >> {headers,
            new List < String > {'760545',' Mahendra',' Patel',
                'mahendra@codehs.com','1231231234',' 2018-08-16 10:08:22',' 2018-08-22 11:08:40',
                '889AD',' DEERFIELD HIGH SCHOOL','1.72E+11',' TWP HSD 113','1719080',
                'DEERFIELD',' IL',' USA','1','4','0','8',' True',' True',' True',' False',
                'False','6','3','3','2','1','0','8','6','5','4','5','2','1'}  
        };    
        return csvData;
    }    
        
    static List< List< String >> getCSVDataStage_S1_S2_S3_S4_NS1(){
        List < List < String >> csvData = new List < List < String >> {headers,
            new List < String > {'760545',' Mahendra',' Patel',
                'mahendra@codehs.com','1231231234',' 2018-08-16 10:08:22',' 2018-08-22 11:08:40',
                '889AD',' DEERFIELD HIGH SCHOOL','1.72E+11',' TWP HSD 113','1719080',
                'DEERFIELD',' IL',' USA','1','14','1','8',' True',' True',' True',' False',
                'False','6','3','3','2','1','0','8','6','5','4','5','2','1'}   
        };    
        return csvData;
    }  
        
    static List< List< String >> getCSVDataStage_S1_S2_S3_S4_NS1_NS2(){
        List < List < String >> csvData = new List < List < String >> {headers,
            new List < String > {'760545',' Mahendra',' Patel',
                'mahendra@codehs.com','1231231234',' 2018-08-16 10:08:22',' 2018-08-22 11:08:40',
                '889AD',' DEERFIELD HIGH SCHOOL','1.72E+11',' TWP HSD 113','1719080',
                'DEERFIELD',' IL',' USA','1','14','7','8',' True',' True',' True',' False',
                'False','6','3','3','2','1','0','8','6','5','4','5','2','7'}    
        };
        return csvData;
    }  
    
    static List< List< String >> getCSVDataStage_S1_S2_S3_S4_NS1_NS2_NS3(){
        List < List < String >> csvData = new List < List < String >> {headers,
            new List < String > {'760545',' Mahendra',' Patel',
                'mahendra@codehs.com','1231231234',' 2018-08-16 10:08:22',' 2018-08-22 11:08:40',
                '889AD',' DEERFIELD HIGH SCHOOL','1.72E+11',' TWP HSD 113','1719080',
                'DEERFIELD',' IL',' USA','1','14','11','8',' True',' True',' True',' False',
                'False','6','3','3','2','1','0','8','6','5','4','5','2','11'}   
        };     
        return csvData;  
    }  
    
    static List< List< String >> getCSVDataStage_S1_S2_S3_S4_NS1_NS2_NS3_NS4(){
        List < List < String >> csvData = new List < List < String >> {headers,
            new List < String > {'760545',' Mahendra',' Patel',
                'mahendra@codehs.com','1231231234',' 2018-08-16 10:08:22',' 2018-08-22 11:08:40',
                '889AD',' DEERFIELD HIGH SCHOOL','1.72E+11',' TWP HSD 113','1719080',
                'DEERFIELD',' IL',' USA','1','14','14','8',' True',' True',' True',' False',
                'False','6','3','3','2','1','0','8','6','5','4','5','2','14'}       
        };          
        return csvData;
    }  
    
    static List< List< String >> getSmallCSVDataStage_S1_S2_S3_S4_NS1(){
        List < List < String >> csvData = new List < List < String >> {headers,
            new List < String > {'760545',' Mahendra',' Patel',
                'mahendra@codehs.com','1231231234',' 2018-08-16 10:08:22',' 2018-08-22 11:08:40',
                '889AD',' DEERFIELD HIGH SCHOOL','1.72E+11',' TWP HSD 113','1719080',
                'DEERFIELD',' IL',' USA','1','4','1','8',' True',' True',' True',' False',
                'False','6','3','3','2','1','0','8','6','5','4','5','2','1'}   
        };    
        return csvData;
    } 
    static List< List< String >> getSmallCSVDataStage_S1_S2_S3_S4_NS1_NS2(){
        List < List < String >> csvData = new List < List < String >> {headers,
            new List < String > {'760545',' Mahendra',' Patel',
                'mahendra@codehs.com','1231231234',' 2018-08-16 10:08:22',' 2018-08-22 11:08:40',
                '889AD',' DEERFIELD HIGH SCHOOL','1.72E+11',' TWP HSD 113','1719080',
                'DEERFIELD',' IL',' USA','1','4','2','8',' True',' True',' True',' False',
                'False','6','3','3','2','1','0','8','6','5','4','5','2','2'}   
        };    
        return csvData;
    } 
	static List< List< String >> getSmallCSVDataStage_S1_S2_S3_S4_NS1_NS2_NS3(){
        List < List < String >> csvData = new List < List < String >> {headers,
            new List < String > {'760545',' Mahendra',' Patel',
                'mahendra@codehs.com','1231231234',' 2018-08-16 10:08:22',' 2018-08-22 11:08:40',
                '889AD',' DEERFIELD HIGH SCHOOL','1.72E+11',' TWP HSD 113','1719080',
                'DEERFIELD',' IL',' USA','1','4','3','8',' True',' True',' True',' False',
                'False','6','3','3','2','1','0','8','6','5','4','5','2','3'}   
        };    
        return csvData;
    } 
    static List< List< String >> getSmallCSVDataStage_S1_S2_S3_S4_NS1_NS2_NS3_NS4(){
        List < List < String >> csvData = new List < List < String >> {headers,
            new List < String > {'760545',' Mahendra',' Patel',
                'mahendra@codehs.com','1231231234',' 2018-08-16 10:08:22',' 2018-08-22 11:08:40',
                '889AD',' DEERFIELD HIGH SCHOOL','1.72E+11',' TWP HSD 113','1719080',
                'DEERFIELD',' IL',' USA','1','4','3','8',' True',' True',' True',' False',
                'False','6','3','3','2','1','0','8','6','5','4','5','2','3'}   
        };    
        return csvData;
    } 
    // Manual Insertion of Program Types for Testing Purposes
    static void insertProgramTest() {
        if ([Select ID from CurrentEducationProgram__c].size() < 1) {
            CurrentEducationProgram__c tsProgram = new CurrentEducationProgram__c();
            tsProgram.Name = 'TS_2018';
            tsProgram.ProgramType__c = 'TS';
            tsProgram.ProgramStartDate__c=Date.valueOf('2018-01-01');
            tsProgram.ProgramEndDate__c=Date.valueOf('2018-12-31');
            insert tsProgram;
            tsProgram = new CurrentEducationProgram__c();
            tsProgram.Name = 'EFTW_2018';
            tsProgram.ProgramType__c = 'EFTW';
            tsProgram.ProgramStartDate__c=Date.valueOf('2018-01-01');
            tsProgram.ProgramEndDate__c=Date.valueOf('2018-12-31');
            insert tsProgram;
        }
        if ([SELECT Id from TechStartPartners__c].size() < 1) {
            TechStartPartners__c tsPartners = new TechStartPartners__c();
            tsPartners.Name = 'DEERFIELD HIGH SCHOOL';
            tsPartners.State_or_Territory__c = 'IL';
            tsPartners.School_NCES_ID__c = '171908002193';
            insert tsPartners;
            tsPartners = new TechStartPartners__c();
            tsPartners.Name = 'Facebook';
            tsPartners.State_or_Territory__c = 'CA';
            tsPartners.School_NCES_ID__c = '171908002555';
            insert tsPartners;
        }   
    }
    
    // This function creates a time gap for the milliseconds passed.
    static void sleep(integer milliseconds) { 
        Long timeDiff = 0;
        DateTime firstTime = System.now();
        do {
            timeDiff = System.now().getTime() - firstTime.getTime();
        }
        while(timeDiff <= milliseconds);      
    }
}