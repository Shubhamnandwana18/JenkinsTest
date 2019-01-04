@isTest
public class EdmodUpdateAccountNameTest {
    
    /* @Test:insertionWithMissingAccountName
	 * @Description: This function tests that default account and contact is created when no account name is passed.
	 */
    @isTest static void insertionWithMissingAccountName() {
        Test.startTest();
        insertProgramTest();
        Id accountIdMissingAccount;
        Id jobId = '7074D00000OOhstQAD';
        List < Account > AccountList;
        List < Contact > ContactList;
		String lastChangeType1;
        String lastChangeType2;
        DateTime lastChangeTime1;
        DateTime lastChangeTime2;
        
        // Adding Teacher with missing School, School NCES ID, District, District NCES ID
        List < List < String >> csvData = getCSVDataMissingAccountDetails();
        EdmodUploadCSVRecords uploadCSVRecordsInitial = new EdmodUploadCSVRecords(csvData, 'TS', 'CODEHS', jobId);
        uploadCSVRecordsInitial.processAccounts();
        AccountList = [Select ID, Name, School_NCES_ID__c, District__c, District_NCES_ID__c from Account];
        ContactList = [Select ID, Name, AccountId, Last_Change_Time__c, Last_Change_Type__c from Contact];

        if (!AccountList.isEmpty()) {
            accountIdMissingAccount = AccountList.get(0).Id;
            lastChangeType1 = ContactList.get(0).Last_Change_Type__c;
            lastChangeTime1 = ContactList.get(0).Last_Change_Time__c;
            System.assertEquals(EdmodConstants.DEFAULT_SCHOOL_NAME, AccountList.get(0).Name);
            System.assertEquals(1, ContactList.size(), 'No contact created');
            System.assertEquals(accountIdMissingAccount, ContactList.get(0).AccountId);
        } else {
            System.assert(false, 'No Account created');
        }
        //check again that change type and change time are not changed when teacher with missing School is re-entered
        uploadCSVRecordsInitial = new EdmodUploadCSVRecords(csvData, 'TS', 'CODEHS', jobId);
        uploadCSVRecordsInitial.processAccounts();
        ContactList = [Select ID, Name, AccountId, Last_Change_Time__c, Last_Change_Type__c from Contact];
        if( !ContactList.isEmpty() ) {
            lastChangeType2 = ContactList.get(0).Last_Change_Type__c;
            lastChangeTime2 = ContactList.get(0).Last_Change_Time__c;
            System.assertEquals(true, lastChangeType1 == lastChangeType2);
            System.assertEquals(true, lastChangeTime1 == lastChangeTime2);
        } else {
            System.assert( false, 'A contact should be present');
        }
        Test.stopTest();
    }
    
    /* @Test:updateInMissingAccount
     * @Description: This function tests that new account is created and account Id for contact is updated when 
     * account Name is passed for a contact which did not had account name earlier.
     */
    @isTest static void updateInMissingAccount() {
        Test.startTest();
        insertProgramTest();
        Id accountIdMissingAccount;
        Id accountIdUpdatedAccount;
        Id jobId = '7074D00000OOhstQAD';
        List < Account > AccountList;
        List < Contact > ContactList;

        // Adding Teacher with missing School, School NCES ID, District, District NCES ID
        List < List < String >> csvData = getCSVDataMissingAccountDetails();
        EdmodUploadCSVRecords uploadCSVRecordsInitial = new EdmodUploadCSVRecords(csvData, 'TS', 'CODEHS', jobId);
        uploadCSVRecordsInitial.processAccounts();

        // Adding Teacher having details of School, School NCES ID, District, District NCES ID
        csvData = getCSVDataAccountInsertionOne();
        uploadCSVRecordsInitial = new EdmodUploadCSVRecords(csvData, 'TS', 'CODEHS', jobId);
        uploadCSVRecordsInitial.processAccounts();

        AccountList = [Select ID, Name, School_NCES_ID__c, District__c, District_NCES_ID__c from Account];
        ContactList = [Select ID, Name, AccountId from Contact];
        if (AccountList.size() == 2) {
            accountIdMissingAccount = AccountList.get(0).Id;
            accountIdUpdatedAccount = AccountList.get(1).Id;
            System.assertEquals('Facebook', AccountList.get(1).Name);
            System.assertEquals(1, ContactList.size());
            System.assertEquals(accountIdUpdatedAccount, ContactList.get(0).AccountId);
        } else {
            System.assert(false, 'All accounts are not created, account size is:' + AccountList.size());
        }
        Test.stopTest();
    }

    /* @Test:updateExistingAccount
     * @Description: This function tests that new account is created, account Id for contact is updated when
     * account name is updated for a contact.
     */
    @isTest static void updateExistingAccount() {
        Test.startTest();
        insertProgramTest();
        Id accountIdInitial;
        Id accountIdUpdated;
        Id jobId = '7074D00000OOhstQAD';
        List < Account > AccountList;
        List < Contact > ContactList;
		String lastChangeType1;
        String lastChangeType2;
        DateTime lastChangeTime1;
        DateTime lastChangeTime2;
        // Adding Teacher having all details of account
        List < List < String >> csvData = getCSVDataAccountInsertionOne();
        EdmodUploadCSVRecords uploadCSVRecordsInitial = new EdmodUploadCSVRecords(csvData, 'TS', 'CODEHS', jobId);
        uploadCSVRecordsInitial.processAccounts();

        // Adding Teacher with updated School, School NCES ID, District, District NCES ID
        csvData = getCSVDataAccountInsertionTwo();
        uploadCSVRecordsInitial = new EdmodUploadCSVRecords(csvData, 'TS', 'CODEHS', jobId);
        uploadCSVRecordsInitial.processAccounts();

        AccountList = [Select ID, Name, School_NCES_ID__c, District__c, District_NCES_ID__c from Account];
        ContactList = [Select ID, Name, AccountId from Contact];

        if (AccountList.size() == 2) {
            accountIdInitial = AccountList.get(0).Id;
            accountIdUpdated = AccountList.get(1).Id;
            System.assertEquals('DEERFIELD HIGH SCHOOL', AccountList.get(1).Name);
            System.assertEquals(1, ContactList.size());
            System.assertEquals(accountIdUpdated, ContactList.get(0).AccountId);
        } else {
            System.assert(false, 'All accounts are not created, account size is:' + AccountList.size());
        }
        Test.stopTest();
    }
	/* @Test: CheckLastChangeTypeOnAccountUpdate
	 * @Description: This function tests that Last_Change_Time, Last_Change_Type are not updated when 
	 * changes are done only in account name.
	 */
    @isTest static void CheckLastChangeTypeOnAccountUpdate() {
        Test.startTest();
        insertProgramTest();
        Id jobId = '7074D00000OOhstQAD';
        List < Account > AccountList;
        List < Contact > ContactList;
		
        String lastChangeType1;
        String lastChangeType2;
		String lastChangeType3;
        
        DateTime lastChangeTime1;
        DateTime lastChangeTime2;
        DateTime lastChangeTime3;
        // Adding Teacher with missing School, School NCES ID, District, District NCES ID
        List < List < String >> csvData = getCSVDataMissingAccountDetails();
        EdmodUploadCSVRecords uploadCSVRecordsInitial = new EdmodUploadCSVRecords(csvData, 'TS', 'CODEHS', jobId);
        uploadCSVRecordsInitial.processAccounts();
        ContactList = [Select ID, Name, AccountId, Last_Change_Time__c, Last_Change_Type__c from Contact];
        if( !ContactList.isEmpty() ) {
            lastChangeType1 = ContactList.get(0).Last_Change_Type__c;
            lastChangeTime1 = ContactList.get(0).Last_Change_Time__c;
        } else {
            System.assert( false, 'No contact inserted');
        }
        // Adding Teacher having details of School, School NCES ID, District, District NCES ID
        csvData = getCSVDataAccountInsertionOne();
        uploadCSVRecordsInitial = new EdmodUploadCSVRecords(csvData, 'TS', 'CODEHS', jobId);
        uploadCSVRecordsInitial.processAccounts();
        ContactList = [Select ID, Name, AccountId, Last_Change_Time__c, Last_Change_Type__c from Contact];
        if ( !ContactList.isEmpty() ) {
            lastChangeType2 = ContactList.get(0).Last_Change_Type__c;
            lastChangeTime2 = ContactList.get(0).Last_Change_Time__c;
            System.assertEquals( true, lastChangeType1 == lastChangeType2);
            System.assertEquals( true, lastChangeTime1 == lastChangeTime2);
        } else {
            System.assert( false, 'At least one contact should be present');
        }
        
        // Adding Teacher with updated School, School NCES ID, District, District NCES ID
        csvData = getCSVDataAccountInsertionTwo();
        uploadCSVRecordsInitial = new EdmodUploadCSVRecords(csvData, 'TS', 'CODEHS', jobId);
        uploadCSVRecordsInitial.processAccounts();

        ContactList = [Select ID, Name, AccountId, Last_Change_Time__c, Last_Change_Type__c from Contact];
        if ( !ContactList.isEmpty() ) {
            lastChangeType3 = ContactList.get(0).Last_Change_Type__c;
            lastChangeTime3 = ContactList.get(0).Last_Change_Time__c;
            System.assertEquals( true, lastChangeType2 == lastChangeType3);
            System.assertEquals( true, lastChangeTime2 == lastChangeTime3);
        } else {
            System.assert( false, 'At least one contact should be present');
        }
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

    // CSV that does't have details for School, School NCES ID, District and District NCES ID
    static List< List< String >> getCSVDataMissingAccountDetails(){
        List < List < String >> csvData = new List < List < String >> {headers,
            new List < String > {'760550','Mohit','Kumawat','mohit@codehs.com',
                '1231231234','2018-08-16 10:08:22','2018-08-22 11:08:40','889AD',
                '','','','','DEERFIELD','IL','USA','1','22','12','5','True','True',
                'True','False','False','6','5','4','3','8','6','13','9',
                '12','9','6','10','16'}
        };    
        return csvData;
    }  
    
    // CSV having all details including School, School NCES ID, District and District NCES ID
    static List< List< String >> getCSVDataAccountInsertionOne(){
        List < List < String >> csvData = new List < List < String >> {headers,
            new List < String > {'760550','Mohit','Kumawat','mohit@codehs.com',
                '1231231234','2018-08-16 10:08:22','2018-08-22 11:08:40','889AD',
                'Facebook','171908002555','TWP HSD 113','1719069','DEERFIELD','IL',
                ' USA','1','22','12','5','True','True','True','False','False',
                '6','5','4','3','8','6','13','9','12','9','6','10','16'}
        };    
        return csvData;
    }
    
    // CSV with new account details corresponding to School, School NCES ID, District and District NCES ID
    static List< List< String >> getCSVDataAccountInsertionTwo(){
        List < List < String >> csvData = new List < List < String >> {headers,
            new List < String > {'760550','Mohit','Kumawat','mohit@codehs.com',
                '1231231234','2018-08-16 10:08:22','2018-08-22 11:08:40','889AD',
                ' DEERFIELD HIGH SCHOOL','171978578500','TWP HSD 113','1719080','DEERFIELD','IL',
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
            tsPartners.School_NCES_ID__c = '1.72E+11';
            insert tsPartners;
        }   
    }
}