public class parseCsvNew {
    
    public void parseCSVFromHttpResponse(HttpResponse response){
        String results = response.getBody();
        //get the response body and adjust the result to remove unwanted empty lines,blanks or tabs.
        String adjustedResult = results.replaceAll('(?m)^[ \t]*\r?\n','');    
        List<String> lines=new List<String>();
        lines=adjustedResult.split('<br>');
  //      System.debug(lines.size());   
         List<String> commaSeparatedValues = adjustedResult.split(',');
        List<List<String>> csvData =new List<List<String>>();
       
        for(Integer rowNumber=0;rowNumber<lines.size();rowNumber++)
        {
           
          List<String> row=lines.get(rowNumber).split(',');
            csvData.add(row);
            
        }
        //System.debug(csvData[0]);
        for(Integer csvDataRow=0;csvDataRow<csvData[0].size();csvDataRow++)
        {
        System.debug(csvData[0].get(csvDataRow));
        }
        //Store the parsing errors in the csvParserErrors list
      /*  List<String> csvParserErrors = new List<String>();
        
        List<String> csvRow = new List<String>();
        List<List<String>> csvData = new List<List<String>>();
     
        for(String csvRowValue:commaSeparatedValues){
            //System.debug(s); 
            if(csvRowValue.contains('<br>')){          
                
                List<String> lastValueInRow=csvRowValue.split('"'); 
                if(lastValueInRow.size()>1)
                {
                    //System.debug(j);
                    if(csvData.size()==0){
                        csvRow.add(lastValueInRow.get(1));
                        csvData.add(csvRow);
                        csvRow=new List<String>();
                        csvRow.add(lastValueInRow.get(3));
                    }
                    else{
                        csvRow.remove(1);
                        csvData.add(csvRow);
                        csvRow=new List<String>();
                        csvRow.add(lastValueInRow.get(1));
                    }
                }
                else if(lastValueInRow.size()==1){
                    csvRow.remove(1);
                    csvData.add(csvRow);
                }
                
            }
            csvRow.add(csvRowValue);
            
        }
        
        for(Integer rowNumber=1;rowNumber<csvData.size();rowNumber++)
        {
            if(rowNumber < csvData.size()-1)
            { 
                if(csvData.get(0).size() != csvData.get(rowNumber).size())
                {
                    csvParserErrors.add('Error in parsing csv row number: '+(rowNumber+1)+' number of headers do not match with number of coloumns in this row');
                    csvData.remove(rowNumber);
                    
                }
            }
            else
            {
                if(csvData.get(0).size() != csvData.get(rowNumber).size()-1)
                {
                    csvParserErrors.add('Error in parsing csv row number: '+(rowNumber+1)+' number of headers do not match with number of coloumns in this row');
                    csvData.remove(rowNumber);
                    
                }
            }
        }
        //System.debug(csvData);
        /* UploadCSVRecords uploadCSVRecords=new UploadCSVRecords();
        if(csvParserErrors.size()>0)
            uploadCSVRecords.printErrorsInLog(csvParserErrors);
        
       //uploadCSVRecords.insertAccountList(csvData,programType,platform);
}*/}
}