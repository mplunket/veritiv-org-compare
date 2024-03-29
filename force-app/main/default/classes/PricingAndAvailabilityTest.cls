@isTest
public class PricingAndAvailabilityTest {

    
    public static testmethod void testPricingAndAvailabilityClasses()
    {
        //Set up data
        PricingAndAvailability.AvailabilityClass testAC = new PricingAndAvailability.AvailabilityClass();
        testAC.ItemDivisionId = '01';
        testAC.ItemIncrement = 'A';
        testAC.ItemMinimumPurchase = 'B';
        testAC.ItemPriceType = 'C';
        testAC.ItemQuantityOnhand = 'D';
        testAC.ItemStockingUOM = 'E';
        testAC.ItemSystemId = 'MA';
        testAC.ItemTransferCutoffTime = 'F';
        testAC.ItemTransferDays = 'G';

         PricingAndAvailability.AvailabilityDescriptionsClass testADC = new  PricingAndAvailability.AvailabilityDescriptionsClass();
        testADC.CertType = 'A';
        testADC.ItemDescription = 'B';
        testADC.ItemStatus = 'C';
        testADC.Line = 'D';
        testADC.ParentID = 'E';
        testADC.RecordID = 'F';

         PricingAndAvailability.ErrorsClass testEC = new  PricingAndAvailability.ErrorsClass();
        testEC.code = 'A';
        testEC.description = 'B';
        testEC.name = 'C';

         PricingAndAvailability.ItemDetailsClass testIDC = new  PricingAndAvailability.ItemDetailsClass();
        testIDC.ItemCostStandard = 'A';
        testIDC.ItemPricePerUOM = 'B';
        testIDC.ItemPricingUOM = 'C';
        testIDC.ItemQuantity = 'D';
        testIDC.ItemQuantityUOM = 'E';
        testIDC.ItemCostCode = 'F';
        testIDC.ItemPriceCode = 'G';

         PricingAndAvailability.PriceBreaksClass testPBC = new  PricingAndAvailability.PriceBreaksClass();
        testPBC.DisplayBreakPrice = 'A';
        testPBC.DisplayBreakQuantity = 'B';
        testPBC.PriceBracket = 'C';
        testPBC.SystemBreakQuantity = 'D';

         PricingAndAvailability.TaxInformationClass testTIC = new  PricingAndAvailability.TaxInformationClass();
        testTIC.ItemTaxable = 'A';
        testTIC.ItemTaxRate = 'B';

          PricingAndAvailability.UnitsOfMeasureClass testUOMC = new   PricingAndAvailability.UnitsOfMeasureClass();
        testUOMC.ParentID = 'A';
        testUOMC.RecordID = 'B';
        testUOMC.UOMDescription = 'C';
        testUOMC.UOMDisplayForPriceOrQuantity = 'D';
        testUOMC.UOMFactor = 'E';
        testUOMC.UOMIsCustomerDefaultForPrice = 'F';
        testUOMC.UOMIsCustomerDefaultForQuantity = 'G';
        testUOMC.UOMIsItemDefaultForPrice = 'H';
        testUOMC.UOMIsItemDefaultForQuantity = 'I';
        testUOMC.UOMName = 'J';
        //Start test
        Test.startTest();

        PricingAndAvailability testPaa = new PricingAndAvailability();
        
        PricingAndAvailability.RequestClass testReq =  new PricingAndAvailability.RequestClass();
        System.assertNotEquals(null, testReq);
        testReq.SystemIdentifier = 'D01TESTSW';
        testReq.DivisionID = '20';
        testReq.CustomerID = '200800';
        testReq.ShipToID = '000001';
        testReq.CIFItemID = '10033390';
        testReq.Quantity = '5000';
        testReq.QuantityUOM = '1';
        testReq.PricingUOM = '1';
        testPaa.Request = testReq;
        System.assertEquals(testReq, testPaa.Request);
        System.assertEquals('Salesforce', testPaa.Request.Computer);
        System.assertEquals(UserInfo.getUserName(), testPaa.Request.WebServiceUser);
        System.assertEquals('D01TESTSW', testPaa.Request.SystemIdentifier);
        System.assertEquals('20', testPaa.Request.DivisionID);
        System.assertEquals('200800', testPaa.Request.CustomerID);
        System.assertEquals('000001', testPaa.Request.ShipToID);
        System.assertEquals('10033390', testPaa.Request.CIFItemID);
        System.assertEquals('5000', testPaa.Request.Quantity);
        System.assertEquals('1', testPaa.Request.QuantityUOM);
        System.assertEquals('1', testPaa.Request.PricingUOM);
        
        PricingAndAvailability.ResponseClass testRes = new PricingAndAvailability.ResponseClass();
        System.assertNotEquals(null, testRes);
        testPaa.Response = testRes;
        System.assertEquals(testRes, testPaa.Response);
        
        
        PricingAndAvailability.AvailabilityClass[] testACs = testPaa.Response.Availability;
        System.assertNotEquals(null, testACs);
        testACs.add(testAc);
        testPaa.Response.Availability = testACs;
        System.assertEquals(testACs, testPaa.Response.Availability);
        System.assertEquals('01', testPaa.Response.Availability[0].ItemDivisionId);
        System.assertEquals('A', testPaa.Response.Availability[0].ItemIncrement);
        System.assertEquals('B', testPaa.Response.Availability[0].ItemMinimumPurchase);
        System.assertEquals('C', testPaa.Response.Availability[0].ItemPriceType);
        System.assertEquals('D', testPaa.Response.Availability[0].ItemQuantityOnhand);
        System.assertEquals('E', testPaa.Response.Availability[0].ItemStockingUOM);
        System.assertEquals('MA', testPaa.Response.Availability[0].ItemSystemId);
        System.assertEquals('F', testPaa.Response.Availability[0].ItemTransferCutoffTime);
        System.assertEquals('G', testPaa.Response.Availability[0].ItemTransferDays);
        
        PricingAndAvailability.AvailabilityDescriptionsClass[] testADCs = testPaa.Response.AvailabilityDescriptions;
        System.assertNotEquals(null, testADCs);
        testADCs.add(testADC);
        testPaa.Response.AvailabilityDescriptions = testADCs;
        System.assertEquals(testADCs, testPaa.Response.AvailabilityDescriptions);
        System.assertEquals('A', testPaa.Response.AvailabilityDescriptions[0].CertType);
        System.assertEquals('B', testPaa.Response.AvailabilityDescriptions[0].ItemDescription);
        System.assertEquals('C', testPaa.Response.AvailabilityDescriptions[0].ItemStatus);
        System.assertEquals('D', testPaa.Response.AvailabilityDescriptions[0].Line);
        System.assertEquals('E', testPaa.Response.AvailabilityDescriptions[0].ParentID);
        System.assertEquals('F', testPaa.Response.AvailabilityDescriptions[0].RecordID);
        
        PricingAndAvailability.ErrorsClass[] testECs = testPaa.Response.Errors;
        System.assertNotEquals(null, testECs);
        testECs.add(testEC);
        testPaa.Response.Errors = testECs;
        System.assertEquals(testECs, testPaa.Response.Errors);
        System.assertEquals('A', testPaa.Response.Errors[0].code);
        System.assertEquals('B', testPaa.Response.Errors[0].description);
        System.assertEquals('C', testPaa.Response.Errors[0].name);
        
        PricingAndAvailability.ItemDetailsClass[] testIDCs = testPaa.Response.ItemDetails;
        System.assertNotEquals(null, testIDCs);
        testIDCs.add(testIDC);
        testPaa.Response.ItemDetails = testIDCs;
        System.assertEquals(testIDCs, testPaa.Response.ItemDetails);
        System.assertEquals('A', testPaa.Response.ItemDetails[0].ItemCostStandard);
        System.assertEquals('B', testPaa.Response.ItemDetails[0].ItemPricePerUOM);
        System.assertEquals('C', testPaa.Response.ItemDetails[0].ItemPricingUOM);
        System.assertEquals('D', testPaa.Response.ItemDetails[0].ItemQuantity);
        System.assertEquals('E', testPaa.Response.ItemDetails[0].ItemQuantityUOM);
        System.assertEquals('F', testPaa.Response.ItemDetails[0].ItemCostCode);
        System.assertEquals('G', testPaa.Response.ItemDetails[0].ItemPriceCode);
        
        PricingAndAvailability.PriceBreaksClass[] testPBCs = testPaa.Response.PriceBreaks;
        System.assertNotEquals(null, testPBCs);
        testPBCs.add(testPBC);
        testPaa.Response.PriceBreaks = testPBCs;
        System.assertEquals(testPBCs, testPaa.Response.PriceBreaks);
        System.assertEquals('A', testPaa.Response.PriceBreaks[0].DisplayBreakPrice);
        System.assertEquals('B', testPaa.Response.PriceBreaks[0].DisplayBreakQuantity);
        System.assertEquals('C', testPaa.Response.PriceBreaks[0].PriceBracket);
        System.assertEquals('D', testPaa.Response.PriceBreaks[0].SystemBreakQuantity);
        
        PricingAndAvailability.TaxInformationClass[] testTICs = testPaa.Response.TaxInformation;
        System.assertNotEquals(null, testTICs);
        testTICs.add(testTIC);
        testPaa.Response.TaxInformation = testTICs;
        System.assertEquals(testTICs, testPaa.Response.TaxInformation);
        System.assertEquals('A', testPaa.Response.TaxInformation[0].ItemTaxable);
        System.assertEquals('B', testPaa.Response.TaxInformation[0].ItemTaxRate);
        
        PricingAndAvailability.UnitsOfMeasureClass[] testUOMCs = testPaa.Response.UnitsOfMeasure;
        System.assertNotEquals(null, testUOMCs);
        testUOMCs.add(testUOMC);
        testPaa.Response.UnitsOfMeasure = testUOMCs;
        System.assertEquals(testUOMCs, testPaa.Response.UnitsOfMeasure);
        System.assertEquals('A', testPaa.Response.UnitsOfMeasure[0].ParentID);
        System.assertEquals('B', testPaa.Response.UnitsOfMeasure[0].RecordID);
        System.assertEquals('C', testPaa.Response.UnitsOfMeasure[0].UOMDescription);
        System.assertEquals('D', testPaa.Response.UnitsOfMeasure[0].UOMDisplayForPriceOrQuantity);
        System.assertEquals('E', testPaa.Response.UnitsOfMeasure[0].UOMFactor);
        System.assertEquals('F', testPaa.Response.UnitsOfMeasure[0].UOMIsCustomerDefaultForPrice);
        System.assertEquals('G', testPaa.Response.UnitsOfMeasure[0].UOMIsCustomerDefaultForQuantity);
        System.assertEquals('H', testPaa.Response.UnitsOfMeasure[0].UOMIsItemDefaultForPrice);
        System.assertEquals('I', testPaa.Response.UnitsOfMeasure[0].UOMIsItemDefaultForQuantity);
        System.assertEquals('J', testPaa.Response.UnitsOfMeasure[0].UOMName);
        
        Test.stopTest();
    }

    public static testmethod void testGetData()
    {
        //Start test
        Test.startTest();
 
        PricingAndAvailability testPaa = new PricingAndAvailability();
        
        testPaa.Request.SystemIdentifier = 'D01TESTSW';
        testPaa.Request.DivisionID = '20';
        testPaa.Request.CustomerID = '200800';
        testPaa.Request.ShipToID = '000001';
        testPaa.Request.CIFItemID = '10033390';
        testPaa.Request.Quantity = '5000';
        testPaa.Request.QuantityUOM = '1';
        testPaa.Request.PricingUOM = '1';
        
        testPaa.getData();
        
        Test.stopTest();
    }
    
    public static testmethod void testSerializeAndParseXML()
    {
        String xmlString = '<?xml version="1.0" encoding="UTF-8"?>';
        xmlString += '<PricingAndAvailability>';
        xmlString += '<UnitsOfMeasure>';
        xmlString += '<RecordID>1</RecordID>';
        xmlString += '<ParentID>0</ParentID>';
        xmlString += '<UOM.Name>SH</UOM.Name>';
        xmlString += '<UOM.Description>Sheet </UOM.Description>';
        xmlString += '<UOM.Factor> 1.0000</UOM.Factor>';
        xmlString += '<UOM.IsCustomerDefaultForQuantity>N</UOM.IsCustomerDefaultForQuantity>';
        xmlString += '<UOM.IsCustomerDefaultForPrice>N</UOM.IsCustomerDefaultForPrice>';
        xmlString += '<UOM.IsItemDefaultForQuantity>Y</UOM.IsItemDefaultForQuantity>';
        xmlString += '<UOM.IsItemDefaultForPrice>N</UOM.IsItemDefaultForPrice>';
        xmlString += '<UOM.DisplayForPriceOrQuantity>Q</UOM.DisplayForPriceOrQuantity>';
        xmlString += '</UnitsOfMeasure>';
        xmlString += '<UnitsOfMeasure>';
        xmlString += '<RecordID>2</RecordID>';
        xmlString += '<ParentID>0</ParentID>';
        xmlString += '<UOM.Name>HU</UOM.Name>';
        xmlString += '<UOM.Description>Hundred </UOM.Description>';
        xmlString += '<UOM.Factor> 100.0000</UOM.Factor>';
        xmlString += '<UOM.IsCustomerDefaultForQuantity>N</UOM.IsCustomerDefaultForQuantity>';
        xmlString += '<UOM.IsCustomerDefaultForPrice>N</UOM.IsCustomerDefaultForPrice>';
        xmlString += '<UOM.IsItemDefaultForQuantity>N</UOM.IsItemDefaultForQuantity>';
        xmlString += '<UOM.IsItemDefaultForPrice>N</UOM.IsItemDefaultForPrice>';
        xmlString += '<UOM.DisplayForPriceOrQuantity>P</UOM.DisplayForPriceOrQuantity>';
        xmlString += '</UnitsOfMeasure>';
        xmlString += '<UnitsOfMeasure>';
        xmlString += '<RecordID>3</RecordID>';
        xmlString += '<ParentID>0</ParentID>';
        xmlString += '<UOM.Name>CT</UOM.Name>';
        xmlString += '<UOM.Description>Carton </UOM.Description>';
        xmlString += '<UOM.Factor> 500.0000</UOM.Factor>';
        xmlString += '<UOM.IsCustomerDefaultForQuantity>N</UOM.IsCustomerDefaultForQuantity>';
        xmlString += '<UOM.IsCustomerDefaultForPrice>N</UOM.IsCustomerDefaultForPrice>';
        xmlString += '<UOM.IsItemDefaultForQuantity>N</UOM.IsItemDefaultForQuantity>';
        xmlString += '<UOM.IsItemDefaultForPrice>N</UOM.IsItemDefaultForPrice>';
        xmlString += '<UOM.DisplayForPriceOrQuantity>B</UOM.DisplayForPriceOrQuantity>';
        xmlString += '</UnitsOfMeasure>';
        xmlString += '<UnitsOfMeasure>';
        xmlString += '<RecordID>4</RecordID>';
        xmlString += '<ParentID>0</ParentID>';
        xmlString += '<UOM.Name>CW</UOM.Name>';
        xmlString += '<UOM.Description>Hundred Pounds (CWT) </UOM.Description>';
        xmlString += '<UOM.Factor> 549.4505</UOM.Factor>';
        xmlString += '<UOM.IsCustomerDefaultForQuantity>N</UOM.IsCustomerDefaultForQuantity>';
        xmlString += '<UOM.IsCustomerDefaultForPrice>N</UOM.IsCustomerDefaultForPrice>';
        xmlString += '<UOM.IsItemDefaultForQuantity>N</UOM.IsItemDefaultForQuantity>';
        xmlString += '<UOM.IsItemDefaultForPrice>N</UOM.IsItemDefaultForPrice>';
        xmlString += '<UOM.DisplayForPriceOrQuantity>P</UOM.DisplayForPriceOrQuantity>';
        xmlString += '</UnitsOfMeasure>';
        xmlString += '<UnitsOfMeasure>';
        xmlString += '<RecordID>5</RecordID>';
        xmlString += '<ParentID>0</ParentID>';
        xmlString += '<UOM.Name>M </UOM.Name>';
        xmlString += '<UOM.Description>Thousand </UOM.Description>';
        xmlString += '<UOM.Factor> 1000.0000</UOM.Factor>';
        xmlString += '<UOM.IsCustomerDefaultForQuantity>N</UOM.IsCustomerDefaultForQuantity>';
        xmlString += '<UOM.IsCustomerDefaultForPrice>N</UOM.IsCustomerDefaultForPrice>';
        xmlString += '<UOM.IsItemDefaultForQuantity>N</UOM.IsItemDefaultForQuantity>';
        xmlString += '<UOM.IsItemDefaultForPrice>Y</UOM.IsItemDefaultForPrice>';
        xmlString += '<UOM.DisplayForPriceOrQuantity>P</UOM.DisplayForPriceOrQuantity>';
        xmlString += '</UnitsOfMeasure>';
        xmlString += '<UnitsOfMeasure>';
        xmlString += '<RecordID>6</RecordID>';
        xmlString += '<ParentID>0</ParentID>';
        xmlString += '<UOM.Name>PL</UOM.Name>';
        xmlString += '<UOM.Description>Pallet/Unit Load </UOM.Description>';
        xmlString += '<UOM.Factor> 11000.0000</UOM.Factor>';
        xmlString += '<UOM.IsCustomerDefaultForQuantity>N</UOM.IsCustomerDefaultForQuantity>';
        xmlString += '<UOM.IsCustomerDefaultForPrice>N</UOM.IsCustomerDefaultForPrice>';
        xmlString += '<UOM.IsItemDefaultForQuantity>N</UOM.IsItemDefaultForQuantity>';
        xmlString += '<UOM.IsItemDefaultForPrice>N</UOM.IsItemDefaultForPrice>';
        xmlString += '<UOM.DisplayForPriceOrQuantity>N</UOM.DisplayForPriceOrQuantity>';
        xmlString += '</UnitsOfMeasure>';
        xmlString += '<Availability.Descriptions>';
        xmlString += '<RecordID>1</RecordID>';
        xmlString += '<ParentID>1</ParentID>';
        xmlString += '<Line>ED00</Line>';
        xmlString += '<Item.Status>Item Status</Item.Status>';
        xmlString += '<CertType>CertType</CertType>';
        xmlString += '<Item.Description>22 1/2X35 182M 90# BLUE</Item.Description>';
        xmlString += '</Availability.Descriptions>';
        xmlString += '<Availability.Descriptions>';
        xmlString += '<RecordID>2</RecordID>';
        xmlString += '<ParentID>1</ParentID>';
        xmlString += '<Line>ED01</Line>';
        xmlString += '<Item.Status/>';
        xmlString += '<CertType/>';
        xmlString += '<Item.Description>COLORSOURCE SMOOTH INDEX</Item.Description>';
        xmlString += '</Availability.Descriptions>';
        xmlString += '<Availability.Descriptions>';
        xmlString += '<RecordID>3</RecordID>';
        xmlString += '<ParentID>1</ParentID>';
        xmlString += '<Line>ED02</Line>';
        xmlString += '<Item.Status/>';
        xmlString += '<CertType/>';
        xmlString += '<Item.Description>500/CT 99768200</Item.Description>';
        xmlString += '</Availability.Descriptions>';
        xmlString += '<Availability.Descriptions>';
        xmlString += '<RecordID>4</RecordID>';
        xmlString += '<ParentID>2</ParentID>';
        xmlString += '<Line>ED00</Line>';
        xmlString += '<Item.Status/>';
        xmlString += '<CertType/>';
        xmlString += '<Item.Description>22 1/2X35 182M 90# BLUE</Item.Description>';
        xmlString += '</Availability.Descriptions>';
        xmlString += '<Availability.Descriptions>';
        xmlString += '<RecordID>5</RecordID>';
        xmlString += '<ParentID>2</ParentID>';
        xmlString += '<Line>ED01</Line>';
        xmlString += '<Item.Status/>';
        xmlString += '<CertType/>';
        xmlString += '<Item.Description>COLORSOURCE SMOOTH INDEX</Item.Description>';
        xmlString += '</Availability.Descriptions>';
        xmlString += '<Availability.Descriptions>';
        xmlString += '<RecordID>6</RecordID>';
        xmlString += '<ParentID>2</ParentID>';
        xmlString += '<Line>ED02</Line>';
        xmlString += '<Item.Status/>';
        xmlString += '<CertType/>';
        xmlString += '<Item.Description>500/CT 99768200</Item.Description>';
        xmlString += '</Availability.Descriptions>';
        xmlString += '<Availability.Descriptions>';
        xmlString += '<RecordID>7</RecordID>';
        xmlString += '<ParentID>3</ParentID>';
        xmlString += '<Line>ED00</Line>';
        xmlString += '<Item.Status/>';
        xmlString += '<CertType/>';
        xmlString += '<Item.Description>22 1/2X35 182M 90# BLUE</Item.Description>';
        xmlString += '</Availability.Descriptions>';
        xmlString += '<Availability.Descriptions>';
        xmlString += '<RecordID>8</RecordID>';
        xmlString += '<ParentID>3</ParentID>';
        xmlString += '<Line>ED01</Line>';
        xmlString += '<Item.Status/>';
        xmlString += '<CertType/>';
        xmlString += '<Item.Description>COLORSOURCE SMOOTH INDEX</Item.Description>';
        xmlString += '</Availability.Descriptions>';
        xmlString += '<Availability.Descriptions>';
        xmlString += '<RecordID>9</RecordID>';
        xmlString += '<ParentID>3</ParentID>';
        xmlString += '<Line>ED02</Line>';
        xmlString += '<Item.Status/>';
        xmlString += '<CertType/>';
        xmlString += '<Item.Description>500/CT 99768200</Item.Description>';
        xmlString += '</Availability.Descriptions>';
        xmlString += '<Availability>';
        xmlString += '<Item.DivisionId>20</Item.DivisionId>';
        xmlString += '<Item.Increment> 1.00</Item.Increment>';
        xmlString += '<Item.MinimumPurchase> 1.00</Item.MinimumPurchase>';
        xmlString += '<Item.PriceType>Item Price Type</Item.PriceType>';
        xmlString += '<Item.QuantityOnhand> 9700.00</Item.QuantityOnhand>';
        xmlString += '<Item.StockingUOM>SH</Item.StockingUOM>';
        xmlString += '<Item.SystemId>03</Item.SystemId>';
        xmlString += '<Item.TransferCutoffTime>0000</Item.TransferCutoffTime>';
        xmlString += '<Item.TransferDays> 0</Item.TransferDays>';
        xmlString += '</Availability>';
        xmlString += '<Availability>';
        xmlString += '<Item.DivisionId>10</Item.DivisionId>';
        xmlString += '<Item.Increment> 1.00</Item.Increment>';
        xmlString += '<Item.MinimumPurchase> 1.00</Item.MinimumPurchase>';
        xmlString += '<Item.PriceType/>';
        xmlString += '<Item.QuantityOnhand> 0.00</Item.QuantityOnhand>';
        xmlString += '<Item.StockingUOM>SH</Item.StockingUOM>';
        xmlString += '<Item.SystemId>03</Item.SystemId>';
        xmlString += '<Item.TransferCutoffTime>1700</Item.TransferCutoffTime>';
        xmlString += '<Item.TransferDays> 7</Item.TransferDays>';
        xmlString += '</Availability>';
        xmlString += '<Availability>';
        xmlString += '<Item.DivisionId>50</Item.DivisionId>';
        xmlString += '<Item.Increment> 1.00</Item.Increment>';
        xmlString += '<Item.MinimumPurchase> 1.00</Item.MinimumPurchase>';
        xmlString += '<Item.PriceType/>';
        xmlString += '<Item.QuantityOnhand> 0.00</Item.QuantityOnhand>';
        xmlString += '<Item.StockingUOM>SH</Item.StockingUOM>';
        xmlString += '<Item.SystemId>03</Item.SystemId>';
        xmlString += '<Item.TransferCutoffTime>1730</Item.TransferCutoffTime>';
        xmlString += '<Item.TransferDays> 7</Item.TransferDays>';
        xmlString += '</Availability>';
        xmlString += '<PriceBreaks>';
        xmlString += '<PriceBracket>A1</PriceBracket>';
        xmlString += '<SystemBreakQuantity> 500</SystemBreakQuantity>';
        xmlString += '<DisplayBreakPrice> 248.52</DisplayBreakPrice>';
        xmlString += '<DisplayBreakQuantity> 500</DisplayBreakQuantity>';
        xmlString += '</PriceBreaks>';
        xmlString += '<PriceBreaks>';
        xmlString += '<PriceBracket>A2</PriceBracket>';
        xmlString += '<SystemBreakQuantity> 2000</SystemBreakQuantity>';
        xmlString += '<DisplayBreakPrice> 222.49</DisplayBreakPrice>';
        xmlString += '<DisplayBreakQuantity> 2000</DisplayBreakQuantity>';
        xmlString += '</PriceBreaks>';
        xmlString += '<PriceBreaks>';
        xmlString += '<PriceBracket>A3</PriceBracket>';
        xmlString += '<SystemBreakQuantity> 8000</SystemBreakQuantity>';
        xmlString += '<DisplayBreakPrice> 209.48</DisplayBreakPrice>';
        xmlString += '<DisplayBreakQuantity> 8000</DisplayBreakQuantity>';
        xmlString += '</PriceBreaks>';
        xmlString += '<ItemDetails>';
        xmlString += '<Item.PricePerUOM> 222.49</Item.PricePerUOM>';
        xmlString += '<Item.PricingUOM>M </Item.PricingUOM>';
        xmlString += '<Item.Quantity> 5000.00</Item.Quantity>';
        xmlString += '<Item.QuantityUOM>SH</Item.QuantityUOM>';
        xmlString += '<Item.CostStandard> 131.550</Item.CostStandard>';
        xmlString += '</ItemDetails>';
        xmlString += '<TaxInformation>';
        xmlString += '<Item.Taxable>N</Item.Taxable>';
        xmlString += '<Item.TaxRate> 0.00000</Item.TaxRate>';
        xmlString += '</TaxInformation>';
        xmlString += '<Errors>';
        xmlString += '<code>code</code>';
        xmlString += '<description>description</description>';
        xmlString += '<name>name</name>';
        xmlString += '</Errors>';
        xmlString += '<ItemEligibility>';
        xmlString += '<EligibilityFlag>Y</EligibilityFlag>';
        xmlString += '<ExceptionFlag>N</ExceptionFlag>';
        xmlString += '<BusinessGroupFlags></BusinessGroupFlags>';
        xmlString += '</ItemEligibility>';
        xmlString += '</PricingAndAvailability>';
        XmlStreamReader xsr = new XmlStreamReader(xmlString);
        
        Test.startTest();
        
        PricingAndAvailability testPaa = new PricingAndAvailability();
        testPaa.serializeXML(xsr);
        System.assert(testPaa.Response.Availability.size() == 3);
        System.assert(testPaa.Response.AvailabilityDescriptions.size() == 9);
        System.assert(testPaa.Response.Errors.size() == 1);
        System.assert(testPaa.Response.ItemDetails.size() == 1);
        System.assert(testPaa.Response.PriceBreaks.size() == 3);
        System.assert(testPaa.Response.ItemDetails.size() == 1);
        System.assert(testPaa.Response.TaxInformation.size() == 1);
        System.assertEquals(1,testPaa.Response.ItemEligibility.size(), 'We expect the list size to the same');
        
        Test.stopTest();
    }

    public static testmethod PricingAndAvailability testExternalSerializeAndParseXML()
    {
        String xmlString = '<?xml version="1.0" encoding="UTF-8"?>';
        xmlString += '<PricingAndAvailability>';
        xmlString += '<UnitsOfMeasure>';
        xmlString += '<RecordID>1</RecordID>';
        xmlString += '<ParentID>0</ParentID>';
        xmlString += '<UOM.Name>SH</UOM.Name>';
        xmlString += '<UOM.Description>Sheet </UOM.Description>';
        xmlString += '<UOM.Factor> 1.0000</UOM.Factor>';
        xmlString += '<UOM.IsCustomerDefaultForQuantity>N</UOM.IsCustomerDefaultForQuantity>';
        xmlString += '<UOM.IsCustomerDefaultForPrice>N</UOM.IsCustomerDefaultForPrice>';
        xmlString += '<UOM.IsItemDefaultForQuantity>Y</UOM.IsItemDefaultForQuantity>';
        xmlString += '<UOM.IsItemDefaultForPrice>N</UOM.IsItemDefaultForPrice>';
        xmlString += '<UOM.DisplayForPriceOrQuantity>Q</UOM.DisplayForPriceOrQuantity>';
        xmlString += '</UnitsOfMeasure>';
        xmlString += '<UnitsOfMeasure>';
        xmlString += '<RecordID>2</RecordID>';
        xmlString += '<ParentID>0</ParentID>';
        xmlString += '<UOM.Name>HU</UOM.Name>';
        xmlString += '<UOM.Description>Hundred </UOM.Description>';
        xmlString += '<UOM.Factor> 100.0000</UOM.Factor>';
        xmlString += '<UOM.IsCustomerDefaultForQuantity>N</UOM.IsCustomerDefaultForQuantity>';
        xmlString += '<UOM.IsCustomerDefaultForPrice>N</UOM.IsCustomerDefaultForPrice>';
        xmlString += '<UOM.IsItemDefaultForQuantity>N</UOM.IsItemDefaultForQuantity>';
        xmlString += '<UOM.IsItemDefaultForPrice>N</UOM.IsItemDefaultForPrice>';
        xmlString += '<UOM.DisplayForPriceOrQuantity>P</UOM.DisplayForPriceOrQuantity>';
        xmlString += '</UnitsOfMeasure>';
        xmlString += '<UnitsOfMeasure>';
        xmlString += '<RecordID>3</RecordID>';
        xmlString += '<ParentID>0</ParentID>';
        xmlString += '<UOM.Name>CT</UOM.Name>';
        xmlString += '<UOM.Description>Carton </UOM.Description>';
        xmlString += '<UOM.Factor> 500.0000</UOM.Factor>';
        xmlString += '<UOM.IsCustomerDefaultForQuantity>N</UOM.IsCustomerDefaultForQuantity>';
        xmlString += '<UOM.IsCustomerDefaultForPrice>N</UOM.IsCustomerDefaultForPrice>';
        xmlString += '<UOM.IsItemDefaultForQuantity>N</UOM.IsItemDefaultForQuantity>';
        xmlString += '<UOM.IsItemDefaultForPrice>N</UOM.IsItemDefaultForPrice>';
        xmlString += '<UOM.DisplayForPriceOrQuantity>B</UOM.DisplayForPriceOrQuantity>';
        xmlString += '</UnitsOfMeasure>';
        xmlString += '<UnitsOfMeasure>';
        xmlString += '<RecordID>4</RecordID>';
        xmlString += '<ParentID>0</ParentID>';
        xmlString += '<UOM.Name>CW</UOM.Name>';
        xmlString += '<UOM.Description>Hundred Pounds (CWT) </UOM.Description>';
        xmlString += '<UOM.Factor> 549.4505</UOM.Factor>';
        xmlString += '<UOM.IsCustomerDefaultForQuantity>N</UOM.IsCustomerDefaultForQuantity>';
        xmlString += '<UOM.IsCustomerDefaultForPrice>N</UOM.IsCustomerDefaultForPrice>';
        xmlString += '<UOM.IsItemDefaultForQuantity>N</UOM.IsItemDefaultForQuantity>';
        xmlString += '<UOM.IsItemDefaultForPrice>N</UOM.IsItemDefaultForPrice>';
        xmlString += '<UOM.DisplayForPriceOrQuantity>P</UOM.DisplayForPriceOrQuantity>';
        xmlString += '</UnitsOfMeasure>';
        xmlString += '<UnitsOfMeasure>';
        xmlString += '<RecordID>5</RecordID>';
        xmlString += '<ParentID>0</ParentID>';
        xmlString += '<UOM.Name>M </UOM.Name>';
        xmlString += '<UOM.Description>Thousand </UOM.Description>';
        xmlString += '<UOM.Factor> 1000.0000</UOM.Factor>';
        xmlString += '<UOM.IsCustomerDefaultForQuantity>N</UOM.IsCustomerDefaultForQuantity>';
        xmlString += '<UOM.IsCustomerDefaultForPrice>N</UOM.IsCustomerDefaultForPrice>';
        xmlString += '<UOM.IsItemDefaultForQuantity>N</UOM.IsItemDefaultForQuantity>';
        xmlString += '<UOM.IsItemDefaultForPrice>Y</UOM.IsItemDefaultForPrice>';
        xmlString += '<UOM.DisplayForPriceOrQuantity>P</UOM.DisplayForPriceOrQuantity>';
        xmlString += '</UnitsOfMeasure>';
        xmlString += '<UnitsOfMeasure>';
        xmlString += '<RecordID>6</RecordID>';
        xmlString += '<ParentID>0</ParentID>';
        xmlString += '<UOM.Name>PL</UOM.Name>';
        xmlString += '<UOM.Description>Pallet/Unit Load </UOM.Description>';
        xmlString += '<UOM.Factor> 11000.0000</UOM.Factor>';
        xmlString += '<UOM.IsCustomerDefaultForQuantity>N</UOM.IsCustomerDefaultForQuantity>';
        xmlString += '<UOM.IsCustomerDefaultForPrice>N</UOM.IsCustomerDefaultForPrice>';
        xmlString += '<UOM.IsItemDefaultForQuantity>N</UOM.IsItemDefaultForQuantity>';
        xmlString += '<UOM.IsItemDefaultForPrice>N</UOM.IsItemDefaultForPrice>';
        xmlString += '<UOM.DisplayForPriceOrQuantity>N</UOM.DisplayForPriceOrQuantity>';
        xmlString += '</UnitsOfMeasure>';
        xmlString += '<Availability.Descriptions>';
        xmlString += '<RecordID>1</RecordID>';
        xmlString += '<ParentID>1</ParentID>';
        xmlString += '<Line>ED00</Line>';
        xmlString += '<Item.Status>Item Status</Item.Status>';
        xmlString += '<CertType>CertType</CertType>';
        xmlString += '<Item.Description>22 1/2X35 182M 90# BLUE</Item.Description>';
        xmlString += '</Availability.Descriptions>';
        xmlString += '<Availability.Descriptions>';
        xmlString += '<RecordID>2</RecordID>';
        xmlString += '<ParentID>1</ParentID>';
        xmlString += '<Line>ED01</Line>';
        xmlString += '<Item.Status/>';
        xmlString += '<CertType/>';
        xmlString += '<Item.Description>COLORSOURCE SMOOTH INDEX</Item.Description>';
        xmlString += '</Availability.Descriptions>';
        xmlString += '<Availability.Descriptions>';
        xmlString += '<RecordID>3</RecordID>';
        xmlString += '<ParentID>1</ParentID>';
        xmlString += '<Line>ED02</Line>';
        xmlString += '<Item.Status/>';
        xmlString += '<CertType/>';
        xmlString += '<Item.Description>500/CT 99768200</Item.Description>';
        xmlString += '</Availability.Descriptions>';
        xmlString += '<Availability.Descriptions>';
        xmlString += '<RecordID>4</RecordID>';
        xmlString += '<ParentID>2</ParentID>';
        xmlString += '<Line>ED00</Line>';
        xmlString += '<Item.Status/>';
        xmlString += '<CertType/>';
        xmlString += '<Item.Description>22 1/2X35 182M 90# BLUE</Item.Description>';
        xmlString += '</Availability.Descriptions>';
        xmlString += '<Availability.Descriptions>';
        xmlString += '<RecordID>5</RecordID>';
        xmlString += '<ParentID>2</ParentID>';
        xmlString += '<Line>ED01</Line>';
        xmlString += '<Item.Status/>';
        xmlString += '<CertType/>';
        xmlString += '<Item.Description>COLORSOURCE SMOOTH INDEX</Item.Description>';
        xmlString += '</Availability.Descriptions>';
        xmlString += '<Availability.Descriptions>';
        xmlString += '<RecordID>6</RecordID>';
        xmlString += '<ParentID>2</ParentID>';
        xmlString += '<Line>ED02</Line>';
        xmlString += '<Item.Status/>';
        xmlString += '<CertType/>';
        xmlString += '<Item.Description>500/CT 99768200</Item.Description>';
        xmlString += '</Availability.Descriptions>';
        xmlString += '<Availability.Descriptions>';
        xmlString += '<RecordID>7</RecordID>';
        xmlString += '<ParentID>3</ParentID>';
        xmlString += '<Line>ED00</Line>';
        xmlString += '<Item.Status/>';
        xmlString += '<CertType/>';
        xmlString += '<Item.Description>22 1/2X35 182M 90# BLUE</Item.Description>';
        xmlString += '</Availability.Descriptions>';
        xmlString += '<Availability.Descriptions>';
        xmlString += '<RecordID>8</RecordID>';
        xmlString += '<ParentID>3</ParentID>';
        xmlString += '<Line>ED01</Line>';
        xmlString += '<Item.Status/>';
        xmlString += '<CertType/>';
        xmlString += '<Item.Description>COLORSOURCE SMOOTH INDEX</Item.Description>';
        xmlString += '</Availability.Descriptions>';
        xmlString += '<Availability.Descriptions>';
        xmlString += '<RecordID>9</RecordID>';
        xmlString += '<ParentID>3</ParentID>';
        xmlString += '<Line>ED02</Line>';
        xmlString += '<Item.Status/>';
        xmlString += '<CertType/>';
        xmlString += '<Item.Description>500/CT 99768200</Item.Description>';
        xmlString += '</Availability.Descriptions>';
        xmlString += '<Availability>';
        xmlString += '<Item.DivisionId>20</Item.DivisionId>';
        xmlString += '<Item.Increment> 1.00</Item.Increment>';
        xmlString += '<Item.MinimumPurchase> 1.00</Item.MinimumPurchase>';
        xmlString += '<Item.PriceType>Item Price Type</Item.PriceType>';
        xmlString += '<Item.QuantityOnhand> 9700.00</Item.QuantityOnhand>';
        xmlString += '<Item.StockingUOM>SH</Item.StockingUOM>';
        xmlString += '<Item.SystemId>03</Item.SystemId>';
        xmlString += '<Item.TransferCutoffTime>0000</Item.TransferCutoffTime>';
        xmlString += '<Item.TransferDays> 0</Item.TransferDays>';
        xmlString += '</Availability>';
        xmlString += '<Availability>';
        xmlString += '<Item.DivisionId>10</Item.DivisionId>';
        xmlString += '<Item.Increment> 1.00</Item.Increment>';
        xmlString += '<Item.MinimumPurchase> 1.00</Item.MinimumPurchase>';
        xmlString += '<Item.PriceType/>';
        xmlString += '<Item.QuantityOnhand> 0.00</Item.QuantityOnhand>';
        xmlString += '<Item.StockingUOM>SH</Item.StockingUOM>';
        xmlString += '<Item.SystemId>03</Item.SystemId>';
        xmlString += '<Item.TransferCutoffTime>1700</Item.TransferCutoffTime>';
        xmlString += '<Item.TransferDays> 7</Item.TransferDays>';
        xmlString += '</Availability>';
        xmlString += '<Availability>';
        xmlString += '<Item.DivisionId>50</Item.DivisionId>';
        xmlString += '<Item.Increment> 1.00</Item.Increment>';
        xmlString += '<Item.MinimumPurchase> 1.00</Item.MinimumPurchase>';
        xmlString += '<Item.PriceType/>';
        xmlString += '<Item.QuantityOnhand> 0.00</Item.QuantityOnhand>';
        xmlString += '<Item.StockingUOM>SH</Item.StockingUOM>';
        xmlString += '<Item.SystemId>03</Item.SystemId>';
        xmlString += '<Item.TransferCutoffTime>1730</Item.TransferCutoffTime>';
        xmlString += '<Item.TransferDays> 7</Item.TransferDays>';
        xmlString += '</Availability>';
        xmlString += '<PriceBreaks>';
        xmlString += '<PriceBracket>A1</PriceBracket>';
        xmlString += '<SystemBreakQuantity> 500</SystemBreakQuantity>';
        xmlString += '<DisplayBreakPrice> 248.52</DisplayBreakPrice>';
        xmlString += '<DisplayBreakQuantity> 500</DisplayBreakQuantity>';
        xmlString += '</PriceBreaks>';
        xmlString += '<PriceBreaks>';
        xmlString += '<PriceBracket>A2</PriceBracket>';
        xmlString += '<SystemBreakQuantity> 2000</SystemBreakQuantity>';
        xmlString += '<DisplayBreakPrice> 222.49</DisplayBreakPrice>';
        xmlString += '<DisplayBreakQuantity> 2000</DisplayBreakQuantity>';
        xmlString += '</PriceBreaks>';
        xmlString += '<PriceBreaks>';
        xmlString += '<PriceBracket>A3</PriceBracket>';
        xmlString += '<SystemBreakQuantity> 8000</SystemBreakQuantity>';
        xmlString += '<DisplayBreakPrice> 209.48</DisplayBreakPrice>';
        xmlString += '<DisplayBreakQuantity> 8000</DisplayBreakQuantity>';
        xmlString += '</PriceBreaks>';
        xmlString += '<ItemDetails>';
        xmlString += '<Item.PricePerUOM> 222.49</Item.PricePerUOM>';
        xmlString += '<Item.PricingUOM>M </Item.PricingUOM>';
        xmlString += '<Item.Quantity> 5000.00</Item.Quantity>';
        xmlString += '<Item.QuantityUOM>SH</Item.QuantityUOM>';
        xmlString += '<Item.CostStandard> 131.550</Item.CostStandard>';
        xmlString += '<Item.PriceOrigin> Egypt</Item.PriceOrigin>';
        xmlString += '<Item.ContractPriceCode> 1234</Item.ContractPriceCode>';
        xmlString += '<Item.IsNationalAccountsPrice> yes</Item.IsNationalAccountsPrice>';
        xmlString += '<Item.TargetPrice> 10000</Item.TargetPrice>';
        xmlString += '<Item.FloorPrice> 100</Item.FloorPrice>';
        xmlString += '<Item.CustomerItemNumber> 12345</Item.CustomerItemNumber>';
        xmlString += '<Item.RebateGroupDescr> a rebate group</Item.RebateGroupDescr>';
        xmlString += '<Item.DateBegin> 01/01/2012</Item.DateBegin>';
        xmlString += '<Item.DateEnd> 12/12/2012</Item.DateEnd>';
        xmlString += '<Item.FutureDevCost> 500</Item.FutureDevCost>';
        xmlString += '<Item.FutureDevCostEffDate> 04/04/2012</Item.FutureDevCostEffDate>';
        xmlString += '</ItemDetails>';
        xmlString += '<TaxInformation>';
        xmlString += '<Item.Taxable>N</Item.Taxable>';
        xmlString += '<Item.TaxRate> 0.00000</Item.TaxRate>';
        xmlString += '</TaxInformation>';
        xmlString += '<Errors>';
        xmlString += '<code>code</code>';
        xmlString += '<description>description</description>';
        xmlString += '<name>name</name>';
        xmlString += '</Errors>';
        xmlString += '<ItemEligibility>';
        xmlString += '<EligibilityFlag>Y</EligibilityFlag>';
        xmlString += '<ExceptionFlag>N</ExceptionFlag>';
        xmlString += '<BusinessGroupFlags></BusinessGroupFlags>';
        xmlString += '</ItemEligibility>';
        xmlString += '</PricingAndAvailability>';

        XmlStreamReader xsr = new XmlStreamReader(xmlString);
        
        PricingAndAvailability testPaa = new PricingAndAvailability();
        testPaa.serializeXML(xsr);
        System.assert(testPaa.Response.Availability.size() == 3);
        System.assert(testPaa.Response.AvailabilityDescriptions.size() == 9);
        System.assert(testPaa.Response.Errors.size() == 1);
        System.assert(testPaa.Response.ItemDetails.size() == 1);
        System.assert(testPaa.Response.PriceBreaks.size() == 3);
        System.assert(testPaa.Response.TaxInformation.size() == 1);

        System.assertEquals('Egypt', testPaa.Response.ItemDetails[0].PriceOrigin);
        System.assertEquals('1234', testPaa.Response.ItemDetails[0].ContractPriceCode);
        System.assertEquals('10000', testPaa.Response.ItemDetails[0].TargetPrice);
        System.assertEquals('100', testPaa.Response.ItemDetails[0].FloorPrice);
        System.assertEquals('12345', testPaa.Response.ItemDetails[0].CustomerItemNumber);
        System.assertEquals('a rebate group', testPaa.Response.ItemDetails[0].RebateGroupDescr);
        System.assertEquals('01/01/2012', testPaa.Response.ItemDetails[0].DateBegin);
        System.assertEquals('12/12/2012', testPaa.Response.ItemDetails[0].DateEnd);
        System.assertEquals('500', testPaa.Response.ItemDetails[0].FutureDevCost);
        System.assertEquals('04/04/2012', testPaa.Response.ItemDetails[0].FutureDevCostEffDate);

        System.assertEquals('Y', testPaa.Response.ItemEligibility[0].EligibilityFlag);
        System.assertEquals('N', testPaa.Response.ItemEligibility[0].ExceptionFlag);
        
        return testPaa;
    }
}