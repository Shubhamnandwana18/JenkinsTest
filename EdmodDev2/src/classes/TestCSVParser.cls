/* CSVParser class parse the csv data from different sources
 * It checks for vaild headers and data 
 */
public class TestCSVParser {
    List < List < String >> dataRows = new List < List < String >> ();
    //List < String > lines = new List < String > ();
 	UtilityRowIterator lines;
    /*
     * parseHttpResponse
     * @description process the CSV data from URL
     * @param response 
     * @param programType : example 'TS','EFTW'
     * @param platform    : exampke 'CodeHS','KhanAcademy'
     *
     * @example
     * CSVParser csvparser = new CSVParser();
     * csvparser.parseHttpResponse(response,programType,platform);
     */
    public void parseHttpResponse(HttpResponse response, String programType, String platform) {
        String results;
        try {
            System.debug('in');
            StaticResource defaultResource = [Select  s.Body From StaticResource s where s.Name LIKE 'BulkData11'];
            System.debug('out');
            //modStyle
            
            blob tempB = defaultResource.Body;            
            //results = tempB.toString().replaceAll('(?m)^[ \t]*\r?\n', '');
			results = tempB.toString();
			
            //lines = results.replaceAll('[\n\r]', '').split(EdmodConstants.CSV_LINE_SEPERATOR);
             lines = New UtilityRowIterator(results, EdmodConstants.CSV_LINE_SEPERATOR);
            
            //results = response.getBody().replaceAll('(?m)^[ \t]*\r?\n', '');
            //lines = results.replaceAll('[\n\r]', '').split(EdmodConstants.CSV_LINE_SEPERATOR);
            
            //get headers from response
            List < String > headers = getHeaders();

            if (headers.size() == EdmodConstants.NO_OF_HEADERS) {
                //validate header 
                headers=validateHeaders(headers);
                //Remove header row from lines to get data lines
                lines.next();
                dataRows.add(headers);
                //add all valid rows to validCSVData
                addValidRows(headers.size());
            } else {
                throw new CustomException('Invalid Header Count in CSV ');
            }
            
           TestingUploadCSVRecords uploadCSVRecords =
		                new TestingUploadCSVRecords(dataRows, programType, platform);
           uploadCSVRecords.processAccounts();
        } catch (Exception e) {
            System.debug(Logginglevel.ERROR, 'Exception in CSV parser ' + e.getLineNumber() + ' message ' + e.getMessage());
        }
    }
    
    public void addValidRows(Integer headerSize) {
        List < String > invalidRows = new List < String > ();
        Integer count = 0;
        while (lines.hasNext()) {
            String line = lines.next().replaceAll('\n', '');
            System.debug('Line  : ' + line);
            if (line.replaceAll(EdmodConstants.CSV_COLUMN_SEPERATOR, '').trim().length() == 0) {
                continue;
            }
            List < String > row = line.split(EdmodConstants.CSV_COLUMN_SEPERATOR);
            List < String > validRows = new List < String > ();
            for (String field: row)
                validRows.add(field.trim());
            if (row.size() != headerSize) {
                invalidRows.add(line);
                continue;
            }
            dataRows.add(validRows);
            count++;
        }
        if(invalidRows.size()>0)
            System.debug(Logginglevel.ERROR, 'Data column length is not equal to Headers length for rows: '+count +'  '+invalidRows);
    }

    public List<String> validateHeaders(List < String > headers) {
        List<String> trimmedHeaders=new List<String>();
        for (String header: headers) {
            if (header == null || header.trim() == '' || header.length() == 0) {
                throw new CustomException('CSV Headers are empty');
            }
            trimmedHeaders.add(header.trim());
        }
        return trimmedHeaders;
    }


    public List < String > getHeaders() {
        List < String > headers = new List < String > ();
        UtilityRowIterator lines1 = lines;
        while (lines1.hasNext()) {
            String line = lines1.next();
            if (line.replaceAll(EdmodConstants.CSV_COLUMN_SEPERATOR, '').trim().length() == 0)
                break;
            headers = line.split(EdmodConstants.CSV_COLUMN_SEPERATOR);
            break;
        }
        System.debug('headers' + headers);
        return headers;
    }
}