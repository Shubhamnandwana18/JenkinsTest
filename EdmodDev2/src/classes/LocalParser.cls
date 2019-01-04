public class LocalParser {
 public void parseHttpResponse(HttpResponse response, String programType, String platform) {
        String results;
        try {
            StaticResource defaultResource = [Select  s.Body From StaticResource s where s.Name LIKE 'SmallData%'];
            //modStyle
            
            blob tempB = defaultResource.Body;            
            //results = tempB.toString().replaceAll('(?m)^[ \t]*\r?\n', '');
			results = tempB.toString();
        }catch (Exception e) {
            System.debug(Logginglevel.ERROR, 'Exception in CSV parser' + e.getMessage());
        }
 }
}