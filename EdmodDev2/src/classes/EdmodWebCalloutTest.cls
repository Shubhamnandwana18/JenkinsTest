@isTest
private class EdmodWebCalloutTest {
    @isTest static void testCallout() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new EdmodMockHttpCSVResponseGenerator()); 
        EdmodWebCallout web=new EdmodWebCallout();
        HttpResponse response= web.getWebURLResponse('http://www.mocky.io/v2/5b992ed43200006a0013fc7a','TS','CODEHS');
        System.assertEquals(200, response.getStatusCode());
    }
}