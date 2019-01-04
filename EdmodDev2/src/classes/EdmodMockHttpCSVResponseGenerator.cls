@isTest
public class EdmodMockHttpCSVResponseGenerator implements HttpCalloutMock 
{
    public HTTPResponse respond(HTTPRequest req) 
    {

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/html; charset=UTF-8');
        res.setBody('Id,\nLast Name,\nFirst Name,\nEmail,\nPhone,\nDate Joined,\nLast Login,\nClass Code,\nSchool,\nSchool NCES ID,\nDistrict,\nDistrict NCES ID,\nCity,\nState,\nCountry,\nNum Sections,\nNum Students,\nNum Students Who Completed A Project,\nNum Student Program Shares,\n\nTeacher Checklist Completed 1,\n\nTeacher Checklist Completed 2,\n\nTeacher Checklist Completed 3,\n\nTeacher Checklist Completed 4,\n\nTeacher Checklist Completed 5,\n\nStudents Completed Music 1 Hour,\nStudents Completed Music 10 Hour,\nStudents Completed Art 1 Hour,\nStudents Completed Art 10 Hour,\nStudents Completed Sports 1 Hour,\nStudents Completed Sports 10 Hour,\nStudents Started Music 1 Hour,\nStudents Started Art 1 Hour,\nStudents Started Sports 1 Hour,\nStudents Started Music 10 Hour,\nStudents Started Art 10 Hour,\nStudents Started Sports 10 Hour,\nNum Students Who Started A Project\n<br>\n\n    760545,\n    Jeremy,\n    TechStart,\n    jkeesh+techstart12@codehs.com,\n    1231231234,\n    2019-08-16 10:08:22,\n    2019-08-23 11:08:40,\n    889AD,\n    \n    DEERFIELD HIGH SCHOOL,\n    171908002193,\n    TWP HSD 113,\n    1719080,\n    DEERFIELD,\n    IL,\n    USA,\n    \n    1,\n    1,\n    0,\n    0,\n\n    True,\n    True,\n    True,\n    True,\n    True,\n\n    0,\n    0,\n    0,\n    0,\n    0,\n    0,\n    0,\n    0,\n    0,\n    0,\n    0,\n    0,\n    0\n    <br>');
        res.setStatusCode(200);
       // System.assertEquals('POST', req.getMethod());
      
        return res;
    }
}