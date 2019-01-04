public class DropboxController
{
    //Fetched from URL
    String code ;
    public DropboxController(){}
    public void getDropboxData(){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://content.dropboxapi.com/2/files/download');
        request.setMethod('POST');
        //request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('Authorization', 'Bearer 4Hw_trydD2AAAAAAAAAAEZmutRqfUSQhPtmHW2H7wT9nwkqrwIbYVZHFMnL4Pmen');
        request.setHeader('Dropbox-API-Arg', '{"path": "/csvrepository/bulkcsv50000records4types.csv"}');
        // Set the body as a JSON object
        //request.setBody('{"name":"mighty moose"}');
        HttpResponse response = http.send(request);
        // Parse the JSON response
        if (response.getStatusCode() != 200) {
            System.debug('The status code returned was not expected: ' +
                         response.getStatusCode() + ' ' + response.getStatus()+response.getBody());
        } else {
            System.debug(response.getBody().split('\n').size());
        }
    }
    //Mocky get API
    public void getDropboxData1(){
        HttpResponse response = null;
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('http://www.mocky.io/v2/5b9a67a23000004b00e7c0b5');
            request.setMethod('GET');
            // request.setTimeout(EdmodConstants.REQUEST_TIMEOUT_MS);
            response = http.send(request);
            System.debug('Response code ' + response.getStatusCode() + ' for URL ');
            if (response.getStatusCode() == 200) {
                String results = response.getBody();
                if (!results.equals(null)) {
                    System.debug('response'+response.getBody());
                }
            }
        }catch(Exception e){
            System.debug('exc'+e.getMessage());
        }
    }
    
    
    
}