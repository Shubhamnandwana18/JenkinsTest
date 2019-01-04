/*
 * Salesforce has a limit of executing only 100 SOQL query per transaction. 
 * To avoid the limit, the SOQL query is fired once at the start and we are using upsert on 
 * various objects.
 * 
 * Salesforce has a limit of executing only 150 DML statements per transaction. To avoid these 
 * governor limits, bulk insert and bulk updates are done.
 * @class EdmodUploadCSVRecords uses CSV parsed content to insert data in corresponding 
 * standard/custom objects.   
 */
public class TempUploadCSVRecords {

    Map < String, Id > accountsMap;
    Map < String, PartnerPlatformInfo__c > partnerPlatformInfoMap;
    Map < Id, Contact > contactsMap;
    Map < String, Contact > newContacts;
    List < Result__c > newResultsToAdd;
    public List < List < String >> csvData;
    public String program;
    public String platformType;
    public String batchJobId;
    List < CurrentEducationProgram__c > currentEducationProgramList;
    Map < String, Opportunity > newOpportunities;
    Map < String, Opportunity > opportunitiesMap;
    Map < String, Opportunity > updatedOpportunities;
    List < Error_Log__c > invalidRowErrors;

    public TempUploadCSVRecords(List < List < String >> data, String programName, String platform, Id batchJobId) {
        csvData = data;
        program = programName;
        platformType = platform;
        accountsMap = new Map < String, Id > ();
        partnerPlatformInfoMap = new Map < String, PartnerPlatformInfo__c > ();
        contactsMap = new Map < Id, Contact > ();
        newContacts = new Map < String, Contact > ();
        newResultsToAdd = new List < Result__c > ();
        currentEducationProgramList = getCurrentEducationProgram(programName);
        newOpportunities = new Map < String, Opportunity > ();
        opportunitiesMap = new Map < String, Opportunity > ();
        updatedOpportunities = new Map < String, Opportunity > ();
        this.batchJobId = String.valueOf(batchJobId);
        invalidRowErrors = new List < Error_Log__c > ();
    }

    /*
     * processAccounts
     * @description Process Accounts for CSV Data
     * @example
     * EdmodUploadCSVRecords edmodUploadCSVRecords = new EdmodUploadCSVRecords();
     * edmodUploadCSVRecords.processAccounts();
     */
    public void processAccounts() {
        try {
            Map < String, Account > accountsToAdd = new Map < String, Account > ();

            //Parse CSV List to Create Account records if not present.        
            accountsToAdd = addAccountsToList();
            List < Account > accountsToAddList = new List < Account > ();
            for (Account acc: accountsToAdd.values()) {
                accountsToAddList.add(acc);
            }
            //Perform upsert of account using External_Lookup_Key__c.           
            Schema.SObjectField keyField = Account.Fields.External_Lookup_Key__c;
            upsertAccountRecords(accountsToAddList, keyField);

            processContacts();
        } catch (Exception e) {
            String errorMessage = 'Exception in Accounts upload at ' + e.getLineNumber() + ' : ' + e.getMessage();
            List < Error_Log__c > errors = new List < Error_Log__c > ();
            errors.add(getErrorLogRecord(batchJobId, DateTime.now(), errorMessage));
            printErrorsInLog(errors);
        }
    }

    /*
     * processContacts
     * @description Process Contacts for CSV Data
     * @example
     * EdmodUploadCSVRecords edmodUploadCSVRecords = new EdmodUploadCSVRecords();
     * edmodUploadCSVRecords.processContacts();
     */
    public void processContacts() {
        List < Error_Log__c > errors = new List < Error_Log__c > ();
        try {
            //Parse CSV List to Create Contact records if not present.          
            addContactsToList();
            List < Contact > contactsList = new List < Contact > ();
            for (Contact contact: newContacts.values()) {
                contactsList.add(contact);
            }

            //Perform upsert of contacts using Email. 
            Database.UpsertResult[] upsertContactStatus;
            List < String > contactErrors = new List < String > ();
            List < PartnerPlatformInfo__c > partnerPlatformList = new List < PartnerPlatformInfo__c > ();
            if (!contactsList.isEmpty()) {
                Schema.SObjectField keyField = Contact.Fields.Email;
                upsertContactStatus = upsertContactRecords(contactsList, keyField);

                for (Database.UpsertResult status: upsertContactStatus) {
                    if(status.isSuccess()) {
                        Contact insertedContact = contactsMap.get(status.getId());
                        List < String > csvRow = getRowFromEmail(insertedContact.Email.trim());
                        if (csvRow != null) {
                            partnerPlatformList.add(getPartnerPlatformObject(csvRow, insertedContact));
                        } else {
                            String errorMessage = 'CSV row is not present for Email :' + insertedContact.Email.trim();
                            errors.add(getErrorLogRecord(batchJobId, DateTime.now(), errorMessage));
                        }
                    }
                }
            }
            //Perform upsert of PartnerPlatformInfo using External_Lookup_Key__c.
            Schema.SObjectField keyField = PartnerPlatformInfo__c.Fields.External_Lookup_Key__c;
            upsertPartnerPlatformInfoRecords(partnerPlatformList, keyField);
            processResults();
        } catch (Exception e) {
            String errorMessage = 'Exception in Contacts upload at ' + e.getLineNumber() + ' : ' + e.getMessage();
            errors.add(getErrorLogRecord(batchJobId, DateTime.now(), errorMessage));
        }
        printErrorsInLog(errors);
    }

    /*
     * processResults
     * @description Process Results for CSV Data
     * @example
     * EdmodUploadCSVRecords edmodUploadCSVRecords = new EdmodUploadCSVRecords();
     * edmodUploadCSVRecords.processResults();
     */
    public void processResults() {
        List < Error_Log__c > errorLogList = new List < Error_Log__c > ();
        try {
            if (currentEducationProgramList.size() > 0) {
                //Parse CSV List to Create Flow records if not present.          
                for (Integer i = 1; i < csvData.size(); i++) {
                    try {
                        if (accountsMap.isEmpty() || partnerPlatformInfoMap.isEmpty())
                            return;
                        PartnerPlatformInfo__c ppi = partnerPlatformInfoMap.get(csvData[i].get(EdmodHeaderConstantIndices.INDEX_ID).trim() +
                            EdmodConstants.KEY_DELIMITER + platformType);
                        Id accId = accountsMap.get(csvData[i].get(EdmodHeaderConstantIndices.INDEX_SCHOOL).trim() +
                            EdmodConstants.KEY_DELIMITER + csvData[i].get(EdmodHeaderConstantIndices.INDEX_STATE).trim());
                        if (ppi != null && accId != null) {
                            Id conId = ppi.Contact_ID__c;
                            Id ppiId = ppi.Id;
                            if (accId != null) {
                                addResultsToList(accId, conId, ppiId, i);
                            }
                        }
                    } catch (NullPointerException e) {
                        String errorMessage = 'Null Pointer Exception in Results upload at ' + e.getLineNumber() + ' : ' + e.getMessage();
                        errorLogList.add(getErrorLogRecord(batchJobId, DateTime.now(), errorMessage));
                    } catch (Exception e) {
                        String errorMessage = 'Exception in Results upload at ' + e.getLineNumber() + ' : ' + e.getMessage();
                        errorLogList.add(getErrorLogRecord(batchJobId, DateTime.now(), errorMessage));
                    }
                }
                //Perform upsert on Results using External_Lookup_Key__c. 
                Schema.SObjectField keyField = Result__c.Fields.External_Lookup_Key__c;
                upsertResultRecords(newResultsToAdd, keyField);
                processOpportunities();
            } else {
                String errorMessage = 'Result: Current Education Program is not present for program type ' + program;
                errorLogList.add(getErrorLogRecord(batchJobId, DateTime.now(), errorMessage));
            }
        } catch (Exception e) {
            String errorMessage = 'Exception in Results upload at ' + e.getLineNumber() + ' : ' + e.getMessage();
            errorLogList.add(getErrorLogRecord(batchJobId, DateTime.now(), errorMessage));
        } finally {
            printErrorsInLog(errorLogList);
        }
    }

    /*
     * processOpportunities
     * @description Process Opportunities for CSV Data
     * @example
     * EdmodUploadCSVRecords edmodUploadCSVRecords = new EdmodUploadCSVRecords();
     * edmodUploadCSVRecords.processOpportunities();
     */
    public void processOpportunities() {
        List < Error_Log__c > errorLogList = new List < Error_Log__c > ();
        try {
            initializeOpportunitiesMap();
            addNewOpportunitiesToList();
            List < Opportunity > newOpportunitiesList = new List < Opportunity > ();
            for (Opportunity opp: newOpportunities.values()) {
                newOpportunitiesList.add(opp);
            }
            List < Opportunity > updatedOpportunitiesList = new List < Opportunity > ();
            for (Opportunity opp: updatedOpportunities.values()) {
                updatedOpportunitiesList.add(opp);
            }

            createOrUpdateRecords(newOpportunitiesList, EdmodConstants.DML_OPERATION_INSERT);
            createOrUpdateRecords(updatedOpportunitiesList, EdmodConstants.DML_OPERATION_UPDATE);

        } catch (Exception e) {
            String errorMessage = 'Exception in Opportunity upload at ' + e.getLineNumber() + ' : ' + e.getMessage();
            errorLogList.add(getErrorLogRecord(batchJobId, DateTime.now(), errorMessage));
        } finally {
            printErrorsInLog(errorLogList);
        }

    }

    /*
     * isRowValid
     * @param csvRow
     * @description check if CSV row is valid
     * 
     */
    public boolean isRowValid(List < String > csvRow) {
        Error_Log__c errorLog = new Error_Log__c();
        String errorMessage = '';
        Boolean isErrorPresent = false;
        Boolean isMetricValuesPresent = checkAllMetricValues(csvRow);

        if (!isMetricValuesPresent) {
            errorMessage = errorMessage + 'Invalid Row: Metric values cannot be Empty or Negative or Decimal';
            isErrorPresent = true;
        } else {
            if ((Integer.valueOf(csvRow.get(EdmodHeaderConstantIndices.INDEX_NUM_STUDENTS_COMPLETED_PROJECT).trim()) >
                    Integer.valueOf(csvRow.get(EdmodHeaderConstantIndices.INDEX_NUM_STUDENTS).trim())) ||
                (Integer.valueOf(csvRow.get(EdmodHeaderConstantIndices.INDEX_NUM_STUDENTS_STARTED_PROJECT).trim()) >
                    Integer.valueOf(csvRow.get(EdmodHeaderConstantIndices.INDEX_NUM_STUDENTS).trim()))) {
                errorMessage = errorMessage +
                    'Invalid Row: #Students signed up is less than sum of #students with project started or #students with project completed.';
                isErrorPresent = true;
            }
            if (Integer.valueOf(csvRow.get(EdmodHeaderConstantIndices.INDEX_NUM_STUDENTS_COMPLETED_PROJECT).trim()) >
                Integer.valueOf(csvRow.get(EdmodHeaderConstantIndices.INDEX_NUM_STUDENTS_STARTED_PROJECT).trim())) {
                errorMessage = errorMessage +
                    '\nInvalid Row: #Students with project started is less than sum of #students completed.';
                isErrorPresent = true;
            }
            if (Datetime.valueOf(csvRow.get(EdmodHeaderConstantIndices.INDEX_LAST_LOGIN).trim()) <
                Datetime.valueOf(csvRow.get(EdmodHeaderConstantIndices.INDEX_DATE_JOINED).trim())) {
                errorMessage = errorMessage +
                    '\nInvalid Row: Last login date is less than date joined.';
                isErrorPresent = true;
            }
        }
        if (isErrorPresent) {
            errorMessage = errorMessage + '\nCSV Row:\n' + String.valueOf(csvRow);
            invalidRowErrors.add(getErrorLogRecord(batchJobId, DateTime.now(), errorMessage));
            return false;
        } else {
            return true;
        }
    }

    /*
     * checkAllMetricValues
     * @param csvRow
     * @description check if metric values of CSV row are valid 
     */
    public Boolean checkAllMetricValues(List < String > csvRow) {
        for (Integer i = EdmodHeaderConstantIndices.INDEX_NUM_STUDENTS; i < csvRow.size(); i++) {

            if (EdmodUtilityMethods.IsNullEmpty(csvRow.get(i).trim())) {
                return false;
            } else if ((!String.valueOf(csvRow.get(i).trim()).equalsIgnoreCase('True')) && (!String.valueOf(csvRow.get(i).trim()).equalsIgnoreCase('False')) &&
                (decimal.valueOf(csvRow.get(i).trim()) - Math.floor(decimal.valueOf(csvRow.get(i).trim())) != 0)) {
                return false;
            } else if ((!String.valueOf(csvRow.get(i).trim()).equalsIgnoreCase('True')) && (!String.valueOf(csvRow.get(i).trim()).equalsIgnoreCase('False')) &&
                (Integer.valueOf(csvRow.get(i).trim()) < 0)) {
                return false;
            }
        }
        return true;
    }

    /*
     * getRowFromEmail
     * @param email
     * @description Returns row for the given email id.
     * 
     */
    public List < String > getRowFromEmail(String email) {
        for (Integer i = 1; i < csvData.size(); i++) {
            if (csvData[i].get(EdmodHeaderConstantIndices.INDEX_EMAIL).trim().equalsIgnoreCase(email))
                return csvData[i];
        }
        return null;
    }

    /*
     * getCurrentEducationProgram
     * @param programType
     * @description Returns detail about Current Education Program for specific program.
     * 
     */
    public List < CurrentEducationProgram__c > getCurrentEducationProgram(String programType) {
        List < CurrentEducationProgram__c > currentEducationProgramList = [SELECT Name, Id, ProgramEndDate__c FROM CurrentEducationProgram__c
            WHERE ProgramType__c =: programType
        ];
        return currentEducationProgramList;
    }

    /*
     * getPartnerPlatformObject
     * @param csvRow
     * @param insertedContact
     * @description Return new PartnerPlatformInfo object corresponding to new Contact.
     * 
     */
    PartnerPlatformInfo__c getPartnerPlatformObject(List < String > csvRow, Contact insertedContact) {
        PartnerPlatformInfo__c partnerPlatformRecord = new PartnerPlatformInfo__c();
        partnerPlatformRecord.Contact_ID__c = insertedContact.Id;
        partnerPlatformRecord.Teacher_ID__c = Double.valueOf(csvRow.get(EdmodHeaderConstantIndices.INDEX_ID).trim());
        partnerPlatformRecord.Name = platformType;
        partnerPlatformRecord.Last_Login_Time__c = DateTime.valueOf(csvRow.get(EdmodHeaderConstantIndices.INDEX_LAST_LOGIN));
        partnerPlatformRecord.Class_Code__c = csvRow.get(EdmodHeaderConstantIndices.INDEX_CLASS_CODE).trim();
        partnerPlatformRecord.Sections__c = Double.valueOf(csvRow.get(EdmodHeaderConstantIndices.INDEX_NUM_SECTIONS).trim());
        partnerPlatformRecord.External_Lookup_Key__c = partnerPlatformRecord.Teacher_ID__c + EdmodConstants.KEY_DELIMITER + partnerPlatformRecord.Name;
        return partnerPlatformRecord;
    }

    /*
     * initializeAccountsMap
     * @param accountIds     
     * @description Returns Account Map
     * 
     */
    public Map < String, Id > initializeAccountsMap(List < id > accountIds) {
        for (Account acc: [SELECT Id, Name, Site FROM Account where Id IN: accountIds]) {
            accountsMap.put(acc.Name + EdmodConstants.KEY_DELIMITER + acc.Site, acc.Id);
        }
        return accountsMap;
    }

    /*
     * initializePartnerPlatformInfoMap
     * @param partnerPlatformInfoIds     
     * @description Returns PartnerPlatformInfo Map
     * 
     */
    public void initializePartnerPlatformInfoMap(List < id > partnerPlatformInfoIds) {
        for (PartnerPlatformInfo__c ppi: [SELECT Teacher_ID__c, Name, Id, Contact_ID__c, Last_Login_Time__c, Class_Code__c, Sections__c
                FROM PartnerPlatformInfo__c WHERE Name =: platformType and Id IN: partnerPlatformInfoIds
            ]) {
            partnerPlatformInfoMap.put(String.valueOf(ppi.Teacher_ID__c) + EdmodConstants.KEY_DELIMITER + ppi.Name, ppi);
        }
    }

    /*
     * initializeContactsMap
     * @param contactIds     
     * @description Returns Contact Map
     * 
     */
    public void initializeContactsMap(List < Id > contactIds) {
        for (Contact con: [SELECT Id, AccountId, Email, FirstName, LastName, Phone, Date_Joined_Time__c, Last_Change_Time__c,
                Last_Change_Type__c FROM Contact where Id IN: contactIds
            ]) {
            contactsMap.put(con.Id, con);
        }
    }

    /*
     * initializeTechStartPartnersSet
     * @description Returns TechStartPartners Set
     * 
     */
    public Set < String > initializeTechStartPartnersSet() {
        Set < String > allTechStartPartnerSet = new Set < String > ();
        for (TechStartPartners__c techStart: [SELECT School_NCES_ID__c FROM TechStartPartners__c]) {
            allTechStartPartnerSet.add(techStart.School_NCES_ID__c);
        }
        return allTechStartPartnerSet;
    }

    /*
     * initializeOpportunitiesMap
     * @description Returns Opportunity Map
     * 
     */
    public void initializeOpportunitiesMap() {
        for (Opportunity opp: [SELECT AccountId, Contact_ID__c, PartnerPlatformInfo__c, Name, Type, S1__c, S2__c, S3__c, S4__c, StageName
                FROM Opportunity WHERE Contact_ID__c IN: contactsMap.keySet() AND Name =: currentEducationProgramList.get(0).Name
            ]) {
            opportunitiesMap.put(opp.AccountId + EdmodConstants.KEY_DELIMITER + opp.Contact_ID__c + EdmodConstants.KEY_DELIMITER +
                opp.PartnerPlatformInfo__c + EdmodConstants.KEY_DELIMITER + opp.Name + EdmodConstants.KEY_DELIMITER + opp.Type, opp);
        }
    }

    /*
     * addAccountsToList
     * @description Create new Account Object and remove csv row that could not pass validations.
     */
    public Map < String, Account > addAccountsToList() {
        Set < String > techStartPartnerSet = initializeTechStartPartnersSet();
        Map < String, Account > accountsToAdd = new Map < String, Account > ();
        List < Error_Log__c > errorLogList = new List < Error_Log__c > ();
        for (Integer i = 1; i < csvData.size(); i++) {
            try {
                if (isRowValid(csvData[i])) {
                    Account acc = new Account();
                    acc.Name = csvData[i].get(EdmodHeaderConstantIndices.INDEX_SCHOOL).trim();
                    acc.School_NCES_ID__c = csvData[i].get(EdmodHeaderConstantIndices.INDEX_SCHOOL_NCES_ID).trim();
                    acc.District__c = csvData[i].get(EdmodHeaderConstantIndices.INDEX_DISTRICT).trim();
                    acc.District_NCES_ID__c = csvData[i].get(EdmodHeaderConstantIndices.INDEX_DISTRICT_NCES_ID).trim();
                    acc.BillingCity = csvData[i].get(EdmodHeaderConstantIndices.INDEX_CITY).trim();
                    acc.Site = csvData[i].get(EdmodHeaderConstantIndices.INDEX_STATE).trim();
                    acc.BillingCountry = csvData[i].get(EdmodHeaderConstantIndices.INDEX_COUNTRY).trim();
                    acc.External_Lookup_Key__c = acc.Name + EdmodConstants.KEY_DELIMITER + acc.Site;

                    if (techStartPartnerSet.contains(csvData[i].get(EdmodHeaderConstantIndices.INDEX_SCHOOL_NCES_ID).trim())) {
                        acc.Is_Partner__c = true;
                    } else {
                        acc.Is_Partner__c = false;
                    }
                    accountsToAdd.put(acc.Name + EdmodConstants.KEY_DELIMITER + acc.Site, acc);
                } else {
                    csvData.remove(i);
                    i--;
                }
            } catch (NullPointerException e) {
                String errorMessage = 'Null Pointer Exception in Accounts upload at ' + e.getLineNumber() + ' : ' + e.getMessage();
                errorLogList.add(getErrorLogRecord(batchJobId, DateTime.now(), errorMessage));
            } catch (Exception e) {
                String errorMessage = 'Exception in Accounts upload at ' + e.getLineNumber() + ' : ' + e.getMessage();
                errorLogList.add(getErrorLogRecord(batchJobId, DateTime.now(), errorMessage));
            }
        }

        printErrorsInLog(invalidRowErrors);
        printErrorsInLog(errorLogList);
        return accountsToAdd;
    }

    /*
     * addContactsToList
     * @description Create new Contact Object.
     */
    public void addContactsToList() {
        List < Error_Log__c > errorLogList = new List < Error_Log__c > ();
        for (Integer i = 1; i < csvData.size(); i++) {
            try {
                if (accountsMap.isEmpty())
                    return;
                Id accId = accountsMap.get(csvData[i].get(EdmodHeaderConstantIndices.INDEX_SCHOOL).trim() +
                    EdmodConstants.KEY_DELIMITER + csvData[i].get(EdmodHeaderConstantIndices.INDEX_STATE).trim());
                if (accId != null) {
                    Contact con = new Contact();
                    con.AccountId = accId;
                    con.FirstName = csvData[i].get(EdmodHeaderConstantIndices.INDEX_FIRST_NAME).trim();
                    con.LastName = csvData[i].get(EdmodHeaderConstantIndices.INDEX_LAST_NAME).trim();
                    con.Email = csvData[i].get(EdmodHeaderConstantIndices.INDEX_EMAIL).trim().toLowerCase();
                    con.Phone = csvData[i].get(EdmodHeaderConstantIndices.INDEX_PHONE).trim();
					con.Last_Change_Time__c = DateTime.valueOf(csvData[i].get(EdmodHeaderConstantIndices.INDEX_DATE_JOINED));
                    con.Last_Change_Type__c = EdmodConstants.TEACHER_REGISTERED;
                        
                    String dateJoined = csvData[i].get(EdmodHeaderConstantIndices.INDEX_DATE_JOINED).trim();
                    dateJoined.replaceAll('[\n\r]', '');
                    con.Date_Joined_Time__c = DateTime.valueOf(dateJoined);

                    String lastLogin = csvData[i].get(EdmodHeaderConstantIndices.INDEX_LAST_LOGIN).trim();
                    lastLogin.replaceAll('[\n\r]', '');
                    if (DateTime.valueOf(lastLogin) != con.Date_Joined_Time__c) {
                        con.IsEngaged__c = 'ENGAGED';
                    } else {
                        con.IsEngaged__c = 'NOT_ENGAGED';
                    }
                    newContacts.put(csvData[i].get(EdmodHeaderConstantIndices.INDEX_ID).trim() + EdmodConstants.KEY_DELIMITER + platformType, con);
                }
            } catch (NullPointerException e) {
                String errorMessage = 'Null Pointer Exception in Contacts upload at ' + e.getLineNumber() + ' : ' + e.getMessage();
                errorLogList.add(getErrorLogRecord(batchJobId, DateTime.now(), errorMessage));
            } catch (Exception e) {
                String errorMessage = 'Exception in Contacts upload at ' + e.getLineNumber() + ' : ' + e.getMessage();
                errorLogList.add(getErrorLogRecord(batchJobId, DateTime.now(), errorMessage));
            }
        }
        printErrorsInLog(errorLogList);
    }

    /*
     * addResultsToList
     * @param accId  
     * @param conId  
     * @param ppiId  
     * @param i : csv row index     
     * @description Add result to list
     */
    public void addResultsToList(Id accId, Id conId, Id ppiId, Integer i) {
        Map < String, String > HeaderToMetricTypeMap = EdmodConstants.getHeaderToMetricTypeMap();
        for (Integer j = 0; j < csvData.get(0).size(); j++) {
            if (HeaderToMetricTypeMap.containsKey(csvData[0].get(j).trim())) {
                addResults(accId, conId, ppiId, HeaderToMetricTypeMap, i, j);
            }
        }
    }

    /*
     * addResults
     * @param accId  
     * @param conId  
     * @param ppiId  
     * @param HeaderToMetricTypeMap
     * @param i : csv row index
     * @param j  
     * @description Process CSV row at index i to Create Result object
     */
    public void addResults(Id accId, Id conId, Id ppiId, Map < String, String > HeaderToMetricTypeMap, Integer i, Integer j) {
        Result__c result = new Result__c();
        result.Account_ID__c = accId;
        result.Contact_ID__c = conId;
        result.MetricType__c = HeaderToMetricTypeMap.get(csvData[0].get(j).trim());
        result.Name = String.valueOf(currentEducationProgramList.get(0).Name);
        result.CurrentEducationProgram_UID__c = currentEducationProgramList.get(0).Id;
        result.PartnerPlatformInfo__c = partnerPlatformInfoMap.get(csvData[i].get(0).trim() + EdmodConstants.KEY_DELIMITER + platformType).Id;
        result.Time__c = DateTime.now();
        result.External_Lookup_Key__c = accId + EdmodConstants.KEY_DELIMITER + conId + EdmodConstants.KEY_DELIMITER +
            String.valueOf(currentEducationProgramList.get(0).Name) + EdmodConstants.KEY_DELIMITER + ppiId +
            EdmodConstants.KEY_DELIMITER + HeaderToMetricTypeMap.get(csvData[0].get(j).trim());

        if (csvData[i].get(j).trim().equalsIgnoreCase('True'))
            result.MetricValue__c = 1;
        else if (csvData[i].get(j).trim().equalsIgnoreCase('False'))
            result.MetricValue__c = 0;
        else
            result.MetricValue__c = Double.valueOf(csvData[i].get(j).trim());

        newResultsToAdd.add(result);
    }

    /*
     * addNewOpportunitiesToList
     * @description Iterate over CSV data to process opportunities
     */
    public void addNewOpportunitiesToList() {
        List < Error_Log__c > errorLogList = new List < Error_Log__c > ();
        if (accountsMap.isEmpty() || partnerPlatformInfoMap.isEmpty())
            return;
        for (Integer i = 1; i < csvData.size(); i++) {
            try {
                PartnerPlatformInfo__c ppi = partnerPlatformInfoMap.get(csvData[i].get(EdmodHeaderConstantIndices.Index_ID).trim() +
                    EdmodConstants.KEY_DELIMITER + platformType);
                Id accId = accountsMap.get(csvData[i].get(EdmodHeaderConstantIndices.INDEX_SCHOOL).trim() +
                    EdmodConstants.KEY_DELIMITER + csvData[i].get(EdmodHeaderConstantIndices.Index_State).trim());
                if (ppi != null && accId != null) {
                    Id conId = ppi.Contact_ID__c;
                    Id ppiId = ppi.Id;
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

                }
            } catch (NullPointerException e) {
                String errorMessage = 'Null Pointer Exception in Opportunity upload at ' + e.getLineNumber() + ' : ' + e.getMessage();
                errorLogList.add(getErrorLogRecord(batchJobId, DateTime.now(), errorMessage));
            } catch (Exception e) {
                String errorMessage = 'Exception in Opportunity upload at ' + e.getLineNumber() + ' : ' + e.getMessage();
                errorLogList.add(getErrorLogRecord(batchJobId, DateTime.now(), errorMessage));
            }
        }
        printErrorsInLog(errorLogList);
    }

    /*
     * addOnboardingOpportunities
     * @description Add onboarding opportunities to map.
     * @param accId
     * @param conId
     * @param ppiId
     * @param i
     */
    public void addOnboardingOpportunities(Id accId, Id conId, Id ppiId, Integer i) {
        DateTime currentDateTime = DateTime.now();

        Id onboardingRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(EdmodConstants.RECORD_TYPE_ONBOARDING).getRecordTypeId();
        Opportunity opportunity = new Opportunity();
        opportunity.RecordTypeId=onboardingRecordTypeId;
        opportunity.AccountId = accId;
        opportunity.Contact_ID__c = conId;
        opportunity.PartnerPlatformInfo__c = ppiId;
        opportunity.Name = currentEducationProgramList.get(0).Name;
        opportunity.Current_Education_Program__c = currentEducationProgramList.get(0).Id;
        opportunity.CloseDate = currentEducationProgramList.get(0).ProgramEndDate__c;
        opportunity.Type = EdmodConstants.ONBOARDING_OPPORTUNITY;
        opportunity.S1__c = currentDateTime;
        opportunity.StageName = EdmodConstants.ONBOARDING_STAGE_S1;
        //Opportunity.External_Lookup_Key__c = accId + EdmodConstants.KEY_DELIMITER + conId + EdmodConstants.KEY_DELIMITER +
            //opportunity.Name + EdmodConstants.KEY_DELIMITER + ppiId + EdmodConstants.KEY_DELIMITER + opportunity.Type;

        if ((Double.valueOf(csvData[i].get(EdmodHeaderConstantIndices.INDEX_NUM_STUDENTS).trim())) >
            Double.valueOf(EdmodConstants.MINIMUM_METRIC_VALUE)) {
            opportunity.S2__c = currentDateTime;
            opportunity.StageName = EdmodConstants.ONBOARDING_STAGE_S2;
        }
        if ((Double.valueOf(csvData[i].get(EdmodHeaderConstantIndices.INDEX_NUM_STUDENTS_STARTED_PROJECT).trim()) >
                Double.valueOf(EdmodConstants.MINIMUM_METRIC_VALUE))) {
            opportunity.S3__c = currentDateTime;
            opportunity.StageName = EdmodConstants.ONBOARDING_STAGE_S3;
        }
        if ((Double.valueOf(csvData[i].get(EdmodHeaderConstantIndices.INDEX_NUM_STUDENTS_COMPLETED_PROJECT).trim()) >
                Double.valueOf(EdmodConstants.MINIMUM_METRIC_VALUE))) {
            opportunity.S4__c = currentDateTime;
            opportunity.StageName = EdmodConstants.ONBOARDING_STAGE_S4;
            addNurturingOpportunities(accId, conId, ppiId, i);
        }

        newOpportunities.put(opportunity.AccountId + EdmodConstants.KEY_DELIMITER + opportunity.Contact_ID__c +
            EdmodConstants.KEY_DELIMITER + opportunity.PartnerPlatformInfo__c + EdmodConstants.KEY_DELIMITER +
            opportunity.Name + EdmodConstants.KEY_DELIMITER + opportunity.Type, opportunity);
    }

    /*
     * addNurturingOpportunities
     * @description Add nurturing opportunities to map.
     * @param accId
     * @param conId
     * @param ppiId
     * @param i
     */
    public void addNurturingOpportunities(Id accId, Id conId, Id ppiId, Integer i) {
        DateTime currentDateTime = DateTime.now();
        
        Id nurturingRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(EdmodConstants.RECORD_TYPE_NURTURING).getRecordTypeId();
        Opportunity opportunity = new Opportunity();
        opportunity.RecordTypeId=nurturingRecordTypeId;
        opportunity.AccountId = accId;
        opportunity.Contact_ID__c = conId;
        opportunity.PartnerPlatformInfo__c = ppiId;
        opportunity.Name = currentEducationProgramList.get(0).Name;
        opportunity.Current_Education_Program__c = currentEducationProgramList.get(0).Id;
        opportunity.Type = EdmodConstants.NURTURING_OPPORTUNITY;
        opportunity.CloseDate = currentEducationProgramList.get(0).ProgramEndDate__c;
        //Opportunity.External_Lookup_Key__c = accId + EdmodConstants.KEY_DELIMITER + conId + EdmodConstants.KEY_DELIMITER +
            //opportunity.Name + EdmodConstants.KEY_DELIMITER + ppiId + EdmodConstants.KEY_DELIMITER + opportunity.Type;

        Double percentageStudentsCompletedProject = computePercentage(i);        

        if ((percentageStudentsCompletedProject >= 0.0) && (percentageStudentsCompletedProject < 50.0)) {
            opportunity.S1__c = currentDateTime;
            opportunity.StageName = EdmodConstants.NURTURING_STAGE_S1;
        }
        if ((percentageStudentsCompletedProject >= 50.0) && (percentageStudentsCompletedProject < 75.0)) {
            opportunity.S1__c = currentDateTime;
            opportunity.S2__c = currentDateTime;
            opportunity.StageName = EdmodConstants.NURTURING_STAGE_S2;
        }
        if ((percentageStudentsCompletedProject >= 75.0) && (percentageStudentsCompletedProject < 100.0)) {
            opportunity.S1__c = currentDateTime;
            opportunity.S2__c = currentDateTime;
            opportunity.S3__c = currentDateTime;
            opportunity.StageName = EdmodConstants.NURTURING_STAGE_S3;
        }
        if (percentageStudentsCompletedProject == 100.0) {
            opportunity.S1__c = currentDateTime;
            opportunity.S2__c = currentDateTime;
            opportunity.S3__c = currentDateTime;
            opportunity.S4__c = currentDateTime;
            opportunity.StageName = EdmodConstants.NURTURING_STAGE_S4;
        }


        newOpportunities.put(opportunity.AccountId + EdmodConstants.KEY_DELIMITER + opportunity.Contact_ID__c +
            EdmodConstants.KEY_DELIMITER + opportunity.PartnerPlatformInfo__c + EdmodConstants.KEY_DELIMITER +
            opportunity.Name + EdmodConstants.KEY_DELIMITER + opportunity.Type, opportunity);
    }

    /*
     * updateOnboardingOpportunities
     * @description Update onboarding opportunities
     * @param accId
     * @param conId
     * @param ppiId
     * @param i
     */
    public void updateOnboardingOpportunities(Id accId, Id conId, Id ppiId, Integer i) {

        Opportunity onboardingOpp = opportunitiesMap.get(accId + EdmodConstants.KEY_DELIMITER + conId + EdmodConstants.KEY_DELIMITER +
            ppiId + EdmodConstants.KEY_DELIMITER + currentEducationProgramList.get(0).Name +
            EdmodConstants.KEY_DELIMITER + EdmodConstants.ONBOARDING_OPPORTUNITY);
        DateTime currentDateTime = DateTime.now();

        if (Double.valueOf(csvData[i].get(EdmodHeaderConstantIndices.INDEX_NUM_STUDENTS).trim()) ==
            Double.valueOf(EdmodConstants.MINIMUM_METRIC_VALUE)) {
            onboardingOpp.StageName = EdmodConstants.ONBOARDING_STAGE_S1;
        }
        if ((Double.valueOf(csvData[i].get(EdmodHeaderConstantIndices.INDEX_NUM_STUDENTS).trim()) >
                Double.valueOf(EdmodConstants.MINIMUM_METRIC_VALUE))) {
            if (onboardingOpp.S2__c == null) {
                onboardingOpp.S2__c = currentDateTime;
            }
            onboardingOpp.StageName = EdmodConstants.ONBOARDING_STAGE_S2;
        }
        if ((Double.valueOf(csvData[i].get(EdmodHeaderConstantIndices.INDEX_NUM_STUDENTS_STARTED_PROJECT).trim()) >
                Double.valueOf(EdmodConstants.MINIMUM_METRIC_VALUE))) {
            if (onboardingOpp.S3__c == null) {
                onboardingOpp.S3__c = currentDateTime;
            }
            if (onboardingOpp.S2__c == null) {
                onboardingOpp.S2__c = currentDateTime;
            }
            onboardingOpp.StageName = EdmodConstants.ONBOARDING_STAGE_S3;
        }
        if (Double.valueOf(csvData[i].get(EdmodHeaderConstantIndices.INDEX_NUM_STUDENTS_COMPLETED_PROJECT).trim()) >
            Double.valueOf(EdmodConstants.MINIMUM_METRIC_VALUE)) {
            if (onboardingOpp.S4__c == null) {
                onboardingOpp.S4__c = currentDateTime;
            }
            if (onboardingOpp.S3__c == null) {
                onboardingOpp.S3__c = currentDateTime;
            }
            if (onboardingOpp.S2__c == null) {
                onboardingOpp.S2__c = currentDateTime;
            }
            onboardingOpp.StageName = EdmodConstants.ONBOARDING_STAGE_S4;
        }

        updatedOpportunities.put(onboardingOpp.AccountId + EdmodConstants.KEY_DELIMITER + onboardingOpp.Contact_ID__c +
            EdmodConstants.KEY_DELIMITER + onboardingOpp.PartnerPlatformInfo__c + EdmodConstants.KEY_DELIMITER +
            onboardingOpp.Name + EdmodConstants.KEY_DELIMITER + onboardingOpp.Type, onboardingOpp);

        if (!(opportunitiesMap.containsKey((accId + EdmodConstants.KEY_DELIMITER + conId + EdmodConstants.KEY_DELIMITER +
                ppiId + EdmodConstants.KEY_DELIMITER + currentEducationProgramList.get(0).Name +
                EdmodConstants.KEY_DELIMITER + EdmodConstants.NURTURING_OPPORTUNITY).trim()))) {
            if (Double.valueOf(csvData[i].get(EdmodHeaderConstantIndices.INDEX_NUM_STUDENTS_COMPLETED_PROJECT).trim()) > 0.0) {
                addNurturingOpportunities(accId, conId, ppiId, i);
            }
        } else {
            updateNurturingOpportunities(accId, conId, ppiId, i);
        }
    }

    /*
     * updateNurturingOpportunities
     * @description Update nurturing opportunities
     * @param accId
     * @param conId
     * @param ppiId
     * @param i
     */
    public void updateNurturingOpportunities(Id accId, Id conId, Id ppiId, Integer i) {
        Opportunity nurturingOpp = opportunitiesMap.get(accId + EdmodConstants.KEY_DELIMITER + conId + EdmodConstants.KEY_DELIMITER +
            ppiId + EdmodConstants.KEY_DELIMITER + currentEducationProgramList.get(0).Name +
            EdmodConstants.KEY_DELIMITER + EdmodConstants.NURTURING_OPPORTUNITY);
        DateTime currentDateTime = DateTime.now();
        Double percentageStudentsCompletedProject = computePercentage(i);

        if ((percentageStudentsCompletedProject >= 0.0) && (percentageStudentsCompletedProject < 50.0)) {
            if (nurturingOpp.S1__c == null) {
                nurturingOpp.S1__c = currentDateTime;
            }
            nurturingOpp.StageName = EdmodConstants.NURTURING_STAGE_S1;
        }
        if ((percentageStudentsCompletedProject >= 50.0) && (percentageStudentsCompletedProject < 75.0)) {
            if (nurturingOpp.S2__c == null) {
                nurturingOpp.S2__c = currentDateTime;
                if (nurturingOpp.S1__c == null) {
                    nurturingOpp.S1__c = currentDateTime;
                }
            }
            nurturingOpp.StageName = EdmodConstants.NURTURING_STAGE_S2;
        }
        if ((percentageStudentsCompletedProject >= 75.0) && (percentageStudentsCompletedProject < 100.0)) {
            if (nurturingOpp.S3__c == null) {
                nurturingOpp.S3__c = currentDateTime;
                if (nurturingOpp.S2__c == null) {
                    nurturingOpp.S2__c = currentDateTime;
                    if (nurturingOpp.S1__c == null) {
                        nurturingOpp.S1__c = currentDateTime;
                    }
                }
            }
            nurturingOpp.StageName = EdmodConstants.NURTURING_STAGE_S3;
        }
        if (percentageStudentsCompletedProject == 100.0) {
            if (nurturingOpp.S4__c == null) {
                nurturingOpp.S4__c = currentDateTime;
                if (nurturingOpp.S3__c == null) {
                    nurturingOpp.S3__c = currentDateTime;
                    if (nurturingOpp.S2__c == null) {
                        nurturingOpp.S2__c = currentDateTime;
                        if (nurturingOpp.S1__c == null) {
                            nurturingOpp.S1__c = currentDateTime;
                        }
                    }
                }
            }
            nurturingOpp.StageName = EdmodConstants.NURTURING_STAGE_S4;
        }
        updatedOpportunities.put(nurturingOpp.AccountId + EdmodConstants.KEY_DELIMITER + nurturingOpp.Contact_ID__c +
            EdmodConstants.KEY_DELIMITER + nurturingOpp.PartnerPlatformInfo__c + EdmodConstants.KEY_DELIMITER +
            nurturingOpp.Name + EdmodConstants.KEY_DELIMITER + nurturingOpp.Type, nurturingOpp);
    }

    /*
     * computePercentage
     * @description Calculate percentage of students who completed project
     * @param i     
     */
    public Double computePercentage(Integer i) {
        Double studentsCompletedProject = Double.valueOf(csvData[i].get(EdmodHeaderConstantIndices.INDEX_NUM_STUDENTS_COMPLETED_PROJECT).trim());
        Integer totalStudents = Integer.valueOf(csvData[i].get(EdmodHeaderConstantIndices.INDEX_NUM_STUDENTS).trim());
        if (totalStudents > 0) {
            Double percentage = (studentsCompletedProject / totalStudents) * 100;
            return percentage;
        } else
            return 0.0;
    }

    /*
     * upsertAccountRecords
     * @description Upsert account records
     * @param recordsList
     * @param key
     */
    void upsertAccountRecords(List < Account > recordsList, Schema.SObjectField key) {
        List < Id > accountIds = new List < Id > ();
        Database.UpsertResult[] upsertStatus;
        if (!recordsList.isEmpty()) {
            upsertStatus = Database.upsert(recordsList, key, false);
            accountIds = getRecordIdsPrintErrors(recordsList, upsertStatus);
        }
        if (accountIds.size() > 0) {
            initializeAccountsMap(accountIds);
        }
    }

    /*
     * upsertContactRecords
     * @description Upsert contact records
     * @param recordsList
     * @param key
     */
    Database.UpsertResult[] upsertContactRecords(List < Contact > recordsList, Schema.SObjectField key) {
        List < Id > contactIds = new List < Id > ();
        Database.UpsertResult[] upsertStatus;
        if (!recordsList.isEmpty()) {
            upsertStatus = Database.upsert(recordsList, key, false);
            contactIds = getRecordIdsPrintErrors(recordsList, upsertStatus);
        }
        if (contactIds.size() > 0) {
            initializeContactsMap(contactIds);
        }
        return upsertStatus;
    }

    /*
     * upsertPartnerPlatformInfoRecords
     * @description Upsert Partner Platform Info records
     * @param recordsList
     * @param key
     */
    void upsertPartnerPlatformInfoRecords(List < PartnerPlatformInfo__c > recordsList, Schema.SObjectField key) {
        List < Id > partnerPlatformIds = new List < Id > ();
        Database.UpsertResult[] upsertStatus;
        if (!recordsList.isEmpty()) {
            upsertStatus = Database.upsert(recordsList, key, false);
            partnerPlatformIds = getRecordIdsPrintErrors(recordsList, upsertStatus);
        }
        if (partnerPlatformIds.size() > 0) {
            initializePartnerPlatformInfoMap(partnerPlatformIds);
        }
    }

    /*
     * upsertResultRecords
     * @description Upsert Result records
     * @param recordsList
     * @param key
     */
    void upsertResultRecords(List < Result__c > recordsList, Schema.SObjectField key) {
        Database.UpsertResult[] upsertStatus;
        if (!recordsList.isEmpty()) {
            upsertStatus = Database.upsert(recordsList, key, false);
            getRecordIdsPrintErrors(recordsList, upsertStatus);
        }
    }

    /*
     * upsertOpportunityRecords
     * @description Upsert Opportunity records
     * @param recordsList
     * @param key
     */
    void upsertOpportunityRecords(List < Opportunity > recordsList, Schema.SObjectField key) {
        Database.UpsertResult[] upsertStatus;
        if (!recordsList.isEmpty()) {
            upsertStatus = Database.upsert(recordsList, key, false);
            getRecordIdsPrintErrors(recordsList, upsertStatus);
        }
    }

    /*
     * getRecordIdsPrintErrors
     * @description Insert errors for upsert failures
     * @param recordsList
     * @param getRecordIdsPrintErrors
     */
    private List < id > getRecordIdsPrintErrors(List < SObject > recordsList, Database.UpsertResult[] upsertStatus) {
        List < Error_Log__c > errors = new List < Error_Log__c > ();
        List < Id > ids = new List < Id > ();
        for (Database.UpsertResult status: upsertStatus) {
            if (!status.isSuccess()) {
                String errorMessage = 'Error while inserting ' + recordsList.getSObjectType() + '\n';
                for (Database.Error err: status.getErrors()) {
                    errorMessage = errorMessage + '\nMessage: ' + err.getMessage();
                }
                errors.add(getErrorLogRecord(batchJobId, DateTime.now(), errorMessage));
            } else {
                ids.add(status.getId());
            }
        }
        printErrorsInLog(errors);
        return ids;
    }

    /*
     * createOrUpdateRecords
     * @description Insert or Update records
     * @param newRecordsList
     * @param action : 'Insert' or 'Update'
     */
    public void createOrUpdateRecords(List < sObject > newRecordsList, String action) {
        if (!newRecordsList.isEmpty()) {
            Database.SaveResult[] saveStatus;
            List < Error_Log__c > errors = new List < Error_Log__c > ();
            if (action.equals(EdmodConstants.DML_OPERATION_INSERT)) {
                saveStatus = Database.insert(newRecordsList, false);
            } else {
                saveStatus = Database.update(newRecordsList, false);
            }
            for (Database.SaveResult status: saveStatus) {
                if (!status.isSuccess()) {
                    String errorMessage = '';
                    for (Database.Error err: status.getErrors()) {
                        errorMessage += newRecordsList.getSObjectType() + ' : ' + err.getMessage();
                    }
                    errors.add(getErrorLogRecord(batchJobId, Datetime.now(), errorMessage));
                }
            }
            printErrorsInLog(errors);
        }
    }

    /*
     * printErrorsInLog
     *  @description Insert Errors in Error Log object
     * 
     */
    public void printErrorsInLog(List < Error_Log__c > errorsList) {
        if (errorsList.size() > 0) {
            Database.SaveResult[] saveStatus = Database.insert(errorsList, false);
        }
    }

    /*
     * getErrorLogRecord
     * @param batchJobId
     * @param currentTime
     * @param errorMessage
     * @Description returns ErrorLog object
     * 
     */
    public Error_Log__c getErrorLogRecord(Id jobId, DateTime currentTime, String errorMessage) {
        Error_Log__c errorLog = new Error_Log__c();
        errorLog.JobId__c = jobId;
        errorLog.Time__c = currentTime;
        errorLog.Error_Message__c = errorMessage;
        return errorLog;
    }
}