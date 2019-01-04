/* CSVParser class parse the csv data from different sources
 * It checks for vaild headers and data 
 */
public class TempCSVParser {
    List < List < String >> dataRows = new List < List < String >> ();
    List < String > lines = new List < String > ();
    Id batchJobId;
    /*
     * parseHttpResponse
     * @description process the CSV data from URL
     * @param response 
     * @param programType : example 'TS','EFTW'
     * @param platform    : example 'CodeHS','KhanAcademy'
     *
     * @example
     * CSVParser csvparser = new CSVParser();
     * csvparser.parseHttpResponse(response,programType,platform);
     */
    public void parseHttpResponse(HttpResponse response, String programType, String platform) {
        String results;
        try {
            /*StaticResource defaultResource = [Select s.Body From StaticResource s where s.Name LIKE 'BulkCSV5000'];
            blob tempB = defaultResource.Body;
            results = tempB.toString();       */

            results = response.getBody();
            lines = safeSplit(results, EdmodConstants.CSV_LINE_SEPERATOR_CSV);

            //get headers from response
            List < String > headers = getHeaders();
            if (headers.size() == EdmodConstants.NO_OF_HEADERS) {
                //validate header 
                headers = validateHeaders(headers);
                //Remove header row from lines to get data lines
                lines.remove(0);
                if (lines.size() < 1) {
                    throw new EdmodCustomException('Zero valid data rows in CSV ');
                }
            } else {
                throw new EdmodCustomException('Invalid Header Count in CSV ');
            }

            TempExecuteBatches executeBatches = new TempExecuteBatches(lines, platform, programType, headers);
            batchJobId = Database.executeBatch(executeBatches);
            // batchJobId = Database.executeBatch(executeBatches, 100);

        } catch (Exception e) {
            List < Error_Log__c > errors = new List < Error_Log__c > ();
            Error_Log__c errorLog = new Error_Log__c();
            errorLog.JobId__c = batchJobId;
            errorLog.Time__c = DateTime.now();
            errorLog.Error_Message__c = 'Exception in CSV parser' + 'at ' + e.getLineNumber() + ' : ' + e.getMessage();
            errors.add(errorLog);
            Database.SaveResult[] saveStatus = Database.insert(errors, false);
        }
    }

    /*
     * validateHeaders
     * @description validate header list
     * @param headers  
     */
    public List < String > validateHeaders(List < String > headers) {
        List < String > trimmedHeaders = new List < String > ();
        String stripped = lines.get(0).replaceAll(' ', '').trim();
        if (!stripped.equalsIgnoreCase(EdmodConstants.HEADER_ROW)) {
            throw new EdmodCustomException('CSV Headers does not match');
        }
        for (String header: headers) {
            trimmedHeaders.add(header.trim());
        }
        return trimmedHeaders;
    }

    /*
     * getHeaders
     * @description get the list of headers from the CSV response
     */
    public List < String > getHeaders() {
        List < String > headers = new List < String > ();
        for (String line: lines) {
            if (line.replaceAll(EdmodConstants.CSV_COLUMN_SEPERATOR, '').trim().length() == 0)
                break;
            headers = line.split(EdmodConstants.CSV_COLUMN_SEPERATOR);
            break;
        }
        return headers;
    }

    /*
     * safeSplit
     * @description Split CSV data in lines 
     * @param inStr : CSV data
     * @param delim : Delimeter to split CSV data. 
     */
    List < String > safeSplit(String inStr, String delim) {
        Integer regexFindLimit = 1000;
        Integer regexFindCount = 0;
        List < String > output = new List < String > ();
        Matcher match = Pattern.compile(delim).matcher(inStr);
        Integer lastEnd = 0;
        while (!match.hitEnd()) {
            while (regexFindCount < regexFindLimit && !match.hitEnd()) {
                if (match.find()) {
                    output.add(inStr.substring(lastEnd, match.start()).replaceAll('[\"]', ''));
                    lastEnd = match.end();
                } else {
                    output.add(inStr.substring(lastEnd).replaceAll('[\"]', ''));
                    lastEnd = inStr.length();
                }
                regexFindCount++;
            }
            match.reset(inStr);
            match.region(lastEnd, match.regionEnd());
            regexFindCount = 0;
        }
        return output;
    }
}