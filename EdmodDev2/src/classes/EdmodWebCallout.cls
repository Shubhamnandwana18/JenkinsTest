public class EdmodWebCallout {
    
    /*
     * getWebURLResponse
     * @description Get response for the given url
     * @param url 
     * @param programType : example 'TS','EFTW'
     * @param platform    : exampke 'CodeHS','KhanAcademy'
     *
     * @example
     * EdmodWebCallout web = new EdmodWebCallout();
     * web.getWebURLResponse(url,programType,platform);
     */
    public HttpResponse getWebURLResponse(String url, String programType, String platform) {
        HttpResponse response = null;
        List < Error_Log__c > errors = new List < Error_Log__c > ();
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(url);
            request.setMethod('GET');
            request.setTimeout(EdmodConstants.REQUEST_TIMEOUT_MS);
            response = http.send(request);
            System.debug('Response code ' + response.getStatusCode() + ' for URL '+ url);
            if (response.getStatusCode() == 200) {
                String results = response.getBody();
                if (!results.equals(null)) {
                    return response;
                }
            } else {                            
            	Error_Log__c errorLog = new Error_Log__c();
            	errorLog.Time__c = DateTime.now();
            	errorLog.Error_Message__c = 'Url ' + url + ' Got invalid Http response code:' + response.getStatusCode();
            	errors.add(errorLog);
            }
        } catch (System.CalloutException e) {
            	Error_Log__c errorLog = new Error_Log__c();
            	errorLog.Time__c = DateTime.now();
            	errorLog.Error_Message__c = 'Timeout error occured in getting http response for url ' + url + 'Message: ' + e.getMessage();
            	errors.add(errorLog);
        } catch (Exception e) {
            	Error_Log__c errorLog = new Error_Log__c();
            	errorLog.Time__c = DateTime.now();
            	errorLog.Error_Message__c = 'Error in getting http response for url ' + url + 'Message: ' + e.getMessage();
            	errors.add(errorLog);
        }
        if(errors.size()>0){
            Database.SaveResult[] saveStatus = Database.insert(errors, false);
        }
        return null;
    }
}