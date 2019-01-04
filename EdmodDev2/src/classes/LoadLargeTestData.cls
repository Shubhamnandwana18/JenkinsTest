public class LoadLargeTestData {
    public void asd() {
        StaticResource defaultResource = [Select s.Body From StaticResource s where s.Name LIKE 'LargeTestDataStaticResource%'];
        blob tempB = defaultResource.Body;
        String contentFile = tempB.toString();
        String[] filelines = contentFile.split('\n');
        System.debug('asdf' + filelines[0]);
    }
}