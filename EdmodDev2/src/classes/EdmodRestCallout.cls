@RestResource(urlMapping='/EdmodRestCallout/*')
global with sharing class EdmodRestCallout {
    @HttpGet
    global static String doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        System.debug('req:::'+ req.params);
        return 'result';

    }
}