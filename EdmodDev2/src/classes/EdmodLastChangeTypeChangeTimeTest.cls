@isTest
public class EdmodLastChangeTypeChangeTimeTest {     
    
    /* @Test:testChangeTypeChangeTime
     * @Description: This function tests the complete flow for LastChangeType and LastChangeTime.
     * LastChangeTime includes different values according to updation time of MetricType. In case of TEACHER_REGISTERED it is 
     * equal to Date Joined, otherwise equal to last time when records were updated.
     */
    @isTest static void testChangeTypeChangeTime() {
        Test.startTest();
        List < List < String >> csvData = getCSVDataTeacherRegistered();
        insertProgramTest();
        Id jobId = '7074D00000OOhstQAD';
        String lastChangeType1;
        String lastChangeType2;
        String lastChangeType3;
        String lastChangeType4;
		String lastChangeType5;
        
        DateTime lastChangeTime1;
        DateTime lastChangeTime2;
        DateTime lastChangeTime3;
        DateTime lastChangeTime4;
        DateTime lastChangeTime5;
        
        String expectedChangeType;

        // Teacher Registered ( TEACHER_REGISTERED )
        EdmodUploadCSVRecords uploadCSVRecordsInitial = new EdmodUploadCSVRecords(csvData, 'TS', 'CODEHS', jobId);
        uploadCSVRecordsInitial.processAccounts();
        List < Contact > ContactCompleteFlowResultList = [Select ID, Name, Last_Change_Time__c, Last_Change_Type__c from Contact];
        lastChangeTime1 = DateTime.valueOf(ContactCompleteFlowResultList.get(0).Last_Change_Time__c);
        lastChangeType1 = ContactCompleteFlowResultList.get(0).Last_Change_Type__c;
        expectedChangeType = 'TEACHER_REGISTERED';
        System.assertEquals(expectedChangeType, lastChangeType1);
        System.assertEquals(DateTime.valueOf('2018-08-16 10:08:22'), lastChangeTime1);

        // Twenty students sign up for teacher ( UNIQUE_SIGN_UPS = 20) 
        sleep(1000);
        csvData = getCSVDataUniqueSignUps();
        uploadCSVRecordsInitial = new EdmodUploadCSVRecords(csvData, 'TS', 'CODEHS', jobId);
        uploadCSVRecordsInitial.processAccounts();
        ContactCompleteFlowResultList = [Select ID, Name, Last_Change_Time__c, Last_Change_Type__c from Contact];
        lastChangeTime2 = DateTime.valueOf(ContactCompleteFlowResultList.get(0).Last_Change_Time__c);
        lastChangeType2 = ContactCompleteFlowResultList.get(0).Last_Change_Type__c;
        expectedChangeType = 'UNIQUE_SIGN_UPS';
        System.assertEquals(expectedChangeType, lastChangeType2);
        System.assertEquals(false, lastChangeTime1 == lastChangeTime2);

        //  Changed MetricValues other than UNIQUE_SIGN_UPS, C4, C5
        sleep(1000);
        csvData = getCSVDataUpdateMetricValues1();
        uploadCSVRecordsInitial = new EdmodUploadCSVRecords(csvData, 'TS', 'CODEHS', jobId);
        uploadCSVRecordsInitial.processAccounts();
        ContactCompleteFlowResultList = [Select ID, Name, Last_Change_Time__c, Last_Change_Type__c from Contact];
        lastChangeTime3 = DateTime.valueOf(ContactCompleteFlowResultList.get(0).Last_Change_Time__c);
        lastChangeType3 = ContactCompleteFlowResultList.get(0).Last_Change_Type__c;
        expectedChangeType = 'UNIQUE_PROJECT_COMPLETED,UNIQUE_SHARES,C1,C2,C3,COMPLETED_MUSIC1H,' +
            'COMPLETED_MUSIC10H,COMPLETED_ART1H,COMPLETED_ART10H,COMPLETED_SPORTS1H,COMPLETED_SPORTS10H,' +
            'STARTED_MUSIC1H,STARTED_ART1H,STARTED_SPORTS1H,STARTED_MUSIC10H,STARTED_ART10H,STARTED_SPORTS10H,' +
            'UNIQUE_PROJECT_STARTED';
        System.assertEquals(expectedChangeType, lastChangeType3);
        System.assertEquals(false, lastChangeTime1 == lastChangeTime3);
        System.assertEquals(false, lastChangeTime2 == lastChangeTime3);

        //  Changed MetricValues for UNIQUE_SIGN_UPS, STARTED_MUSIC1H, STARTED_ART1H, UNIQUE_PROJECT_STARTED
        sleep(1000);
        csvData = getCSVDataUpdateMetricValues2();
        uploadCSVRecordsInitial = new EdmodUploadCSVRecords(csvData, 'TS', 'CODEHS', jobId);
        uploadCSVRecordsInitial.processAccounts();
        ContactCompleteFlowResultList = [Select ID, Name, Last_Change_Time__c, Last_Change_Type__c from Contact];
        lastChangeTime4 = DateTime.valueOf(ContactCompleteFlowResultList.get(0).Last_Change_Time__c);
        lastChangeType4 = ContactCompleteFlowResultList.get(0).Last_Change_Type__c;
        expectedChangeType = 'UNIQUE_SIGN_UPS,STARTED_MUSIC1H,STARTED_ART1H,UNIQUE_PROJECT_STARTED';
        System.assertEquals(expectedChangeType, lastChangeType4);
        System.assertEquals(false, lastChangeTime1 == lastChangeTime4);
        System.assertEquals(false, lastChangeTime2 == lastChangeTime4);
        System.assertEquals(false, lastChangeTime3 == lastChangeTime4);
        
        //  Check that lastChangeTime and lastChangeType are not changed when same contact details are entered
        sleep(1000);
        uploadCSVRecordsInitial = new EdmodUploadCSVRecords(csvData, 'TS', 'CODEHS', jobId);
        uploadCSVRecordsInitial.processAccounts();
        ContactCompleteFlowResultList = [Select ID, Name, Last_Change_Time__c, Last_Change_Type__c from Contact];
        lastChangeTime5 = DateTime.valueOf(ContactCompleteFlowResultList.get(0).Last_Change_Time__c);
        lastChangeType5 = ContactCompleteFlowResultList.get(0).Last_Change_Type__c;
		expectedChangeType = 'UNIQUE_SIGN_UPS,STARTED_MUSIC1H,STARTED_ART1H,UNIQUE_PROJECT_STARTED';
        System.assertEquals(expectedChangeType,lastChangeType5);
        System.assertEquals(true, lastChangeTime4 == lastChangeTime5);
        Test.stopTest();
    }
    
    //header list used in every test function to denote headers in input data.
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
    
    // Teacher registered with all metricTypes equal to either false or 0
    static List< List< String >> getCSVDataTeacherRegistered(){
        List < List < String >> csvData = new List < List < String >> {headers,
            new List < String > {'760550','Mohit','Kumawat','mohit@codehs.com',
                '1231231234','2018-08-16 10:08:22','2018-08-22 11:08:40','889AD',
                ' DEERFIELD HIGH SCHOOL','1.72E+11','TWP HSD 113','1719080','DEERFIELD','IL',
                ' USA','1','0','0','0','False','False','False','False','False',
                '0','0','0','0','0','0','0','0','0','0','0','0','0'}
        };    
        return csvData;
    }
    
    // Teacher having twenty students signed up
    static List< List< String >> getCSVDataUniqueSignUps(){
        List < List < String >> csvData = new List < List < String >> {headers,
            new List < String > {'760550','Mohit','Kumawat','mohit@codehs.com',
                '1231231234', ' 2018-08-16 10:08:22',' 2018-08-22 11:08:40',' 889AD',
                ' DEERFIELD HIGH SCHOOL', '1.72E+11',' TWP HSD 113','1719080',' DEERFIELD',' IL',
                ' USA','1','20','0','0', ' False',' False',' False',' False',' False',
                '0','0','0','0','0','0','0','0','0','0','0','0','0'}
        };    
        return csvData;
    }
    
    //Changed MetricValues other than  Num Students,  
    //Teacher Checklist Completed 4,  Teacher Checklist Completed 5
    static List< List< String >> getCSVDataUpdateMetricValues1(){
        List < List < String >> csvData = new List < List < String >> {headers,
            new List < String > {'760550','Mohit','Kumawat','mohit@codehs.com',
                '1231231234','2018-08-16 10:08:22','2018-08-22 11:08:40','889AD',
                ' DEERFIELD HIGH SCHOOL','1.72E+11','TWP HSD 113','1719080','DEERFIELD','IL',
                ' USA','1','20','12','5','True','True','True','False','False',
                '6','5','4','3','8','6','12','8','12','9','6','10','14'}
        };    
        return csvData;
    }
    
    // Updation in only Num Students, Num Students Who Started A Project, Students Started Music 1 Hour,
    // Students Started Art 1 Hour
    static List< List< String >> getCSVDataUpdateMetricValues2(){
        List < List < String >> csvData = new List < List < String >> {headers,
            new List < String > {'760550','Mohit','Kumawat','mohit@codehs.com',
                '1231231234','2018-08-16 10:08:22','2018-08-22 11:08:40','889AD',
                ' DEERFIELD HIGH SCHOOL','1.72E+11','TWP HSD 113','1719080','DEERFIELD','IL',
                ' USA','1','22','12','5','True','True','True','False','False',
                '6','5','4','3','8','6','13','9','12','9','6','10','16'}
        };    
       return csvData;
    }
    
	// Manual Insertion of Program Types for Testing Purposes
    static void insertProgramTest() {
        if ([Select ID from CurrentEducationProgram__c].size() < 1) {
            CurrentEducationProgram__c tsProgram = new CurrentEducationProgram__c();
            tsProgram.Name = 'TS_2018';
            tsProgram.ProgramType__c = 'TS';
            tsProgram.ProgramStartDate__c = Date.valueOf('2018-01-01');
            tsProgram.ProgramEndDate__c = Date.valueOf('2018-12-31');
            insert tsProgram;
            tsProgram = new CurrentEducationProgram__c();
            tsProgram.Name = 'EFTW_2018';
            tsProgram.ProgramType__c = 'EFTW';
            tsProgram.ProgramStartDate__c = Date.valueOf('2018-01-01');
            tsProgram.ProgramEndDate__c = Date.valueOf('2018-12-31');
            insert tsProgram;
        }
        if ([SELECT Id from TechStartPartners__c].size() < 1) {
            TechStartPartners__c tsPartners = new TechStartPartners__c();
            tsPartners.Name = 'DEERFIELD HIGH SCHOOL';
            tsPartners.State_or_Territory__c = 'IL';
            tsPartners.School_NCES_ID__c = '1.72E+11';
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
        while (timeDiff <= milliseconds);
    }
}