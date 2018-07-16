global class I2MAXDataSourceConnection extends DataSource.Connection {
   
    private DataSource.ConnectionParams connectionInfo; 

    global I2MAXDataSourceConnection(DataSource.ConnectionParams connectionParams) {
        this.connectionInfo = connectionInfo;
    }

    override global DataSource.TableResult query(DataSource.QueryContext context) {
        List<Map<String, Object>> rows = null;
        if( null == context )
           return null; 
        try 
        {
           
            DataSource.Filter filter = context.tableSelection.filter;
            String url;
            if (filter != null) {
                String thisColumnName = filter.columnName;
                if (thisColumnName != null &&
                        (thisColumnName.equals('ExternalId') ||
                                thisColumnName.equals('time')))
                    url = 'https://leemfirst.herokuapp.com/testSfdcAdt.do?'
                            + filter.columnValue;
                else
                        url = 'https://leemfirst.herokuapp.com/testSfdcAdt.do';
            } else {
                url = 'https://leemfirst.herokuapp.com/testSfdcAdt.do';
            }
    
            /**
             * Filters, sorts, and applies limit and offset clauses.
             **/
            rows =  DataSource.QueryUtils.process(context, getData(url));
         } catch(exception e) {
           return null;
        }
        return DataSource.TableResult.get(true, null,context.tableSelection.tableSelected, rows);
    }

    override global List<DataSource.Table> sync() {

        List<DataSource.Table> tables = new List<DataSource.Table>();
        List<DataSource.Column> columns  = new List<DataSource.Column>(); 
        //columns.add(DataSource.Column.indirectLookup('login', 'Contact', 'github_username__c'));
        columns.add(DataSource.Column.text('id', 255));
        columns.add(DataSource.Column.text('name',255));
        columns.add(DataSource.Column.text('phone',255));
        columns.add(DataSource.Column.text('type',255));
        columns.add(DataSource.Column.text('billingstreet',255));
        columns.add(DataSource.Column.text('billingcity',255));
        columns.add(DataSource.Column.text('description',255));
        columns.add(DataSource.Column.url('website'));
        columns.add(DataSource.Column.url('photourl'));
        columns.add(DataSource.Column.url('DisplayUrl'));
        columns.add(DataSource.Column.text('ExternalId',255));
        tables.add(DataSource.Table.get('td_account','time',columns));
        return tables;
    } 

    override global List<DataSource.TableResult> search(DataSource.SearchContext context) {

        if( null == context )
           return null;
        List<DataSource.TableResult> results = new List<DataSource.TableResult>();
        try 
        {
            for (Integer i =0;i< context.tableSelections.size();i++) {
                String entity = context.tableSelections[i].tableSelected;
                // Search usernames
                String url = 'https://leemfirst.herokuapp.com/testSearch.do?' + context.searchPhrase;
                results.add(DataSource.TableResult.get(true, null, entity, getData(url)));
            } 
        } catch(exception e) {
           return null;
        }

        return results;
    }


    // Helper methods

    /**
    *   Helper method to parse the data.
    *   The url argument is the URL of the external system.
    *   Returns a list of rows from the external system.
    **/
    public List<Map<String, Object>> getData(String url) { 
        List<Map<String, Object>> rows = null;
        if( null == url)
           return null;
        try 
        {
           String response = getResponse(url);
           // Standardize response string
           if (!response.contains('"items":')) {
               if (response.substring(0,1).equals('{')) {
                   response = '[' + response  + ']';
               }
               response = '{"items": ' + response + '}';
           }
           rows = new List<Map<String, Object>>();
           Map<String, Object> responseBodyMap = (Map<String, Object>)JSON.deserializeUntyped(response);
           /**
            *   Checks errors.
            **/
           Map<String, Object> error =
                   (Map<String, Object>)responseBodyMap.get('error');
           if (error!=null) {
               List<Object> errorsList =
                       (List<Object>)error.get('errors');
               Map<String, Object> errors =
                       (Map<String, Object>)errorsList[0];
               String errorMessage = (String)errors.get('message');
               throw new
                       DataSource.OAuthTokenExpiredException(errorMessage);
           }
               List<Object> fileItems =
                   (List<Object>)responseBodyMap.get('items');
           if (fileItems != null) {
               for (Integer i=0; i < fileItems.size(); i++) {
                   Map<String, Object> item =
                           (Map<String, Object>)fileItems[i];
                   rows.add(createRow(item));
               }
           } else {
               rows.add(createRow(responseBodyMap));
           }
        } catch(exception e) {
           return null;
        }
        return rows;
    }

/*
* Apex Developer Guide Using Salesforce Features with Apex
* Helper method to populate the External ID and Display
* URL fields on external object records based on the 'id'
* value that’s sent by the external system.
**
The Map<String, Object> item parameter maps to the data
* that represents a row.
** 임용훈
Returns an updated map with the External ID and
* Display URL values.
**/
    public Map<String, Object> createRow(Map<String, Object> item)
    {
        Map<String, Object> row = null;
        if( null == item)
           return null;
        try {
             row = new Map<String, Object>();
             for ( String key : item.keySet() ) {
                 if (key == 'id') {
                     row.put('ExternalId', item.get(key));
                 } else if (key=='photourl') {
                     row.put('DisplayUrl', item.get(key));
                 }
                 row.put(key, item.get(key));
             }   
        } catch (exception e) {
          return null;    
        } 
        return row;
    }


    /**
     * Helper method to make the HTTP GET call.
     * The url argument is the URL of the external system.
     * Returns the response from the external system.
     **/
    public String getResponse(String url) {
        if( null == url)
           return null;
        // Perform callouts for production (non-test) results.
        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndPoint(url);
        request.setMethod('GET');
        HttpResponse response = httpProtocol.send(request);
        return response.getBody();   
    } 
}
