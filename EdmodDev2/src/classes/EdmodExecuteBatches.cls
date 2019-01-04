/*
 * EdmodExecuteBatches class execute batches to insert data.
 */
global class EdmodExecuteBatches implements Database.Batchable < String >,Database.AllowsCallouts {
    String sDMLOperation;
    List < String > lines;
    String programType;
    String platform;
    List < List < String >> dataRows = new List < List < String >> ();
    List < String > headers;
    String url;
    
     /**
     * @description 		Constructor to instantiate the object of class EdmodExecuteBatches.
     * @param url			Actual data to be inserted/upserted into various standard/custom objects.
     * @param platform		Platform corresponds to TS/EFTW
     * @param programType	Program Type corresponding to the given data like CODEHS/KHAN_ACADEMY
     */
    public EdmodExecuteBatches(String url,String platform, String programType) {
        this.url=url;
        this.platform = platform;
        this.programType = programType;
        this.headers=EdmodConstants.HEADER_ROW.split(',');
    }
    
    /*
     * start
     * @description Called when Batch Exceution is started
     */
    global List < String > start(Database.BatchableContext info) {
        EdmodWebCallout webCallout=new EdmodWebCallout();
        HttpResponse response=webCallout.getWebURLResponse(url,programType, platform);
        if (response!=null) {
            EdmodCSVParser csvparser = new EdmodCSVParser();
            lines=csvparser.parseHttpResponse(response, programType, platform);            
        }
        if(lines == null){
            lines=new List<String>();
        }
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
            if(rows.size()>0){
                dataRows.add(headers);            
                addValidRows(headers.size(), rows, batchableContext.getJobId());
                EdmodUploadCSVRecords uploadCSVRecords =
                    new EdmodUploadCSVRecords(dataRows, programType, platform, batchableContext.getJobId());
                uploadCSVRecords.processAccounts(); 
            }
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