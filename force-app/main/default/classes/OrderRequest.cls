public virtual class OrderRequest
{
    //Classes
    public class RequestClass
    {
      public HeaderClass Header
      {
          get
          {
              if(Header == null) Header = new HeaderClass();
              return Header;
          }
          set
          {
              Header = value;
          }
      }
  
      public DetailClass[] Details
      {
          get
          {
              if(Details == null) Details = new DetailClass[0];
              return Details;
          }
          set
          {
              Details = value;
          }
      }
    }
    
    public class ResponseClass
    {
      public String StatusCode
      {
        get
        {
          if(StatusCode == null) StatusCode = '';
          return StatusCode;
        }
        set {StatusCode = value;}
      }
      public String StatusMessage
      {
        get
        {
          if(StatusMessage == null) StatusMessage = '';
          return StatusMessage;
        }
        set {StatusMessage = value;}
      }
      public DateTime StatusSendDate{get;set;}
    }

    public class HeaderClass
    {
      public String QuoteNum
      {
        get
        {
          if(QuoteNum == null) QuoteNum = '';
          return QuoteNum;
        }
        set {QuoteNum = value;}
      }
      public String BillToCode
      {
        get
        {
          if(BillToCode == null) BillToCode = '';
          return BillToCode;
        }
        set {BillToCode = value;}
      }
      public String BillToName
      {
        get
        {
          if(BillToName == null) BillToName = '';
          return BillToName;
        }
        set {BillToName = value;}
      }
      public String CustomerContactName
      {
        get
        {
          if(CustomerContactName == null) CustomerContactName = '';
          return CustomerContactName;
        }
        set {CustomerContactName = value;}
      }
      public String ShipToCode
      {
        get
        {
          if(ShipToCode == null) ShipToCode = '';
          return ShipToCode;
        }
        set {ShipToCode = value;}
      }
      public String ShipToName
      {
        get
        {
          if(ShipToName == null) ShipToName = '';
          return ShipToName;
        }
        set {ShipToName = value;}
      }
      public String ShipToStreet
      {
        get
        {
          if(ShipToStreet == null) ShipToStreet = '';
          return ShipToStreet;
        }
        set {ShipToStreet = value;}
      }
      public String ShipToCity
      {
        get
        {
          if(ShipToCity == null) ShipToCity = '';
          return ShipToCity;
        }
        set {ShipToCity = value;}
      }
      public String ShipToState
      {
        get
        {
          if(ShipToState == null) ShipToState = '';
          return ShipToState;
        }
        set {ShipToState = value;}
      }
      public String ShipToZip
      {
        get
        {
          if(ShipToZip == null) ShipToZip = '';
          return ShipToZip;
        }
        set {ShipToZip = value;}
      }
      public String DivisionCode
      {
        get
        {
          if(DivisionCode == null) DivisionCode = '';
          return DivisionCode;
        }
        set {DivisionCode = value;}
      }
      public String SystemCode
      {
        get
        {
          if(SystemCode == null) SystemCode = '';
          return SystemCode;
        }
        set {SystemCode = value;}
      }
      public Date RequestedDeliveryDate
      {
        get
        {
          if(RequestedDeliveryDate == null) RequestedDeliveryDate = Date.newInstance(1901, 1, 1);
          return RequestedDeliveryDate;
        }
        set {RequestedDeliveryDate = value;}
      }
      public String ShipmentMethod
      {
        get
        {
          if(ShipmentMethod == null) ShipmentMethod = '';
          return ShipmentMethod;
        }
        set {ShipmentMethod = value;}
      }
      public String CustomerComments
      {
        get
        {
          if(CustomerComments == null) CustomerComments = '';
          return CustomerComments;
        }
        set {CustomerComments = value;}
      }
      public Double TotalPrice
      {
        get
        {
          if(TotalPrice == null) TotalPrice = 0;
          return TotalPrice;
        }
        set {TotalPrice = value;}
      }
      
      public String PoNumber
      {
        get
        {
          if(PoNumber == null) PoNumber = '';
          return PoNumber;
        }
        set {PoNumber = value;}
      }
    }

    public class DetailClass
    {
      public Double Quantity
      {
        get
        {
          if(Quantity == null) Quantity = 0;
          return Quantity;
        }
        set {Quantity = value;}
      }
      public String QuantityUOM
      {
        get
        {
          if(QuantityUOM == null) QuantityUOM = '';
          return QuantityUOM;
        }
        set {QuantityUOM = value;}
      }
      public Date ProjectedDeliveryDate
      {
        get
        {
          if(ProjectedDeliveryDate == null) ProjectedDeliveryDate = Date.newInstance(1901, 1, 1);
          return ProjectedDeliveryDate;
        }
        set {ProjectedDeliveryDate = value;}
      }
      public String ProductCode
      {
        get
        {
          if(ProductCode == null) ProductCode = '';
          return ProductCode;
        }
        set {ProductCode = value;}
      }
      public String ProductDescription
      {
        get
        {
          if(ProductDescription == null) ProductDescription = '';
          return ProductDescription;
        }
        set {ProductDescription = value;}
      }
      public Double UnitPrice
      {
        get
        {
          if(UnitPrice == null) UnitPrice = 0;
          return UnitPrice;
        }
        set {UnitPrice = value;}
      }
      public Double UnitCost
      {
        get
        {
          if(UnitCost == null) UnitCost = 0;
          return UnitCost;
        }
        set {UnitCost = value;}
      }
      public String UnitPriceUOM
      {
        get
        {
          if(UnitPriceUOM == null) UnitPriceUOM = '';
          return UnitPriceUOM;
        }
        set {UnitPriceUOM = value;}
      }
      public String BidNumber
      {
        get
        {
          if(BidNumber == null) BidNumber = '';
          return BidNumber;
        }
        set {BidNumber = value;}
      }
    }
    //Properties
    public RequestClass Request
    {
        get
        {
            if(Request == null) Request = new RequestClass();
            return Request;
        }
        set
        {
            Request = value;
        }
    }

    public ResponseClass Response
    {
        get
        {
            if(Response == null) Response = new ResponseClass();
            return Response;
        }
        set
        {
            Response = value;
        }
    }
    //Methods
    public virtual void postData()
    {
        //Clear previous response
        Response = new ResponseClass();
        
        Http h = new Http();
        
        HttpRequest req = new HttpRequest();
        //Get URL from custom object
        String endPoint = '';
        try
        {
          endPoint = [select URL__c from WebService__c where Type__c = 'OrderRequest'].URL__c;
        }
        catch(QueryException qe)
        {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The URL for the Order Request web service has not been configured in the WebService object.'));
          return;
        }
        req.setEndpoint(endPoint);
        System.debug('endPoint='+endPoint);
        req.setBody(prepareXML());
        System.debug('Order Request XML='+prepareXML());
        req.setMethod('POST');
        
        HttpResponse res = null;
        XmlStreamReader xsr = null;
        
        try
        {  
            res = h.send(req);
            xsr = new XmlStreamReader(res.getBody());
            System.debug('Order Response XML=' + res.getBody());
        }
        catch(Exception e)
        {
            Response.StatusMessage = e.getMessage();
            return;
        }
        
        serializeXML(xsr);
    }
    
    private String prepareXML()
    {
      String returnXML = '<?xml version="1.0" encoding="UTF-8"?>\n';
      //  returnXML += '<!DOCTYPE cXML SYSTEM "http://xml.cXML.org/schemas/cXML/1.2.009/cXML.dtd">\n';
        returnXML += '<cXML payloadID="' + replaceIllegalChars(Request.Header.QuoteNum) + '" timestamp="' + System.now().format('yyyy-MM-dd HH:mm:ssZ') + '" xml:lang="en-US">\n';
        returnXML += '  <Header>\n';
        returnXML += '    <From>\n';
        returnXML += '      <Credential domain="">\n';
        returnXML += '        <Identity/>\n';
        returnXML += '      </Credential>\n';
        returnXML += '    </From>\n';
        returnXML += '    <To>\n';
        returnXML += '      <Credential domain="">\n';
        returnXML += '        <Identity>' + replaceIllegalChars(Request.Header.SystemCode) + '</Identity>\n';
        returnXML += '      </Credential>\n';
        returnXML += '    </To>\n';
        returnXML += '    <Sender>\n';
        returnXML += '      <Credential domain="">\n';
        returnXML += '        <Identity/>\n';
        returnXML += '      </Credential>\n';
        returnXML += '      <UserAgent/>\n';
        returnXML += '    </Sender>\n';
        returnXML += '  </Header>\n';
        returnXML += '  <Request>\n';
        returnXML += '    <OrderRequest>\n';
        returnXML += '      <OrderRequestHeader orderID="' + replaceIllegalChars(Request.Header.QuoteNum) + '" orderDate="' + System.now().format('yyyy-MM-dd') + '" agreementPayloadID="' + replaceIllegalChars(Request.Header.PoNumber) + '">\n';
        returnXML += '        <Total>\n';
        returnXML += '          <Money currency="USD">' + Request.Header.TotalPrice + '</Money>\n';
        returnXML += '        </Total>\n';
        returnXML += '        <ShipTo>\n';
        returnXML += '          <Address addressID="' + replaceIllegalChars(Request.Header.BillToCode + Request.Header.ShipToCode) + '">\n';
        returnXML += '            <Name xml:lang="en-US">' + replaceIllegalChars(Request.Header.ShipToName) + '</Name>\n';
        returnXML += '            <PostalAddress>\n';
        returnXML += '              <DeliverTo>' + replaceIllegalChars(Request.Header.CustomerContactName) + '</DeliverTo>\n';
        returnXML += '              <Street>' + replaceIllegalChars(Request.Header.ShipToStreet) + '</Street>\n';
        returnXML += '              <City>' + replaceIllegalChars(Request.Header.ShipToCity) + '</City>\n';
        returnXML += '              <State>' + replaceIllegalChars(Request.Header.ShipToState) + '</State>\n';
        returnXML += '              <PostalCode>' + replaceIllegalChars(Request.Header.ShipToZip) + '</PostalCode>\n';
        returnXML += '              <Country isoCountryCode="US">United States</Country>\n';
        returnXML += '            </PostalAddress>\n';
        returnXML += '          </Address>\n';
        returnXML += '        </ShipTo>\n';
        returnXML += '        <BillTo>\n';
        returnXML += '          <Address addressID="' + replaceIllegalChars(Request.Header.DivisionCode + Request.Header.BillToCode + Request.Header.ShipToCode) + '">\n';
        returnXML += '            <Name xml:lang="en-US">' + replaceIllegalChars(Request.Header.BillToName) + '</Name>\n';
        returnXML += '          </Address>\n';
        returnXML += '        </BillTo>\n';
        returnXML += '        <Comments xml:lang="en-US">' + replaceIllegalChars(Request.Header.CustomerComments) + '</Comments>\n';
        Datetime reqDelDate = Datetime.newInstance(Request.Header.RequestedDeliveryDate.year(), Request.Header.RequestedDeliveryDate.month(), Request.Header.RequestedDeliveryDate.day());
        returnXML += '        <Extrinsic name="RequestedDeliveryDate">' + reqDelDate.format('yyyy-MM-dd') + '</Extrinsic>\n';
        returnXML += '        <Extrinsic name="ShipmentMethod">' + replaceIllegalChars(Request.Header.ShipmentMethod) + '</Extrinsic>\n';
        returnXML += '      </OrderRequestHeader>\n';
        Integer counter = 0;
        for(DetailClass Detail : Request.Details)
        {
          Datetime projDelDate = Datetime.newInstance(Detail.ProjectedDeliveryDate.year(), Detail.ProjectedDeliveryDate.month(), Detail.ProjectedDeliveryDate.day());
          counter++;
          returnXML += '      <ItemOut quantity="' + Detail.Quantity + '" lineNumber="' + counter + '" requestedDeliveryDate="' + projDelDate.format('yyyy-MM-dd') + '">\n';
          returnXML += '        <ItemID>\n';
          returnXML += '          <SupplierPartID>' + replaceIllegalChars(Detail.ProductCode) + '</SupplierPartID>\n';
          returnXML += '        </ItemID>\n';
          returnXML += '        <ItemDetail>\n';
          returnXML += '          <UnitPrice>\n';
          returnXML += '            <Money currency="USD">' + Detail.UnitPrice + '</Money>\n';
          returnXML += '          </UnitPrice>\n';
          returnXML += '          <Description xml:lang="en-US">' + replaceIllegalChars(Detail.ProductDescription) + '</Description>\n';
          returnXML += '          <UnitOfMeasure>' + replaceIllegalChars(Detail.UnitPriceUOM) + '</UnitOfMeasure>\n';
          returnXML += '          <Classification domain="">' + replaceIllegalChars(Detail.BidNumber) + '</Classification>\n';
          returnXML += '          <Extrinsic name="QuantityUOM">' + replaceIllegalChars(Detail.QuantityUOM) + '</Extrinsic>\n';
          returnXML += '          <Extrinsic name="unitCost">' + Detail.UnitCost + '</Extrinsic>\n';
          returnXML += '        </ItemDetail>\n';
          returnXML += '      </ItemOut>\n';
        }
        returnXML += '    </OrderRequest>\n';
        returnXML += '  </Request>\n';
        returnXML += '</cXML>\n';
        
        return returnXML;
    }

    public void serializeXML(XmlStreamReader xsr)
    {
        while(xsr.hasNext())
        {
            if(xsr.isStartElement())
            {
                if(xsr.isStartElement() && xsr.getLocalName() == 'Response')
                    parseResponse(xsr);
            }
            xsr.next();
        }
    }

    public virtual void parseResponse(XmlStreamReader xsr)
    {
        while(xsr.hasNext())
        {
            if(xsr.isEndElement() && xsr.getLocalName() == 'Response')
                break;
            else if(xsr.isStartElement() && xsr.getLocalName() == 'Status')
            {
              Response.StatusCode = xsr.getAttributeValueAt(0);
                xsr.next();
                if(xsr.isCharacters())
                    Response.StatusMessage = xsr.getText().trim();
            }
            xsr.next();
        }
    }
    
    protected String replaceIllegalChars(String inString)
    {
      return inString.replace('&', '&amp;').replace('\'', '&quot;').replace('<', '&lt;').replace('>', '&gt;');
    }
}