@isTest
public class EdmodExecuteBatchesTest {
    
    /* @Test: EdmodExecuteBatchesTest
     * @Description: This function executes the EdmodExecuteBatches function of class EdmodExecuteBatches 
     */
    @isTest static void EdmodExecuteBatchesTest(){
        Test.startTest();        
        String platform = 'CodeHS';
        String programType = 'TS';
        String url='http://www.mocky.io/v2/5b9a67a23000004b00e7c0b5';
        EdmodExecuteBatches executeBatches = new EdmodExecuteBatches(url,platform, programType);
        Id batchJobId = Database.executeBatch(executeBatches);
        Test.stopTest();
    }
}