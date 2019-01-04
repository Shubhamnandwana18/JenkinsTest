global class TempExecuteBatches implements Database.Batchable < String > {
    String sDMLOperation;
    List < String > lines;
    String programType;
    String platform;
    List < List < String >> dataRows = new List < List < String >> ();
    List < String > headers;

    public TempExecuteBatches(List < String > lines, String platform, String programType, List < String > headers) {
        this.lines = lines;
        this.platform = platform;
        this.headers = headers;
        this.programType = programType;
    }

    /*
     * start
     * @description Called when Batch Exceution is started
     */
    global List < String > start(Database.BatchableContext info) {
        return lines;
    }

    /*
     * execute
     * @description Process row data in batches to create records
     * @param headerSize 
     * @param rows : CSV rows
     * @param jobId : Batch Job Id
     */
    global void execute(Database.BatchableContext batchableContext, List < String > rows) {
        try {
            dataRows.add(headers);
            addValidRows(headers.size(), rows, batchableContext.getJobId());
            TempUploadCSVRecords uploadCSVRecords =
                new TempUploadCSVRecords(dataRows, programType, platform, batchableContext.getJobId());
            uploadCSVRecords.processAccounts();
        } catch (Exception e) {
            Error_Log__c errorLog = new Error_Log__c();
            errorLog.JobId__c = batchableContext.getJobId();
            errorLog.Time__c = DateTime.now();
            errorLog.Error_Message__c = 'Exception in batch execute at ' + e.getLineNumber() + e.getMessage();
            printErrorsInLog(new List < Error_Log__c > {
                errorLog
            });
        }
    }

    /*
     * finish
     * @description Called when Batch Exceution is finished
     */
    global void finish(Database.BatchableContext batchableContext) {
        System.debug('Job is Finished');
    }

    /*
     * addValidRows
     * @description process all the rows and add valid rows to dataRows
     * @param headerSize 
     * @param rows : CSV rows
     * @param jobId : Batch Job Id
     */
    void addValidRows(Integer headerSize, List < String > rows, Id jobId) {
        List < String > invalidRows = new List < String > ();
        for (String row: rows) {
            row = row.trim().replace(',$', '');
            if (row.replaceAll(EdmodConstants.CSV_COLUMN_SEPERATOR, '').trim().length() == 0) {
                continue;
            }
            List < String > rowData = row.split(EdmodConstants.CSV_COLUMN_SEPERATOR);
            if (rowData.size() != headerSize) {
                invalidRows.add(row);
                continue;
            }
            dataRows.add(rowData);
        }
        if (invalidRows.size() > 0) {
            Error_Log__c errorLog = new Error_Log__c();
            errorLog.JobId__c = jobId;
            errorLog.Time__c = DateTime.now();
            errorLog.Error_Message__c = 'Data column length is not equal to Headers length for rows:' + invalidRows;
            printErrorsInLog(new List < Error_Log__c > {
                errorLog
            });
        }
    }

    /*
     * printErrorsInLog
     * @description insert errors in Error_Log__c
     */
    public void printErrorsInLog(List < Error_Log__c > errorsList) {
        Database.SaveResult[] saveStatus = Database.insert(errorsList, false);
    }
}