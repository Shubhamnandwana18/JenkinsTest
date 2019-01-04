/**
 * Salesforce has a limit of executing only 100 SOQL query per transaction. 
 * To avoid the limit, the SOQL query is fired once at the start and we are using upsert on 
 * various objects.
 * 
 * Salesforce has a limit of executing only 150 DML statements per transaction. To avoid these 
 * governor limits, bulk insert and bulk updates are done.
 * @class EdmodUploadCSVRecords uses CSV parsed content, check for it's validation and finally insert/upsert the 
 * List < List < String >> data into corresponding standard/custom objects.   
 */
public class EdmodUploadCSVRecords {

    /**
     * Stores Account id's for all accounts that were upserted successfully.
     */
    Map < String, Id > accountsMap;
    /**
     * Stores PartnerPlatformInfo object that were upserted successfully.
     */
    Map < String, PartnerPlatformInfo__c > partnerPlatformInfoMap;
    /**
     * Stores Contact id's for all Contacts that were upserted successfully.
     */
    Map < Id, Contact > contactsMap;
    /**
     * Stores the Result object to be upserted.
     */
    List < Result__c > newResultsToAdd;
    /*
     * Stores actual data to be inserted/upserted into various standard/custom objects.   
     */
    public List < List < String >> csvData;
    /**
     * Stores Program Name corresponding to the csvData.
     */
    public String program;
    /**
     * Stores Program Type corresponding to the csvData.
     */
    public String platformType;
    /**
     * Stores the batch Id for corresponding batch.
     */
    public String batchJobId;
    /**
     * Stores detail of currentEducationProgram for given Program Type.
     */
    List < CurrentEducationProgram__c > currentEducationProgramList;
    /**
     * Store Onbarding/Nurturing Opportunities to be inserted.
     */
    Map < String, Opportunity > newOpportunities;
    /**
     * Stores Opportunity object corresponding to given Program Name and Contacts in a particular batch
     */
    Map < String, Opportunity > opportunitiesMap;
    /**
     * Store Onbarding/Nurturing Opportunities to be updated.
     */
    Map < String, Opportunity > updatedOpportunities;
    /**
     * Stores Error_Log__c object corresponding to all rows that are not valid.
     */
    List < Error_Log__c > invalidRowErrors;

    /**
     * @description 		Constructor to instantiate the object of class EdmodUploadCSVRecords.
     * @param data			Actual data to be inserted/upserted into various standard/custom objects. 
     * @param programName	Program Name corresponding to the given data.
     * @param platform		Program Type corresponding to the given data.
     * @param batchJobId	Batch Id for corresponding batch.
     */
    public EdmodUploadCSVRecords(List < List < String >> data, String programName, String platform, Id batchJobId) {
        csvData = data;
        program = programName;
        platformType = platform;
        accountsMap = new Map < String, Id > ();
        partnerPlatformInfoMap = new Map < String, PartnerPlatformInfo__c > ();
        contactsMap = new Map < Id, Contact > ();
        newResultsToAdd = new List < Result__c > ();
        currentEducationProgramList = getCurrentEducationProgram(programName);
        newOpportunities = new Map < String, Opportunity > ();
        opportunitiesMap = new Map < String, Opportunity > ();
        updatedOpportunities = new Map < String, Opportunity > ();
        this.batchJobId = String.valueOf(batchJobId);
        invalidRowErrors = new List < Error_Log__c > ();
    }

    /*
     * @description	Validates Account details that is present in csvData and upsert all valid accounts. 
     * @example
     * EdmodUploadCSVRecords edmodUploadCSVRecords = new EdmodUploadCSVRecords();
     * edmodUploadCSVRecords.processAccounts();
     */
    public void processAccounts() {
        try {
            
            //Parse CSV List to Create Contact records and Get List of account objects to upsert.
            List < Account > accountsToAddList = getAccountsToAdd();
        
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
     * @description Upsert all Contacts present in the given csvData, create PartnerPlatformInfo object
     * 				for all those Contacts that are successfully upserted and upsert all PartnerPlatformInfo.
     * @example
     * EdmodUploadCSVRecords edmodUploadCSVRecords = new EdmodUploadCSVRecords();
     * edmodUploadCSVRecords.processContacts();
     */
    public void processContacts() {
        List < Error_Log__c > errors = new List < Error_Log__c > ();
        try {
            
            //Parse CSV List to Create Contact records.          
            List < Contact > contactsList = addContactsToList();
            
            //Perform upsert of contacts using Email. 
            Database.UpsertResult[] upsertContactStatus;
            List < String > contactErrors = new List < String > ();
            List < PartnerPlatformInfo__c > partnerPlatformList = new List < PartnerPlatformInfo__c > ();
            if (!contactsList.isEmpty()) {
                Schema.SObjectField keyField = Contact.Fields.Email;
                upsertContactStatus = upsertContactRecords(contactsList, keyField);

                for (Database.UpsertResult status: upsertContactStatus) {
                    //Create PartnerPlatformInfo object for all contacts that are successfully upserted.
                    if (status.isSuccess()) {
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
     * @description Get Account Id, Contact Id, and PartnerPlatformInfo Id for each row of csvData 
     * 				and perform upsert on result object.
     * @example
     * EdmodUploadCSVRecords edmodUploadCSVRecords = new EdmodUploadCSVRecords();
     * edmodUploadCSVRecords.processResults();
     */
    public void processResults() {
        List < Error_Log__c > errorLogList = new List < Error_Log__c > ();
        try {
            if (currentEducationProgramList.size() > 0) {
                //Parse CSV List to create Result records.          
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
                            if (conId != null && ppiId != null) {
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
                String errorMessage = 'Result: Current Education Program is not present for program type: ' + program;
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
     * @description Initialize Opportunities Map and perform insert/update for all opportunity.
     * @example
     * EdmodUploadCSVRecords edmodUploadCSVRecords = new EdmodUploadCSVRecords();
     * edmodUploadCSVRecords.processOpportunities();
     */
    public void processOpportunities() {
        List < Error_Log__c > errorLogList = new List < Error_Log__c > ();
        try {
            //Initialize map with existing opportunities.
            initializeOpportunitiesMap();
            addNewOpportunitiesToList();

            //Convert newOpportunities Map to List.
            List < Opportunity > newOpportunitiesList = new List < Opportunity > ();
            for (Opportunity opp: newOpportunities.values()) {
                newOpportunitiesList.add(opp);
            }
            //Convert updatedOpportunities Map to List.
            List < Opportunity > updatedOpportunitiesList = new List < Opportunity > ();
            for (Opportunity opp: updatedOpportunities.values()) {
                updatedOpportunitiesList.add(opp);
            }
            //Insert new Opportunities and Update existing Opportunities.
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
     * @param csvRow	Single csv row 
     * @param i  		csv row index.
     * @description 	check for validation of csv row and print error message if row is not valid
     * 
     */
    public boolean isRowValid(List < String > csvRow, Integer i) {
        Error_Log__c errorLog = new Error_Log__c();
        String errorMessage = '';
        Boolean isErrorPresent = false;
        Boolean isMetricValuesPresent = checkAllMetricValues(csvRow);
        String requiredFieldError = checkRequiredFields(csvRow);

        if (!String.isEmpty(requiredFieldError)) {
            errorMessage = 'Required field(s) missing: ' + requiredFieldError.substring(0, requiredFieldError.length() - 1);
            isErrorPresent = true;
        }
        if (!isMetricValuesPresent) {
            errorMessage = errorMessage + 'Invalid Row: Metric values cannot be Empty or Negative or Decimal';
            isErrorPresent = true;
        } else {
            if ((Integer.valueOf(csvRow.get(EdmodHeaderConstantIndices.INDEX_NUM_STUDENTS_COMPLETED_PROJECT).trim()) >
                    Integer.valueOf(csvRow.get(EdmodHeaderConstantIndices.INDEX_NUM_STUDENTS).trim())) ||
                (Integer.valueOf(csvRow.get(EdmodHeaderConstantIndices.INDEX_NUM_STUDENTS_STARTED_PROJECT).trim()) >
                    Integer.valueOf(csvRow.get(EdmodHeaderConstantIndices.INDEX_NUM_STUDENTS).trim()))) {
                errorMessage = errorMessage +
                    'Invalid Row: #Students signed up is less than #students with project started or #students with project completed.';
                isErrorPresent = true;
            }
            if (Integer.valueOf(csvRow.get(EdmodHeaderConstantIndices.INDEX_NUM_STUDENTS_COMPLETED_PROJECT).trim()) >
                Integer.valueOf(csvRow.get(EdmodHeaderConstantIndices.INDEX_NUM_STUDENTS_STARTED_PROJECT).trim())) {
                errorMessage = errorMessage +
                    '\nInvalid Row: #Students with project started is less than sum of #students completed.';
                isErrorPresent = true;
            }
            if ((!isErrorPresent) && Datetime.valueOf(csvRow.get(EdmodHeaderConstantIndices.INDEX_LAST_LOGIN).trim()) <
                Datetime.valueOf(csvRow.get(EdmodHeaderConstantIndices.INDEX_DATE_JOINED).trim())) {
                errorMessage = errorMessage +
                    '\nInvalid Row: Last login date is less than date joined.';
                isErrorPresent = true;
            }
        }
        if (isErrorPresent) {
            errorMessage = errorMessage + '\nCSV Row:\n' + JSON.serializePretty(csvRow);
            invalidRowErrors.add(getErrorLogRecord(batchJobId, DateTime.now(), errorMessage));
            return false;
        } else {
            if (String.isEmpty(String.valueOf(csvData[i].get(EdmodHeaderConstantIndices.INDEX_SCHOOL).trim()))) {
                csvData[i].set(EdmodHeaderConstantIndices.INDEX_SCHOOL, EdmodConstants.DEFAULT_SCHOOL_NAME);
            }
            if (String.isEmpty(String.valueOf(csvData[i].get(EdmodHeaderConstantIndices.INDEX_STATE).trim()))) {
                csvData[i].set(EdmodHeaderConstantIndices.INDEX_STATE, EdmodConstants.DEFAULT_SCHOOL_STATE);
            }
            if (String.isEmpty(String.valueOf(csvData[i].get(EdmodHeaderConstantIndices.INDEX_CITY).trim()))) {
                csvData[i].set(EdmodHeaderConstantIndices.INDEX_CITY, EdmodConstants.DEFAULT_SCHOOL_CITY);
            }
            if (String.isEmpty(String.valueOf(csvData[i].get(EdmodHeaderConstantIndices.INDEX_COUNTRY).trim()))) {
                csvData[i].set(EdmodHeaderConstantIndices.INDEX_COUNTRY, EdmodConstants.DEFAULT_SCHOOL_COUNTRY);
            }
            return true;
        }
    }

    /*
     * @param csvRow	Single csv row 
     * @description 	check if required fields are not Empty.
     * @return 			Error message
     * 
     */
    public String checkRequiredFields(List < String > csvRow) {
        String errorMessage = '';
        if (EdmodUtilityMethods.IsNullEmpty(String.valueOf(csvRow.get(EdmodHeaderConstantIndices.INDEX_EMAIL).trim()))) {
            errorMessage += 'Email, ';
        }
        if (EdmodUtilityMethods.IsNullEmpty(String.valueOf(csvRow.get(EdmodHeaderConstantIndices.INDEX_FIRST_NAME).trim()))) {
            errorMessage += 'First Name, ';
        }
        if (EdmodUtilityMethods.IsNullEmpty(String.valueOf(csvRow.get(EdmodHeaderConstantIndices.INDEX_LAST_NAME).trim()))) {
            errorMessage += 'Last Name, ';
        }
        if (EdmodUtilityMethods.IsNullEmpty(String.valueOf(csvRow.get(EdmodHeaderConstantIndices.INDEX_DATE_JOINED).trim()))) {
            errorMessage += 'Date Joined, ';
        }
        if (EdmodUtilityMethods.IsNullEmpty(String.valueOf(csvRow.get(EdmodHeaderConstantIndices.INDEX_ID).trim()))) {
            errorMessage += 'Id, ';
        }
        if (EdmodUtilityMethods.IsNullEmpty(String.valueOf(csvRow.get(EdmodHeaderConstantIndices.INDEX_LAST_LOGIN).trim()))) {
            errorMessage += 'Last Login Time, ';
        }

        return errorMessage;
    }

    /*
     * @param csvRow	Single csv row 
     * @description		Check if metric values of CSV row are valid. Metric values cannot be negative, decimal or empty.
     */
    public Boolean checkAllMetricValues(List < String > csvRow) {
        for (Integer i = EdmodHeaderConstantIndices.INDEX_NUM_STUDENTS; i < csvRow.size(); i++) {
            if (EdmodUtilityMethods.IsNullEmpty(csvRow.get(i).trim())) {
                return false;
            } else if ((!String.valueOf(csvRow.get(i).trim()).equalsIgnoreCase('True')) && (!String.valueOf(csvRow.get(i).trim()).equalsIgnoreCase('False')) &&
                (decimal.valueOf(String.valueOf(csvRow.get(i).trim())) - Math.floor(decimal.valueOf(String.valueOf(csvRow.get(i).trim()))) != 0)) {
                return false;
            } else if ((!String.valueOf(csvRow.get(i).trim()).equalsIgnoreCase('True')) && (!String.valueOf(csvRow.get(i).trim()).equalsIgnoreCase('False')) &&
                (Integer.valueOf(csvRow.get(i).trim()) < 0)) {
                return false;
            }
        }
        return true;
    }

    /*
     * @param email		
     * @return	The csv row corresponding to the given email from csv data.
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
     * @param programType	Program Name corresponding to the given data.
     * @return				The detail about Current Education Program for given program.
     * 
     */
    public List < CurrentEducationProgram__c > getCurrentEducationProgram(String programType) {
        List < CurrentEducationProgram__c > currentEducationProgramList = [SELECT Name, Id, ProgramEndDate__c FROM CurrentEducationProgram__c
            WHERE ProgramType__c =: programType
        ];
        return currentEducationProgramList;
    }

    /*
     * @param csvRow			Single csv row 
     * @param insertedContact	Contact Id's of all contacts that are successfully upserted.
     * @return					New PartnerPlatformInfo object corresponding to each Contact.
     * 
     */
    PartnerPlatformInfo__c getPartnerPlatformObject(List < String > csvRow, Contact insertedContact) {
        PartnerPlatformInfo__c partnerPlatformRecord = new PartnerPlatformInfo__c();
        partnerPlatformRecord.Contact_ID__c = insertedContact.Id;
        if (!String.isEmpty(String.valueOf(csvRow.get(EdmodHeaderConstantIndices.INDEX_ID).trim()))) {
            partnerPlatformRecord.Teacher_ID__c = Double.valueOf(csvRow.get(EdmodHeaderConstantIndices.INDEX_ID).trim());
        }
        partnerPlatformRecord.Name = platformType;
        partnerPlatformRecord.Last_Login_Time__c = DateTime.valueOf(csvRow.get(EdmodHeaderConstantIndices.INDEX_LAST_LOGIN));
        partnerPlatformRecord.Class_Code__c = csvRow.get(EdmodHeaderConstantIndices.INDEX_CLASS_CODE).trim();
        partnerPlatformRecord.Sections__c = Double.valueOf(csvRow.get(EdmodHeaderConstantIndices.INDEX_NUM_SECTIONS).trim());
        partnerPlatformRecord.External_Lookup_Key__c = partnerPlatformRecord.Teacher_ID__c + EdmodConstants.KEY_DELIMITER + partnerPlatformRecord.Name;
        return partnerPlatformRecord;
    }

    /*
     * @param accountIds     Account Id's of all accounts that are successfully upserted.
     * @return				 Account details corresponding to the given account id's.
     * 
     */
    public Map < String, Id > initializeAccountsMap(List < id > accountIds) {
        for (Account acc: [SELECT Id, Name, Site FROM Account where Id IN: accountIds]) {
            accountsMap.put(acc.Name + EdmodConstants.KEY_DELIMITER + acc.Site, acc.Id);
        }
        return accountsMap;
    }

    /*
     * @param partnerPlatformInfoIds     PartnerPlatformInfo Id's of all PartnerPlatformInfo__c object that are successfully upserted.
     * @return 							 PartnerPlatformInfo object corresponding to the given PartnerPlatformInfo Id's.
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
     * @param contactIds    Contact Id's of all contacts that are successfully upserted. 
     * @returns 			Contact object corresponding to the given contact id's.
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
     * @description Initializes TechStartPartners set.
     * @return 		Set containing School_NCES_ID of all TechStartPartners.
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
     * @description Initializes Opportunity Map.
     * @return 		Opportunities Map corresponding to given program name and Contact id's.
     * 
     */
    public void initializeOpportunitiesMap() {
        for (Opportunity opp: [SELECT AccountId, Contact_ID__c, PartnerPlatformInfo__c, Name, Type, S1__c, S2__c, S3__c, S4__c, StageName
                FROM Opportunity WHERE Contact_ID__c IN: contactsMap.keySet() AND Name =: currentEducationProgramList.get(0).Name
            ]) {
            opportunitiesMap.put(opp.Contact_ID__c + EdmodConstants.KEY_DELIMITER +
                opp.PartnerPlatformInfo__c + EdmodConstants.KEY_DELIMITER + opp.Name + EdmodConstants.KEY_DELIMITER + opp.Type, opp);
        }
    }

    /*
     * @description Initializes TechStartPartner set, create new Account Object, remove csv row's that are not valid and print errors.
     * @return 		Map containing Account's object.
     */
    public List < Account > getAccountsToAdd() {
        Set < String > techStartPartnerSet = initializeTechStartPartnersSet();
        Set < String > accountsAdded = new Set < String > ();
        List < Account > accountsToAdd = new List < Account > ();
        List < Error_Log__c > errorLogList = new List < Error_Log__c > ();
        for (Integer i = 1; i < csvData.size(); i++) {
            try {
                if (isRowValid(csvData[i], i)) {
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
                    // accountsToAdd.put(acc.Name + EdmodConstants.KEY_DELIMITER + acc.Site, acc);
                    if(!accountsAdded.contains(acc.External_Lookup_Key__c)){
						accountsAdded.add(acc.External_Lookup_Key__c);
                        accountsToAdd.add(acc);
                    }
                } else {
                    //Remove invalid row from csvData.
                    csvData.remove(i);
                    i--;
                }
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
     * @description Create new Contact Object corresponding to each csv row.
     * @return 		Map containing Contact's object.
     */
    public List < Contact > addContactsToList() {
        List < Error_Log__c > errorLogList = new List < Error_Log__c > ();
        Set < String > addedContacts = new Set < String > ();
        List < Contact > newContacts = new List < Contact > ();
        for (Integer i = 1; i < csvData.size(); i++) {
            try {
                if (accountsMap.isEmpty())
                    return newContacts;
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
                    if (!addedContacts.contains(csvData[i].get(EdmodHeaderConstantIndices.INDEX_ID).trim() + EdmodConstants.KEY_DELIMITER + platformType)){
                    	addedContacts.add(csvData[i].get(EdmodHeaderConstantIndices.INDEX_ID).trim() + EdmodConstants.KEY_DELIMITER + platformType);
                        newContacts.add(con);
                    }
                }
            } catch (Exception e) {
                String errorMessage = 'Exception in Contacts upload at ' + e.getLineNumber() + ' : ' + e.getMessage();
                errorLogList.add(getErrorLogRecord(batchJobId, DateTime.now(), errorMessage));
            }
        }
        printErrorsInLog(errorLogList);
        return newContacts;
    }

    /*
     * @param accId		Account Id corresponding to account of csv row index i.
     * @param conId  	Contact Id corresponding to contact of csv row index i.
     * @param ppiId  	PartnerPlatformInfo Id corresponding to csv row at index i.
     * @param i  		csv row index.    
     * @description 	Add result object for all metric values.
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
     * @param accId		Account Id corresponding to account of csv row index i.
     * @param conId  	Contact Id corresponding to contact of csv row index i.
     * @param ppiId  	PartnerPlatformInfo Id corresponding to csv row at index i.
     * @param HeaderToMetricTypeMap		Map containing mapping of CSV headers to their corresponding Metric Type. 
     * @param i  		csv row index.
     * @param j  		Index of metric type.
     * @description 	Create new Result object and add it to the list.
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
        result.External_Lookup_Key__c = conId + EdmodConstants.KEY_DELIMITER +
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
     * @description Check for onboarding opportunity corresponding to each csv row in Opportunity map.
     * 				If onboarding opportunity is present then we update it else we create a newOpportunity.
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
                    if (!(opportunitiesMap.containsKey((conId + EdmodConstants.KEY_DELIMITER +
                            ppiId + EdmodConstants.KEY_DELIMITER + currentEducationProgramList.get(0).Name +
                            EdmodConstants.KEY_DELIMITER + EdmodConstants.ONBOARDING_OPPORTUNITY).trim())) &&
                        !(newOpportunities.containsKey((conId + EdmodConstants.KEY_DELIMITER +
                            ppiId + EdmodConstants.KEY_DELIMITER + currentEducationProgramList.get(0).Name +
                            EdmodConstants.KEY_DELIMITER + EdmodConstants.ONBOARDING_OPPORTUNITY).trim()))) {

                        // Add new opportunities to Map.
                        addOnboardingOpportunities(accId, conId, ppiId, i);

                    } else {
                        //Update existing Opportunities
                        updateOnboardingOpportunities(accId, conId, ppiId, i);
                    }
                }
            } catch (Exception e) {
                String errorMessage = 'Exception in Opportunity upload at ' + e.getLineNumber() + ' : ' + e.getMessage();
                errorLogList.add(getErrorLogRecord(batchJobId, DateTime.now(), errorMessage));
            }
        }
        printErrorsInLog(errorLogList);
    }

    /*
     * @description 	Add new onboarding opportunities to map. If onboarding opportunity is on stage S4, then we create new nurturing opportunity.
     * @param accId		Account Id corresponding to account of csv row index i.
     * @param conId  	Contact Id corresponding to contact of csv row index i.
     * @param ppiId  	PartnerPlatformInfo Id corresponding to csv row at index i.
     * @param i			csv row index.
     */
    public void addOnboardingOpportunities(Id accId, Id conId, Id ppiId, Integer i) {
        DateTime currentDateTime = DateTime.now();

        Id onboardingRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(EdmodConstants.RECORD_TYPE_ONBOARDING).getRecordTypeId();
        Opportunity opportunity = new Opportunity();
        opportunity.RecordTypeId = onboardingRecordTypeId;
        opportunity.AccountId = accId;
        opportunity.Contact_ID__c = conId;
        opportunity.PartnerPlatformInfo__c = ppiId;
        opportunity.Name = currentEducationProgramList.get(0).Name;
        opportunity.Current_Education_Program__c = currentEducationProgramList.get(0).Id;
        opportunity.CloseDate = currentEducationProgramList.get(0).ProgramEndDate__c;
        opportunity.Type = EdmodConstants.ONBOARDING_OPPORTUNITY;
        opportunity.S1__c = currentDateTime;
        opportunity.StageName = EdmodConstants.ONBOARDING_STAGE_S1;

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

        newOpportunities.put(opportunity.Contact_ID__c +
            EdmodConstants.KEY_DELIMITER + opportunity.PartnerPlatformInfo__c + EdmodConstants.KEY_DELIMITER +
            opportunity.Name + EdmodConstants.KEY_DELIMITER + opportunity.Type, opportunity);
    }

    /*
     * @description 	Add new Nurturing opportunities to map.
     * @param accId		Account Id corresponding to account of csv row index i.
     * @param conId  	Contact Id corresponding to contact of csv row index i.
     * @param ppiId  	PartnerPlatformInfo Id corresponding to csv row at index i.
     * @param i			csv row index.
     */
    public void addNurturingOpportunities(Id accId, Id conId, Id ppiId, Integer i) {
        DateTime currentDateTime = DateTime.now();

        Id nurturingRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(EdmodConstants.RECORD_TYPE_NURTURING).getRecordTypeId();
        Opportunity opportunity = new Opportunity();
        opportunity.RecordTypeId = nurturingRecordTypeId;
        opportunity.AccountId = accId;
        opportunity.Contact_ID__c = conId;
        opportunity.PartnerPlatformInfo__c = ppiId;
        opportunity.Name = currentEducationProgramList.get(0).Name;
        opportunity.Current_Education_Program__c = currentEducationProgramList.get(0).Id;
        opportunity.Type = EdmodConstants.NURTURING_OPPORTUNITY;
        opportunity.CloseDate = currentEducationProgramList.get(0).ProgramEndDate__c;

        Double percentageStudentsCompletedProject = computePercentage(i);
		System.debug('inside'+Integer.valueOf(csvData[i].get(EdmodHeaderConstantIndices.INDEX_NUM_STUDENTS)+EdmodConstantS.MIN_STUDENTS_NURTURING_STAGES));
        if ((percentageStudentsCompletedProject >= 0.0) && (percentageStudentsCompletedProject < 50.0)) {
            opportunity.S1__c = currentDateTime;
            opportunity.StageName = EdmodConstants.NURTURING_STAGE_S1;
        }
        //Check minimum no of students signed up
        if( (Integer.valueOf(csvData[i].get(EdmodHeaderConstantIndices.INDEX_NUM_STUDENTS)) >= EdmodConstantS.MIN_STUDENTS_NURTURING_STAGES)){
            if ((percentageStudentsCompletedProject >= 50.0) && (percentageStudentsCompletedProject < 75.0))  {
                opportunity.S1__c = currentDateTime;
                opportunity.S2__c = currentDateTime;
                opportunity.StageName = EdmodConstants.NURTURING_STAGE_S2;
            }
            if ((percentageStudentsCompletedProject >= 75.0) && (percentageStudentsCompletedProject < 100.0)){               
                opportunity.S1__c = currentDateTime;
                opportunity.S2__c = currentDateTime;
                opportunity.S3__c = currentDateTime;
                opportunity.StageName = EdmodConstants.NURTURING_STAGE_S3;
            }
            if (percentageStudentsCompletedProject == 100.0){
                opportunity.S1__c = currentDateTime;
                opportunity.S2__c = currentDateTime;
                opportunity.S3__c = currentDateTime;
                opportunity.S4__c = currentDateTime;
                opportunity.StageName = EdmodConstants.NURTURING_STAGE_S4;
            }
        }
        newOpportunities.put(opportunity.Contact_ID__c +
            EdmodConstants.KEY_DELIMITER + opportunity.PartnerPlatformInfo__c + EdmodConstants.KEY_DELIMITER +
            opportunity.Name + EdmodConstants.KEY_DELIMITER + opportunity.Type, opportunity);
    }

    /*
     * @description 	Update the existing onboarding opportunity. Also create/update nurturing opportunity. 
     * @param accId		Account Id corresponding to account of csv row index i.
     * @param conId  	Contact Id corresponding to contact of csv row index i.
     * @param ppiId  	PartnerPlatformInfo Id corresponding to csv row at index i.
     * @param i			csv row index.
     */
    public void updateOnboardingOpportunities(Id accId, Id conId, Id ppiId, Integer i) {

        Opportunity onboardingOpp = opportunitiesMap.get(conId + EdmodConstants.KEY_DELIMITER +
            ppiId + EdmodConstants.KEY_DELIMITER + currentEducationProgramList.get(0).Name +
            EdmodConstants.KEY_DELIMITER + EdmodConstants.ONBOARDING_OPPORTUNITY);
        DateTime currentDateTime = DateTime.now();
        onboardingOpp.AccountId = accId;

        if (Double.valueOf(csvData[i].get(EdmodHeaderConstantIndices.INDEX_NUM_STUDENTS).trim()) ==
            Double.valueOf(EdmodConstants.MINIMUM_METRIC_VALUE)) {
            onboardingOpp.StageName = EdmodConstants.ONBOARDING_STAGE_S1;
        }
        if (Double.valueOf(csvData[i].get(EdmodHeaderConstantIndices.INDEX_NUM_STUDENTS).trim()) >
                Double.valueOf(EdmodConstants.MINIMUM_METRIC_VALUE)) {
            if (onboardingOpp.S2__c == null) {
                onboardingOpp.S2__c = currentDateTime;
            }
            onboardingOpp.StageName = EdmodConstants.ONBOARDING_STAGE_S2;
        }
        if (Double.valueOf(csvData[i].get(EdmodHeaderConstantIndices.INDEX_NUM_STUDENTS_STARTED_PROJECT).trim()) >
                Double.valueOf(EdmodConstants.MINIMUM_METRIC_VALUE)) {
            if (onboardingOpp.S3__c == null) {
                onboardingOpp.S3__c = currentDateTime;
            }
            if (onboardingOpp.S2__c == null) {
                onboardingOpp.S2__c = currentDateTime;
            }
            onboardingOpp.StageName = EdmodConstants.ONBOARDING_STAGE_S3;
        }
        if (Double.valueOf(csvData[i].get(EdmodHeaderConstantIndices.INDEX_NUM_STUDENTS_COMPLETED_PROJECT).trim()) >
            Double.valueOf(EdmodConstants.MINIMUM_METRIC_VALUE))  {
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

        updatedOpportunities.put(onboardingOpp.Contact_ID__c +
            EdmodConstants.KEY_DELIMITER + onboardingOpp.PartnerPlatformInfo__c + EdmodConstants.KEY_DELIMITER +
            onboardingOpp.Name + EdmodConstants.KEY_DELIMITER + onboardingOpp.Type, onboardingOpp);

        if (!(opportunitiesMap.containsKey((conId + EdmodConstants.KEY_DELIMITER +
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
     * @description 	Update the existing nurturing opportunity. 
     * @param accId		Account Id corresponding to account of csv row index i.
     * @param conId  	Contact Id corresponding to contact of csv row index i.
     * @param ppiId  	PartnerPlatformInfo Id corresponding to csv row at index i.
     * @param i			csv row index.
     */
    public void updateNurturingOpportunities(Id accId, Id conId, Id ppiId, Integer i) {
        Opportunity nurturingOpp = opportunitiesMap.get(conId + EdmodConstants.KEY_DELIMITER +
            ppiId + EdmodConstants.KEY_DELIMITER + currentEducationProgramList.get(0).Name +
            EdmodConstants.KEY_DELIMITER + EdmodConstants.NURTURING_OPPORTUNITY);
        DateTime currentDateTime = DateTime.now();
        nurturingOpp.AccountId = accId;
        Double percentageStudentsCompletedProject = computePercentage(i);

        if ((percentageStudentsCompletedProject >= 0.0) && (percentageStudentsCompletedProject < 50.0)) {
            if (nurturingOpp.S1__c == null) {
                nurturingOpp.S1__c = currentDateTime;
            }
            nurturingOpp.StageName = EdmodConstants.NURTURING_STAGE_S1;
        }
        //Check minimum no of students signed up
        if( (Integer.valueOf(csvData[i].get(EdmodHeaderConstantIndices.INDEX_NUM_STUDENTS)) >= EdmodConstantS.MIN_STUDENTS_NURTURING_STAGES)){
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
        }
        updatedOpportunities.put(nurturingOpp.Contact_ID__c +
            EdmodConstants.KEY_DELIMITER + nurturingOpp.PartnerPlatformInfo__c + EdmodConstants.KEY_DELIMITER +
            nurturingOpp.Name + EdmodConstants.KEY_DELIMITER + nurturingOpp.Type, nurturingOpp);
    }

    /*
     * @param i     csv row index.
     * @return 		percentage of students who completed the project.
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
     * @description 		Upsert account records, print errors and initialize Accounts Map with all the upserted account.
     * @param recordsList	List of Accounts to be upserted.
     * @param key			Key used to upsert records.
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
     * @description Upsert contact records, print errors and initialize Contacts Map with all the upserted contact.
     * @param recordsList	List of Contacts to be upserted.
     * @param key			Key used to upsert records.
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
     * @description 		Upsert PartnerPlatformInfo records, print errors and initialize PartnerPlatformInfo Map with all the upserted contact.
     * @param recordsList	List of PartnerPlatformInfo to be upserted.
     * @param key			Key used to upsert records.
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
     * @description 		Upsert Result records and print errors.
     * @param recordsList	List of Result to be upserted.
     * @param key			Key used to upsert records.
     */
    void upsertResultRecords(List < Result__c > recordsList, Schema.SObjectField key) {
        Database.UpsertResult[] upsertStatus;
        if (!recordsList.isEmpty()) {
            upsertStatus = Database.upsert(recordsList, key, false);
            getRecordIdsPrintErrors(recordsList, upsertStatus);
        }
    }
    
    /*
     * @description 		Print errors corresponding to records that are not successfully upserted.
     * @param recordsList	List of records to be upserted.
     * @param upsertStatus	Upsert status of all records present in recordsList. 
     * @return 				List of Id's for records that are successfully upserted. 
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
     * @description 			Insert or Update records and print errors.
     * @param newRecordsList	List of records to be upserted.
     * @param action 			Insert or Update
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
     *  @description Insert Errors in Error Log object
     * 
     */
    public void printErrorsInLog(List < Error_Log__c > errorsList) {
        if (errorsList.size() > 0) {
            Database.SaveResult[] saveStatus = Database.insert(errorsList, false);
        }
    }

    /*
     * @param batchJobId	Batch Id for corresponding batch.
     * @param currentTime	Current DateTime.
     * @param errorMessage	Error message.
     * @return				ErrorLog object
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