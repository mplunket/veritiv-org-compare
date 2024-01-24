public class CPLXLSController extends CPLController{
    
    public String xmlHeader {get;set;}
    public String xlsColumns {get; set;}
    public String xlsData {get; set;}
    public String numberFormat {get; set;}
    public List<String> tableHeaders {get; set;}
    public String division {get; set;}
    
    public CPLXLSController(){
        super();
        xmlHeader = '<?xml version="1.0" ?><?mso-application progid="Excel.Sheet"?>';
        numberFormat = '<NumberFormat ss:Format="_(&quot;$&quot;* #,##0.0000_);_(&quot;$&quot;* \\(#,##0.0000\\);_(&quot;$&quot;* &quot;-&quot;??_);_(@_)"/>';
        generateXLSFromController();
        system.debug('xlsData: '+ xlsData);
    }
    
    public void generateXLSFromController(){
        xlsColumns = generateColumnDeclarations();
        for(CPL cpl : cplByDivision) {
            if (cpl.rows.size() > 0){
                xlsData = generateHeader(cpl);
                xlsData += generateRows();
            } 
            else {
                xlsData += '<Row><Cell><Data ss:Type="String">' + Label.Customer_Price_List_No_Results_Message + '</Data></Cell></Row>';
            }
        }
    }
    
    private String generateHeader(CPL cpl){
        tableHeaders = cpl.headers;
        
        String header = '<Row ss:Height="45">';
        if(tableHeaders != null){
            for (String tableHeader : tableHeaders){
                header += '<Cell ss:StyleID="s67"><Data ss:Type="String">' + tableHeader + '</Data></Cell>';
            }
            
            header += '</Row>';    
        }
        return header;
    }
    
    private String generateRows(){
        String rows = '';
        
        for(CPL cpl : cplByDivision) {
            if(cplRecord.Agreement__r.Account.Recordtype.Name != 'Chain Account' && cpl.isNationals != true && cpl.Division != null){
                rows += '<Row><Cell ss:MergeAcross="' + (cpl.headers.size() - 1) + '" ss:StyleID="s69"><Data ss:Type="String">' + cpl.Division.escapeXml() + '</Data></Cell></Row>';            
            }
            //system.debug('cpl rows: '+ cpl.rows.keySet());
            list<string> rowsKeyset = new list<string>(cpl.rows.keySet());
            rowsKeyset.sort();
            system.debug('cpl rowsKeyset: '+ rowsKeyset);
            for (String subtitle : rowsKeyset) {
                //for (String sortedSubtitle : cpl.rows.keySet()) {
                    if(subtitle != ''){
                        rows += '<Row ss:Height="25"><Cell ss:MergeAcross="' + (cpl.headers.size() - 1) + '" ss:StyleID="s80"><Data ss:Type="String">' + subtitle.escapeXml() + '</Data></Cell></Row>';
                        //system.debug('Subtitle: '+ '<Row ss:Height="25"><Cell ss:MergeAcross="' + (cpl.headers.size() - 1) + '" ss:StyleID="s80"><Data ss:Type="String">' + subtitle.escapeXml() + '</Data></Cell></Row>');//to test when the sort changes
                    }
                    
                    if (CPLType == 'External'){
                        for (CPLController.CPLRow row : cpl.rows.get(subtitle)){                    
                            if(row != null){
                                rows += generateExternalRow(row);
                            }
                        }
                    }
                    else if (CPLType == 'Internal'){
                        for (CPLController.CPLRow row : cpl.rows.get(subtitle)){
                            if(row != null){                       
                                rows += generateInternalRow(row);
                            }
                        }
                    }
                //}
        	}
        }
        return rows;
    }
    
    private String generateInternalRow(CPLController.CPLRow row){
        CPLController.InternalCPLRow internalRow = (CPLController.InternalCPLRow) row;
        return '<Row ss:Height="45">'
                + '<Cell ss:StyleID="s81"><Data ss:Type="String">' + valueOrEmptyString(internalRow.Division) + '</Data></Cell>'
                + '<Cell ss:StyleID="s81"><Data ss:Type="String">' + valueOrEmptyString(internalRow.Segment) + '</Data></Cell>'
                + '<Cell ss:StyleID="s81"><Data ss:Type="String">' + valueOrEmptyString(internalRow.CPLClass) + '</Data></Cell>'                
                + '<Cell ss:StyleID="s81"><Data ss:Type="String">' + valueOrEmptyString(internalRow.Brand).escapeXml() + '</Data></Cell>'
                + '<Cell ss:StyleID="s81"><Data ss:Type="String">' + valueOrEmptyString(internalRow.CPLSet) + '</Data></Cell>'
                + '<Cell ss:StyleID="s81"><Data ss:Type="String">' + valueOrEmptyString(internalRow.Subset) + '</Data></Cell>'
                + '<Cell ss:StyleID="s81"><Data ss:Type="String">' + valueOrEmptyString(internalRow.ProductCode) + '</Data></Cell>'
                + '<Cell ss:StyleID="s81"><Data ss:Type="String">' + valueOrEmptyString(internalRow.CustomerSKU) + '</Data></Cell>'
                + '<Cell ss:StyleID="s81"><Data ss:Type="String">' + valueOrEmptyString(internalRow.Vendor) + '</Data></Cell>'
                + '<Cell ss:StyleID="s81"><Data ss:Type="String">' + valueOrEmptyString(internalRow.ProductDescription) + '</Data></Cell>'
                + '<Cell ss:StyleID="s81"><Data ss:Type="Number">' + valueOrEmptyString(internalRow.QTYPriceBreak) + '</Data></Cell>'
                  //+ (valueOrEmptyString(internalRow.PriceType) != 'List Down' ? 
                  //'<Cell ss:StyleID="s90"><Data ss:Type="Number">' + valueOrEmptyString(internalRow.CurrentPrice) + '</Data></Cell>' : 
                  //'<Cell ss:StyleID="s92"><Data ss:Type="Number">' + valueOrEmptyString(internalRow.CurrentPrice) + '</Data></Cell>' )
                + 
                ((valueOrEmptyString(internalRow.Cost) == '0.00' || String.isBlank(valueOrEmptyString(internalRow.Cost)))  && valueOrEmptyString(internalRow.PriceType) == 'List Down' ?
                 '<Cell ss:StyleID="s92"><Data ss:Type="Number">' + valueOrEmptyString(internalRow.CurrentPrice) + '</Data></Cell>' :   
                 '<Cell ss:StyleID="s81"><Data ss:Type="Number">' + valueOrEmptyString(internalRow.CurrentPrice) + '</Data></Cell>' )
                 
                + '<Cell ss:StyleID="s81"><Data ss:Type="String">' + valueOrEmptyString(internalRow.CustPriceUOM) + '</Data></Cell>'
                + '<Cell ss:StyleID="s81"><Data ss:Type="Number">' + valueOrEmptyString(internalRow.Cost) + '</Data></Cell>'
                + '<Cell ss:StyleID="s92"><Data ss:Type="Number">' + valueOrEmptyString(internalRow.GTM) + '</Data></Cell>'
                + '<Cell ss:StyleID="s91"><Data ss:Type="String">' + valueOrEmptyString(internalRow.BeginDate) + '</Data></Cell>'
                + '<Cell ss:StyleID="s81"><Data ss:Type="Number">' + valueOrEmptyString(internalRow.FuturePrice) + '</Data></Cell>'
                + '<Cell ss:StyleID="s81"><Data ss:Type="Number">' + valueOrEmptyString(internalRow.FutureCost) + '</Data></Cell>'
                + '<Cell ss:StyleID="s81"><Data ss:Type="String">' + valueOrEmptyString(internalRow.FutureGTM) + '</Data></Cell>'
                + '<Cell ss:StyleID="s81"><Data ss:Type="String">' + valueOrEmptyString(internalRow.FutureEffDate) + '</Data></Cell>'
                + '<Cell ss:StyleID="s81"><Data ss:Type="String">' + valueOrEmptyString(internalRow.PriceType) + '</Data></Cell>'
                + '<Cell ss:StyleID="s81"><Data ss:Type="Number">' + valueOrEmptyString(internalRow.PolicyValue) + '</Data></Cell>'
                + '<Cell ss:StyleID="s81"><Data ss:Type="Number">' + valueOrEmptyString(internalRow.FuturePolicyValue) + '</Data></Cell>'
                + '<Cell ss:StyleID="s81"><Data ss:Type="String">' + valueOrEmptyString(internalRow.Rebate) + '</Data></Cell>'
                + '<Cell ss:StyleID="s81"><Data ss:Type="String">' + valueOrEmptyString(internalRow.RebateExpirationDate) + '</Data></Cell>'
                + '<Cell ss:StyleID="s81"><Data ss:Type="String">' + valueOrEmptyString(internalRow.CWTPrice) + '</Data></Cell>'
                + '<Cell ss:StyleID="s81"><Data ss:Type="Number">' + valueOrEmptyString(internalRow.TwelveMonthSales) + '</Data></Cell>'
                + '</Row>';
    }

    private String generateExternalRow(CPLController.CPLRow row){
        CPLController.ExternalCPLRow externalRow = (CPLController.ExternalCPLRow) row;
        return '<Row ss:Height="45">'
                + '<Cell ss:StyleID="s81"><Data ss:Type="String">' + valueOrEmptyString(externalRow.ProductCode) + '</Data></Cell>'
                + '<Cell ss:StyleID="s81"><Data ss:Type="String">' + valueOrEmptyString(externalRow.OrderQty) + '</Data></Cell>'
                + '<Cell ss:StyleID="s81"><Data ss:Type="String">' + valueOrEmptyString(externalRow.CustomerSKU) + '</Data></Cell>'
                + '<Cell ss:StyleID="s81"><Data ss:Type="String">' + valueOrEmptyString(externalRow.ProductDescription) + '</Data></Cell>'
                + '<Cell ss:StyleID="s81"><Data ss:Type="Number">' + valueOrEmptyString(externalRow.QTYPriceBreak) + '</Data></Cell>'
                + '<Cell ss:StyleID="s81"><Data ss:Type="String">' + valueOrEmptyString(externalRow.OrderQtyUOM) + '</Data></Cell>'
                
               /*+ (valueOrEmptyString(externalRow.PriceType) != 'List Down' ? 
                  '<Cell ss:StyleID="s90"><Data ss:Type="Number">' + valueOrEmptyString(externalRow.CurrentPrice) + '</Data></Cell>' : 
                  '<Cell ss:StyleID="s92"><Data ss:Type="Number">' + valueOrEmptyString(externalRow.CurrentPrice) + '</Data></Cell>')*/
               + 
                ((valueOrEmptyString(externalRow.Cost) == '0.00' || String.isBlank(valueOrEmptyString(externalRow.Cost))) && valueOrEmptyString(externalRow.PriceType) == 'List Down' ?
                 '<Cell ss:StyleID="s92"><Data ss:Type="Number">' + valueOrEmptyString(externalRow.CurrentPrice) + '</Data></Cell>' :   
                 '<Cell ss:StyleID="s81"><Data ss:Type="Number">' + valueOrEmptyString(externalRow.CurrentPrice) + '</Data></Cell>' )
                + '<Cell ss:StyleID="s81"><Data ss:Type="String">' + valueOrEmptyString(externalRow.CustPriceUOM) + '</Data></Cell>'
                + '<Cell ss:StyleID="s81"><Data ss:Type="String">' + valueOrEmptyString(externalRow.FuturePrice) + '</Data></Cell>'
                + '<Cell ss:StyleID="s81"><Data ss:Type="String">' + valueOrEmptyString(externalRow.FuturePriceUOM) + '</Data></Cell>'
                + '<Cell ss:StyleID="s81"><Data ss:Type="String">' + valueOrEmptyString(externalRow.FutureEffDate) + '</Data></Cell>'
                + '<Cell ss:StyleID="s81"><Data ss:Type="String">' + valueOrEmptyString(externalRow.EmptyColumn) + '</Data></Cell>'
                + '</Row>';
    }
    
    private String generateColumnDeclarations(){
        String columns = '';
        if (CPLType == 'Internal') {
            columns = generateInternalColumns();
        } 
        else {
            columns = generateExternalColumns();
        }
        return columns;
    }
    
    private String generateInternalColumns(){
        return '<Column ss:AutoFitWidth="0" ss:Width="80"/>'
                + '<Column ss:AutoFitWidth="0" ss:Width="80"/>'
                + '<Column ss:AutoFitWidth="0" ss:Width="80"/>'
                + '<Column ss:AutoFitWidth="0" ss:Width="80"/>'
                + '<Column ss:AutoFitWidth="0" ss:Width="50"/>'
                + '<Column ss:AutoFitWidth="0" ss:Width="50"/>'
                + '<Column ss:AutoFitWidth="0" ss:Width="54.50"/>'
                + '<Column ss:AutoFitWidth="0" ss:Width="80"/>'
                + '<Column ss:AutoFitWidth="0" ss:Width="80"/>'
                + '<Column ss:AutoFitWidth="0" ss:Width="250"/>'
                + '<Column ss:AutoFitWidth="0" ss:Width="50"/>'
                + '<Column ss:AutoFitWidth="0" ss:Width="70"/>'
                + '<Column ss:AutoFitWidth="0" ss:Width="50"/>'
                + '<Column ss:AutoFitWidth="0" ss:Width="50"/>'
                + '<Column ss:AutoFitWidth="0" ss:Width="70"/>'
                + '<Column ss:AutoFitWidth="0" ss:Width="50"/>'
                + '<Column ss:AutoFitWidth="0" ss:Width="70"/>'
                + '<Column ss:AutoFitWidth="0" ss:Width="80"/>'
                + '<Column ss:AutoFitWidth="0" ss:Width="80"/>'
                + '<Column ss:AutoFitWidth="0" ss:Width="80"/>'
                + '<Column ss:AutoFitWidth="0" ss:Width="70"/>'
                + '<Column ss:AutoFitWidth="0" ss:Width="70"/>'
                + '<Column ss:AutoFitWidth="0" ss:Width="70"/>'
                + '<Column ss:AutoFitWidth="0" ss:Width="70"/>'
                + '<Column ss:AutoFitWidth="0" ss:Width="70"/>'
                + '<Column ss:AutoFitWidth="0" ss:Width="70"/>'
                + '<Column ss:AutoFitWidth="0" ss:Width="70"/>';
    }

    private String generateExternalColumns(){
        return  '<Column ss:AutoFitWidth="0" ss:Width="54.50"/>'
                + '<Column ss:AutoFitWidth="0" ss:Width="55"/>'
                + '<Column ss:AutoFitWidth="0" ss:Width="80"/>'
                + '<Column ss:AutoFitWidth="0" ss:Width="250"/>'
                + '<Column ss:AutoFitWidth="0" ss:Width="60"/>'
                + '<Column ss:AutoFitWidth="0" ss:Width="60"/>'
                + '<Column ss:AutoFitWidth="0" ss:Width="70"/>'
                + '<Column ss:AutoFitWidth="0" ss:Width="50"/>'
                + '<Column ss:AutoFitWidth="0" ss:Width="70"/>'
                + '<Column ss:AutoFitWidth="0" ss:Width="70"/>'
                + '<Column ss:AutoFitWidth="0" ss:Width="70"/>'
                + '<Column ss:AutoFitWidth="0" ss:Width="70"/>';
    }
    
    private String valueOrEmptyString(Object value){
        if (value != null) {
            if(value instanceof Datetime) {
                return String.valueof(value).remove('00:00:00');
            }
            else if(value instanceof Decimal) {
                Decimal d = (Decimal) value;
                //if (d <= 0.009) return '';
                return String.valueof(d.setscale(2));
            } else {
                return String.valueof(value);
            }
        }
        return '';
    }
       
    /*private String stringPercent(Object value){
        if (value != null) {
           if(value instanceof Decimal) {
                Decimal d = (Decimal) value;
                return String.valueof(d.setscale(2));
            } 
            
        }
        return '';
        
    }*/
    
    public Integer getColumnCount(){
        //Integer headerValue = 0;
        
        if(tableHeaders != null && tableHeaders.size() > 0){
            return tableHeaders.size();//cpl.headers.size();
        }
        System.debug('Error file');
        return 0;
    }
}