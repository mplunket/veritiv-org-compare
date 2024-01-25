var matrixRecords;
var matrix_ErrorToDisplayField = 'Error_To_Display__c';
var matrix_FieldsToBlankField = 'Fields_To_Blank__c';
var matrix_FieldsToGreyField = 'Fields_To_Grey__c';
var matrix_PolicyTypeValueField = 'Policy_Type_Value__c';
var matrix_PriceLevelValueField = 'Price_Level_Value__c';
var matrix_CWTDependentField = 'CWT_Dependent__c';
var matrix_CWTDependentFieldField = 'CWT_Dependent_Field__c';

var currPricingStartDate = '';
var policyTypeValue = priceLevelValue = '';
var currentRow = 0;
var ERROR_SEVERITY = 'Error';
var WARNING_SEVERITY = 'Warning';

var ERROR_INVALID_DATE = 'Pricing start date should be greater than or equal to today ';
var previousError = '';

Ext.onReady(function()
{
	$j = jQuery.noConflict();
	
	Ext.select('.lineItemRow .gtmPercentField').on('change', function() {
		try
		{
			var gtmPercentEl = Ext.get(this);
			preserveDecimals(gtmPercentEl, 1, false);
			calculateValues(gtmPercentEl);
		}
		catch( ex )	{
		}
	});
	Ext.select('.lineItemRow .priceField').on('change', function() {
		try
		{
			var priceEl = Ext.get(this);
			preserveDecimals(priceEl,2);
			calculateValues(priceEl);
		}
		catch( ex )	{
		}
	});
	Ext.select('.lineItemRow .costField').on('change', function() {
		try
		{
			var costEl = Ext.get(this);
			preserveDecimals(costEl,3);
			calculateValues(costEl);
		}
		catch( ex )	{
		}
	});
	Ext.select('.lineItemRow .qtyField').on('change', function() {
		try
		{
			var qtyEl = Ext.get(this);
			preserveDecimals(qtyEl,2);
			calculateExtendedPrice(qtyEl);
		}
		catch( ex )	{
		}
	});
	Ext.select('.extPriceField, .extCostField').on('change', function() {
		try
		{
			var modifiedEl = Ext.get(this);
			calculateGTMPrice(modifiedEl);
		}
		catch( ex )	{
		}
	});

	Ext.select('.gtmPriceField').each(function(el){
		try
		{
			el.dom.innerHTML = convertToCurrency(roundNumber(el.dom.innerHTML,2), true);
		}
		catch( ex )	{
		}
	});
	
	
	Ext.select('.extPriceField').each(function(el){
		try
		{
			loadFieldsValuesOrHtml( el, 2 );
		}
		catch( ex )	{
		}
			
	});

	Ext.select('.extCostField').each(function(el){
		try
		{
			loadFieldsValuesOrHtml( el, 3 );
		}
		catch( ex )	{
		}
		
	});

	Ext.select('.qtyField').each(function(el){
		try
		{
			loadFieldsValuesOrHtml( el, 2 );
		}
		catch( ex )	{
		}
		
	});
	
	Ext.select('.costUpField').on('change', function() {
		try
		{
			var modifiedEl = Ext.get(this); // Cost Up Element
			calculatePriceAndGTM(modifiedEl);
		}
		catch( ex )	{
		}
		
	});
	
	Ext.select('.listDownField').on('change', function() {
		try
		{
			var modifiedEl = Ext.get(this);
			
			if( modifiedEl.dom.value.length > 0 && modifiedEl.dom.value.charAt(modifiedEl.dom.value.length-1)!='%')
			{
				modifiedEl.dom.innerHTML+='%';
				//modifiedEl.dom.value+='%';
			}
		}
		catch( ex )	{
		}
		
	});
	
	// Disable Uneditable Fields
	$j("input[id$=':CWT_Subset_Level_Pricing_Allowed__c']").prop('disabled', true);
	$j("input[id$=':CWT_Set_Level_Pricing_Allowed__c']").prop('disabled', true);
	$j("input[id$=':CWT_Item_Level_Pricing_Allowed__c']").prop('disabled', true);
	$j("input[id$=':Quantity_unit_of_measure__c']").prop('disabled', true);
	$j("input[id$=':Price_unit_of_measure__c']").prop('disabled', true);
	$j("input[id$=':Target_Price__c']").prop('disabled', true);
	$j("input[id$=':Future_Dev_Cost__c']").prop('disabled', true);
	$j("input[id$=':Future_Dev_Cost_Starts__c']").prop('disabled', true);
	$j("input[id$=':Class__c']").prop('disabled', true);
	$j("input[id$=':Brand__c']").prop('disabled', true);
	$j("input[id$=':Subset__c']").prop('disabled', true);
	$j("input[id$=':Set__c']").prop('disabled', true);
	$j("input[id$=':Cost__c']").prop('disabled', true);
	
	if( matrixRecords == undefined)
	{
		getPriceMatrices();
	}
	
});

function loadFieldsValuesOrHtml( el, decimals )
{
		var isText = el.dom.value == null ? true : false;
		
		var tempValue = isText ? el.dom.innerHTML : el.dom.value;
		
		var extcost = tempValue.replace( /[%,]/g, '' );
		
		if( isText )
			el.dom.innerHTML = convertToCurrency(roundNumber(extcost, decimals), true);
		else
			el.dom.value = convertToCurrency(roundNumber(extcost, decimals), true);
}

function calculateValues(modifiedEl)
{
	
	var parentEl = modifiedEl.parent('.lineItemRow');
	var costEl = parentEl.child('.costField');
	var gtmPercentEl = parentEl.child('.gtmPercentField');
	var priceEl = parentEl.child('.priceField');
	
	if( gtmPercentEl == null ) {
		return;
	}

	var gtmVal = gtmPercentEl.getValue().replace( /[%,]/g, '' );
	var costVal = costEl.getValue().replace( /[%,]/g, '' );
	var oldCostVal = costEl.dom.defaultValue;
	var priceVal = priceEl.getValue().replace( /[%,]/g, '' );

	if( !(isNaN(costVal) || isNaN(gtmVal) || costVal == '' || costVal < 0 || gtmVal == '' || oldCostVal <= 0)
		&& (modifiedEl.hasClass('gtmPercentField') || modifiedEl.hasClass('costField')) )
	{
		var divisor = (1-gtmVal/100) == 0 ? 0.0001 : (1-gtmVal/100);

		var price = costVal/divisor;
		priceEl.dom.value = Math.round(price*100)/100;
		preserveDecimals(priceEl,2);
	}
	else if(!(isNaN(costVal) || isNaN(priceVal) || costVal == '' || costVal < 0)
			&& ( modifiedEl.hasClass('priceField') || modifiedEl.hasClass('costField') ) )
	{
		var gtmPercent;
		if(priceVal == 0)
			gtmPercent = 0;
		else
			gtmPercent = Math.round( ( (1 - ( costVal/priceVal ) ) * 100 ) *100 ) / 100;
		gtmPercentEl.dom.value = roundNumber( gtmPercent, 1 );
	}
	
	if( gtmPercentEl.dom.value.length > 0 && gtmPercentEl.dom.value.charAt(gtmPercentEl.dom.value.length-1)!='%')
	   gtmPercentEl.dom.value+='%';
	
	calculateExtendedPrice( modifiedEl );
	renderNegative(gtmPercentEl);
	costEl.dom.defaultValue = costEl.getValue();
	
}

function calculateGTMPrice(modifiedEl)
{
	var parentEl = modifiedEl.parent('.lineParentBody');
	var specialItem = parentEl.child('.specialItemField').getValue();

	if(specialItem) {
		var extPriceEl = parentEl.child('.extPriceField');
		var extCostEl = parentEl.child('.extCostField');
		var gtmPriceEl = parentEl.child('.gtmPriceField');

		var extPriceVal = extPriceEl.getValue().replace(/[^0-9\.]/g,'');
		var extCostVal = extCostEl.getValue().replace(/[^0-9\.]/g,'');

		var newGTMPrice = extPriceVal - extCostVal;
		gtmPriceEl.dom.innerHTML = convertToCurrency(newGTMPrice, true);

		preserveDecimals(extPriceEl, 2);
		preserveDecimals(extCostEl, 3);
	}
}

function preserveDecimals(modifiedEl,decimalPlaces, convertCurrency)
{
	convertCurrency = convertCurrency == null ? true : false;
	
	if( !isNaN(parseFloat( modifiedEl.dom.value )) ) {
		modifiedEl.dom.value = roundNumber( parseFloat( modifiedEl.dom.value.replace( /[%,]/g, '' ) ), decimalPlaces);
		
		if( convertCurrency )
		 modifiedEl.dom.value = convertToCurrency( modifiedEl.dom.value, true);
	}
	
}

function isBlank (value)
{
	return ( value == '' ) || (value == null) || isNaN(value);
}

function isStringBlank (value)
{
	return (value == null) || ( value.trim() == '' )  ;
}

function renderNegative(elementToModify)
{
	if( elementToModify && elementToModify.dom
		&& String(elementToModify.dom.value).match(/^-/g)
		|| elementToModify.dom.value.match( /^0+\.?0*%/g ) ) {
		elementToModify.addClass('negativeValue');
	}
	else {
		elementToModify.removeClass('negativeValue');
	}
}

function calculateExtendedPrice( modifiedEl )
{
	var grandParentEl = modifiedEl.parent('.lineParentBody');
	var extCostEl = grandParentEl.child('.extCostField');

	var parentEl = modifiedEl.parent('.lineItemRow');
	var specialItem = parentEl.child('.specialItemField').getValue() == 'true';

	var priceEl = parentEl.child('.priceField');
	var qtyEl = parentEl.child('.qtyField');
	var costEl = parentEl.child('.costField');
	var extPriceEl = parentEl.child('.extPriceField');
	var extAmountEl = parentEl.child('.extAmountField');
	var gtmPriceEl = parentEl.child('.gtmPriceField');
	var priceFactorEl = parentEl.child('.priceFactorField');
	var qtyFactorEl = parentEl.child('.qtyFactorField');
	var costFactorEl = parentEl.child('.costFactorField');

	var price = priceEl.getValue().replace( /[%,]/g, '' );
	var quantity = qtyEl.getValue().replace( /[%,]/g, '' );
	var cost = costEl.getValue().replace( /[%,]/g, '' );
	var quantityUnitFactor = qtyFactorEl.getValue().replace( /[%,]/g, '' );
	var priceUnitFactor = priceFactorEl.getValue().replace( /[%,]/g, '' );
	var costUnitFactor = costFactorEl.getValue().replace( /[%,]/g, '' );

	if(!isBlank(quantity) && !isBlank(price) && !isBlank(priceUnitFactor) && !isBlank(quantityUnitFactor) && !specialItem) {
		if(priceUnitFactor > 0)
			if(quantityUnitFactor >= 0)
				extPriceEl.dom.innerHTML = (price / priceUnitFactor) * quantityUnitFactor * quantity;
			else
				extPriceEl.dom.innerHTML = ((price / priceUnitFactor) / Math.abs(quantityUnitFactor)) * quantity;
			else
				if(quantityUnitFactor >= 0)
					extPriceEl.dom.innerHTML = price * Math.abs(priceUnitFactor) * quantityUnitFactor * quantity;
				else
					extPriceEl.dom.innerHTML = ((price * Math.abs(priceUnitFactor)) / Math.abs(quantityUnitFactor)) * quantity;

		gtmPriceEl.dom.innerHTML = extPriceEl.dom.innerHTML - extAmountEl.dom.innerHTML;
	}
	else{
		if( !specialItem ) {
			extPriceEl.dom.innerHTML = price * quantity;
			gtmPriceEl.dom.innerHTML = extPriceEl.dom.innerHTML - extAmountEl.dom.innerHTML;
		}
		else {
			extPriceEl.dom.value = price * quantity;
			gtmPriceEl.dom.innerHTML = extPriceEl.dom.value - extCostEl.dom.value;
		}
	}

	if(!isBlank(quantity) && !isBlank(cost) && !isBlank(costUnitFactor) && !isBlank(quantityUnitFactor) && !specialItem) {
		var extendedCost = 0;
		if(costUnitFactor > 0)
			if(quantityUnitFactor >= 0)
				extendedCost = (cost / costUnitFactor) * quantityUnitFactor * quantity;
			else
				extendedCost = ((cost / costUnitFactor) / Math.abs(quantityUnitFactor)) * quantity;
		else
			if(quantityUnitFactor >= 0)
				extendedCost = cost * Math.abs(costUnitFactor) * quantityUnitFactor * quantity;
			else
				extendedCost = ((cost * Math.abs(costUnitFactor)) / Math.abs(quantityUnitFactor)) * quantity;
		extCostEl.dom.innerHTML = extendedCost;

		var extendedPrice = extPriceEl.dom.innerHTML == null? 0: extPriceEl.dom.innerHTML;
		gtmPriceEl.dom.innerHTML = extendedPrice - extendedCost;
	}
	else{
		if( !specialItem ) {
			extCostEl.dom.innerHTML = cost * quantity;
			gtmPriceEl.dom.innerHTML = extPriceEl.dom.innerHTML - extCostEl.dom.innerHTML;
		}
		else {
			extCostEl.dom.value = cost * quantity;
			gtmPriceEl.dom.innerHTML = extPriceEl.dom.value - extCostEl.dom.value;
		}
	}

	
	if( !specialItem ) {
		//Formatting to add commas
		gtmPriceEl.dom.innerHTML = convertToCurrency(roundNumber(gtmPriceEl.dom.innerHTML,2), true);
		extPriceEl.dom.innerHTML = convertToCurrency(roundNumber(extPriceEl.dom.innerHTML,2), true);
		extCostEl.dom.innerHTML = convertToCurrency(roundNumber(extCostEl.dom.innerHTML,3), true);
	}
	else {
		gtmPriceEl.dom.innerHTML = convertToCurrency(roundNumber(gtmPriceEl.dom.innerHTML,2), true);
		extPriceEl.dom.value = convertToCurrency(roundNumber(extPriceEl.dom.value,2), true);
		extCostEl.dom.value = convertToCurrency(roundNumber(extCostEl.dom.value,3), true);
		
	}
	
}

function calculatePriceAndGTM( el )
{
	var parentEl = el.parent('.lineParentBody'); 

	var priceEl = parentEl.child('.priceField'); 
	var gtmPercentEl = parentEl.child('.gtmPercentField'); 
	var costEl = parentEl.child('.costField'); 
		
	var priceVal = priceEl.getValue().replace(/[^0-9\.]/g,'');
	var costVal = costEl.getValue().replace(/[^0-9\.]/g,'');
	var costUpVal = el.getValue().replace(/[^0-9\.]/g,'') / 100;

	var newPrice = costVal * (1 + costUpVal);
	var newGTMPercent = ( 1 - (costVal / newPrice) ) * 100;
	
	var roundedGTM = roundNumber(newGTMPercent, 0); 
	var roundedPrice = roundNumber(newPrice, 3);
	
	gtmPercentEl.dom.value = roundedGTM;
	gtmPercentEl.dom.innerHTML = roundedGTM;
	priceEl.dom.value = convertToCurrency(roundedPrice, true);
	priceEl.dom.innerHTML = convertToCurrency(roundedPrice, true);
	
	if( el.dom.value.length > 0 && el.dom.value.charAt(el.dom.value.length-1)!='%')
		el.dom.innerHTML +='%'; // .value
	
	if( gtmPercentEl.dom.value.length > 0 && gtmPercentEl.dom.value.charAt(gtmPercentEl.dom.value.length-1)!='%')
		gtmPercentEl.dom.value +='%'; // .value -> Because of fields being read based on Pricing Matrices containg %
}

function addCommasToNumber(num)
{
	//ensure that num has more that 3 digits
	var currSplit = num.split('.');
	var dollars = '';
	dollars = currSplit[0];
	var negative = false;

	//Is this a negative number?
	if(dollars.charAt(0) == '-')
	negative = true;

	if(negative)
		dollars = dollars.substring(1, dollars.length);

	var charCounter = 0;
	var commaSeparatedDollars = '';
	var dollarsToDisplay = '';

	//Need 1000 or more to add commas
	if(dollars.length > 3) {
		while(charCounter < dollars.length) {
			if(charCounter % 3 == 0 && charCounter > 0)
				commaSeparatedDollars = ',' + commaSeparatedDollars;

			commaSeparatedDollars = dollars.charAt(dollars.length - (charCounter + 1)) + commaSeparatedDollars;

			charCounter++;
		}

		if(commaSeparatedDollars != '')
			dollarsToDisplay = commaSeparatedDollars;
	}
	else
		return num;

	if(dollarsToDisplay != '') {
		if(negative)
			dollarsToDisplay = '-' + dollarsToDisplay;
		num = dollarsToDisplay;
	}

	if ( currSplit[1] != null)
		return num + '.' + currSplit[1];
	else
		return num;
}

function convertToCurrency(num, addCommas)
{
	num = num + '';
	var toDisplay = '';

	//Find the location on the '.'
	if(num.lastIndexOf(".") == num.length-2 && num.length > 1) {
		//Corrected from 0 to .0
		toDisplay = '0';
	}
	else if(num.lastIndexOf(".") == -1)
		toDisplay = '.00';

	if(addCommas) {
		num = addCommasToNumber(num);
	}

	return num+toDisplay;
}

function roundNumber(number,decimals)
{
	
	//WHAT: function pulled online to round numbers properly using strings
	//WHERE: http://www.mediacollege.com/internet/java_script/number/round.html
	//WHY: number.toFixed(int) isn't reliable enough to use here.  This function has passed all tests
	var newString;// The new rounded number
	var negative;
	decimals = Number(decimals);
	
	if (decimals < 1) {
		newString = (Math.round(number)).toString();
	} else {
		var numString = number.toString();
		
		if(numString.charAt(0) == '-')
		{
			numString = numString.substring(1, numString.length);
			negative = true;
		}
		
		if (numString.lastIndexOf(".") == -1) {// If there is no decimal point
			numString += ".";// give it one at the end
		}
		var decplaces = numString.lastIndexOf(".");
		var cutoff = numString.lastIndexOf(".") + decimals;// The point at which to truncate the number
		var d1 = Number(numString.substring(cutoff,cutoff+1));// The value of the last decimal place that we'll end up with
		var d2 = Number(numString.substring(cutoff+1,cutoff+2));// The next decimal, after the last one we want
		
		if (d2 >= 5) {// Do we need to round up at all? If not, the string will just be truncated
			if (d1 == 9 && cutoff > 0) {// If the last digit is 9, find a new cutoff point
				while (cutoff > 0 && (d1 == 9 || isNaN(d1))) {
					if (d1 != ".") {
						cutoff -= 1;
						d1 = Number(numString.substring(cutoff,cutoff+1));
					} else {
						cutoff -= 1;
					}
				}
			}
			d1 += 1;
		}
		if (d1 == 10) {
			numString = numString.substring(0, numString.lastIndexOf("."));
			var roundedNum = Number(numString) + 1;
			newString = roundedNum.toString() + '.';
		} else {
			newString = numString.substring(0,cutoff) + d1.toString();
			var appendHowManyZeroes = decplaces-cutoff-1;
			for(var k = 0; k < appendHowManyZeroes; k++)
				{
					newString+='0';
				}
			
		}
	}
		
	if (newString.lastIndexOf(".") == -1) {// Do this again, to the new string
		newString += ".";
	}
	var decs = (newString.substring(newString.lastIndexOf(".")+1)).length;

	var i = 0;
	while (i < (decimals-decs)) {
		newString += "0";
		i++;
	}

	if(negative)
	{
		var justZeros = true;
		for(var k = 0; k < newString.length; k++)
		{
			var char = newString.charAt(k);
			justZeros = justZeros && (char==='.' || char==='0');
		}
		
		//If the number is just zero, then don't have negative zero.
		if(!justZeros)
			newString = '-' + newString;
	}
	
	if(	newString.charAt(newString.length-1) == '.') {
		newString = newString.substring(0,newString.length-1);
	}	
	return newString;
}

function parsePicklist(fields)
{
	var listOfItems = [];
	var initialSize;
	
	if(fields == null || fields == undefined || fields.length == 0)
	{
		return listOfItems;
	}
	
	listOfItems = fields.split(';');
	
	var tempSet = new Set();
	for(var i = 0; i < listOfItems.length; i++)
	{
		tempSet.add( listOfItems[i] );
	}

	return tempSet; 
}

function validatePricingStartDate(rowNumber)
{
	// Date captured from the UI
	currPricingStartDate = $j("input[id$='"+rowNumber+":Pricing_Start_Date__c']").val();
	
	// Gets current date.
	currentDate = new Date(Date.now());
	
	var currRowNumber = rowNumber;
	var error = '';
	
	try
	{
		startDate = new Date( currPricingStartDate.valueOf() );
		
		if( !isStringBlank(currPricingStartDate) )
		{
			if ( currentDate.setHours(0, 0, 0, 0) > startDate.setHours(0, 0, 0, 0) ) 
			{
				error = ERROR_INVALID_DATE + 'on Line Item ' + (++currRowNumber) + '.';
				//addToPageMessage(ERROR_SEVERITY, error, rowNumber, true);
			}
			else
			{
				//addToPageMessage(ERROR_SEVERITY, '', rowNumber, true);
			}
		}
	}
	catch( ex )
	{
		error = ex;
	}
	
	return error;

}

function updateCurrentQLI(rowNumber)
{
	currentRow = rowNumber;
}

function updatePriceLevelValue(rowNumber) //targetId
{
	var target = rowNumber + ":idPriceLevelValue"; 
	var targetPTV = rowNumber + ":idPolicyTypeValue";
	policyTypeValue = $j("select[id$='"+targetPTV+"']").val();
	priceLevelValue = $j("select[id$='"+target+"']").val();
	currentRow = rowNumber;
	
	$j("select[id$='"+target+"']").attr('disabled', true); 
	updatePricingUI(priceLevelValue, policyTypeValue, rowNumber);
}

function updatePolicyTypeValue(rowNumber) 
{
	var target = rowNumber + ":idPolicyTypeValue";
	var targetPLV = rowNumber + ":idPriceLevelValue";
	policyTypeValue = $j("select[id$='"+target+"']").val();
	priceLevelValue = $j("select[id$='"+targetPLV+"']").val();
	currentRow = rowNumber;
	
	$j("select[id$='"+target+"']").attr('disabled', true); 
	updatePricingUI(priceLevelValue, policyTypeValue, rowNumber);
}

function removeFields(priceLevelValue, rowNumber)
{
	if(priceLevelValue == '--None--')
	{
		$j("span[id$='" + rowNumber + ":Text_Product_Code__c']").css('visibility', 'visible');
		$j("input[id$='" + rowNumber + ":Brand__c']").css('visibility', 'visible');
		$j("input[id$='" + rowNumber + ":Set__c']").css('visibility', 'visible');
		$j("input[id$='" + rowNumber + ":Subset__c']").css('visibility', 'visible');
		return;
	}
	
	if(priceLevelValue.toUpperCase() == 'Item'.toUpperCase())
	{
		// No Changes
	}
	else if(priceLevelValue.toUpperCase() == 'Class'.toUpperCase())
	{
		$j("span[id$='" + rowNumber + ":Text_Product_Code__c']").css('visibility', 'hidden');
		$j("input[id$='" + rowNumber + ":Brand__c']").css('visibility', 'hidden');
		$j("input[id$='" + rowNumber + ":Set__c']").css('visibility', 'hidden');
		$j("input[id$='" + rowNumber + ":Subset__c']").css('visibility', 'hidden');
	}
	else if(priceLevelValue.toUpperCase() == 'Brand'.toUpperCase())
	{
		$j("span[id$='" + rowNumber + ":Text_Product_Code__c']").css('visibility', 'hidden');
		$j("input[id$='" + rowNumber + ":Set__c']").css('visibility', 'hidden');
		$j("input[id$='" + rowNumber + ":Subset__c']").css('visibility', 'hidden');
	}
	else if(priceLevelValue.toUpperCase() == 'Set'.toUpperCase())
	{
		$j("span[id$='" + rowNumber + ":Text_Product_Code__c']").css('visibility', 'hidden');
		$j("input[id$='" + rowNumber + ":Subset__c']").css('visibility', 'hidden');
	}
	else if(priceLevelValue.toUpperCase() == 'Subset'.toUpperCase())
	{
		$j("span[id$='" + rowNumber + ":Text_Product_Code__c']").css('visibility', 'hidden');
	}
	
}

function cleanseFields(rowNumber)
{
	// Remove disabled. -> Except from output only fields.
	$j('*').filter(":disabled").filter("[id*='" + rowNumber + ":']")
		   .not("input[id$=':CWT_Subset_Level_Pricing_Allowed__c']")
		   .not("input[id$=':CWT_Set_Level_Pricing_Allowed__c']")
		   .not("input[id$=':CWT_Item_Level_Pricing_Allowed__c']")
		   .not("input[id$=':Target_Price__c']")
		   .not("input[id$=':Quantity_unit_of_measure__c']")
		   .not("input[id$=':Price_unit_of_measure__c']")
		   .not("input[id$=':Future_Dev_Cost__c']")
		   .not("input[id$=':Future_Dev_Cost_Starts__c']")
		   .not("input[id$=':Class__c']")
		   .not("input[id$=':Brand__c']")
		   .not("input[id$=':Subset__c']")
		   .not("input[id$=':Set__c']")
		   .not("input[id$=':Cost__c']")
		   .not("select[id$=':idPolicyTypeValue']")
		   .not("select[id$=':idPriceLevelValue']")
		   .removeAttr('disabled');
	
	// Resetting Visibility on Inputs.
	$j('*').filter("input[id*='" + rowNumber + ":']")
	   .css('visibility', 'visible');
	
	// Resetting Visibility on Text. (Product Code).
	$j("span[id$='" + rowNumber + ":Text_Product_Code__c']")
		.css('visibility', 'visible');
	
}

function getPriceMatrices()
{
	var matrices = new RemoteObjectModel.Matrix();
	matrices.retrieve( { limit: 100 }, function(err, records) {
		
		var matrixErrors = '';
		
		if( err ) 
		{
			matrixErrors = matrixErrors + 'Something wrong with getting the Price Matrix records. Contact your Salesforce Admin and DO NOT Update Pricing.';
		}
		else if( records.length == 0 )
		{
			matrixErrors = matrixErrors + 'There are no Price Matrix records, please contact your Salesforce Admin.';
		}
		else
		{
			this.matrixRecords = records;
		}
		
		if(isStringBlank(matrixErrors))
		{
			addToPageMessage(ERROR_SEVERITY, matrixErrors, 0, true);
		}
	});
}

function resetPricingUI()
{
	var target = currentRow + ":idPolicyTypeValue";
	var targetPLV = currentRow + ":idPriceLevelValue";
	//$j("select[id$='"+target+"']").attr('Value', '--None--');
	//$j("select[id$='"+targetPLV+"']").val('--None--');
	
	$j("select[id$='"+targetPLV+"']")[0].selectedIndex = 0;
	$j("select[id$='"+target+"']")[0].selectedIndex = 0;
	
	updatePricingUI('--None--', '--None--', currentRow);
	$j("select[id$='"+target+"']").attr('disabled', false);
	$j("select[id$='"+targetPLV+"']").attr('disabled', false);
	
	$j("input[id$='" + currentRow + ":Cost_Up_Percent__c']").val(0);
	$j("input[id$='" + currentRow + ":List_Down_Percent__c']").val(0);
	
	val = $j("input[id$='" + currentRow + ":Id']").attr('value'); 
	
	var requeriedQLIs = new RemoteObjectModel.QLIs();
	var productId;
	requeriedQLIs.retrieve( {where: {Id: {eq: val} }, limit: 1 }, function(err, records) {
		if(err)
		{
			console.debug('Found Error in getting QLI records: ' + err);
		}
		else if(records.length == 0)
		{
			console.debug('No records returned.');
		}
		else
		{
			var price = records[0].get('Price__c'); 
			var quo = records[0].get('Quantity_unit_of_measure__c'); 
			var puo = records[0].get('Price_unit_of_measure__c'); 
			var productCode = records[0].get('Product_Code__c'); 
			var gtm = records[0].get('GTM_percent__c');
			var pricingStartDate = records[0].get('Pricing_Start_Date__c');
			productId = records[0].get('Product__c'); 
			
			$j("input[id$='" + currentRow + ":Price__c']").val(price);
			$j("input[id$='" + currentRow + ":Quantity_unit_of_measure__c']").val(quo);
			$j("input[id$='" + currentRow + ":Price_unit_of_measure__c']").val(puo);
			$j("input[id$='" + currentRow + ":GTM_percent__c']").val(gtm + '%');
			$j("input[id$='" + currentRow + ":Product_Code__c']").val(productCode);
			$j("input[id$='" + currentRow + ":Pricing_Start_Date__c']").val(pricingStartDate);
			
			if( productId )
			{
				var requeriedProducts = new RemoteObjectModel.Prods();
				requeriedProducts.retrieve( {where: {Id: {eq: productId} }, limit: 1 }, function(err, records) {
				if(err)
				{
					console.debug('Found Error in getting Prod records: ' + err);
				}
				else if(records.length == 0)
				{
					console.debug('No records returned.');
				}
				else
				{
					var prodSet = records[0].get('Set__c'); 
					var prodSubset = records[0].get('Subset__c'); 
					var prodClass = records[0].get('Class__c'); 
					var prodBrand = records[0].get('Brand__c'); 
					
					$j("input[id$='" + currentRow + ":Set__c']").val(prodSet);
					$j("input[id$='" + currentRow + ":Subset__c']").val(prodSubset);
					$j("input[id$='" + currentRow + ":Class__c']").val(prodClass);
					$j("input[id$='" + currentRow + ":Brand__c']").val(prodBrand);
				}
				});
			}
		}
	});
	
}

function updatePricingUI_ExistingValues()
{
	updatePricingUI(priceLevelValue, policyTypeValue, currentRow);
	//validatePricingStartDate(currentRow);
}

function updatePricingUI(plv, ptv, targetRow)
{
	var recordsLength = Object.keys(matrixRecords).length;
	
	cleanseFields(targetRow);
	removeFields(plv, targetRow);
	
	if( !isStringBlank(plv) && !isStringBlank(ptv) )
	{
		var displayError = '';
		var dependencyError = '';
		var dateError = '';
		
		for(i = 0; i < recordsLength; i++)
		{
			if(matrixRecords[i].get(matrix_PriceLevelValueField) == plv && matrixRecords[i].get(matrix_PolicyTypeValueField) == ptv)
			{
				var cwtDependency = false;
				var allowDependency = true;
				
				// Handle CWT Dependent field
				if( matrixRecords[i].get(matrix_CWTDependentField) != undefined && matrixRecords[i].get(matrix_CWTDependentField) != null)
				{
					cwtDependency = matrixRecords[i].get(matrix_CWTDependentField);
				}
				
				// Handle CWT Dependent Field field
				if( matrixRecords[i].get(matrix_CWTDependentFieldField) != undefined && matrixRecords[i].get(matrix_CWTDependentFieldField) != null)
				{
					// Get product value of thedependentfieldfield from the page using javascript
					if( cwtDependency == true )
					{
						var field = matrixRecords[i].get(matrix_CWTDependentFieldField);

						allowDependency = $j("input[id$='" + targetRow + ":" + field + "']").is(':checked');
					}
				}
				
				// Errors to dislplay -> addToPageMessage
				if( matrixRecords[i].get(matrix_ErrorToDisplayField) != undefined && matrixRecords[i].get(matrix_ErrorToDisplayField) != null)
				{
					var qliNum = parseInt(targetRow) + 1;
					var error = matrixRecords[i].get(matrix_ErrorToDisplayField) + ' on Line Item ' + qliNum + '.';
					
					if( (cwtDependency == false) || (cwtDependency == true && allowDependency == false) )
					{
						//addToPageMessage(ERROR_SEVERITY, error, targetRow, true );
						dependencyError = error;
					}
				}
				
				dateError = validatePricingStartDate(targetRow);
				
				if(	!isStringBlank(dependencyError) && !isStringBlank(dateError) )
				{
					displayError = dependencyError + ' <br /> ' + dateError;
				}
				else if( !isStringBlank(dependencyError) && isStringBlank(dateError) )
				{
					displayError = dependencyError;
				}
				else if( isStringBlank(dependencyError) && !isStringBlank(dateError) )
				{
					displayError = dateError;
				}
				else if( isStringBlank(dependencyError) && isStringBlank(dateError) )
				{
					
				}
				
				if( !isStringBlank(displayError) )
				{
					addToPageMessage(ERROR_SEVERITY, displayError, targetRow, true ); 
				}
				else
				{
					resetPageErrors(targetRow);
				}
				
				// greyed out -> disabled || greyed out -> readonly
				if( matrixRecords[i].get(matrix_FieldsToGreyField) != undefined && matrixRecords[i].get(matrix_FieldsToGreyField) != null)
				{
					parsePicklist( matrixRecords[i].get(matrix_FieldsToGreyField) ).forEach( function(item) {
							$j("input[id$='"+ targetRow + ":" + item + "']").prop('disabled', true);
					});
					
				}
	
				// blank out -> value = ''
				if( matrixRecords[i].get(matrix_FieldsToBlankField) != undefined && matrixRecords[i].get(matrix_FieldsToBlankField) != null)
				{
					parsePicklist( matrixRecords[i].get(matrix_FieldsToBlankField) ).forEach( function( item ) {
						
						$j("input[id$='" + targetRow + ":" + item + "']").val('');
						
						//$j("span[id$='" + targetRow + ":" + item + "']").val('');
						
						if( item == 'Cost_Up_Percent__c' || item == 'List_Down_Percent__c')
						{
							$j("input[id$='" + targetRow + ":" + item + "']").val('0');
						}
						
					});
					
				}
				
				break;
			}
		}
	}
	else
	{
		return;
	}
}