 
@IsTest
private class Sample_Test {  
    @isTest static void getAuthenticationCapabilities(){ 

        I2MAXDataSourceProvider  sampleProvider = new I2MAXDataSourceProvider();  
        sampleProvider.getAuthenticationCapabilities();  
    }


    @isTest static void getCapabilities(){  
        I2MAXDataSourceProvider  sampleProvider = new I2MAXDataSourceProvider();  
        sampleProvider.getCapabilities(); 
    } 

    @isTest static void getConnection(){  

        MockHttpResponseGenerator  fakeResponse = new MockHttpResponseGenerator( ); 
        Test.setMock(HttpCalloutMock.class,  fakeResponse);

        I2MAXDataSourceProvider  sampleProvider = new I2MAXDataSourceProvider();  
        DataSource.ConnectionParams connectionParams = new  DataSource.ConnectionParams (); 
        I2MAXDataSourceConnection testConn  =(I2MAXDataSourceConnection) sampleProvider.getConnection(connectionParams);    
        DataSource.QueryContext qeuryContext = new  DataSource.QueryContext (); 
        DataSource.SearchContext searchContext = new  DataSource.SearchContext ();
        DataSource.TableSelection tblSel1 =  new DataSource.TableSelection();
        DataSource.TableSelection tblSel2=  new DataSource.TableSelection();
        Map<String, Object> item = new  Map<String, Object> ();
 
        item.put('test', 'test'); 
        
        tblSel1.tableSelected  = 'select id from Account limit 1';
        
        tblSel2.tableSelected = 'select id from Account limit 1';

        qeuryContext.tableSelection = tblSel1;
        searchContext.tableSelections = new List<DataSource.TableSelection> ();
        searchContext.tableSelections.add(tblSel2) ;  
 

        testConn.query( qeuryContext );  
        testConn.sync( ); 
        testConn.search(searchContext);  
        testConn.getData('http://example.com/example/test'); 
        testConn.createRow(item);
        testConn.getResponse('http://example.com/example/test'); 
 
    }
}
