/*
 * Salesforce has a limit of executing only 100 SOQL query per transaction. 
 * To avoid the limit, the SOQL query is fired once at the start to get data of different Objects 
 * in a Map having key as their primary key fields and these maps are refreshed after new objects 
 * are inserted.
 * 
 * Salesforce has a limit of executing only 150 DML statements per transaction. To avoid these 
 * governor limits, bulk insert and bulk updates are done.
 * @class EdmodUploadCSVRecords uses CSV parsed content to insert data in corresponding 
 * standard/custom objects.   
 */
public class TempUpsertCSVRecords {

    Map < String, Id > accountsMap;
    Map < String, PartnerPlatformInfo__c > partnerPlatformInfoMap;
    Map < Id, Contact > contactsMap;
    Map < String, Contact > newContacts;
    List < PartnerPlatformInfo__c > updatePartnerPlatformInfo;
    List < LastLoginInfo__c > newLastLoginInfo;
    List < Result__c > newResultsToAdd;
    List < Result__c > resultsToBeUpdated;
    Map < String, Opportunity > opportunitiesMap;
    Map < String, Opportunity > newOpportunities;
    Map < String, Opportunity > updatedOpportunities;
    Map < String, Result__c > resultsMap;
    public List < List < String >> csvData;
    public String program;
    public String platformType;
    List < CurrentEducationProgram__c > currentEducationProgramList;

    public TempUpsertCSVRecords(List < List < String >> data, String programName, String platform) {
        csvData = data;
        program = programName;
        platformType = platform;
        accountsMap = new Map < String, Id > ();
        partnerPlatformInfoMap = new Map < String, PartnerPlatformInfo__c > ();
        contactsMap = new Map < Id, Contact > ();
        newContacts = new Map < String, Contact > ();
        updatePartnerPlatformInfo = new List < PartnerPlatformInfo__c > ();
        newLastLoginInfo = new List < LastLoginInfo__c > ();
        newResultsToAdd = new List < Result__c > ();
        opportunitiesMap = new Map < String, Opportunity > ();
        newOpportunities = new Map < String, Opportunity > ();
        updatedOpportunities = new Map < String, Opportunity > ();
        resultsToBeUpdated = new List < Result__c > ();
        resultsMap = new Map < String, Result__c > ();
        currentEducationProgramList = getCurrentEducationProgram(program);
    }

    /*
     * insertAccountList: Insert Data into Accounts Object 
     * @param data:Valid Input for any source
     * @param programName
     * @param platform
     */
    public void processAccounts() {
        try {
            Map < String, Account > newAccountsToAdd = new Map < String, Account > ();
            initializeAccountsMap();

            //Parse CSV List to Create Account records if not present.        
            newAccountsToAdd = addNewAccountsToList();
            List < Account > newAccountsToAddList = new List < Account > ();
            for (Account acc: newAccountsToAdd.values()) {
                newAccountsToAddList.add(acc);
            }
            
            //Perform insertion of new accounts. 			
            createOrUpdateRecords(newAccountsToAddList, 'Insert');

            //Update the accountsMap with new accounts and use for Contacts/Results object processing.        
            initializeAccountsMap();
            processContacts();
        } catch (Exception e) {
            System.debug(Logginglevel.ERROR, 'Class: UploadCSVRecords, Line Number: ' + e.getLineNumber() +
                         ' Exception has occurred in Accounts: ' );
            System.debug('Data: ' + csvData);
        }
    }

    public void processContacts() {
        try {
            //Create a Map for PartnerPlatformInfo for lookup        
            initializePartnerPlatformInfoMap();

            //Parse CSV List to Create Contact records if not present.          
            addNewContactsToList();
            List < Contact > newContactsList = new List < Contact > ();
            for (Contact contact: newContacts.values()) {
                newContactsList.add(contact);
            }

            //Perform insertion of new contacts. 
            Database.SaveResult[] saveContactStatus;
            List < String > contactErrors = new List < String > ();
            List < PartnerPlatformInfo__c > newPartnerPlatformList = new List < PartnerPlatformInfo__c > ();
            Integer i = 0;
            if (!newContactsList.isEmpty()) {
                saveContactStatus = Database.insert(newContactsList, false);

                // Update a Map for Contacts.
                contactsMap = initializeContactsMap();

                for (Database.SaveResult status: saveContactStatus) {
                    if (!status.isSuccess()) {
                        for (Database.Error err: status.getErrors()) {
                            contactErrors.add('Error while inserting Contact ' + newContactsList.get(i) +
                                ' Message: ' + err.getStatusCode() + ': ' + err.getMessage());
                        }
                    } else {
                        Contact insertedContact = contactsMap.get(status.getId());
                        List < String > csvRow = getRowFromEmail(insertedContact.Email.trim());
                        newPartnerPlatformList.add(createPartnerPlatformObject(csvRow, insertedContact));
                    }
                    i++;
                }
            }

            //Perform insert/update on PartnerPlatformInfo List.            
            createOrUpdateRecords(updatePartnerPlatformInfo, 'Update');
            createOrUpdateRecords(newPartnerPlatformList, 'Insert');
            //Perform insertion on LastLoginInfo List.             
            createOrUpdateRecords(newLastLoginInfo, 'Insert');

            // Update the Map for Contacts.
            contactsMap = initializeContactsMap();

            //Update the Map for PartnerPlatformInfo.  
            initializePartnerPlatformInfoMap();
            processResults();
        } catch (Exception e) {
            System.debug(Logginglevel.ERROR, 'Class: UploadCSVRecords, Line Number: ' + e.getLineNumber() +
                         ' Exception has occurred in Contacts: ' + e.getStackTraceString());
            System.debug('Data: ' + csvData);
        }

    }

    public void processResults1() {
        try {
            List < Contact > updateChangeTypeTime = new List < Contact > ();
            initializeResultsMap();
            System.debug('line135 maps '+accountsMap);
            System.debug('line136 maps '+contactsMap);
            //Parse CSV List to Create Flow records if not present.          
            for (Integer i = 1; i < csvData.size(); i++) {
                try {
                    if (isRowValid(csvData[i])) {
                        
                        Id accId = accountsMap.get(csvData[i].get(EdmodHeaderConstantIndices.INDEX_SCHOOL).trim() +
                            EdmodConstants.KEY_DELIMITER + csvData[i].get(EdmodHeaderConstantIndices.Index_State).trim());
                        Id conId = partnerPlatformInfoMap.get(csvData[i].get(EdmodHeaderConstantIndices.Index_ID).trim() +
                            EdmodConstants.KEY_DELIMITER + platformType).Contact_ID__c;
                        Id ppiId = partnerPlatformInfoMap.get(csvData[i].get(EdmodHeaderConstantIndices.Index_ID).trim() +
                            EdmodConstants.KEY_DELIMITER + platformType).Id;

                        String changeType = addResultsToListAndGetChangeType(accId, conId, ppiId, i);
						System.debug('inside processresults  '+changeType +' '+ accId+' '+ conId +' '+ ppiId+' '+ i);
                        Contact contact = contactsMap.get(conId);
                        if (changeType.length() > 0) {
                            contact.Last_Change_Type__c = String.valueOf(changeType).substring(0, changeType.length() - 1);
                        }
                        contact.Last_Change_Time__c = DateTime.now();
                        updateChangeTypeTime.add(contact);
                        changeType = '';
                    }
                } catch (NullPointerException e) {
                    System.debug(Logginglevel.ERROR, 'Class: UploadCSVRecords, Line Number: ' + e.getLineNumber() +
                        ' NullPointerException has occurred for record ' + i + ' in Contacts: ' + e.getStackTraceString());
                } catch (Exception e) {
                    System.debug(Logginglevel.ERROR, 'Class: UploadCSVRecords, Line Number: ' + e.getLineNumber() +
                        ' Exception has occurred for record ' + i + ' in Contacts: ' + e.getStackTraceString());
                }
            }
            //Perform insertion of new Results. 
            createOrUpdateRecords(newResultsToAdd, 'Insert');

            //Update Change Type and Change Time for each contact.
            createOrUpdateRecords(updateChangeTypeTime, 'Update');

            //Perform update on existing result.                 
            createOrUpdateRecords(resultsToBeUpdated, 'Update');
            processOpportunities();
        } catch (Exception e) {
            System.debug(Logginglevel.ERROR, 'Class: UploadCSVRecords, Line Number: ' + e.getLineNumber() + ' Exception has occurred in Results: ' + e.getStackTraceString());
            System.debug('Data: ' + csvData);
        }
    }
        public void processResults() {
        try {
            List < Contact > updateChangeTypeTime = new List < Contact > ();
           // initializeResultsMap();
            System.debug('line135 maps '+accountsMap);
            System.debug('line136 maps '+contactsMap);
            //Parse CSV List to Create Flow records if not present.          
            for (Integer i = 1; i < csvData.size(); i++) {
                try {
                  //  if (isRowValid(csvData[i])) {
                          if (true) {
                        
                        Id accId = accountsMap.get(csvData[i].get(EdmodHeaderConstantIndices.INDEX_SCHOOL).trim() +
                                                   EdmodConstants.KEY_DELIMITER + csvData[i].get(EdmodHeaderConstantIndices.INDEX_State).trim());
                        Id conId = partnerPlatformInfoMap.get(csvData[i].get(EdmodHeaderConstantIndices.INDEX_ID).trim() +
                                                              EdmodConstants.KEY_DELIMITER + platformType).Contact_ID__c;
                        Id ppiId = partnerPlatformInfoMap.get(csvData[i].get(EdmodHeaderConstantIndices.INDEX_ID).trim() +
                                                              EdmodConstants.KEY_DELIMITER + platformType).Id;
                        
                        String changeType = addResultsToListAndGetChangeType(accId, conId, ppiId, i);
                        System.debug('inside processresults  '+changeType +' '+ accId+' '+ conId +' '+ ppiId+' '+ i);
                        Contact contact = contactsMap.get(conId);
                        if (changeType.length() > 0) {
                            contact.Last_Change_Type__c = String.valueOf(changeType).substring(0, changeType.length() - 1);
                        }
                        contact.Last_Change_Time__c = DateTime.now();
                        updateChangeTypeTime.add(contact);
                        changeType = '';
                    }
                } catch (NullPointerException e) {
                    System.debug(Logginglevel.ERROR, 'Class: UploadCSVRecords, Line Number: ' + e.getLineNumber() +
                                 ' NullPointerException has occurred for record ' + i + ' in Contacts: ' +  e.getMessage() );
                } catch (Exception e) {
                    System.debug(Logginglevel.ERROR, 'Class: UploadCSVRecords, Line Number: ' + e.getLineNumber() + ' ' 
                                + ' Exception has occurred for record ' + i + ' in Contacts: ' +  e.getMessage() );
                }
            }
            //Perform insertion of new Results. 
           // createOrUpdateRecords(newResultsToAdd, 'Insert');
           Schema.SObjectField keyField = Result__c.Fields.External_Lookup_Key__c;
			upsertRecords(newResultsToAdd,keyField);          
            //Update Change Type and Change Time for each contact.
            createOrUpdateRecords(updateChangeTypeTime, 'Update');
            
            //Perform update on existing result.                 
            //createOrUpdateRecords(resultsToBeUpdated, 'Update');
        } catch (Exception e) {
            System.debug(Logginglevel.ERROR, 'Class: UploadCSVRecords, Line Number: ' + e.getLineNumber() + ' Exception has occurred in Results: ' + e.getStackTraceString());
            System.debug('Data: ' + csvData);
        }
    }
    public void processOpportunities() {
        try {
            //Initialize Opportuniy Map
            initializeOpportunitiesMap();
            
            
            for (String opp: newOpportunities.keySet()) {
                System.debug('Key:' + opp);
            }

            addNewOpportunitiesToList();

            List < Opportunity > newOpportunitiesList = new List < Opportunity > ();
            for (Opportunity opp: newOpportunities.values()) {
                newOpportunitiesList.add(opp);
            }
			List < Opportunity > updatedOpportunitiesList = new List < Opportunity > ();
            for (Opportunity opp: updatedOpportunities.values()) {
                updatedOpportunitiesList.add(opp);
            }

            //Insert new/updated Opportunities.
            if(newOpportunitiesList.size() > 0) {
                createOrUpdateRecords(newOpportunitiesList, EdmodConstants.DML_OPERATION_INSERT);
            }
            
            if(updatedOpportunitiesList.size() > 0) {
                createOrUpdateRecords(updatedOpportunitiesList, EdmodConstants.DML_OPERATION_UPDATE);
            }
            

        } catch (Exception e) {
            System.debug(Logginglevel.ERROR, 'Class: UploadCSVRecords, Line Number: ' + e.getLineNumber() + ' Exception has occurred in Opportunity: ' + e.getStackTraceString());
            System.debug('Data: ' + csvData);
        }
    }
    
    //To check that Num Students Who Completed A Project should not be greater than Total Students.
    public boolean isRowValid(List < String > csvRow) {
        List < String > errorList = new List < String > ();
        Boolean isErrorPresent = false;
        Boolean isMetricValuesPresent = checkAllMetricValues(csvRow);

        if (!isMetricValuesPresent) {
            errorList.add('Metric values cannot be null or empty');
            isErrorPresent = true;
        } else {
            if ((Integer.valueOf(csvRow.get(EdmodHeaderConstantIndices.INDEX_NUM_STUDENTS_COMPLETED_PROJECT)) >
                    Integer.valueOf(csvRow.get(EdmodHeaderConstantIndices.INDEX_NUM_STUDENTS))) ||
                (Integer.valueOf(csvRow.get(EdmodHeaderConstantIndices.INDEX_NUM_STUDENTS_STARTED_PROJECT)) >
                    Integer.valueOf(csvRow.get(EdmodHeaderConstantIndices.INDEX_NUM_STUDENTS)))) {
                errorList.add('Invalid Row: #Students signed up is less than sum of #students with project started or #students with project completed');
                isErrorPresent = true;
            }
            if (Integer.valueOf(csvRow.get(EdmodHeaderConstantIndices.INDEX_NUM_STUDENTS_COMPLETED_PROJECT)) >
                Integer.valueOf(csvRow.get(EdmodHeaderConstantIndices.INDEX_NUM_STUDENTS_STARTED_PROJECT))) {
                    System.debug(Integer.valueOf(csvRow.get(EdmodHeaderConstantIndices.INDEX_NUM_STUDENTS_COMPLETED_PROJECT))+ ' > '+
                                Integer.valueOf(csvRow.get(EdmodHeaderConstantIndices.INDEX_NUM_STUDENTS_STARTED_PROJECT)));
                errorList.add('Invalid Row: #Students with project started is less than #students completed');
                isErrorPresent = true;
            }
            if (Datetime.valueOf(csvRow.get(EdmodHeaderConstantIndices.INDEX_LAST_LOGIN)) <
                Datetime.valueOf(csvRow.get(EdmodHeaderConstantIndices.INDEX_DATE_JOINED))) {
                errorList.add('Invalid Row: Last login date is less than date joined');
                isErrorPresent = true;
            }
        }
        
        if (isErrorPresent) {
            System.debug(LoggingLevel.ERROR, errorList);
            return false;
        } else {
            return true;
        }
    }

    public Boolean checkAllMetricValues(List < String > csvRow) {
        for (Integer i = EdmodHeaderConstantIndices.INDEX_NUM_STUDENTS; i < csvRow.size(); i++) {
            if (EdmodUtilityMethods.IsNullEmpty(csvRow.get(i))) {
                return false;
            }
        }
        return true;
    }

    //To print error list in debug logs
    public void printErrorsInLog(List < String > errorsList) {
        for (Integer i = 0; i < errorsList.size(); i++) {
            System.debug(Logginglevel.ERROR, errorsList[i]);
        }
    }

    public List < String > getRowFromEmail(String email) {
        for (Integer i = 1; i < csvData.size(); i++) {
            if (csvData[i].get(EdmodHeaderConstantIndices.Index_Email).trim().equalsIgnoreCase(email))
                return csvData[i];
        }
        return null;
    }

    public List < CurrentEducationProgram__c > getCurrentEducationProgram(String programType) {
        List < CurrentEducationProgram__c > nameIdList = [SELECT Name, Id, ProgramEndDate__c FROM CurrentEducationProgram__c
            WHERE ProgramType__c =: programType
        ];
        return nameIdList;
    }

    PartnerPlatformInfo__c createPartnerPlatformObject(List < String > csvRow, Contact insertedContact) {
        PartnerPlatformInfo__c partnerPlatformRecord = new PartnerPlatformInfo__c();
        partnerPlatformRecord.Contact_ID__c = insertedContact.Id;
        partnerPlatformRecord.Teacher_ID__c = Double.valueOf(csvRow.get(EdmodHeaderConstantIndices.INDEX_ID));
        partnerPlatformRecord.Name = platformType;
        partnerPlatformRecord.Last_Login_Time__c = DateTime.valueOf(EdmodHeaderConstantIndices.INDEX_LAST_LOGIN);
        partnerPlatformRecord.Class_Code__c = csvRow.get(EdmodHeaderConstantIndices.INDEX_CLASS_CODE);
        partnerPlatformRecord.Sections__c = Double.valueOf(csvRow.get(EdmodHeaderConstantIndices.INDEX_NUM_SECTIONS));
        return partnerPlatformRecord;
    }

    public Map < String, Id > initializeAccountsMap() {
        //Create a Map that contains <Name,Id> for all accounts.
        accountsMap.clear();
        for (Account acc: [SELECT Id, Name, Site FROM Account]) {
            accountsMap.put(acc.Name + EdmodConstants.KEY_DELIMITER + acc.Site, acc.Id);
        }
        system.debug('@! '+accountsMap.size());
        return accountsMap;
    }

    public Map < String, Result__c > initializeResultsMap() {
        resultsMap.clear();
        String searchPattern = program + EdmodConstants.SERACH_LIKE;
        for (Result__c result: [SELECT Id, CurrentEducationProgram_UID__c, Account_ID__c, Contact_ID__c, Name,
                PartnerPlatformInfo__c, MetricType__c, MetricValue__c, MetricText__c, Time__c FROM Result__c
                WHERE CurrentEducationProgram_UID__c != null AND Name LIKE: searchPattern
            ]) {
            resultsMap.put(result.Contact_ID__c + EdmodConstants.KEY_DELIMITER + result.Name + EdmodConstants.KEY_DELIMITER +
                result.MetricType__c + EdmodConstants.KEY_DELIMITER + result.Account_ID__c + EdmodConstants.KEY_DELIMITER + result.PartnerPlatformInfo__c, result);
        }
        return resultsMap;
    }

    public Map < String, PartnerPlatformInfo__c > initializePartnerPlatformInfoMap() {
        partnerPlatformInfoMap.clear();
        for (PartnerPlatformInfo__c ppi: [SELECT Teacher_ID__c, Name, Id, Contact_ID__c, Last_Login_Time__c, Class_Code__c, Sections__c
                FROM PartnerPlatformInfo__c WHERE Name =: platformType
            ]) {
            partnerPlatformInfoMap.put(String.valueOf(ppi.Teacher_ID__c) + EdmodConstants.KEY_DELIMITER + ppi.Name, ppi);
        }
        return partnerPlatformInfoMap;
   }

    public Map < Id, Contact > initializeContactsMap() {
        contactsMap.clear();
        Map < Id, Contact > contactsMap = new Map < Id, Contact > ();
        for (Contact con: [SELECT Id, AccountId, Email, FirstName, LastName, Phone, Date_Joined_Time__c, Last_Change_Time__c, Last_Change_Type__c FROM Contact]) {
            contactsMap.put(con.Id, con);
        }
        return contactsMap;
    }

    public Set < String > initializeTechStartPartnersSet() {
        //Create a Set that stores  all TechStart Partners School_NCES_ID__c.
        Set < String > allTechStartPartnerSet = new Set < String > ();
        for (TechStartPartners__c techStart: [SELECT School_NCES_ID__c from TechStartPartners__c]) {
            allTechStartPartnerSet.add(techStart.School_NCES_ID__c);
        }
        return allTechStartPartnerSet;
    }

    public Map < String, Account > addNewAccountsToList() {
        Set < String > techStartPartnerSet = new Set < String > ();
        techStartPartnerSet = initializeTechStartPartnersSet();
        Map < String, Account > newAccountsToAdd = new Map < String, Account > ();
        for (Integer i = 1; i < csvData.size(); i++) {
            try {
				//System.debug('accountsMap '+accountsMap.size());
                if ((!(accountsMap.containsKey(csvData[i].get(EdmodHeaderConstantIndices.INDEX_SCHOOL).trim() +
                        EdmodConstants.KEY_DELIMITER + csvData[i].get(EdmodHeaderConstantIndices.Index_State).trim())) &&
                    !(newAccountsToAdd.containsKey(csvData[i].get(EdmodHeaderConstantIndices.INDEX_SCHOOL).trim() +
                        EdmodConstants.KEY_DELIMITER + csvData[i].get(EdmodHeaderConstantIndices.Index_State).trim())))) {
                    Account acc = new Account();
                    acc.Name = csvData[i].get(EdmodHeaderConstantIndices.INDEX_SCHOOL);
                    acc.School_NCES_ID__c = csvData[i].get(EdmodHeaderConstantIndices.INDEX_SCHOOL_NCES_ID);
                    acc.District__c = csvData[i].get(EdmodHeaderConstantIndices.INDEX_DISTRICT);
                    acc.District_NCES_ID__c = csvData[i].get(EdmodHeaderConstantIndices.INDEX_DISTRICT_NCES_ID);
                    acc.BillingCity = csvData[i].get(EdmodHeaderConstantIndices.Index_City);
                    acc.Site = csvData[i].get(EdmodHeaderConstantIndices.Index_State);
                    acc.BillingCountry = csvData[i].get(EdmodHeaderConstantIndices.Index_Country);

                    if (techStartPartnerSet.contains(csvData[i].get(EdmodHeaderConstantIndices.INDEX_SCHOOL_NCES_ID))) {
                        acc.Is_Partner__c = true;
                    } else {
                        acc.Is_Partner__c = false;
                    }
                    newAccountsToAdd.put(acc.Name + EdmodConstants.KEY_DELIMITER + acc.Site, acc);
                }

            } catch (NullPointerException e) {
                System.debug(Logginglevel.ERROR, 'Class: UploadCSVRecords, Line Number: ' + e.getLineNumber() + ' NullPointerException has occurred for record ' +
                    i + ' in Accounts: ' + e.getStackTraceString());
            } catch (Exception e) {
                System.debug(Logginglevel.ERROR, 'Class: UploadCSVRecords, Line Number: ' + e.getLineNumber() + ' Exception has occurred for record ' + i +
                    ' in Accounts: ' + e.getStackTraceString());
            }
        }
        return newAccountsToAdd;
    }

    public void createOrUpdateRecords(List < sObject > newRecordsList, String action) {
        Database.SaveResult[] saveStatus;
        List < String > errors = new List < String > ();
        if (!newRecordsList.isEmpty()) {
            if (action.equals('Insert'))
                saveStatus = Database.insert(newRecordsList, false);
            else
                saveStatus = Database.update(newRecordsList, false);
            //System.debug('saveResultListAccount:' + saveStatus);
            Integer i = 0;
            for (Database.SaveResult status: saveStatus) {
                if (!status.isSuccess()) {
                    for (Database.Error err: status.getErrors()) {
                        errors.add('Error while inserting ' + newRecordsList.getSObjectType() + ' ' + newRecordsList.get(i) +
                            ' Message: ' + err.getStatusCode() + ': ' + err.getMessage());
                    }
                }
                i++;
            }
        }
        printErrorsInLog(errors);
    }

    public void addNewContactsToList() {
        for (Integer i = 1; i < csvData.size(); i++) {
            try {
                if (!(partnerPlatformInfoMap.containsKey(csvData[i].get(EdmodHeaderConstantIndices.Index_Id).trim() +
                            EdmodConstants.KEY_DELIMITER + platformType)) &&
                        !(newContacts.containsKey(csvData[i].get(EdmodHeaderConstantIndices.Index_Id).trim() +
                            EdmodConstants.KEY_DELIMITER + platformType))) {
                    Contact con = new Contact();
                    con.AccountId = accountsMap.get(csvData[i].get(EdmodHeaderConstantIndices.INDEX_SCHOOL).trim() +
                        EdmodConstants.KEY_DELIMITER + csvData[i].get(EdmodHeaderConstantIndices.Index_State).trim());
                    con.FirstName = csvData[i].get(EdmodHeaderConstantIndices.INDEX_FIRST_NAME);
                    con.LastName = csvData[i].get(EdmodHeaderConstantIndices.INDEX_LAST_NAME);
                    con.Email = csvData[i].get(EdmodHeaderConstantIndices.INDEX_EMAIL).toLowerCase();
                    con.Phone = csvData[i].get(EdmodHeaderConstantIndices.INDEX_PHONE);

                    String dateJoined = csvData[i].get(EdmodHeaderConstantIndices.INDEX_DATE_JOINED);
                    dateJoined.replaceAll('[\n\r]', '');
                    con.Date_Joined_Time__c = DateTime.valueOf(dateJoined);

                    newContacts.put(csvData[i].get(EdmodHeaderConstantIndices.Index_ID).trim() + EdmodConstants.KEY_DELIMITER + platformType, con);

                } else {
                    PartnerPlatformInfo__c newPPIRow = partnerPlatformInfoMap.get(csvData[i].get(EdmodHeaderConstantIndices.Index_ID).trim() +
                        EdmodConstants.KEY_DELIMITER + platformType);
                    newPPIRow.Last_Login_Time__c = DateTime.valueOf(csvData[i].get(EdmodHeaderConstantIndices.INDEX_LAST_LOGIN));
                    updatePartnerPlatformInfo.add(newPPIRow);
                    LastLoginInfo__c newLLIRow = new LastLoginInfo__c();
                    newLLIRow.Platform_ID__c = newPPIRow.Id;
                    newLLIRow.Last_Login__c = newPPIRow.Last_Login_Time__c;
                    newLastLoginInfo.add(newLLIRow);
                }
            } catch (NullPointerException e) {
                System.debug(Logginglevel.ERROR, 'Class: UploadCSVRecords, Line Number: ' + e.getLineNumber() + ' NullPointerException has occurred for record ' +
                    i + ' in Contacts: ' + e.getStackTraceString());
            } catch (Exception e) {
                System.debug(Logginglevel.ERROR, 'Class: UploadCSVRecords, Line Number: ' + e.getLineNumber() + ' Exception has occurred for record ' +
                    i + ' in Contacts: ' + e.getStackTraceString());
            }
        }
    }

    public String addResultsToListAndGetChangeType1(Id accId, Id conId, Id ppiId, Integer i) {
        Map < String, String > HeaderToMetricTypeMap = EdmodConstants.getHeaderToMetricTypeMap();
        String changeType = ''; //To update Change Type field of Contact. 
        //System.debug('414 '+HeaderToMetricTypeMap);
        for (Integer j = 0; j < csvData.get(0).size(); j++) {
            //System.debug('415 '+HeaderToMetricTypeMap.containsKey(csvData[0].get(j).trim()));
            
            if (HeaderToMetricTypeMap.containsKey(csvData[0].get(j).trim())) {
                Result__c result = new Result__c();
                if (!resultsMap.containsKey(conId + EdmodConstants.KEY_DELIMITER + currentEducationProgramList.get(0).Name + EdmodConstants.KEY_DELIMITER +
                        HeaderToMetricTypeMap.get(csvData[0].get(j).trim()) + EdmodConstants.KEY_DELIMITER + accId + EdmodConstants.KEY_DELIMITER + ppiId)) {
                            //System.debug('421 '+csvData[i].get(j).trim().equalsIgnoreCase('False'));
                            if (csvData[i].get(j).trim().equalsIgnoreCase('False')){                                 
                                continue;
                            }
                    changeType = addResults(accId, conId,ppiId, changeType, HeaderToMetricTypeMap, i, j);
                } else {                     
                    changeType = updateResults(accId, conId, ppiId, changeType, HeaderToMetricTypeMap, i, j);
                    //System.debug('426 '+changeType);
                }
            }
        }
        return changeType;
    }
	public String addResultsToListAndGetChangeType(Id accId, Id conId, Id ppiId, Integer i) {
        Map < String, String > HeaderToMetricTypeMap = EdmodConstants.getHeaderToMetricTypeMap();
        String changeType = ''; //To update Change Type field of Contact. 
       // System.debug('414 '+HeaderToMetricTypeMap);
        for (Integer j = 0; j < csvData.get(0).size(); j++) {
         //   System.debug('415 '+HeaderToMetricTypeMap.containsKey(csvData[0].get(j).trim()));
            
            if (HeaderToMetricTypeMap.containsKey(csvData[0].get(j).trim())) {
                                
                    if (csvData[i].get(j).trim().equalsIgnoreCase('False')){                                 
                        continue;
                    }
                    changeType = addResults(accId, conId,ppiId, changeType, HeaderToMetricTypeMap, i, j);                
            }
        }
        return changeType;
    }
    public String addResults(Id accId, Id conId,Id ppiId, String changeType, Map < String, String > HeaderToMetricTypeMap, 
                             Integer i, Integer j) {
                                 Result__c result = new Result__c();
                                 //  System.debug('line432 '+changeType);
                                 if ((csvData[i].get(j).trim().equalsIgnoreCase('True') || Double.valueOf(csvData[i].get(j).trim()) > Double.valueOf(EdmodConstants.MINIMUM_METRIC_VALUE) ||
                                      (csvData[0].get(j).trim().equals('Num Students') && Double.valueOf(csvData[i].get(j).trim()) == Double.valueOf(EdmodConstants.MINIMUM_METRIC_VALUE)))) {
                                          
                                          result.Account_ID__c = accId;
                                          result.Contact_ID__c = conId;
                                          result.MetricType__c = HeaderToMetricTypeMap.get(csvData[0].get(j).trim());
                                          result.Name = String.valueOf(currentEducationProgramList.get(0).Name);
                                          result.CurrentEducationProgram_UID__c = currentEducationProgramList.get(0).Id;
                                          result.PartnerPlatformInfo__c = partnerPlatformInfoMap.get(csvData[i].get(0).trim() + EdmodConstants.KEY_DELIMITER + platformType).Id;
                                          result.Time__c = DateTime.now();
                                          changeType = changeType + String.valueOf(HeaderToMetricTypeMap.get(csvData[0].get(j).trim())) + ',';
                                          result.External_Lookup_Key__c=accId+EdmodConstants.KEY_DELIMITER+conId+EdmodConstants.KEY_DELIMITER
                                              +String.valueOf(currentEducationProgramList.get(0).Name)+EdmodConstants.KEY_DELIMITER+ppiId+
                                              EdmodConstants.KEY_DELIMITER+HeaderToMetricTypeMap.get(csvData[0].get(j).trim());
                                          
                                          //  System.debug('line444 '+changeType);
                                          if (csvData[i].get(j).trim().equalsIgnoreCase('True'))
                                              result.MetricValue__c = 1;
                                          else
                                              result.MetricValue__c = Double.valueOf(csvData[i].get(j).trim());
                                          
                                          newResultsToAdd.add(result);
                                      }
                                 return changeType;
                             }

    public String updateResults(Id accId, Id conId, Id ppiId, String changeType, Map < String, String > HeaderToMetricTypeMap, 
                                Integer i, Integer j) {
        Result__c result = new Result__c();
        result = resultsMap.get(conId + EdmodConstants.KEY_DELIMITER + currentEducationProgramList.get(0).Name +
            EdmodConstants.KEY_DELIMITER + HeaderToMetricTypeMap.get(csvData[0].get(j).trim()) + EdmodConstants.KEY_DELIMITER + accId +
            EdmodConstants.KEY_DELIMITER + ppiId);
        Double oldMetricValue = result.MetricValue__c;
        Double fieldValue;
        if (csvData[i].get(j).equalsIgnoreCase('True')) {
            fieldValue = 1.0;
        } else if (csvData[i].get(j).equalsIgnoreCase('False')) {
            fieldValue = 0.0;
        } else
            fieldValue = Double.valueOf(csvData[i].get(j));
		//System.debug('@@@@@####Condition TEst'+(oldMetricValue != fieldValue));
        if (oldMetricValue != fieldValue) {
            if (csvData[i].get(j).trim().equalsIgnoreCase('True')){
                result.MetricValue__c = 1;
                //System.debug('@@@@@####IN result.MetricValue__c');
            }
            else if (csvData[i].get(j).trim().equalsIgnoreCase('False'))
                result.MetricValue__c = 0;
            else{
                result.MetricValue__c = Double.valueOf(csvData[i].get(j));
                        }
            changeType = changeType + String.valueOf(HeaderToMetricTypeMap.get(csvData[0].get(j).trim())) + ',';
        }
        resultsToBeUpdated.add(result);
        return changeType;
    }
    public void initializeOpportunitiesMap() {
        opportunitiesMap.clear();
        for (Opportunity opp: [SELECT AccountId, Contact_ID__c, PartnerPlatformInfo__c, Name, Type, S1__c, S2__c, S3__c, S4__c, StageName from Opportunity]) {
            opportunitiesMap.put(opp.AccountId + EdmodConstants.KEY_DELIMITER + opp.Contact_ID__c + EdmodConstants.KEY_DELIMITER +
                opp.PartnerPlatformInfo__c + EdmodConstants.KEY_DELIMITER + opp.Name + EdmodConstants.KEY_DELIMITER + opp.Type, opp);
        }
    }

    public void addNewOpportunitiesToList() {
        for (Integer i = 1; i < csvData.size(); i++) {
            if (isRowValid(csvData[i])) {
                try {
                    Id accId = accountsMap.get(csvData[i].get(EdmodHeaderConstantIndices.INDEX_SCHOOL).trim() +
                        EdmodConstants.KEY_DELIMITER + csvData[i].get(EdmodHeaderConstantIndices.Index_State).trim());
                    Id conId = partnerPlatformInfoMap.get(csvData[i].get(EdmodHeaderConstantIndices.Index_ID).trim() +
                        EdmodConstants.KEY_DELIMITER + platformType).Contact_ID__c;
                    Id ppiId = partnerPlatformInfoMap.get(csvData[i].get(EdmodHeaderConstantIndices.Index_ID).trim() +
                        EdmodConstants.KEY_DELIMITER + platformType).Id;

                    if (!(opportunitiesMap.containsKey((accId + EdmodConstants.KEY_DELIMITER + conId + EdmodConstants.KEY_DELIMITER +
                            ppiId + EdmodConstants.KEY_DELIMITER + currentEducationProgramList.get(0).Name +
                            EdmodConstants.KEY_DELIMITER + EdmodConstants.ONBOARDING_OPPORTUNITY).trim())) &&
                        !(newOpportunities.containsKey((accId + EdmodConstants.KEY_DELIMITER + conId + EdmodConstants.KEY_DELIMITER +
                            ppiId + EdmodConstants.KEY_DELIMITER + currentEducationProgramList.get(0).Name +
                            EdmodConstants.KEY_DELIMITER + EdmodConstants.ONBOARDING_OPPORTUNITY).trim()))) {

                        // Add new opportunities to Map.
                        addOnboardingOpportunities(accId, conId, ppiId, i);
                    } else {
                        //Update existing Opportunities
                        updateOnboardingOpportunities(accId, conId, ppiId, i);
                    }

                } catch (NullPointerException e) {
                    System.debug(Logginglevel.ERROR, 'Class: UploadCSVRecords, Line Number: ' + e.getLineNumber() + ' NullPointerException has occurred for record ' +
                        i + ' in Opportunities: ' + e.getStackTraceString());
                } catch (Exception e) {
                    System.debug(Logginglevel.ERROR, 'Class: UploadCSVRecords, Line Number: ' + e.getLineNumber() + ' Exception has occurred for record ' +
                        i + ' in Opportunities: ' + e.getStackTraceString());
                }
            }
        }
    }
    
    public void addOnboardingOpportunities(Id accId, Id conId, Id ppiId, Integer i) {
        System.debug('currentEducationProgramList'+currentEducationProgramList);
        Opportunity opportunity = new Opportunity();
        opportunity.AccountId = accId;
        opportunity.Contact_ID__c = conId;
        opportunity.PartnerPlatformInfo__c = ppiId;
        opportunity.Name = currentEducationProgramList.get(0).Name;
        opportunity.Type = EdmodConstants.ONBOARDING_OPPORTUNITY;
        if(currentEducationProgramList.get(0).ProgramEndDate__c != null)
	        opportunity.CloseDate = currentEducationProgramList.get(0).ProgramEndDate__c;
        opportunity.S1__c = DateTime.now();
        opportunity.StageName = EdmodConstants.ONBOARDING_STAGE_S1;
        if ((Double.valueOf(csvData[i].get(EdmodHeaderConstantIndices.INDEX_NUM_STUDENTS))) >
            Double.valueOf(EdmodConstants.MINIMUM_METRIC_VALUE)) {
            opportunity.S2__c = DateTime.now();
            opportunity.StageName = EdmodConstants.ONBOARDING_STAGE_S2;
        }
        if ((Double.valueOf(csvData[i].get(EdmodHeaderConstantIndices.INDEX_NUM_STUDENTS_STARTED_PROJECT)) >
                Double.valueOf(EdmodConstants.MINIMUM_METRIC_VALUE))) {
            opportunity.S3__c = DateTime.now();
            opportunity.StageName = EdmodConstants.ONBOARDING_STAGE_S3;
        }
        if ((Double.valueOf(csvData[i].get(EdmodHeaderConstantIndices.INDEX_NUM_STUDENTS_COMPLETED_PROJECT)) >
                Double.valueOf(EdmodConstants.MINIMUM_METRIC_VALUE))) {
            opportunity.S4__c = DateTime.now();
            opportunity.StageName = EdmodConstants.ONBOARDING_STAGE_S4;
            addNurturingOpportunities(accId, conId, ppiId, i);

        }
        
        System.debug('New Onboarding Opp added:'+opportunity);

        newOpportunities.put(opportunity.AccountId + EdmodConstants.KEY_DELIMITER + opportunity.Contact_ID__c +
            EdmodConstants.KEY_DELIMITER + opportunity.PartnerPlatformInfo__c + EdmodConstants.KEY_DELIMITER +
            opportunity.Name + EdmodConstants.KEY_DELIMITER + opportunity.Type, opportunity);

    }

    public void addNurturingOpportunities(Id accId, Id conId, Id ppiId, Integer i) {
        Opportunity opportunity = new Opportunity();
        opportunity.AccountId = accId;
        opportunity.Contact_ID__c = conId;
        opportunity.PartnerPlatformInfo__c = ppiId;
        opportunity.Name = currentEducationProgramList.get(0).Name;
        opportunity.Type = EdmodConstants.NURTURING_OPPORTUNITY;
        opportunity.CloseDate = currentEducationProgramList.get(0).ProgramEndDate__c;
        Double percentageStudentsCompletedProject = computePercentage(i);
        if ((percentageStudentsCompletedProject > 0.0) && (percentageStudentsCompletedProject < 50.0)) {
            opportunity.S1__c = DateTime.now();
            opportunity.StageName = EdmodConstants.NURTURING_STAGE_S1;
        }
        if ((percentageStudentsCompletedProject >= 50.0) && (percentageStudentsCompletedProject < 75.0)) {
            opportunity.S1__c = DateTime.now();
            opportunity.S2__c = DateTime.now();
            opportunity.StageName = EdmodConstants.NURTURING_STAGE_S2;
        }
        if ((percentageStudentsCompletedProject >= 75.0) && (percentageStudentsCompletedProject < 100.0)) {
            opportunity.S1__c = DateTime.now();
            opportunity.S2__c = DateTime.now();
            opportunity.S3__c = DateTime.now();
            opportunity.StageName = EdmodConstants.NURTURING_STAGE_S3;
        }
        if (percentageStudentsCompletedProject == 100.0) {
            opportunity.S1__c = DateTime.now();
            opportunity.S2__c = DateTime.now();
            opportunity.S3__c = DateTime.now();
            opportunity.S4__c = DateTime.now();
            opportunity.StageName = EdmodConstants.NURTURING_STAGE_S4;
        }

        System.debug('New Nurturing Opp added:'+opportunity);
        
        newOpportunities.put(opportunity.AccountId + EdmodConstants.KEY_DELIMITER + opportunity.Contact_ID__c +
            EdmodConstants.KEY_DELIMITER + opportunity.PartnerPlatformInfo__c + EdmodConstants.KEY_DELIMITER +
            opportunity.Name + EdmodConstants.KEY_DELIMITER + opportunity.Type, opportunity);
    }

    public void updateOnboardingOpportunities(Id accId, Id conId, Id ppiId, Integer i) {
        
        System.debug(' Opp Map:' + opportunitiesMap);
        //System.debug('Existing Opp: '+opportunitiesMap.get(accId + EdmodConstants.KEY_DELIMITER + conId + EdmodConstants.KEY_DELIMITER +
            //ppiId + EdmodConstants.KEY_DELIMITER + currentEducationProgramList.get(0).Name +
            //EdmodConstants.KEY_DELIMITER + EdmodConstants.ONBOARDING_OPPORTUNITY));
        Boolean flag = false;
        Opportunity onboardingOpp = opportunitiesMap.get(accId + EdmodConstants.KEY_DELIMITER + conId + EdmodConstants.KEY_DELIMITER +
            ppiId + EdmodConstants.KEY_DELIMITER + currentEducationProgramList.get(0).Name +
            EdmodConstants.KEY_DELIMITER + EdmodConstants.ONBOARDING_OPPORTUNITY);
        
        System.debug('Existing Opppp: '+onboardingOpp);

        //System.debug('opp condition'+(onboardingOpp.S2__c == null));
        if ((onboardingOpp.S2__c == null) && (Double.valueOf(csvData[i].get(EdmodHeaderConstantIndices.INDEX_NUM_STUDENTS)) >
                Double.valueOf(EdmodConstants.MINIMUM_METRIC_VALUE))) {
            onboardingOpp.S2__c = DateTime.now();
            onboardingOpp.StageName = EdmodConstants.ONBOARDING_STAGE_S2;
            flag = true;
        }
        if ((onboardingOpp.S3__c == null) && (Double.valueOf(csvData[i].get(EdmodHeaderConstantIndices.INDEX_NUM_STUDENTS_STARTED_PROJECT)) >
                Double.valueOf(EdmodConstants.MINIMUM_METRIC_VALUE))) {
            onboardingOpp.S3__c = DateTime.now();
            onboardingOpp.StageName = EdmodConstants.ONBOARDING_STAGE_S3;
            flag = true;
        }
        if (Double.valueOf(csvData[i].get(EdmodHeaderConstantIndices.INDEX_NUM_STUDENTS_COMPLETED_PROJECT)) >
            Double.valueOf(EdmodConstants.MINIMUM_METRIC_VALUE)) {
            if (onboardingOpp.S4__c == null) {
                onboardingOpp.S4__c = DateTime.now();
                onboardingOpp.StageName = EdmodConstants.ONBOARDING_STAGE_S4;
                flag = true;
            }
            
            if(!opportunitiesMap.containsKey((accId + EdmodConstants.KEY_DELIMITER + conId + EdmodConstants.KEY_DELIMITER +
                            ppiId + EdmodConstants.KEY_DELIMITER + currentEducationProgramList.get(0).Name +
                                             EdmodConstants.KEY_DELIMITER + EdmodConstants.NURTURING_OPPORTUNITY).trim())) {
                                                 addNurturingOpportunities(accId, conId, ppiId, i);     
                                             }
                else {
                    updateNurturingOpportunities(accId, conId, ppiId, i);       
                }                 
        }
        if(flag) {
            updatedOpportunities.put(onboardingOpp.AccountId + EdmodConstants.KEY_DELIMITER + onboardingOpp.Contact_ID__c +
            EdmodConstants.KEY_DELIMITER + onboardingOpp.PartnerPlatformInfo__c + EdmodConstants.KEY_DELIMITER +
            onboardingOpp.Name + EdmodConstants.KEY_DELIMITER + onboardingOpp.Type, onboardingOpp);
        }
        System.debug('******** Onboarding Update completed ');
        
    }

    public void updateNurturingOpportunities(Id accId, Id conId, Id ppiId, Integer i) {
        Opportunity nurturingOpp = opportunitiesMap.get(accId + EdmodConstants.KEY_DELIMITER + conId + EdmodConstants.KEY_DELIMITER +
            ppiId + EdmodConstants.KEY_DELIMITER + currentEducationProgramList.get(0).Name +
            EdmodConstants.KEY_DELIMITER + EdmodConstants.NURTURING_OPPORTUNITY);
        Boolean flag = false;
        System.debug('Existing Nurturing Opp: '+accId + EdmodConstants.KEY_DELIMITER + conId + EdmodConstants.KEY_DELIMITER +
            ppiId + EdmodConstants.KEY_DELIMITER + currentEducationProgramList.get(0).Name +
            EdmodConstants.KEY_DELIMITER + EdmodConstants.NURTURING_OPPORTUNITY);

        Double percentageStudentsCompletedProject = computePercentage(i);
        System.debug('% calculated'+ percentageStudentsCompletedProject);
        if ((percentageStudentsCompletedProject > 0.0) && (percentageStudentsCompletedProject < 50.0)) {
            if (nurturingOpp.S1__c == null) {
                nurturingOpp.S1__c = DateTime.now();
            }
            nurturingOpp.StageName = EdmodConstants.NURTURING_STAGE_S1;
        }
        if ((percentageStudentsCompletedProject >= 50.0) && (percentageStudentsCompletedProject < 75.0)) {
            if (nurturingOpp.S2__c == null) {
                nurturingOpp.S2__c = DateTime.now();
            }
            nurturingOpp.StageName = EdmodConstants.NURTURING_STAGE_S2;
        }
        if ((percentageStudentsCompletedProject >= 75.0) && (percentageStudentsCompletedProject < 100.0)) {
            if (nurturingOpp.S3__c == null) {
                nurturingOpp.S3__c = DateTime.now();
            }
            nurturingOpp.StageName = EdmodConstants.NURTURING_STAGE_S3;
        }
        if (percentageStudentsCompletedProject == 100.0) {
            if (nurturingOpp.S4__c == null) {
                nurturingOpp.S4__c = DateTime.now();
            }
            nurturingOpp.StageName = EdmodConstants.NURTURING_STAGE_S4;
        }
	
        
        updatedOpportunities.put(nurturingOpp.AccountId + EdmodConstants.KEY_DELIMITER + nurturingOpp.Contact_ID__c +
            EdmodConstants.KEY_DELIMITER + nurturingOpp.PartnerPlatformInfo__c + EdmodConstants.KEY_DELIMITER +
            nurturingOpp.Name + EdmodConstants.KEY_DELIMITER + nurturingOpp.Type, nurturingOpp);
        
        System.debug('updated Opp:'+updatedOpportunities);
    }

    public Double computePercentage(Integer i) {
        Double studentsCompletedProject = Double.valueOf(csvData[i].get(EdmodHeaderConstantIndices.INDEX_NUM_STUDENTS_COMPLETED_PROJECT).trim());
        Integer totalStudents = Integer.valueOf(csvData[i].get(EdmodHeaderConstantIndices.INDEX_NUM_STUDENTS).trim());
        Double percentage = (studentsCompletedProject / totalStudents) * 100;
        return percentage;
    }
    void upsertRecords(List<Result__c> newRecordsList,Schema.SObjectField key){
        Database.UpsertResult[] saveStatus;
        List < String > errors = new List < String > ();
        if (!newRecordsList.isEmpty()) {
                saveStatus = Database.upsert(newRecordsList,key,false);
            System.debug('saveResultListResult:' + saveStatus);
            Integer i = 0;
            for (Database.UpsertResult status: saveStatus) {
                if (!status.isSuccess()) {
                    for (Database.Error err: status.getErrors()) {
                        errors.add('Error while inserting ' + newRecordsList.getSObjectType() + ' ' + newRecordsList.get(i) +
                                   ' Message: ' + err.getStatusCode() + ': ' + err.getMessage());
                    }
                }
                i++;
            }
        }
        printErrorsInLog(errors);    
    }
}