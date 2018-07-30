 
@IsTest
private class Sample_Test {  
    @isTest static void getAuthenticationCapabilities(){ 

        SampleDataSourceProvider  sampleProvider = new SampleDataSourceProvider();  
        sampleProvider.getAuthenticationCapabilities();  
    }


    @isTest static void getCapabilities(){  
        SampleDataSourceProvider  sampleProvider = new SampleDataSourceProvider();  
        sampleProvider.getCapabilities(); 
    } 

    @isTest static void getConnection(){  

        MockHttpResponseGenerator  fakeResponse = new MockHttpResponseGenerator( ); 
        Test.setMock(HttpCalloutMock.class,  fakeResponse);

        SampleDataSourceProvider  sampleProvider = new SampleDataSourceProvider();  
        DataSource.ConnectionParams connectionParams = new  DataSource.ConnectionParams (); 
        SampleDataSourceConnection testConn  =(SampleDataSourceConnection) sampleProvider.getConnection(connectionParams);    
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
