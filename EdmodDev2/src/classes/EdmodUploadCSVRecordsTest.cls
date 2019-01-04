@isTest
public class EdmodUploadCSVRecordsTest {

    /*
     * Functional Testing
     * @Test:testInsertion
     * @Description:This method tests complete flow for insertion in all standard/custom objects 
     *  
     * Below tests are done in sequence
     * 1.Test the number of accounts in the Account object that were created.
     * 2.Test the number of contacts in the Contact object that were created.
     * 3.Test if a teacher is Engaged or Not Engaged.
     * 4.Test the number of records in the PartnerPlatformInfo object that were created.
     * 5.Test the number of records in the LastLoginInfo object that were created.
     * 6.Test the number of records in the Opportunities object that were created.
     * 7.Test the number of records in the Result object that were created.
     */
    @isTest static void testInsertion() {
        //csvDataForInsertion Stores actual data to be inserted into various standard/custom objects.
        List < List < String >> csvDataForInsertion = getcsvDataForInsertion();
        Test.startTest();
        //To manually insert in the objects which the code assumes to be already filled for testing purposes.
        insertProgramTest();
        /*
         * TS is the Program Name corresponding to the csvData.
         * CODEHS is the Program Type corresponding to the csvData.
         * jobId Stores the batch Id for corresponding batch.
         */
        Id jobId = '7074D00000OOhstQAD';
        EdmodUploadCSVRecords uploadCSVRecord = new EdmodUploadCSVRecords(csvDataForInsertion, 'TS', 'CODEHS', jobId);
        uploadCSVRecord.processAccounts();
        // Fetch Inserted Rows
        List < Account > accountResultList = [Select ID, Name, Site from Account];
        List < Contact > contactResultList = [Select ID, Email, IsEngaged__c from Contact];
        List < Opportunity > onboardingOpportunityResultList = [Select ID, Name, Type, StageName, S1__c, S2__c, S3__c, S4__c from Opportunity
            where Type = 'ONBOARDING'
        ];
        List < Opportunity > nurturingOpportunityResultList = [Select ID, Name, Type, StageName, S1__c, S2__c, S3__c, S4__c from Opportunity
            where Type = 'NURTURING'
        ];
        List < Result__c > result = [Select ID From Result__c];
        List < PartnerPlatformInfo__c > partnerPlatformInfoResultList = [Select ID from PartnerPlatformInfo__c];
        List < LastLoginInfo__c > lastLoginInfoResultList = [Select ID from LastLoginInfo__c];
        // test Accounts object
        if (!accountResultList.isEmpty()) {
            System.assertEquals(2, accountResultList.size());
            System.assertEquals('DEERFIELD HIGH SCHOOL', accountResultList.get(0).Name);
            System.assertEquals('IL', accountResultList.get(0).Site);
        } else {
            System.assert(false, 'Error has occured while testing Account Insertion');
        }
        // test Contacts object
        if (!contactResultList.isEmpty()) {
            System.assertEquals(3, contactResultList.size());
            System.assertEquals('jkeesh+techstart12@codehs.com', contactResultList.get(0).Email);
            // test if teacher is Engaged or Not Engaged. 
            System.assertEquals('ENGAGED', contactResultList.get(0).IsEngaged__c);
            System.assertEquals('NOT_ENGAGED', contactResultList.get(1).IsEngaged__c);
        } else {
            System.assert(false, 'Error has occured while testing Contact Insertion');
        }
        // test PartnerPlatformInfo object 
        if (!partnerPlatformInfoResultList.isEmpty()) {
            System.assertEquals(3, partnerPlatformInfoResultList.size());
        } else {
            System.assert(false, 'Error has occured while testing PartnerPlatformInfo Insertion');
        }
        // test LastLoginInfo object 
        if (!lastLoginInfoResultList.isEmpty()) {
            System.assertEquals(3, lastLoginInfoResultList.size());
        } else {
            System.assert(false, 'Error has occured while testing LastLoginInfo Insertion');
        }
        // test opportunities object
        if (!onboardingOpportunityResultList.isEmpty()) {
            System.assertEquals(3, onboardingOpportunityResultList.size());
        } else {
            System.assert(false, 'Error has occured while testing Onboarding Opportunity Insertion');
        }
        
        System.assertEquals(true, nurturingOpportunityResultList.isEmpty());
        
        // test result object 
        if (!result.isEmpty()) {
            System.assertEquals(63, result.size());
        } else {
            System.assert(false, 'Error has occured while testing Result Insertion');
        }
        Test.stopTest();
    }
    /*
     * Functional Testing
     * @Test:testUpdation
     * @Description:This method tests complete flow for updation in all standard/custom objects 
     *  
     * Below tests are done in sequence
     * 1.Test the number of accounts in the Account object that were created/updated.
     * 2.Test the number of contacts in the Contact object that were created/updated.
     * 3.Test if a teacher is Engaged or Not Engaged.
     * 4.Test the number of records in the PartnerPlatformInfo object that were created/updated.
     * 5.Test the number of records in the LastLoginInfo object that were created/updated.
     * 6.Test the number of records in the Opportunities object that were created/updated.
     * 7.Test the number of records in the Result object that were created/updated.
     */
    @isTest static void testUpdation() {
        //csvDataForInsertion Stores actual data to be inserted into various standard/custom objects.
        List < List < String >> csvDataForInsertion = getCSVDataForInsertion();
        //csvDataForUpdation Stores actual data to be update the previously inserted data in various standard/custom objects.
        List < List < String >> csvDataForUpdation = getCSVDataForUpdation();
        Test.startTest();
        //To manually insert in the objects which the code assumes to be already filled for testing purposes.
        insertProgramTest();
        /*
         * TS is the Program Name corresponding to the csvData.
         * CODEHS is the Program Type corresponding to the csvData.
         * jobId Stores the batch Id for corresponding batch.
         */
        Id jobId = '7074D00000OOhstQAD';
        EdmodUploadCSVRecords uploadCSVRecordInsertion = new EdmodUploadCSVRecords(csvDataForInsertion, 'TS', 'CODEHS', jobId);
        EdmodUploadCSVRecords uploadCSVRecordUpdation = new EdmodUploadCSVRecords(csvDataForUpdation, 'TS', 'CODEHS', jobId);
        uploadCSVRecordInsertion.processAccounts();
        uploadCSVRecordUpdation.processAccounts();
        // Fetch Inserted Rows
        List < Account > accountResultList = [Select ID, Name, Site from Account];
        List < Contact > contactResultList = [Select ID, Email, IsEngaged__c from Contact];
        List < Opportunity > onboardingOpportunityResultList = [Select ID, Name, Type, StageName, S1__c, S2__c, S3__c, S4__c from Opportunity
            where Type = 'ONBOARDING'
        ];
        List < Opportunity > nurturingOpportunityResultList = [Select ID, Name, Type, StageName, S1__c, S2__c, S3__c, S4__c from Opportunity
            where Type = 'NURTURING'
        ];
        List < Result__c > result = [Select ID From Result__c];
        List < PartnerPlatformInfo__c > partnerPlatformInfoResultList = [Select ID from PartnerPlatformInfo__c];
        List < LastLoginInfo__c > lastLoginInfoResultList = [Select ID from LastLoginInfo__c];
        // test Accounts object
        if (!accountResultList.isEmpty()) {
            System.assertEquals(2, accountResultList.size());
            System.assertEquals('DEERFIELD HIGH SCHOOL', accountResultList.get(0).Name);
            System.assertEquals('IL', accountResultList.get(0).Site);
        } else {
            System.assert(false, 'Error has occured while testing Account Insertion');
        }
        // test Contacts object
        if (!contactResultList.isEmpty()) {
            System.assertEquals(3, contactResultList.size());
            System.assertEquals('jkeesh+techstart12@codehs.com', contactResultList.get(0).Email);
            // test if teacher is Engaged or Not Engaged. 
            System.assertEquals('ENGAGED', contactResultList.get(0).IsEngaged__c);
            System.assertEquals('NOT_ENGAGED', contactResultList.get(1).IsEngaged__c);
        } else {
            System.assert(false, 'Error has occured while testing Contact Insertion');
        }
        // test PartnerPlatformInfo object 
        if (!partnerPlatformInfoResultList.isEmpty()) {
            System.assertEquals(3, partnerPlatformInfoResultList.size());
        } else {
            System.assert(false, 'Error has occured while testing PartnerPlatformInfo Insertion');
        }
        // test LastLoginInfo object 
        if (!lastLoginInfoResultList.isEmpty()) {
            System.assertEquals(3, lastLoginInfoResultList.size());
        } else {
            System.assert(false, 'Error has occured while testing LastLoginInfo Insertion');
        }
        // test opportunities object
        if (!onboardingOpportunityResultList.isEmpty()) {
            System.assertEquals(3, onboardingOpportunityResultList.size());
        } else {
            System.assert(false, 'Error has occured while testing Onboarding Opportunity Insertion');
        }
        if (nurturingOpportunityResultList.isEmpty()) {
            System.assertEquals(true, nurturingOpportunityResultList.isEmpty());
        } else {
            System.assert(false, 'Error has occured while testing Nurturing Opportunity Insertion');
        }
        // test result object 
        if (!result.isEmpty()) {
            System.assertEquals(63, result.size());
        } else {
            System.assert(false, 'Error has occured while testing Result Insertion');
        }
        Test.stopTest();
    }
    /*
     * Unit Testing
     * @Test:testRequiredFieldsInAccounts
     * @Description:This method tests the required fields in Accounts object.
     * Data without the fields that are marked required in account object is given as input.
     * Since this is an error case,Error Log object will have an insertion with an appropriate message. 
     */
    @isTest static void testRequiredFieldsInAccounts() {
        //missingRequiredFieldsInAccounts Stores data without the required fields in Accounts object.
        List < String > missingRequiredFieldsInAccounts = getAccountRequiredFieldMissingData();
        Test.startTest();
        // jobId Stores the batch Id for corresponding batch. 
        Id jobId = '7074D00000OOhstQAD';
        EdmodUploadCSVRecords uploadCSVRecord = new EdmodUploadCSVRecords(null, null, null, jobId);
        System.assertEquals(true, uploadCSVRecord.checkRequiredFields(missingRequiredFieldsInAccounts).contains('First Name'));
        Test.stopTest();
    }
    /*
     * @Test:testRequiredFieldsInContacts
     * @Description:This method tests the required fields in Contacts object.
     * Data without the fields that are marked required in Contacts object is given as input.
     * Since this is an error case,Error Log object will have an insertion with an appropriate message. 
     */
    @isTest static void testRequiredFieldsInContacts() {
        //missingRequiredFieldsInAccounts Stores data without the required fields in Accounts object.
        List < String > missingRequiredFieldsInContacts = getContactRequiredFieldMissingData();
        Test.startTest();
        // jobId Stores the batch Id for corresponding batch. 
        Id jobId = '7074D00000OOhstQAD';
        EdmodUploadCSVRecords uploadCSVRecord = new EdmodUploadCSVRecords(null, null, null, jobId);
        System.assertEquals(true, uploadCSVRecord.checkRequiredFields(missingRequiredFieldsInContacts).contains('Email, First Name, Last Name,'));
        Test.stopTest();
    }
    /*
     * @Test:testRequiredFieldsInPartnerPlatformInfo
     * @Description:This method tests the required fields in PartnerPlatformInfo object.
     * Data without the fields that are marked required in PartnerPlatformInfo object is given as input.
     * Since this is an error case,Error Log object will have an insertion with an appropriate message. 
     */
    @isTest static void testRequiredFieldsInPartnerPlatformInfo() {
        //missingRequiredFieldsInAccounts Stores data without the required fields in Accounts object.
        List < String > missingRequiredFieldsInPPI = getPPIRequiredFieldMissingData();
        Test.startTest();
        // jobId Stores the batch Id for corresponding batch. 
        Id jobId = '7074D00000OOhstQAD';
        EdmodUploadCSVRecords uploadCSVRecord = new EdmodUploadCSVRecords(null, null, null, jobId);
        System.assertEquals(true, uploadCSVRecord.checkRequiredFields(missingRequiredFieldsInPPI).contains('Id'));
        Test.stopTest();
    }

    /*
     * @Test:testInvalidFieldTypes
     * @Description:This method tests the validity of Field Types.
     * Data with invalid format is passed .
     * Since this is an error case,Error Log object will have an insertion with an appropriate message. 
     * The Following cases are checked here,
     * 1.Email Format 
     * 2.Invalid Date/Time
     * 3.Length of classcode should be exactly either 0 or 5.
     */
    @isTest static void testInvalidFieldTypes() {
        //invalidFieldTypes has data in invalid format for "datejoined","last login", "Email","Class Code"
        List < List < String >> invalidFieldTypes = getinvalidFieldTypes();
        Test.startTest();
        //To manually insert in the objects which the code assumes to be already filled for testing purposes.
        insertProgramTest();
        /*
         * TS is the Program Name corresponding to the csvData.
         * CODEHS is the Program Type corresponding to the csvData.
         * jobId Stores the batch Id for corresponding batch.
         */
        Id jobId = '7074D00000OOhstQAD';
        EdmodUploadCSVRecords uploadCSVRecord = new EdmodUploadCSVRecords(invalidFieldTypes, 'TS', 'CODEHS', jobId);
        uploadCSVRecord.processAccounts();
        List < Error_Log__c > errorList = [Select Id, Error_Message__c from Error_Log__c];
        if (!errorList.isEmpty()) {
            System.assertEquals(true, errorList.get(0).Error_Message__c.contains('Invalid date/time'));
            System.assertEquals(true, errorList.get(1).Error_Message__c.contains('invalid email address'));
            System.assertEquals(true, errorList.get(2).Error_Message__c.contains('Class code should have 0 or 5 characters'));
        } else {
            System.assert(false, 'Insertion in Error Log failed');
        }
        Test.stopTest();
    }
    /*
     * @Test:testDuplicateObjectInsertion
     * @Description:This method tests the uniqueness of School in Accounts object incase of same state name.
     * Data with duplicate row of school and state name is passed .
     * Accounts object should have a unique entry for a same school and state. 
     */
    @isTest static void testDuplicateObjectInsertion() {
        //csvDataForduplicateObjectInsertion has data with duplicate entry with same school and state.
        List < List < String >> csvDataForduplicateObjectInsertion = getcsvDataForduplicateObjectInsertion();
        Test.startTest();
        //To manually insert in the objects which the code assumes to be already filled for testing purposes.
        insertProgramTest();
        /*
         * TS is the Program Name corresponding to the csvData.
         * CODEHS is the Program Type corresponding to the csvData.
         * jobId Stores the batch Id for corresponding batch.
         */
        Id jobId = '7074D00000OOhstQAD';
        EdmodUploadCSVRecords uploadCSVRecord = new EdmodUploadCSVRecords(csvDataForduplicateObjectInsertion, 'TS', 'CODEHS', jobId);
        uploadCSVRecord.processAccounts();
        // Fetch Inserted Rows
        List < Account > accountResultList = [Select ID, Name, Site from Account];
        // test Accounts
        if (!accountResultList.isEmpty()) {
            System.assertEquals(1, accountResultList.size());
            System.assertEquals('DEERFIELD HIGH SCHOOL', accountResultList.get(0).Name);
            System.assertEquals('IL', accountResultList.get(0).Site);
        } else {
            System.assert(false, 'Error has occured while testing Account Insertion');
        }
    }
    /*
     * @Test:testUniqueInsertion
     * @Description:This method tests the uniqueness of School Name with different State name in Accounts object.  
     * Data with Same School Name but different state name is passed .
     * Accounts object should have entries corresponding to same school name and different state name denoting a school with same name in different locations. 
     */
    @isTest static void testUniqueInsertion() {
        //csvDataForUniqueInsertion has data with same school Name and different State name.  
        List < List < String >> csvDataForUniqueInsertion = getcsvDataForUniqueInsertion();
        Test.startTest();
        //To manually insert in the objects which the code assumes to be already filled for testing purposes.
        insertProgramTest();
        /*
         * TS is the Program Name corresponding to the csvData.
         * CODEHS is the Program Type corresponding to the csvData.
         * jobId Stores the batch Id for corresponding batch.
         */
        Id jobId = '7074D00000OOhstQAD';
        EdmodUploadCSVRecords uploadCSVRecord = new EdmodUploadCSVRecords(csvDataForUniqueInsertion, 'TS', 'CODEHS', jobId);
        uploadCSVRecord.processAccounts();
        // Fetch Inserted Rows
        List < Account > accountResultList = [Select ID, Name, Site from Account];
        // test Accounts
        if (!accountResultList.isEmpty()) {
            System.assertEquals(2, accountResultList.size());
            System.assertEquals('DEERFIELD HIGH SCHOOL', accountResultList.get(0).Name);
            System.assertEquals('IL', accountResultList.get(0).Site);
            System.assertEquals('DEERFIELD HIGH SCHOOL', accountResultList.get(1).Name);
            System.assertEquals('CA', accountResultList.get(1).Site);
        } else {
            System.assert(false, 'Error has occured while testing Account Insertion');
        }
    }
    /*
     * @Test:testUniqueEmailInsertion
     * @Description:This method tests the uniqueness of Email in contacts Object.  
     * Data with duplicate Email.
     * Since This is an error case as two contacts cannot be associated with multiple emails, Error log object will have an insertion. 
     */
    @isTest static void testUniqueEmailInsertion() {
        //duplicateEmailDataInsertion has data with Duplicate email  
        List < List < String >> duplicateEmailDataInsertion = getCSVDataWithDuplicateEmail();
        Test.startTest();
        //To manually insert in the objects which the code assumes to be already filled for testing purposes.
        insertProgramTest();
        /*
         * TS is the Program Name corresponding to the csvData.
         * CODEHS is the Program Type corresponding to the csvData.
         * jobId Stores the batch Id for corresponding batch.
         */
        Id jobId = '7074D00000OOhstQAD';
        EdmodUploadCSVRecords uploadCSVRecord = new EdmodUploadCSVRecords(duplicateEmailDataInsertion, 'TS', 'CODEHS', jobId);
        uploadCSVRecord.processAccounts();
        List < Error_Log__c > errorList = [Select Id, Error_Message__c from Error_Log__c];
        if (errorList.isEmpty()) { // Fetch Inserted Rows
            List < Contact > contactResultList = [Select ID, Email, IsEngaged__c from Contact];
            // test that Contacts should have no insertion
            if (!contactResultList.isEmpty()) {
                System.assert(false, 'Test Failed :Check required fields for contacts object');
            } else {
                System.assert(false, 'Insertion in Error Log failed');
            }
        } else {
            System.assertEquals(true, errorList.get(1).Error_Message__c.contains('Duplicate external id specified'));
        }
        Test.stopTest();
    }
    /*
     * @Test:testEngagedOrNotEngaged
     * @Description:This method tests if a contact is Engaged or not engaged
     */
    @isTest static void testEngagedOrNotEngaged() {
        List < List < String >> csvDataForEngagedOrNotEngaged = getCSVDataForEngagedAndNotEngaged();
        Test.startTest();
        //To manually insert in the objects which the code assumes to be already filled for testing purposes.    
        insertProgramTest();
        /*
         * TS is the Program Name corresponding to the csvData.
         * CODEHS is the Program Type corresponding to the csvData.
         * jobId Stores the batch Id for corresponding batch.
         */
        Id jobId = '7074D00000OOhstQAD';
        EdmodUploadCSVRecords uploadCSVRecord = new EdmodUploadCSVRecords(csvDataForEngagedOrNotEngaged, 'TS', 'CODEHS', jobId);
        uploadCSVRecord.processAccounts();
        // Fetch Inserted Rows
        List < Contact > contactResultList = [Select ID, Email, IsEngaged__c from Contact];
        // test if teacher is Engaged or Not Engaged. 
        if (!contactResultList.isEmpty()) {
            System.assertEquals('ENGAGED', contactResultList.get(0).IsEngaged__c);
            System.assertEquals('NOT_ENGAGED', contactResultList.get(1).IsEngaged__c);
        } else {
            System.assert(false, 'Error has occured while testing Contact Insertion');
        }
    }
    /*
     * @Test:testStateValidityInsertion
     * @Description:This method tests the two character abbreviation State field Validity.  
     * Data with state field having more than two characters.
     * Since This is an error case ,Error log object will have an insertion. 
     */
    @isTest static void testStateValidityInsertion() {
        List < List < String >> csvDataForStateValidity = getDataTwoCharacterAbbreviationInsertion();
        Test.startTest();
        //To manually insert in the objects which the code assumes to be already filled for testing purposes.
        insertProgramTest();
        /*
         * TS is the Program Name corresponding to the csvData.
         * CODEHS is the Program Type corresponding to the csvData.
         * jobId Stores the batch Id for corresponding batch.
         */
        Id jobId = '7074D00000OOhstQAD';
        EdmodUploadCSVRecords uploadCSVRecord = new EdmodUploadCSVRecords(csvDataForStateValidity, 'TS', 'CODEHS', jobId);
        uploadCSVRecord.processAccounts();
        // Fetch Inserted Rows
        List < Account > accountResultList = [Select ID, Name, Site from Account];
        List < Error_Log__c > errorList = [Select Id, Error_Message__c from Error_Log__c];
        // test Accounts
        if (!accountResultList.isEmpty()) {
            System.assertEquals(1, accountResultList.size());
            System.assertEquals('DEERFIELD HIGH SCHOOL', accountResultList.get(0).Name);
            System.assertEquals('IL', accountResultList.get(0).Site);
        } else {
            System.assert(false, 'Error has occured while testing Account Insertion');
        }
        if (!errorList.isEmpty()) {
            System.assertEquals(1, errorList.size());
            System.assertEquals(true, errorList.get(0).Error_Message__c.contains('State name should be in form of abbreviated code of 2 letters'));
        } else {
            System.assert(false, 'Error while inserting in Error Log object');
        }

    }
    /*
     * @Test:testCorrectRowList
     * @Description:This method tests the row validations for a list with correct values.  
     */
    @isTest static void testCorrectRowList() {
        List < String > correctRowList = getValidRowList();
        Test.startTest();
        // jobId Stores the batch Id for corresponding batch. 
        Id jobId = '7074D00000OOhstQAD';
        EdmodUploadCSVRecords uploadCSVRecord = new EdmodUploadCSVRecords(getcsvDataForInsertion(), null, null, jobId);
        System.assertEquals(true, uploadCSVRecord.isRowValid(correctRowList, 0));
        Test.stopTest();
    }
    /*
     * @Test:testDateJoinedGreatertoLastLogin
     * @Description:This method tests the row validations for a list when date joined is greater than last login.  
     */
    @isTest static void testDateJoinedGreatertoLastLogin() {
        List < String > dateJoinedGreaterToLastLogin = getDateJoinedGreaterToLastLogin();
        Test.startTest();
        // jobId Stores the batch Id for corresponding batch. 
        Id jobId = '7074D00000OOhstQAD';
        EdmodUploadCSVRecords uploadCSVRecord = new EdmodUploadCSVRecords(getcsvDataForInsertion(), null, null, jobId);
        System.assertEquals(false, uploadCSVRecord.isRowValid(dateJoinedGreaterToLastLogin, 0));
        Test.stopTest();
    }
    /*
     * @Test:testNumStartedLesserToCompletedProject
     * @Description:This method tests the row validations for a list when num of students who started a project are lesser to students who completed a project. 
     */
    @isTest static void testNumStartedLesserToCompletedProject() {
        List < String > numStartedLesserToCompletedProject = getNumStartedLesserToCompletedProject();
        Test.startTest();
        // jobId Stores the batch Id for corresponding batch. 
        Id jobId = '7074D00000OOhstQAD';
        EdmodUploadCSVRecords uploadCSVRecord = new EdmodUploadCSVRecords(getcsvDataForInsertion(), null, null, jobId);
        System.assertEquals(false, uploadCSVRecord.isRowValid(numStartedLesserToCompletedProject, 0));
        Test.stopTest();
    }
    /*
     * @Test:testNumSignUpLesserToStartedRow
     * @Description:This method tests the row validations for a list when num of students signed up is lesser to students who started the project 
     */
    @isTest static void testNumSignUpLesserToStartedRow() {
        List < String > numSignUpLesserToStartedProject = getNumSignUpLesserToStartedProjectRowList();
        Test.startTest();
        // jobId Stores the batch Id for corresponding batch. 
        Id jobId = '7074D00000OOhstQAD';
        EdmodUploadCSVRecords uploadCSVRecord = new EdmodUploadCSVRecords(getcsvDataForInsertion(), null, null, jobId);
        System.assertEquals(false, uploadCSVRecord.isRowValid(numSignUpLesserToStartedProject, 0));
        Test.stopTest();
    }
    /*
     * @Test:testNumSignUpLesserToCompletedRow
     * @Description:This method tests the row validations for a list when num of students signed up is lesser to students who completed a project
     */
    @isTest static void testNumSignUpLesserToCompletedRow() {
        List < String > numSignUpLesserToCompletedProject = getNumSignUpLesserToCompletedProjectRowList();
        Test.startTest();
        // jobId Stores the batch Id for corresponding batch. 
        Id jobId = '7074D00000OOhstQAD';
        EdmodUploadCSVRecords uploadCSVRecord = new EdmodUploadCSVRecords(getcsvDataForInsertion(), null, null, jobId);
        System.assertEquals(false, uploadCSVRecord.isRowValid(numSignUpLesserToCompletedProject, 1));
        Test.stopTest();
    }
    /*
     * @Test:testEmptyMetricValuesRowValidation
     * @Description:This method tests the row validations for a list with empty metric values
     */
    @isTest static void testEmptyMetricValuesRowValidation() {
        List < String > emptyMetricValuesRowList = getEmptyMetricValuesRowList();
        Test.startTest();
        Id jobId = '7074D00000OOhstQAD';
        EdmodUploadCSVRecords uploadCSVRecord = new EdmodUploadCSVRecords(null, null, null, jobId);
        System.assertEquals(false, uploadCSVRecord.checkAllMetricValues(emptyMetricValuesRowList));
        Test.stopTest();
    }
    /*
     * @Test:testDecimalValueRowListValidation
     * @Description:This method tests the row validations for a list with decimal values
     */
    @isTest static void testDecimalValueRowListValidation() {
        List < String > decimalValuesList = getDecimalValuesList();
        Test.startTest();
        // jobId Stores the batch Id for corresponding batch. 
        Id jobId = '7074D00000OOhstQAD';
        EdmodUploadCSVRecords uploadCSVRecord = new EdmodUploadCSVRecords(null, null, null, jobId);
        System.assertEquals(false, uploadCSVRecord.checkAllMetricValues(decimalValuesList));
        Test.stopTest();
    }
    /*
     * @Test:testNegativeValueRowListValidation
     * @Description:This method tests the row validations for a list with negative values
     */
    @isTest static void testNegativeValueRowListValidation() {
        List < String > negativeValuesList = getNegativeValuesList();
        Test.startTest();
        // jobId Stores the batch Id for corresponding batch. 
        Id jobId = '7074D00000OOhstQAD';
        EdmodUploadCSVRecords uploadCSVRecord = new EdmodUploadCSVRecords(null, null, null, jobId);
        System.assertEquals(false, uploadCSVRecord.checkAllMetricValues(negativeValuesList));
        Test.stopTest();
    }
    /*
     * @Test:testTSPartner
     * @Description:This method tests if a school is a Tech start partner 
     */
    @isTest static void testTSPartner() {
        List < List < String >> csvData = getCSVDataInitialEntry();
        Test.startTest();
        //To manually insert in the objects which the code assumes to be already filled for testing purposes.
        insertProgramTest();
        /*
         * TS is the Program Name corresponding to the csvData.
         * CODEHS is the Program Type corresponding to the csvData.
         * jobId Stores the batch Id for corresponding batch.
         */
        Id jobId = '7074D00000OOhstQAD';
        EdmodUploadCSVRecords uploadCSVRecord = new EdmodUploadCSVRecords(csvData, 'TS', 'CODEHS', jobId);
        uploadCSVRecord.processAccounts();
        List < Account > accountResultList = [Select ID, Name, School_NCES_ID__c, Is_Partner__c from Account];
        if (!accountResultList.isEmpty()) {
            for (Account account: accountResultList) {
                List < TechStartPartners__c > countPartner = [select ID, Name, School_NCES_ID__c from TechStartPartners__c where name =: account.Name];
                if (countPartner.size() > 0) {
                    System.assertEquals(true, account.Is_Partner__c);
                } else {
                    System.assertEquals(false, account.Is_Partner__c);
                }
            }
        } else {
            System.assert(false, 'Error while inserting account');
        }
        Test.stopTest();
    }
    /*
     * @Test:testLastLoginTime
     * @Description:This method tests for last login time field in PartnerPlatformInfo object.
     * The flow tests the updation of last login time field with the following Test cases.
     * 1.Last Login Time with current entry.
     * 2.Last Login Time updation Verification with entry previous to current entry.
     * 3.Last Login Time Updation Verification with entry of next date than current entry.
     */
    @isTest static void testLastLoginTime() {
        List < List < String >> csvDataForLastLoginTime = getCSVDataForLastLoginTimePresentDay();
        Test.startTest();
        //To manually insert in the objects which the code assumes to be already filled for testing purposes.
        insertProgramTest();
        /*
         * TS is the Program Name corresponding to the csvData.
         * CODEHS is the Program Type corresponding to the csvData.
         * jobId Stores the batch Id for corresponding batch.
         */
        Id jobId = '7074D00000OOhstQAD';
        DateTime lastLoginTimePresentDay;
        EdmodUploadCSVRecords uploadCSVRecord = new EdmodUploadCSVRecords(csvDataForLastLoginTime, 'TS', 'CODEHS', jobId);
        uploadCSVRecord.processAccounts();
        // Fetch Inserted Rows
        List < PartnerPlatformInfo__c > partnerPlatformInfoResultList = [Select ID, Last_Login_Time__c from PartnerPlatformInfo__c];
        //Retrieve the last Login Time and store it for verification
        if (!partnerPlatformInfoResultList.isEmpty()) {
            lastLoginTimePresentDay = DateTime.valueOf(partnerPlatformInfoResultList.get(0).Last_Login_Time__c);
        } else {
            System.assert(false, 'Error while inserting in partnerPlatformInfo object for Present Day entry');
        }
        csvDataForLastLoginTime = getCSVDataForLastLoginTimePreviousDay();
        uploadCSVRecord = new EdmodUploadCSVRecords(csvDataForLastLoginTime, 'TS', 'CODEHS', jobId);
        uploadCSVRecord.processAccounts();
        // Fetch Inserted Rows
        List < PartnerPlatformInfo__c > partnerPlatformInfoPreviousDayResultList = [Select ID, Last_Login_Time__c from PartnerPlatformInfo__c];
        //Retrieve the last Login Time and check if it is same as the previous value.
        if (!partnerPlatformInfoPreviousDayResultList.isEmpty()) {
            System.assertEquals(true, lastLoginTimePresentDay == DateTime.valueOf(partnerPlatformInfoPreviousDayResultList.get(0).Last_Login_Time__c));
        } else {
            System.assert(false, 'Error while inserting in partnerPlatformInfo object for Previous Day entry');
        }
        csvDataForLastLoginTime = getCSVDataForLastLoginTimeNextDay();
        uploadCSVRecord = new EdmodUploadCSVRecords(csvDataForLastLoginTime, 'TS', 'CODEHS', jobId);
        uploadCSVRecord.processAccounts();
        // Fetch Inserted Rows
        List < PartnerPlatformInfo__c > partnerPlatformInfoNextDayResultList = [Select ID, Last_Login_Time__c from PartnerPlatformInfo__c];
        //Retrieve the last Login Time and check if it is different than the new value.
        if (!partnerPlatformInfoNextDayResultList.isEmpty()) {
            System.assertEquals(false, lastLoginTimePresentDay == DateTime.valueOf(partnerPlatformInfoNextDayResultList.get(0).Last_Login_Time__c));
        } else {
            System.assert(false, 'Error while inserting in partnerPlatformInfo object for Next Day entry');
        }
        Test.stopTest();
    }
    /*
     * @Test:testUniqueEmailInsertion
     * @Description:This method tests the updation of Result Object if there is any change in Metric value.
     */
    @isTest static void testUpdateResults() {
        List < List < String >> csvDataInitialEntry = getCSVDataInitialEntry();
        List < List < String >> csvDataResultUpdation = getCSVDataResultUpdation();
        Test.startTest();
        //To manually insert in the objects which the code assumes to be already filled for testing purposes.
        insertProgramTest();
        Id jobId = '7074D00000OOhstQAD';
        EdmodUploadCSVRecords uploadCSVRecordsInitial = new EdmodUploadCSVRecords(csvDataInitialEntry, 'TS', 'CODEHS', jobId);
        EdmodUploadCSVRecords UploadCSVRecordsResultUpdation = new EdmodUploadCSVRecords(csvDataResultUpdation, 'TS', 'CODEHS', jobId);
        uploadCSVRecordsInitial.processAccounts();
        List < Result__c > resultList = [Select ID, MetricValue__c, MetricType__c from Result__c];
        if (!resultList.isEmpty()) {
            if ((String.valueOf(csvDataInitialEntry[1].get(19))).equalsIgnoreCase('true')) {
                System.assertEquals(1, resultList.get(3).MetricValue__c);
            } else if ((String.valueOf(csvDataInitialEntry[1].get(19))).equalsIgnoreCase('false')) {
                System.assertEquals(0, resultList.get(3).MetricValue__c);
            } else {
                System.assertEquals(resultList.get(0).MetricValue__c, Double.valueOf(csvDataInitialEntry[1].get(16)));
            }
        } else {
            System.assert(false, 'Error while inserting in Result object');
        }
        UploadCSVRecordsResultUpdation.processAccounts();
        List < Result__c > resultUpdatedRowList = [Select ID, MetricValue__c, MetricType__c from Result__c];
        if (!resultUpdatedRowList.isEmpty()) {
            if ((String.valueOf(csvDataResultUpdation[1].get(19))).equalsIgnoreCase('true')) {
                System.assertEquals(1, resultUpdatedRowList.get(3).MetricValue__c);
            } else if ((String.valueOf(csvDataResultUpdation[1].get(19))).equalsIgnoreCase('false')) {
                System.assertEquals(0, resultUpdatedRowList.get(3).MetricValue__c);
            } else {
                System.assertEquals(resultUpdatedRowList.get(0).MetricValue__c, Double.valueOf(csvDataResultUpdation[1].get(16)));
            }
        } else {
            System.assert(false, 'Error while Updating Result object');
        }
    }
    //Row Valid data checks
    static List < String > getEmptyMetricValuesRowList() {
        List < String > emptyMetricValuesRowList = new List < String > {'760545', 'Jeremy', 'TechStart', 'jkeesh+techstart12@codehs.com', '1231231234', 
            '2018-08-16 10:08:22', '2018-08-22 11:08:40', '889AD', 'DEERFIELD HIGH SCHOOL', '171908002193', 'TWP HSD 113', '1719080', 'DEERFIELD',
            'IL', 'USA', '1', '', '', '0', 'True', 'True', 'True', 'False', 'False', '', '', '', '', '', '', '', '', '', '', '', '', ''};
                return emptyMetricValuesRowList;
    }
    //Returns CSV Row for Num SignUp Lesser To num Completed Project
    static List < String > getNumSignUpLesserToCompletedProjectRowList() {
        List < String > numSignUpLesserToCompletedProject = new List < String > {'760545', 'Jeremy', 'TechStart', 'jkeesh+techstart12@codehs.com',
            '1231231234','2018-08-16 10:08:22', '2018-08-22 11:08:40', '889AD', 'DEERFIELD HIGH SCHOOL', '171908002193', 'TWP HSD 113', '1719080',
            'DEERFIELD', 'IL', 'USA', '1', '0', '1', '0', 'True', 'True', 'True', 'False', 'False', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 
            '0', '0', '0'};
                return numSignUpLesserToCompletedProject;
    }
    //Returns CSV Row for Num SignUp Lesser To num Started Project
    static List < String > getNumSignUpLesserToStartedProjectRowList() {
        List < String > numSignUpLesserToStartedProject =new List < String > {'760545', 'Jeremy', 'TechStart', 'jkeesh+techstart12@codehs.com', 
            '1231231234', '2018-08-16 10:08:22', '2018-08-22 11:08:40', '889AD', 'DEERFIELD HIGH SCHOOL', '171908002193', 'TWP HSD 113', '1719080',
            'DEERFIELD', 'IL', 'USA', '1', '0', '0', '0', 'True', 'True', 'True', 'False', 'False', '0', '0', '0', '0', '0', '0', '0', '0', '0', 
            '0', '0', '0', '12'};
                return numSignUpLesserToStartedProject;
    }
    //Returns CSV Row for num started greater to completed
    static List < String > getNumStartedLesserToCompletedProject() {
        List < String > numStartedLesserToCompletedProject =new List < String > {'760545', 'Jeremy', 'TechStart', 'jkeesh+techstart12@codehs.com', 
            '1231231234', '2018-08-16 10:08:22', '2018-08-22 11:08:40', '889AD', 'DEERFIELD HIGH SCHOOL', '171908002193', 'TWP HSD 113',
            '1719080', 'DEERFIELD', 'IL', 'USA', '1', '12', '11', '0', 'True', 'True', 'True', 'False', 'False', '0', '0', '0', '0', '0', '0',
            '0', '0', '0', '0', '0', '0', '1'};
                return numStartedLesserToCompletedProject;
    }
    //Returns CSV Row for date joined greater than last login
    static List < String > getDateJoinedGreaterToLastLogin() {
        List < String > dateJoinedGreaterToLastLogin =new List < String > {'760545', 'Jeremy', 'TechStart', 'jkeesh+techstart12@codehs.com','1231231234',
            '2018-08-22 10:08:22', '2018-08-16 11:08:40', '889AD', 'DEERFIELD HIGH SCHOOL', '171908002193', 'TWP HSD 113','1719080', 'DEERFIELD', 'IL', 
            'USA', '1', '0', '0', '0', 'True', 'True', 'True', 'False', 'False', '0', '0', '0', '0', '0','0', '0', '0', '0', '0', '0', '0', '0'};  
                return dateJoinedGreaterToLastLogin;
    }
    //Returns CSV Row for Negative Values
    static List < String > getNegativeValuesList() {
        List < String > negativeValuesList =new List < String > {'760545', 'Jeremy', 'TechStart', 'jkeesh+techstart12@codehs.com','1231231234',
            '2018-08-22 10:08:22', '2018-08-16 11:08:40', '889AD', 'DEERFIELD HIGH SCHOOL', '171908002193', 'TWP HSD 113','1719080', 'DEERFIELD', 'IL', 
            'USA', '1', '-1', '-1', '0', 'True', 'True', 'True', 'False', 'False', '0', '0', '0', '0', '0','0', '0', '0', '0', '0', '0', '0', '-2'}; 
                return negativeValuesList;
    }
    //Returns CSV Row for decimal values in metric values
    static List < String > getDecimalValuesList() {
        List < String > decimalValuesList =new List < String > {'760545', 'Jeremy', 'TechStart', 'jkeesh+techstart12@codehs.com','1231231234',
            '2018-08-22 10:08:22', '2018-08-16 11:08:40', '889AD', 'DEERFIELD HIGH SCHOOL', '171908002193', 'TWP HSD 113','1719080', 'DEERFIELD', 'IL', 
            'USA', '1', '10.455', '1', '0', 'True', 'True', 'True', 'False', 'False', '0', '0', '0', '0', '0','0', '0', '0', '0', '0', '0', '0', '2'};
                return decimalValuesList;
    }
    static List < String > getValidRowList() {
        List < String > correctRowList =new List < String > {'760545', 'Jeremy', 'TechStart', 'jkeesh+techstart12@codehs.com', '1231231234', 
            '2018-08-16 10:08:22', '2018-08-22 11:08:40', '889AD', 'DEERFIELD HIGH SCHOOL', '171908002193', 'TWP HSD 113', '1719080', 'DEERFIELD',
            'IL', 'USA', '1', '0', '0', '0', 'True', 'True', 'True', 'False', 'False', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0','0'};
                return correctRowList;
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
 	
    //Returns CSV Data for Insertion
    static List < List < String >> getCSVDataForInsertion() {
        List < List < String >> csvDataForInsertion = new List < List < String >> {headers,
            new List < String > {'760545', 'Jeremy', 'TechStart', 'jkeesh+techstart12@codehs.com', '1231231234','2018-08-16 10:08:22', 
                '2018-08-17 11:08:40', '889AD', 'DEERFIELD HIGH SCHOOL', '171908002193', 'TWP HSD 113', '1719080', 'DEERFIELD', 'IL',
                'USA', '1', '4', '0', '0', 'True', 'True', 'True', 'False', 'False', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0',
                '0', '0', '0'},    
            new List < String > {'760547', 'Jeren', 'Techrt', 'jkeesh+techstart18@codehs.com', '1231231234', '2018-08-16 10:08:22',
                '2018-08-16 10:08:22', '889AD', 'DEERFIELD HIGH SCHOOL', '171908002193', 'TWP HSD 113', '1719080', 'DEERFIELD', 'CA',
                'USA', '1', '1', '1', '0', 'True', 'True', 'True', 'False', 'False', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0',
                '0', '0', '1'},
            new List < String > {'760548', 'Jeremy', 'TechStart', 'jkeesh+techstart13@codehs.com', '1231231234', '2018-08-16 10:08:22', 
                '2018-08-17 11:08:40', '889AD', 'DEERFIELD HIGH SCHOOL', '171908002193', 'TWP HSD 113', '1719080', 'DEERFIELD', 'IL',
                'USA', '1', '1', '0', '0', 'True', 'True', 'True', 'False', 'False', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0',
                '0', '0', '1'},        
            new List < String > {'736980', 'Lusmaia', 'Diaz', 'lusmaia@fb.com', '1111111111', '2018-07-20 02:07:35', '2018-08-09 01:08:51',
                '31A73', 'Facebook', '171908002555', 'TWP HSD 113', '1719069', 'Menlo Park', 'CA', 'USA', '2', '15', '1', '6', 'True',
                'False', 'False', 'True', 'False', '1', '0', '0', '0', '0', '0', '9', '3', '2', '0', '0', '1', '0'},
            new List < String > {'760545', 'Jeremy', 'TechStart', 'jkeesh+techstart12@codehs.com', '1231231234', '2018-08-16 10:08:22',
                '2018-08-22 11:08:40', '889AD', 'DEERFIELD HIGH SCHOOL', '171908002193', 'TWP HSD 113', '1719080', 'DEERFIELD', 'NewYork', 
                'USA', '1', '0', '0', '0', 'True', 'True', 'True', 'False', 'False', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0',
                '0', '0'},
            new List < String > {'755097', '', '', 'jkeesh+techstart_codehs.com', '1231231234', '2018-08-14 01:08:35', '2018-08-14 01:08:35', 
                'D85BB', 'HIGH SCHOOL',null,'TWP HSD 113', '1719080', 'DEERFIELD', 'IL', 'USA', '1', '1', '0', '0', 'True', 'True', 'False',
                'False', 'False', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0'},
            new List < String > {'760545', 'Jeremy', 'TechStart', 'jkeesh+techstart12@codehs.com', '1231231234', '2018-08-16 10:08:22', 
                '2018-08-22 11:08:40', '889AD', 'DEERFIELD COOL', '171908002193', 'TWP HSD 113', '1719080', 'DEERFIELD', 'IL',
                'USA', '1', '-4', '-1', '-2', 'True', 'True', 'True', 'False', 'False', '15', '0', '0', '0', '0', '0', '0', '0', '0', '0',
                '0', '0', '0'},        
            new List < String > {'755098', 'Jeremy', 'TechStart', '', '1231231234', '', '', 'D85BB8888', '171908002193', 'TWP HSD 113', '1719080',
                 'DEERFIELD', '', 'USA', '1', '1', '0', '0', 'True', 'True', 'False', 'False', 'False', '0', '0', '0', '0', '0', '0', '0', '0',
                 '0', '0', '0', '0', '0'}
        };
        return csvDataForInsertion;
    }
    static List < List < String >> getCSVDataForLastLoginTimePresentDay() {
        List < List < String >> csvDataForLastLoginTimeFirstInsertion = new List < List < String >> {headers,
            new List < String > {'760545', 'Jeremy', 'TechStart', 'jkeesh+techstart12@codehs.com', '1231231234', '2018-08-16 10:08:22', 
                '2018-08-19 11:08:40', '889AD', 'DEERFIELD HIGH SCHOOL', '171908002193', 'TWP HSD 113', '1719080', 'DEERFIELD', 'IL',
                'USA', '1', '4', '0', '0', 'True', 'True', 'True', 'False', 'False', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0',
                '0', '0', '0'}
        };
        return csvDataForLastLoginTimeFirstInsertion;
    }
    static List < List < String >> getCSVDataForLastLoginTimePreviousDay() {
        List < List < String >> csvDataForLastLoginTimePreviousDay = new List < List < String >> {headers,
            new List < String > {'760545', 'Jeremy', 'TechStart', 'jkeesh+techstart12@codehs.com', '1231231234', '2018-08-16 10:08:22', 
                '2018-08-18 11:08:40', '889AD', 'DEERFIELD HIGH SCHOOL', '171908002193', 'TWP HSD 113', '1719080', 'DEERFIELD', 'IL',
                'USA', '1', '4', '0', '0', 'True', 'True', 'True', 'False', 'False', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0',
                '0', '0', '0'}
        };
        return csvDataForLastLoginTimePreviousDay;
    }
    static List < List < String >> getCSVDataForLastLoginTimeNextDay() {
        List < List < String >> csvDataForLastLoginTimeNextDay = new List < List < String >> {headers,
            new List < String > {'760545', 'Jeremy', 'TechStart', 'jkeesh+techstart12@codehs.com', '1231231234', '2018-08-16 10:08:22', 
                '2018-08-20 11:08:40', '889AD', 'DEERFIELD HIGH SCHOOL', '171908002193', 'TWP HSD 113', '1719080', 'DEERFIELD', 'IL',
                'USA', '1', '4', '0', '0', 'True', 'True', 'True', 'False', 'False', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0',
                '0', '0', '0'}
                        };
        return csvDataForLastLoginTimeNextDay;
    }
    static List < List < String >> getcsvDataForduplicateObjectInsertion() {
        List < List < String >> csvDataForDuplicateInsertion = new List < List < String >> {headers,
            new List < String > {'760545', 'Jeremy', 'TechStart', 'jkeesh+techstart12@codehs.com', '1231231234', '2018-08-16 10:08:22', 
                '2018-08-17 11:08:40', '889AD', 'DEERFIELD HIGH SCHOOL', '171908002193', 'TWP HSD 113', '1719080', 'DEERFIELD', 'IL',
                'USA', '1', '4', '0', '0', 'True', 'True', 'True', 'False', 'False', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0',
                '0', '0', '0'},    
            new List < String > {'760547', 'Jeren', 'Techrt', 'jkeesh+techstart18@codehs.com', '1231231234', '2018-08-16 10:08:22',
                '2018-08-16 10:08:22', '889AD', 'DEERFIELD HIGH SCHOOL', '171908002193', 'TWP HSD 113', '1719080', 'DEERFIELD', 'IL',
                'USA', '1', '1', '1', '0', 'True', 'True', 'True', 'False', 'False', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0',
                '0', '0', '1'}
                         };
        return csvDataForDuplicateInsertion;
    }
    static List < List < String >> getCSVDataForUniqueInsertion() {
        List < List < String >> csvDataForUniqueInsertion = new List < List < String >> {headers,
            new List < String > {'760545', 'Jeremy', 'TechStart', 'jkeesh+techstart12@codehs.com', '1231231234', '2018-08-16 10:08:22', 
                '2018-08-17 11:08:40', '889AD', 'DEERFIELD HIGH SCHOOL', '171908002193', 'TWP HSD 113', '1719080', 'DEERFIELD', 'IL',
                'USA', '1', '4', '0', '0', 'True', 'True', 'True', 'False', 'False', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0',
                '0', '0', '0'},    
            new List < String > {'760547', 'Jeren', 'Techrt', 'jkeesh+techstart18@codehs.com', '1231231234', '2018-08-16 10:08:22',
                '2018-08-16 10:08:22', '889AD', 'DEERFIELD HIGH SCHOOL', '171908002193', 'TWP HSD 113', '1719080', 'DEERFIELD', 'CA',
                'USA', '1', '1', '1', '0', 'True', 'True', 'True', 'False', 'False', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0',
                '0', '0', '1'}
                         };
        return csvDataForUniqueInsertion;
    }
    static List < List < String >> getDataTwoCharacterAbbreviationInsertion() {
        List < List < String >> csvDataWithStateAbbreviations = new List < List < String >> {headers,
            new List < String > {'760545', 'Jeremy', 'TechStart', 'jkeesh+techstart12@codehs.com', '1231231234', '2018-08-16 10:08:22', 
                '2018-08-17 11:08:40', '889AD', 'DEERFIELD HIGH SCHOOL', '171908002193', 'TWP HSD 113', '1719080', 'DEERFIELD', 'IL',
                'USA', '1', '4', '0', '0', 'True', 'True', 'True', 'False', 'False', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0',
                '0', '0', '0'},    
            new List < String > {'760547', 'Jeren', 'Techrt', 'jkeesh+techstart12@codehs.com', '1231231234', '2018-08-16 10:08:22',
                '2018-08-16 10:08:22', '889AD', 'DEERFIELD HIGH SCHOOL', '171908002193', 'TWP HSD 113', '1719080', 'DEERFIELD', 'NewYork',
                'USA', '1', '1', '1', '0', 'True', 'True', 'True', 'False', 'False', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0',
                '0', '0', '1'}
        };
        return csvDataWithStateAbbreviations;
    } 
    static List < List < String >> getCSVDataWithDuplicateEmail() {
        List < List < String >> csvDataWithDuplicateEmail = new List < List < String >> {headers,
            new List < String > {'760545', 'Jeremy', 'TechStart', 'jkeesh+techstart12@codehs.com', '1231231234', '2018-08-16 10:08:22', 
                '2018-08-17 11:08:40', '889AD', 'DEERFIELD HIGH SCHOOL', '171908002193', 'TWP HSD 113', '1719080', 'DEERFIELD', 'IL',
                'USA', '1', '4', '0', '0', 'True', 'True', 'True', 'False', 'False', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0',
                '0', '0', '0'},    
            new List < String > {'760547', 'Jeren', 'Techrt', 'jkeesh+techstart12@codehs.com', '1231231234', '2018-08-16 10:08:22',
                '2018-08-16 10:08:22', '889AD', 'DEERFIELD HIGH SCHOOL', '171908002193', 'TWP HSD 113', '1719080', 'DEERFIELD', 'CA',
                'USA', '1', '1', '1', '0', 'True', 'True', 'True', 'False', 'False', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0',
                '0', '0', '1'}
        };
        return csvDataWithDuplicateEmail;
    }
    static List < List < String >> getCSVDataForEngagedAndNotEngaged() {
        List < List < String >> csvDataForEngagedNotEnagedInsertion = new List < List < String >> {headers,
            new List < String > {'760545', 'Jeremy', 'TechStart', 'jkeesh+techstart12@codehs.com', '1231231234', '2018-08-16 10:08:22', 
                '2018-08-17 11:08:40', '889AD', 'DEERFIELD HIGH SCHOOL', '171908002193', 'TWP HSD 113', '1719080', 'DEERFIELD', 'IL',
                'USA', '1', '4', '0', '0', 'True', 'True', 'True', 'False', 'False', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0',
                '0', '0', '0'},    
            new List < String > {'760547', 'Jeren', 'Techrt', 'jkeesh+techstart18@codehs.com', '1231231234', '2018-08-16 10:08:22',
                '2018-08-16 10:08:22', '889AD', 'DEERFIELD HIGH SCHOOL', '171908002193', 'TWP HSD 113', '1719080', 'DEERFIELD', 'CA',
                'USA', '1', '1', '1', '0', 'True', 'True', 'True', 'False', 'False', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0',
                '0', '0', '1'}
        };
        return csvDataForEngagedNotEnagedInsertion;
    }
    static List < String > getPPIRequiredFieldMissingData() {
        List < String > ppiRequiredFieldMissingData = new List < String >{'', 'Jeremy', 'TechStart', 'jkeesh+techstart12@codehs.com', '1231231234', 
            '2018-08-16 10:08:22','2018-08-17 11:08:40', '889AD', 'DEERFIELD HIGH SCHOOL', '171908002193', 'TWP HSD 113', '1719080', 'DEERFIELD', 'IL',
                'USA', '1', '4', '0', '0', 'True', 'True', 'True', 'False', 'False', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0',
                '0', '0', '0'};
        return ppiRequiredFieldMissingData;
    }
    static  List < String > getAccountRequiredFieldMissingData() {
        List < String > accountRequiredFieldMissingData = new List < String > {'760545', '', 'TechStart', 'jkeesh+techstart12@codehs.com', '1231231234', 
           '2018-08-16 10:08:22', '2018-08-17 11:08:40', '889AD', 'DEERFIELD HIGH SCHOOL', '171908002193', 'TWP HSD 113', '1719080', 'DEERFIELD', 'IL',
                'USA', '1', '4', '0', '0', 'True', 'True', 'True', 'False', 'False', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0',
                '0', '0', '0'};
        return accountRequiredFieldMissingData;
    }
    static  List < String > getContactRequiredFieldMissingData() {
        List < String > contactRequiredFieldMissingData = new List < String > {'760545', '', '', '', '1231231234', '2018-08-16 10:08:22', 
                '2018-08-17 11:08:40', '889AD', 'DEERFIELD HIGH SCHOOL', '171908002193', 'TWP HSD 113', '1719080', 'DEERFIELD', 'IL',
                'USA', '1', '4', '0', '0', 'True', 'True', 'True', 'False', 'False', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0',
                '0', '0', '0'};
        return contactRequiredFieldMissingData;
    }
    //Returns CSV Data for invalid Email classcode,and invalid Date/Time
    static List < List < String >> getinvalidFieldTypes() {
        List < List < String >> invalidFieldTypes = new List < List < String >> {headers,
            new List < String > {'760545', 'Jeremy', 'TechStart', 'jkeesh+techstart12_codehs.com','1231231234', '2018-08-16 10:08:22', 
                '2018-08-17 11:08:40', '889AD', 'DEERFIELD HIGH SCHOOL', '171908002193', 'TWP HSD 113', '1719080', 'DEERFIELD', 'IL',
                'USA', '1', '4', '0', '0', 'True', 'True', 'True', 'False', 'False', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0',
                '0', '0', '0'}, 
            new List < String > {'760546', 'Jeremy', 'TechStart', 'jkeesh+techstart12@codehs.com','1231231234', '2018-08-16 10:08:22', 
                '2018-08-17 11:08:40', '88', 'DEERFIELD HIGH SCHOOL', '171908002193', 'TWP HSD 113', '1719080', 'DEERFIELD', 'IL',
                'USA', '1', '4', '0', '0', 'True', 'True', 'True', 'False', 'False', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0',
                '0', '0', '0'},               
            new List < String > {'760547', 'Jeren', 'Techrt', 'jkeesh+techstart18@codehs.com', '1231231234', '2010:08:22',
                '2018-08-16 10:08:22', '889AD', 'DEERFIELD HIGH SCHOOL', '171908002193', 'TWP HSD 113', '1719080', 'DEERFIELD', 'CA',
                'USA', '1', '10', '8', '0', 'True', 'True', 'True', 'False', 'False', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0',
                '0', '0', '8'}   
        };
        return invalidFieldTypes;
    }
    //Returns CSV Data for Updation
    static List < List < String >> getCSVDataForUpdation() {
        List < List < String >> csvDataForUpdation = new List < List< String >> {headers,
            new List < String > {'760545', 'Jeremy', 'TechStart', 'jkeesh+techstart12@codehs.com', '1231231234', '2018-08-16 10:08:22', 
                '2018-08-22 11:08:40', '889AD', 'DEERFIELD HIGH SCHOOL', '171908002193', 'TWP HSD 113', '1719080', 'DEERFIELD', 'IL',
                'USA', '1', '8', '1', '0', 'False', 'false', 'false', 'false', 'false', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0',
                '0', '0', '1'},
            new List < String > {'760547', 'Jeren', 'Techrt', 'jkeesh+techstart18@codehs.com', '1231231234', '2018-08-16 10:08:22',
                '2018-08-16 10:08:22', '889AD', 'DEERFIELD HIGH SCHOOL', '171908002193', 'TWP HSD 113', '1719080', 'DEERFIELD', 'CA',
                'USA', '1', '10', '8', '0', 'True', 'True', 'True', 'False', 'False', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0',
                '0', '0', '8'},
            new List < String > {'760548', 'Jeremy', 'TechStart', 'jkeesh+techstart12@codehs.com', '1231231234', '2018-08-16 10:08:22', 
                '2018-08-17 11:08:40', '889AD', 'DEERFIELD HIGH SCHOOL', '171908002193', 'TWP HSD 113', '1719080', 'DEERFIELD', 'IL',
                'USA', '1', '2', '0', '0', 'True', 'True', 'True', 'False', 'False', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0',
                '0', '0', '2'},          
            new List < String > {'736980', 'Lusmaia', 'Diaz', 'lusmaia@fb.com', '1111111111', '2018-07-20 02:07:35', '2018-08-09 01:08:51',
                '31A73', 'Facebook', '171908002555', 'TWP HSD 113', '1719069', 'Menlo Park', 'CA', 'USA', '2', '15', '1', '6', 'True', 'True', 
                'True', 'True', 'True', '1', '0', '0', '0', '0', '0', '9', '3', '2', '0', '0', '1', '0'},
            new List < String > {'760545', 'Jeremy', 'TechStart', 'jkeesh+techstart13@codehs.com', '1231231234', '2018-08-16 10:08:22', 
                '2018-08-22 11:08:40', '889AD', 'DEERFIELD HIGH SCHOOL', '171908002193', 'TWP HSD 113', '1719080', 'DEERFIELD', 'IL',
                'USA', '1', '8', '0', '0', 'True', 'True', 'True', 'False', 'False', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 
                '0', '0', '0'},
            new List < String > {'760546', 'Jeren', 'Techrt', 'jkeesh+techstart18@codehs.com', '1231231234', '2018-08-16 10:08:22',
                '2018-08-16 10:08:22', '889AD', 'DEERFIELD HIGH SCHOOL', '171908002193', 'TWP HSD 113', '1719080', 'DEERFIELD', 'CA',
                'USA', '1', '1', '1', '0', 'True', 'True', 'True', 'False', 'False', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0',
                '0', '0', '1'},        
            new List < String > {'760545', '', 'TechStart', 'jkeesh+techstart13@codehs.com', '1231231234', '2018-08-16 10:08:22', '2018-08-22 11:08:40',
                '889AD', 'DEERFIELD HIGH SCHOOL', '171908002193', 'TWP HSD 113', '1719080', 'DEERFIELD', 'IL', 'USA', '1', '8', '0', '0', 'True',
                'True', 'True', 'False', 'False', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0'}
        };
        return csvDataForUpdation;
    }
    //Returns CSV Data for first insertion to test metric Change Type
    static List< List< String >> getCSVDataInitialEntry() {
        List < List < String >> csvDataInitialEntry = new List < List < String >> {headers,
            new List < String > {'760545', 'Jeremy', 'TechStart', 'jkeesh+techstart12@codehs.com', '1231231234', '2018-08-16 10:08:22', 
                '2018-08-22 11:08:40', '889AD', 'DEERFIELD HIGH SCHOOL', '171908002193', 'TWP HSD 113', '1719080', 'DEERFIELD', 'IL',
                'USA', '1', '0', '0', '0', 'True', 'True', 'True', 'True', 'True', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 
                '0', '0', '0'}
        };    
        return csvDataInitialEntry;
    }
    //Returns CSV Data to test same Metric Type Change
    static List < List< String >> getCSVDataResultUpdation() {
        List < List < String >> csvDataResultUpdate = new List < List < String >> {headers,
            new List < String > {'760545', 'Jeremy', 'TechStart', 'jkeesh+techstart12@codehs.com', '1231231234', '2018-08-16 10:08:22',
                '2018-08-22 11:08:40', '889AD', 'DEERFIELD HIGH SCHOOL', '171908002193', 'TWP HSD 113', '1719080', 'DEERFIELD', 'IL',
                'USA', '1', '8', '0', '0', 'True', 'True', 'True', 'True', 'True', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0',
                '0', '0', '0'}
        };   
        return csvDataResultUpdate;
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