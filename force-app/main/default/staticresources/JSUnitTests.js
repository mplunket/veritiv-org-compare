module('JS_Unit_Tests', {
	
	setup:  function(assert){
		$j = jQuery.noConflict();  
		
		assertEquals = function (arg0, arg1, arg2){
            assert.equal(arg2, arg1, arg0);
    	}

    	assertTrue = function (arg0, arg1){
    		assert.ok(arg1, arg0);
    	}

    	assertFalse = function (arg0, arg1){
    		assert.ok(!arg1, arg0);
    	}
    	
		//Function that calculates the size of an array
		Object.size = function(obj) {
		    var size = 0, key;
		    for (key in obj) {
		        if (obj.hasOwnProperty(key)) size++;
		    }
		    return size;
		};
		
		this.stringContains = function ( haystack, needle ){
			return haystack.indexOf( needle ) > -1;
		};
		
		/*
    	JSTestUtils.mock('Unisource.', function( callback ){
    		alert('Skip'); //callback('');
    	}); 
    	*/
		
		setEquals = function(setA, setB) {
			var areEqual = true;
			
			if(setA.size == setB.size)
			{
				for(item in setA)
				{
					if(!setB.has(item))
					{
						areEqual = false;
						break;
					}
				}
			}
			else
			{
				areEqual = false;
			}
			
			if( !areEqual )
			{
				console.log('SetA: ' + setA);
				console.log('SetB: ' + setB);
			}
			
			return areEqual;
		}
		
		// Sets up the Remote Object Model PriceMatrix object.
    	var testMatrices = new RemoteObjectModel.Matrix();
    	matrixRecords, policyTypeValue, priceLevelValue;
    	someTextValue = 'someValue';
    	/*var matrix_ErrorToDisplayField = 'Error_To_Display__c';
    	var matrix_FieldsToBlankField = 'Fields_To_Blank__c';
    	var matrix_FieldsToGreyField = 'Fields_To_Grey__c';
    	var matrix_PolicyTypeValueField = 'Policy_Type_Value__c';
    	var matrix_PriceLevelValueField = 'Price_Level_Value__c';
    	var matrix_CWTDependentField = 'CWT_Dependent__c';
    	var matrix_CWTDependentFieldField = 'CWT_Dependent_Field__c';*/
		
		mockPage = function(rowNumber) {
			$j('<input id="' + rowNumber + ':Price__c" class="" value="someValue"> someElement content </input>').appendTo('#qunit-fixture');
			$j('<input id="' + rowNumber + ':Cost__c" class="" value="someValue"> someElement content </input>').appendTo('#qunit-fixture');
			$j('<input id="' + rowNumber + ':GTM_percent__c" class="" value="someValue"> someElement content </input>').appendTo('#qunit-fixture');
			$j('<input id="' + rowNumber + ':Cost_Up_Percent__c" class="" value="someValue"> someElement content </input>').appendTo('#qunit-fixture');
			$j('<input id="' + rowNumber + ':List_Down_Percent__c" class="" value="someValue"> someElement content </input>').appendTo('#qunit-fixture');
			
			$j('<input id="' + rowNumber + ':QtyUOM__c" class="" value="someValue"> someElement content </input>').appendTo('#qunit-fixture');
			$j('<input id="' + rowNumber + ':Price_UOM__c" class="" value="someValue"> someElement content </input>').appendTo('#qunit-fixture');
			
			$j('<input id="' + rowNumber + ':CWT_Item_Level_Pricing_Allowed__c" class="" value="someValue"> someElement content </input>').appendTo('#qunit-fixture');
			$j('<input id="' + rowNumber + ':CWT_Item_Level_Pricing_Allowed__c" class="" value="someValue"> someElement content </input>').appendTo('#qunit-fixture');
			
			$j('<input id="' + rowNumber + ':Grade_Name_Class__c" class="" value="someValue"> someElement content </input>').appendTo('#qunit-fixture');
			$j('<input id="' + rowNumber + ':Brand__c" class="" value="someValue"> someElement content </input>').appendTo('#qunit-fixture');
			$j('<input id="' + rowNumber + ':Set__c" class="" value="someValue"> someElement content </input>').appendTo('#qunit-fixture');
			$j('<input id="' + rowNumber + ':Subset__c" class="" value="someValue"> someElement content </input>').appendTo('#qunit-fixture');
			
			$j('<input id="' + rowNumber + ':Target_Price__c" class="" value="someValue"> someElement content </input>').appendTo('#qunit-fixture');
			$j('<input id="' + rowNumber + ':Future_Dev_Cost__c" class="" value="someValue"> someElement content </input>').appendTo('#qunit-fixture');
			$j('<input id="' + rowNumber + ':Future_Dev_Cost_Starts__c" class="" value="someValue"> someElement content </input>').appendTo('#qunit-fixture');
		}
		
		/*
		var mockRecordObject = {
				
				Id : index,
				CWT_Dependent__c : someTextValue,
				CWT_Dependent_Field__c : someTextValue,
				Error_To_Display__c : someTextValue,
				Fields_To_Blank__c : someTextValue,
				Fields_To_Grey__c : someTextValue,
				Policy_Type_Value__c : someTextValue,
				Price_Level_Value__c : someTextValue,
				
				get : function(field) {
					if(field == 'CWT_Dependent__c')
						return CWT_Dependent__c;
					else if (field == 'CWT_Dependent_Field__c')
						return CWT_Dependent_Field__c;
					else if (field == 'Error_To_Display__c')
						return Error_To_Display__c;
					else if (field == 'Fields_To_Blank__c')
						return Fields_To_Blank__c;
					else if (field == 'Fields_To_Grey__c')
						return Fields_To_Grey__c;
					else if (field == 'Policy_Type_Value__c')
						return Policy_Type_Value__c;
					else if (field == 'Price_Level_Value__c')
						return Price_Level_Value__c;
				}
				
		};
		/////////////////////////////
		
		
		function mockRecordObject() {
			
			var Id, CWT_Dependend__c, CWT_Dependent_Field__c, Error_To_Display__c, Fields_To_Blank__c, Fields_To_Blank__c, Fields_To_Grey__c, Policy_Type_Value__c, Price_Level_Value__c;
			
			this.get = function(field) {
				return this[field];
			}
			
			/*
			 if(field == 'CWT_Dependent__c')
					return CWT_Dependent__c;
				else if (field == 'CWT_Dependent_Field__c')
					return CWT_Dependent_Field__c;
				else if (field == 'Error_To_Display__c')
					return Error_To_Display__c;
				else if (field == 'Fields_To_Blank__c')
					return Fields_To_Blank__c;
				else if (field == 'Fields_To_Grey__c')
					return Fields_To_Grey__c;
				else if (field == 'Policy_Type_Value__c')
					return Policy_Type_Value__c;
				else if (field == 'Price_Level_Value__c')
					return Price_Level_Value__c;
				
		};
		*/
		///////////////////////////
		
    	setupMockRecords = function(numOfRecords) {
    		var mockRecords = [];
    		
    		for(index = 0; index < numOfRecords; index++)
    		{
    			//mockRecords.push( new mockRecordObject() );
    			/*
    			mockRecords.push({
    				Id : index,
    				CWT_Dependent__c : someTextValue,
    				CWT_Dependent_Field__c : someTextValue,
    				Error_To_Display__c : someTextValue,
    				Fields_To_Blank__c : someTextValue,
    				Fields_To_Grey__c : someTextValue,
    				Policy_Type_Value__c : someTextValue,
    				Price_Level_Value__c : someTextValue,
    				Length : function(){ return 1; }
    			});
    			*/
    			
    			var matRec = new RemoteObjectModel.Matrix();
    			matRec.set('Id', 'a1O324jdkal343f');
    			//matRec.CWT_Dependent__c = someTextValue;
				//CWT_Dependent_Field__c : someTextValue,
				//Error_To_Display__c : someTextValue,
				//Fields_To_Blank__c : someTextValue,
				//Fields_To_Grey__c : someTextValue,
				//Policy_Type_Value__c : someTextValue,
				//Price_Level_Value__c : someTextValue
    			mockRecords.push(matRec);
    		}
    		
    		return mockRecords;
    	};
		
	},
    teardown: function() {
		JSTestUtils.mock.restoreAll();
    }
});

QUnit.test("Test showDropDown", function(){
	expect(4);
	
	var result;
	var anId = 'someIdValue';
	var elemId = 'dropList' + anId;
	
	$j('<span id="' + elemId + '" class="slds-is-closed"> someElement content </span>').appendTo('#qunit-fixture');
	
	result = $j('#' + elemId).hasClass('slds-is-closed');
	assertEquals('We expect the tag to contain the class.', true, result);
	result = $j('#' + elemId).hasClass('slds-is-open');
	assertEquals('We expect the tag to not contain the class.', false, result);
	
	showDropDown(anId);
	
	result = $j('#' + elemId).hasClass('slds-is-open');
	assertEquals('We expect the tag to contain the class.', true, result);
	result = $j('#' + elemId).hasClass('slds-is-closed');
	assertEquals('We expect the tag to not contain the class.', false, result);
});

QUnit.test("Test hideDropDown", function(){
	expect(4);
	
	var result;
	var anId = 'someIdValue';
	var elemId = 'dropList' + anId;
	
	$j('<span id="' + elemId + '" class="slds-is-open"> someElement content </span>').appendTo('#qunit-fixture');
	
	result = $j('#' + elemId).hasClass('slds-is-open');
	assertEquals('We expect the tag to contain the class.', true, result);
	result = $j('#' + elemId).hasClass('slds-is-close');
	assertEquals('We expect the tag to not contain the class.', false, result);
	
	hideDropDown(anId);
	
	result = $j('#' + elemId).hasClass('slds-is-closed');
	assertEquals('We expect the tag to contain the class.', true, result);
	result = $j('#' + elemId).hasClass('slds-is-open');
	assertEquals('We expect the tag to not contain the class.', false, result);
});

QUnit.test("Test parsePicklist 1 Value", function(){
	expect(3);
	
	var result;
	var expectedSize = 1;
	var picklistValue = 'value1';
	var expectedResult = [ 'value1' ];
	
	result = parsePicklist(picklistValue);
	
	var resultSet = new Set(result);
	var expectedSet = new Set(expectedResult);
	
	assertTrue('We expect the result to not be null or undefined.', resultSet != null || resultSet != undefined);
	assertEquals('We expect the result to have the expected size.', expectedSize, resultSet.size);
	assertTrue('We expect the result to match our expected result.', setEquals(expectedSet, resultSet) );
});

QUnit.test("Test parsePicklist 3 Values", function(){
	expect(3);
	
	var result;
	var expectedSize = 3;
	var picklistValue = 'value1;value2;value3';
	var expectedResult = [ 'value1', 'value2', 'value3' ];
	
	result = parsePicklist(picklistValue);
	
	var resultSet = new Set(result);
	var expectedSet = new Set(expectedResult);
	
	assertTrue('We expect the result to not be null or undefined.', resultSet != null || resultSet != undefined);
	assertEquals('We expect the result to have the expected size.', expectedSize, resultSet.size);
	assertTrue('We expect the result to match our expected result.', setEquals(expectedSet, resultSet) );
});

QUnit.test("Test parsePicklist Repeated Values", function(){
	expect(3);
	
	var result;
	var expectedSize = 3;
	var picklistValue = 'value1;value2;value3;value2';
	var expectedResult = [ 'value1', 'value2', 'value3' ];
	
	result = parsePicklist(picklistValue);
	
	var resultSet = new Set(result);
	var expectedSet = new Set(expectedResult);
	
	assertTrue('We expect the result to not be null or undefined.', result != null || result != undefined);
	assertEquals('We expect the result to have the expected size.', expectedSize, result.size);
	assertTrue('We expect the result to match our expected result.', setEquals(expectedSet, resultSet) );
});

QUnit.test("Test isValidString", function(){
	expect(4);
	
	var result;
	var exampleString_Valid = 'This is a Valid String';
	var exampleString_InvalidBlank = '';
	var exampleString_InvalidUndefined = undefined;
	var exampleString_InvalidNull = null;
	var expectedResult = true;
	
	result = isValidString(exampleString_Valid);
	assertEquals('We expect the result to valid.', true, result);
	
	result = isValidString(exampleString_InvalidBlank);
	assertEquals('We expect the result to not be valid.', false, result);
	
	result = isValidString(exampleString_InvalidUndefined);
	assertEquals('We expect the result to not be valid.', false, result);
	
	result = isValidString(exampleString_InvalidNull);
	assertEquals('We expect the result to not be valid.', false, result);
});

QUnit.test("Test getPriceMatrices", function(){
	expect(3);
	
	JSTestUtils.mock('getPriceMatrices', function( ){
		matrixRecords = this.setupMockRecords(3);
	});
	
	assertTrue('We expect the value to be undefined.', matrixRecords == undefined);
	
	getPriceMatrices();
	
	assertFalse('We expect this value to be defined.', matrixRecords == undefined);
	assertEquals('We expect this varaible to contain a certain number of records.', 3, matrixRecords.length);
});

QUnit.test("Test updatePricingUI Single Record", function(){
	expect(10);
	
	var priceLevelValue = 'Brand';
	var policyTypeValue = 'Maintain Margin';
	var targetRow = '0';
	var numOfRecords = 1;
	
	JSTestUtils.mock('getPriceMatrices', function( ){
		//matrixRecords = this.setupMockRecords(1);
		matrixRecords = Object.assign({}, this.setupMockRecords( numOfRecords ));
	});
	
	getPriceMatrices();
	
	// Setup the data based on above plv and ptv
	//matrixRecords = setupMockRecords(1);
	var matrixRec = new RemoteObjectModel.Matrix();
	matrixRec.set('CWT_Dependent__c', null);
	matrixRec.set('CWT_Dependent_Field__c', null);
	matrixRec.set('Error_To_Display__c', null);
	matrixRec.set('Fields_To_Blank__c', 'Price__c; QtyUOM__c; Price_UOM__c');
	matrixRec.set('Fields_To_Grey__c', 'Cost_Up__c;List_Down__c');
	matrixRec.set('Policy_Type_Value__c', policyTypeValue);
	matrixRec.set('Price_Level_Value__c', priceLevelValue);
	
	matrixRecords[0] = matrixRec;
	//matrixRecords[0] = Object.assign({}, matrixRec);
	
	console.log('TEST: ' + matrixRecords.Length + matrixRecords.size );
	console.debug( matrixRecords );
	
	mockPage(targetRow);
	
	// Fields To Blank
	result = $j("input[id='" + targetRow + ":Price__c']").val(); console.log('Result: ' + result);
	assertEquals('We expect the Price__c to contain the correct value.', someTextValue, result);
	result = $j("input[id='" + targetRow + ":QtyUOM__c']").val(); console.log('Result: ' + result);
	assertEquals('We expect the QtyUOM__c to contain the correct value.', someTextValue, result);
	result = $j("input[id='" + targetRow + ":Price_UOM__c']").val(); console.log('Result: ' + result);
	assertEquals('We expect the Price_UOM__c to contain the correct value.', someTextValue, result);
	
	// Fields to Grey
	result = $j("input[id='" + targetRow + ":Cost_Up_Percent__c']").is(":disabled"); console.log('Result: ' + result);
	assertEquals('We expect the Cost_Up_Percent__c to not contain the correct class.', false, result);
	result = $j("input[id='" + targetRow + ":List_Down_Percent__c']").is(":disabled"); console.log('Result: ' + result);
	assertEquals('We expect the List_Down_Percent__c to not contain the correct class.', false, result);
	
	updatePricingUI(priceLevelValue, policyTypeValue, targetRow);
	
	// Fields to Blank
	result = $j("input[id='" + targetRow + ":Price__c']").val();
	assertEquals('We expect the Price__c to contain the correct value.', '', result);
	result = $j("input[id='" + targetRow + ":QtyUOM__c']").val();
	assertEquals('We expect the QtyUOM__c to contain the correct value.', '', result);
	result = $j("input[id='" + targetRow + ":Price_UOM__c']").val();
	assertEquals('We expect the Price_UOM__c to contain the correct value.', '', result);
	
	// Fields to Grey
	result = $j("input[id='" + targetRow + ":Cost_Up_Percent__c']").is('[disabled=disabled]');console.debug($j("input[id='" + targetRow + ":Cost_Up_Percent__c']"));
	assertEquals('We expect the Cost_Up_Percent__c to contain the correct class.', true, result);
	result = $j("input[id='" + targetRow + ":List_Down_Percent__c']").is('[disabled=disabled]');
	assertEquals('We expect the List_Down_Percent__c to contain the correct class.', true, result);
});

/*
QUnit.test("test calulcateBinaryValue binaryExpression", function( ){
	expect(1);
	
	window.fieldValueMap['1'] = '3';
	window.fieldValueMap['2'] = '3';
	window.fieldValueMap['3'] = '4';
	
	this.tableMap['moc'] = '2';
	
	var testFormula = "(moc*12)*('1'+'2'+'3')";
	
	var results = calulcateBinaryValue( this.formulaObject( testFormula), this.tableMap);  
	
	assertEquals('We expect the results value to be match.', 240, results);
});

QUnit.test("test calulcateBinaryValue binaryExpressionRightSide Simple", function( ){
	expect(1);
	
	window.fieldValueMap['1'] = '3';
	window.fieldValueMap['2'] = '3';
	window.fieldValueMap['3'] = '4';
	
	this.tableMap['moc'] = '2';
	
	var testFormula = "(moc*12)*('1')";
	
	var results = calulcateBinaryValue( this.formulaObject( testFormula), this.tableMap);  
	
	assertEquals('We expect the results value to be match.', 72, results);
});

QUnit.test("test calulcateBinaryValue binaryExpressionRightSide Complex", function( ){
	expect(1);
	
	window.fieldValueMap['1'] = '3';
	window.fieldValueMap['2'] = '3';
	window.fieldValueMap['3'] = '4';
	
	this.tableMap['moc'] = '2';
	
	var testFormula = "(moc*12)*(moc)";
	
	var results = calulcateBinaryValue( this.formulaObject( testFormula), this.tableMap);  
	
	assertEquals('We expect the results value to be match.', 48, results);
});

QUnit.test("test calulcateBinaryValue callExpression", function( ){
	expect(1);
	
	window.fieldValueMap['1'] = '10';
	window.fieldValueMap['2'] = '10';
	window.fieldValueMap['3'] = '2';
	window.fieldValueMap['4'] = '8';
	
	this.tableMap['selected'] = true;
	
	var testFormula = "IF(selected==true,(0.05*('1'+'2'+'3'+'4')),0)";
	
	var results = calculateCallExpression( this.formulaObject( testFormula), this.tableMap);  
	
	assertEquals('We expect the results value to be match.', 1.5, results);
});

QUnit.test("test calulcateBinaryValue ComplexCallExpression", function( ){
	expect(1);
	
	window.fieldValueMap['1'] = '10';
	window.fieldValueMap['2'] = '10';
	window.fieldValueMap['3'] = '2';
	window.fieldValueMap['4'] = '8';
	
	this.tableMap['selected'] = true;
	this.tableMap['volume'] = '1000';
	
	var testFormula = "IF(selected==true,IF(volume<1000,1.5,IF(volume<5000,('1'+'2'+'3'+'4'),1)),0)";
	
	var results = calculateCallExpression( this.formulaObject( testFormula), this.tableMap);  
	
	assertEquals('We expect the results value to be match.', 30, results);
});

QUnit.test("test calulcateBinaryValue Multiple ComplexCallExpression", function( ){
	expect(1);
	
	window.fieldValueMap['1'] = '10';
	window.fieldValueMap['2'] = '10';
	window.fieldValueMap['3'] = '2';
	window.fieldValueMap['4'] = '8';
	
	this.tableMap['selected'] = true;
	this.tableMap['volume'] = '1000';
	
	var testFormula = "IF(('1'+'3')<('1'+'2'),IF(volume<('1'+'2'),1.5,IF(volume<5000,('1'+'2'+'3'+'4'),1)),0)";
	
	var results = calculateCallExpression( this.formulaObject( testFormula), this.tableMap);  
	
	assertEquals('We expect the results value to be match.', 30, results);
});

QUnit.test("test calulcateValuesVolume", function( ){
	expect(1);
	
	window.fieldValueMap['1'] = '10';
	window.fieldValueMap['2'] = '10';
	window.fieldValueMap['3'] = '2';
	window.fieldValueMap['4'] = '8';
	
	var testFormula = "(1+2+3+4)";
	
	var results = calculateValues( testFormula, this.tableMap, false);  
	
	assertEquals('We expect the results value to be match.', 30, results);
});

QUnit.test("test calulcateValuesBasicMath", function( ){
	expect(1);
	
	window.fieldValueMap['1'] = '10';
	window.fieldValueMap['2'] = '10';
	window.fieldValueMap['3'] = '2';
	window.fieldValueMap['4'] = '8';
	
	var testFormula = "(1+2+3+4)";
	
	var results = calculateValues( testFormula, this.tableMap, true);  
	
	assertEquals('We expect the results value to be match.', 10, results);
});

QUnit.test("test calulcateValues Multiple ComplexCallExpression", function( ){
	expect(1);
	
	window.fieldValueMap['1'] = '10';
	window.fieldValueMap['2'] = '10';
	window.fieldValueMap['3'] = '2';
	window.fieldValueMap['4'] = '8';
	
	this.tableMap['selected'] = true;
	this.tableMap['volume'] = '1000';
	
	var testFormula = "IF(('1'+'3')<('1'+'2'),IF(volume<('1'+'2'),1.5,IF(volume<5000,('1'+'2'+'3'+'4'),1)),0)";
	
	var results = calculateValues( testFormula, this.tableMap, true	);  
	
	assertEquals('We expect the results value to be match.', 30, results);
});

QUnit.test("test calulcateValues literal", function( ){
	expect(1);
	
	window.fieldValueMap['1'] = '10';
	window.fieldValueMap['2'] = '10';
	window.fieldValueMap['3'] = '2';
	window.fieldValueMap['4'] = '8';
	
	var testFormula = "3";
	
	var results = calculateValues( testFormula, this.tableMap, true	);  
	
	assertEquals('We expect the results value to be match.', 2, results);
});

QUnit.test("test calulcateValues undefined", function( ){
	expect(1);
	
	window.fieldValueMap['1'] = '10';
	window.fieldValueMap['2'] = '10';
	window.fieldValueMap['3'] = undefined;
	window.fieldValueMap['4'] = '8';
	
	var testFormula = "3";
	
	var results = calculateValues( testFormula, this.tableMap, true	);  
	
	assertEquals('We expect the results value to be match.', 0, results);
});


QUnit.test("test calulcateFinalValue literal", function( ){
	expect(1);
	
	var testFormula = "3";
	
	var results = calculateFinalValue( this.formulaObject( testFormula), this.tableMap );  
	
	assertEquals('We expect the results value to be match.', 3, results);
});

*/
