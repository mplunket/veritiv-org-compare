/**
Objective: All the custom logic to operate on Quote & QLI's
Developer: Hiremath, Naveen - Bluewolf
*/
//prevents mixed content message in ie
Ext.BLANK_IMAGE_URL = '/s.gif';
Ext.SSL_SECURE_URL = '/s.gif';

Ext.namespace('Unisource');
Ext.Ajax.timeout = 120000;

function newWindowForPrintableUrl() {
	var targetUrl = document.getElementById('printableViewUrl').value;
	if (targetUrl != null && targetUrl.trim() != '') {
		window.open(targetUrl);
	}
};

var Unisource = (function (window, document, undefined) {

	var searchResultStore, searchResultGrid, searchResultGridCheckBoxGroup, qliStore, qliGrid, qliWriter,
		qliGridCheckBoxGroup, createOrderWindow, isAdditionalPopUpEnabled;



	function calculateRunningTotals() {
		var allQLIs, totalExtendedPrice = totalGTMDollar = 0.0;
		allQLIs = qliStore.getRange();

		for (var i = allQLIs.length - 1; i >= 0; --i) {
			//All Items must be included in the Running Total
			totalExtendedPrice += parseFloat(allQLIs[i].get('qliExtendedPrice'));
			totalGTMDollar += parseFloat(allQLIs[i].get('qliGTMDollar'));
		}
		var totalExtendedPriceValue = totalExtendedPrice.toFixed(2);
		var totalGTMDollarValue = totalGTMDollar.toFixed(2);

		Ext.getCmp('runningTotalPrice').setText(Ext.util.Format.usMoney(totalExtendedPrice));
		Ext.getCmp('runningTotalGTM').setText(Ext.util.Format.usMoney(totalGTMDollar));
	};

	//private
	function updateAllFields(response, qliStore) {
		var jsonData, responseRecords = [], recordToUpdate, qliStoreFields = [];

		jsonData = Ext.util.JSON.decode(response.responseText);

		if (!jsonData.success) {
			return alert('Error: ' + jsonData.message);
		}

		for (var i = jsonData.results.length - 1; i >= 0; --i) {
			responseRecords.push(new qliStore.recordType(jsonData.results[i]));
		}

		//Retain all the fields
		qliStoreFields = qliStore.fields.keys;
		for (var i = 0; i < responseRecords.length; ++i) {

			recordToUpdate = qliStore.getById(responseRecords[i].get('id'));
			recordToUpdate.beginEdit();

			for (var field in qliStoreFields) {
				recordToUpdate.set(qliStoreFields[field], responseRecords[i].get(qliStoreFields[field]));
			}

			recordToUpdate.endEdit();
			qliStore.commitChanges();
		}
		qliGrid.getView().refresh();
	};

	function init() {

		var quoteId = document.getElementById('quoteId').innerHTML;
		var SFDC_CALLOUT_LIMIT = 100;

		// Update Pricing Detail Messages
		var CANNOT_UPDATE_LOCKED_ITEM_UPDATE_PRICING_DETAILS = 'Please deselect locked items before loading into Zilliant.';
		var NO_UPDATE_PRICING_ON_SPECIAL_ITEM = 'Special Line Items are not supported on loading into Zilliant. Please remove the Special Item(s) and try again.';
		var NO_UPDATE_PRICING_CALLOUT_ON_FREIGHT = 'Sundry and Freight Codes cannot be loaded into Zilliant.  Please uncheck those line items and submit only Product Codes.';

		var NO_QLIS_SELECTED = 'Check the box for each appropriate quote line(s), then click this button again.';
		var SAVE_REMINDER = 'Please make sure that you have saved the header information before sending this quote or creating an order.';
		var NO_CALC_ON_SPECIAL_ITEM = 'Special Line Items cannot be calculated with this process. Please remove the Special Item(s) and click \'Calc\' again.';
		var NO_PANDA_ON_SPECIAL_ITEM = 'Special Line Items cannot be sent to Update P&A. Please remove the Special Item(s) and try again.';
		var NO_CALLOUT_ON_FREIGHT = 'Sundry Codes and Freight Codes cannot be sent to Update P&A nor calculated. Please remove the code(s) and try again.';
		var CANNOT_ORDER_LOCKED_ITEM = 'Please deselect locked items before creating an order.';
		var CANNOT_DELETE_LOCKED_ITEM = 'Please deselect locked items before deleting.';
		var CANNOT_UPDATE_LOCKED_ITEM = 'Please deselect locked items before sending to Update P&A.';
		var TOO_MANY_ROWS = 'More than ' + SFDC_CALLOUT_LIMIT + ' lines have been selected, only the first ' + SFDC_CALLOUT_LIMIT + ' will be processed.\n'
			+ ' To process the remaining lines, select only those lines (up to ' + SFDC_CALLOUT_LIMIT + ") and click 'Update P&A'";

		searchResultGridCheckBoxGroup = new Ext.grid.CheckboxSelectionModel({
			header: '<div>&#160;</div>'
		});
		qliGridCheckBoxGroup = new Ext.grid.CheckboxSelectionModel();

		Ext.data.DataProxy.addListener('write', function (proxy, action, result, res, rs) {
			calculateRunningTotals();
		});

		var extendedEditorGridPanel = Ext.extend(Ext.grid.EditorGridPanel, {
			//renderTo: 'quoteLineItems',
			//iconCls: 'silk-grid',
			//frame: true,
			//title: 'Users',
			//height: 300,
			//width: 500,
			//style: 'margin-top: 10px',

			initComponent: function () {

				// typical viewConfig
				this.viewConfig = {
					forceFit: true
				};

				// relay the Store's CRUD events into this grid so these events can be conveniently listened-to in our application-code.
				this.relayEvents(this.store, ['destroy', 'save', 'update']);

				// build toolbars and buttons.
				this.tbar = this.buildTopToolbar();
				this.bbar = this.buildBottomToolbar();

				// super
				extendedEditorGridPanel.superclass.initComponent.call(this);
			},

			/**
			 * buildTopToolbar
			 */
			buildTopToolbar: function () {
				return [{
					text: 'Additional Details',
					handler: this.onAdditionalDetails,
					scope: this
				}, {
					id: 'reloadQLI',
					text: 'Reload',
					handler: this.onReload,
					scope: this
				}, '-', {
					text: 'Add Special Line Item',
					handler: this.onAddSpecial,
					scope: this
				}, {
					text: 'Add Freight',
					menu: [
						{
							text: 'Customer Freight',
							handler: this.onAddfreight,
							scope: this
						},
						{
							text: 'Customer Freight 3rd Party',
							handler: this.onAddfreight,
							scope: this
						},
						{
							text: 'No Freight',
							handler: this.onAddfreight,
							scope: this
						},
						{
							text: 'Split Freight',
							handler: this.onAddfreight,
							scope: this
						},
						{
							text: 'Unisource Freight',
							handler: this.onAddfreight,
							scope: this
						},
						{
							text: 'Unisource Freight 3rd Party',
							handler: this.onAddfreight,
							scope: this
						}
					]
				}, '-', {
					text: 'Clone',
					handler: this.onClone,
					scope: this
				},

				/*
					// 11/29(Krishna Kollu) :
					// The calc button no longer displays, but the onCalc handler is left untouched
					{
					text: 'Calc',
					handler: this.onCalc,
					scope: this
				},*/

				{
					text: 'Delete',
					handler: this.onDelete,
					scope: this
				},/*{
					text: 'Refresh',
					handler: this.onRefresh,
					scope: this
				},*/{
					text: 'Update P &amp A',
					handler: this.onUpdatePA,
					scope: this
				}, '->', /*{
					text: 'Saalfeld Pricing',
					handler: this.onUpdatePricing,
					scope: this
				}, '->', */ /*{
					text: 'Create Order',
					handler: this.onCreateOrder,
					scope: this
				}, */ {
					text: 'Send To',
					menu: [
						{
							text: 'Customer',
							handler: this.onSendToCustomer,
							scope: this
						},
						{
							text: 'Sales Rep',
							handler: this.onSendToSalesRep,
							scope: this
						},
						{
							text: 'Vendor',
							handler: this.onSendToVendor,
							scope: this
						}
					]
				}];
			},

			/**
			 * buildBottomToolbar
			 */
			buildBottomToolbar: function () {
				return ['->', '<b>Running Total(Price):</b>', {
					id: 'runningTotalPrice',
					xtype: 'tbtext',
					name: 'runningTotalPrice',
					text: ''
				}, '-', '<b>Running Total(GTM):</b>', {
						id: 'runningTotalGTM',
						xtype: 'tbtext',
						name: 'runningTotalGTM',
						text: ''
					}];
			},

			/**
			 * onAddSpecial, create a special line item
			 */
			onAddSpecial: function (btn, ev) {
				var specialLineItemData = {
					quoteId: quoteId,
					itemSeq: '',
					qliSpecialItem: true,
					qliSpecialProduct: false,
					qliQty: '1',
					qliProdId: 'null',
					qliProdCode: 'null',
					qliProdDesc: 'null',
					qliUOM: 'null',
					qliPrice: '0',
					qliTargetPrice: '0',
					qliFloorPrice: '0',
					qliPriceUOM: 'null',
					qliPriceCode: 'null',
					qliExtendedPrice: '0',
					qliExtendedCost: '0',
					qliGTMPercent: '0',
					qliVendor: 'null',
					qliComments: 'null',
					qliCommentsDontPrint: 'null',
					qliBid: 'null',
					qliMinMfgQty: 'null',
					qliCost: '0',
					qliProjDel: 'null',
					qliVendorItem: 'null',
					qliMfgTol: 'null',
					qliLDC: 'null',
					qliGTMDollar: '0',
					qliVendorContact: 'null',
					qliUnisourceItem: 'null',
					qliPriceUnitFactor: 'null',
					qliQuantityUnitFactor: 'null',
					qliCostUnitFactor: 'null',
					qliCloned: false,
					qliStockedMfg: 'null',
					qliTypeOfQuote: 'null',
					qliItemOrigin: 'null',
					qliRollSize: 'null',
					qliBrightness: 'null',
					qliColor: 'null',
					qliFinish: 'null',
					qliBrand: 'null',
					qliGradeNameCls: 'null',
					qliBasisWeight: 'null',
					qliOuterDia: 'null',
					qliCore: 'null',
					qliRecContent: '0',
					qliPcwContent: '0',
					qliCocReq: 'null',
					qliCostComm: 'null',
					qliLastDateOrd: 'null',
					qliLocked: false,
					qliFutDevCost: 'null',
					qliItemEligibility: false
				};

				retrieveMaxSequenceValue();

				var currentCount = retrieveMaxSequenceValue();
				specialLineItemData.itemSeq = currentCount + 1;

				var specialQLI = new this.store.recordType(specialLineItemData);
				this.stopEditing(); //stop any current editing

				//add the special line item as first row
				this.store.insert(this.store.getCount(), specialQLI);
			},

			/**
			 * onClone, clones all the selected records
			*/
			onClone: function (btn, ev) {

				var selectedRecords, selectedRecordsCount, itemSeqArr = [], itemSeqHash = {};

				var clonedLineItemData = {
					quoteId: quoteId,
					itemSeq: '',
					qliSpecialItem: false,
					qliSpecialProduct: false,
					qliQty: '0',
					qliProdId: 'null',
					qliProdCode: 'null',
					qliProdDesc: 'null',
					qliUOM: 'null',
					qliPrice: '0',
					qliTargetPrice: '0',
					qliFloorPrice: '0',
					qliPriceUOM: 'null',
					qliPriceCode: 'null',
					qliExtendedPrice: '0',
					qliExtendedCost: '0',
					qliGTMPercent: '0',
					qliVendor: 'null',
					qliComments: 'null',
					qliCommentsDontPrint: 'null',
					qliBid: 'null',
					qliMinMfgQty: 'null',
					qliCost: '0',
					qliProjDel: 'null',
					qliVendorItem: 'null',
					qliMfgTol: 'null',
					qliLDC: 'null',
					qliGTMDollar: '0',
					qliVendorContact: 'null',
					qliUnisourceItem: 'null',
					qliPriceUnitFactor: 'null',
					qliQuantityUnitFactor: 'null',
					qliCostUnitFactor: 'null',
					qliCloned: true,
					qliStockedMfg: 'null',
					qliTypeOfQuote: 'null',
					qliItemOrigin: 'null',
					qliRollSize: 'null',
					qliBrightness: 'null',
					qliColor: 'null',
					qliFinish: 'null',
					qliBrand: 'null',
					qliGradeNameCls: 'null',
					qliBasisWeight: 'null',
					qliOuterDia: 'null',
					qliCore: 'null',
					qliRecContent: '0',
					qliPcwContent: '0',
					qliCocReq: 'null',
					qliCostComm: 'null',
					qliLastDateOrd: 'null',
					qliLocked: false,
					qliFutDevCost: 'null'
				};

				selectedRecords = qliGridCheckBoxGroup.getSelections();
				selectedRecordsCount = selectedRecords.length;

				//No need to proceed when there are no QLI's
				if (selectedRecordsCount === 0) { alert(NO_QLIS_SELECTED); return; };

				var currentItemSeq;
				for (var i = selectedRecordsCount - 1; i >= 0; --i) {
					currentItemSeq = parseInt(selectedRecords[i].get('itemSeq'));
					itemSeqArr.push(currentItemSeq);
					itemSeqHash[currentItemSeq] = selectedRecords[i];
				}
				itemSeqArr.sort(function (a, b) { return a - b });

				//Items must be cloned in their original order
				//for(var i=0; i < selectedRecordsCount; ++i) {
				for (var i = 0, itemSeqCount = itemSeqArr.length; i < itemSeqCount; ++i) {
					var rec, clonedQLI;

					rec = itemSeqHash[itemSeqArr[i]];
					//rec           = selectedRecords[i];

					clonedLineItemData.id = rec.get('id');
					clonedLineItemData.qliCloned = true;
					clonedLineItemData.quoteId = quoteId;
					clonedLineItemData.qliSpecialItem = rec.get('qliSpecialItem');
					clonedLineItemData.qliSpecialProduct = rec.get('qliSpecialProduct');
					clonedLineItemData.qliQty = rec.get('qliQty');
					clonedLineItemData.qliProdId = rec.get('qliProdId');
					clonedLineItemData.qliProdCode = rec.get('qliProdCode');
					clonedLineItemData.qliProdDesc = rec.get('qliProdDesc');
					clonedLineItemData.qliUOM = rec.get('qliUOM');
					clonedLineItemData.qliPrice = rec.get('qliPrice');
					clonedLineItemData.qliPriceUOM = rec.get('qliPriceUOM');
					clonedLineItemData.qliPriceCode = rec.get('qliPriceCode');
					clonedLineItemData.qliExtendedPrice = rec.get('qliExtendedPrice');
					clonedLineItemData.qliExtendedCost = rec.get('qliExtendedCost');
					clonedLineItemData.qliVendor = rec.get('qliVendor');
					clonedLineItemData.qliComments = rec.get('qliComments');
					clonedLineItemData.qliCommentsDontPrint = rec.get('qliCommentsDontPrint');
					clonedLineItemData.qliBid = rec.get('qliBid');
					clonedLineItemData.qliMinMfgQty = rec.get('qliMinMfgQty');
					clonedLineItemData.qliCost = rec.get('qliCost');
					clonedLineItemData.qliProjDel = rec.get('qliProjDel');
					clonedLineItemData.qliVendorItem = rec.get('qliVendorItem');
					clonedLineItemData.qliMfgTol = rec.get('qliMfgTol');
					clonedLineItemData.qliLDC = rec.get('qliLDC');
					clonedLineItemData.qliVendorContact = rec.get('qliVendorContact');
					clonedLineItemData.qliGTMPercent = rec.get('qliGTMPercent');
					// zero out price and cost if selected was locked
					if (rec.get('qliLocked')) {
						clonedLineItemData.qliCost = 0;
						clonedLineItemData.qliPrice = 0;
					}
					//Copy over web center info for special items
					if (rec.get('qliSpecialItem')) {
						clonedLineItemData.qliStockedMfg = rec.get('qliStockedMfg');
						clonedLineItemData.qliTypeOfQuote = rec.get('qliTypeOfQuote');
						clonedLineItemData.qliItemOrigin = rec.get('qliItemOrigin');
						clonedLineItemData.qliRollSize = rec.get('qliRollSize');
						clonedLineItemData.qliBrightness = rec.get('qliBrightness');
						clonedLineItemData.qliColor = rec.get('qliColor');
						clonedLineItemData.qliFinish = rec.get('qliFinish');
						clonedLineItemData.qliBrand = rec.get('qliBrand');
						clonedLineItemData.qliGradeNameCls = rec.get('qliGradeNameCls');
						clonedLineItemData.qliBasisWeight = rec.get('qliBasisWeight');
						clonedLineItemData.qliOuterDia = rec.get('qliOuterDia');
						clonedLineItemData.qliCore = rec.get('qliCore');
						clonedLineItemData.qliRecContent = rec.get('qliRecContent');
						clonedLineItemData.qliPcwContent = rec.get('qliPcwContent');
						clonedLineItemData.qliCocReq = rec.get('qliCocReq');
						clonedLineItemData.qliCostComm = rec.get('qliCostComm');
						clonedLineItemData.qliLastDateOrd = rec.get('qliLastDateOrd');
					}

					var currentCount = retrieveMaxSequenceValue();
					clonedLineItemData.itemSeq = currentCount + 1;

					clonedQLI = new this.store.recordType(clonedLineItemData);
					this.store.insert(this.store.getCount(), clonedQLI);
					this.store.commitChanges();
				}
			},

			/**
			 * onCalc
			*/
			onCalc: function (btn, ev) {

				var selectedRecords, selectedRecordsCount, isCloned, isSpecialItem, isFreight, isQliPriceLessThanCost, qliStore, qliPrice, qliCost, qliIds = [];
				selectedRecords = qliGridCheckBoxGroup.getSelections();
				selectedRecordsCount = selectedRecords.length;

				//No need to proceed when there are no QLI's
				if (selectedRecordsCount === 0) { alert(NO_QLIS_SELECTED); return; }
				else if (selectedRecordsCount > SFDC_CALLOUT_LIMIT) { alert(TOO_MANY_ROWS); }

				isQliPriceLessThanCost = false;
				for (var i = selectedRecordsCount - 1; i >= 0; --i) {
					qliPrice = parseFloat(selectedRecords[i].get('qliPrice'));
					qliCost = parseFloat(selectedRecords[i].get('qliCost'));


					if (qliPrice < qliCost) {
						isQliPriceLessThanCost = true;
						break;
					}

					qliIds.push(selectedRecords[i].get('id'));
					isCloned = selectedRecords[i].get('qliCloned');
					isSpecialItem = selectedRecords[i].get('qliSpecialItem');
					isFreight = selectedRecords[i].get('qliProdCode').search(/FREIGHT/gi) > -1;
					if (isSpecialItem || isFreight) break;
				}

				// Selected QLI's price is less than the cost
				if (isQliPriceLessThanCost) { alert('WARNING: The unit price is less than the cost.'); }

				// Special Line Items do not support calculation
				if (isSpecialItem) { alert(NO_CALC_ON_SPECIAL_ITEM); return; }

				// Freight codes do not support calculation
				if (isFreight) { alert(NO_CALLOUT_ON_FREIGHT); return; }

				// Retain a reference to our store before we lose it in our next callback
				qliStore = this.store;

				btn.disable();

				Ext.Ajax.request({
					url: '/apex/QuoteLineItemsCalc',
					success: function (response) {
						updateAllFields(response, qliStore);
						btn.enable();
					}, failure: function (response) {
						btn.enable();
						alert(response);
					},
					params: {
						'quoteId': quoteId,
						'qliIds': qliIds.toString(),
						'qliCloned': isCloned
					}
				});
			},

			onReload: function (btn, ev) {
				var selectedRecords, selectedRecordsCount, isCloned, qliStore, qliIds = [], itemSeq = [], el;

				el = Ext.getCmp('qliGrid').getGridEl();
				el.mask().hide();

				//This is set before we show the Additional Details pop-up
				//after inserting a Special Line Item
				if (isAdditionalPopUpEnabled) {
					//Newly created item was added to the bottom of the QLI list
					qliGridCheckBoxGroup.selectLastRow();
					isAdditionalPopUpEnabled = false;
				}

				selectedRecords = qliGridCheckBoxGroup.getSelections();
				selectedRecordsCount = selectedRecords.length;

				//No need to proceed when there are no QLI's
				//if(selectedRecordsCount === 0) { alert(NO_QLIS_SELECTED); return; };

				for (var i = 0; i < selectedRecordsCount; ++i) {
					qliIds.push(selectedRecords[i].get('id'));
					itemSeq.push(selectedRecords[i].get('itemSeq'));
				}

				//Retain a reference to our store before we lose it in our next callback
				qliStore = this.store;

				Ext.Ajax.request({
					url: '/apex/QuoteLineItemsReload',
					success: function (response) {
						updateAllFields(response, qliStore);
					}, failure: function (response) {
						alert(response);
					},
					params: {
						'quoteId': quoteId,
						'qliIds': qliIds.toString(),
						'itemSeq': itemSeq.toString(),
					}
				});

				btn.setText('Reload');
			},

			/**
			* onUpdatePA, update Pricing Availabilty for all the QLI's except Special Line Items
			*/
			onUpdatePA: function (btn, ev) {

				var isSpecialItem, isFreight, isLocked, selectedRecords, selectedRecordsCount, qliStore, qliIds = [], itemSeq = [];

				selectedRecords = qliGridCheckBoxGroup.getSelections();
				selectedRecordsCount = selectedRecords.length;

				//No need to proceed when there are no QLI's
				if (selectedRecordsCount === 0) { alert(NO_QLIS_SELECTED); return; }
				else if (selectedRecordsCount > SFDC_CALLOUT_LIMIT) { alert(TOO_MANY_ROWS); }

				//var counter = 1;
				for (var i = selectedRecordsCount - 1; i >= 0; --i) {
					//for(var i=0; i < selectedRecordsCount-1; i++){
					qliIds.push(selectedRecords[i].get('id'));
					itemSeq.push(selectedRecords[i].get('itemSeq'));
					isSpecialItem = selectedRecords[i].get('qliSpecialItem');
					isLocked = selectedRecords[i].get('qliLocked');
					isFreight = selectedRecords[i].get('qliProdCode').search(/FREIGHT/gi) > -1;
					if (isSpecialItem || isFreight || isLocked) break;

					// Added in to limit the P&A call to 10 line items.
					//if(counter == SFDC_CALLOUT_LIMIT) break;
					//counter++;
				}

				// Special Line Items do not support P and A
				if (isSpecialItem) { alert(NO_PANDA_ON_SPECIAL_ITEM); return; }
				// Freight Codes do not support P and A
				if (isFreight) { alert(NO_CALLOUT_ON_FREIGHT); return; }
				// Locked items do not support P and A
				if (isLocked) { alert(CANNOT_UPDATE_LOCKED_ITEM); return; }

				//Retain a reference to our store
				qliStore = this.store;

				btn.disable();

				Ext.Ajax.request({
					url: '/apex/QuoteLineItemsUpdatePA',
					success: function (response) {

						btn.enable();
						updateAllFields(response, qliStore);
						var jsonData = Ext.util.JSON.decode(response.responseText);

						if (jsonData.hasOwnProperty('ineligibleQLIs') && jsonData.ineligibleQLIs.length > 0)
						//if(jsonData.message.toLowerCase().indexOf('is not Eligible'.toLowerCase()) !== -1)
						{

							/*
							{
								hideLineItemsForReload(jsonData.message);
							}
							*/

							hideItemsForIneligibility(jsonData.ineligibleProductCodes);

							var selectedRecords = qliGridCheckBoxGroup.getSelections();
							qliStore.batch = true;
							for (i = selectedRecords.length - 1; i >= 0; i--) {
								var record = selectedRecords[i];
								if (jsonData.ineligibleQLIs.toString().indexOf(record.id) >= 0) {
									if (record.get('qliLocked')) {
										alert(CANNOT_UPDATE_LOCKED_ITEM + ': #' + record.data.itemSeq + ' Product Code:' + record.data.qliProdCode);
										continue;
									}
									qliStore.remove(record);
									qliStore.commitChanges();
								}
							}
							getLineItemsNumber();
						}
						//return;

						// clear all selections
						qliGridCheckBoxGroup.clearSelections();
						// then find any to recheck, if needed
						if (selectedRecordsCount > 10) {
							var qlisToSelect = [], qliIdsSeen = [];
							// first clear out all selections
							// based on the response, find which qlis were modified
							for (var responseIndex = 0; responseIndex < jsonData.results.length; responseIndex++) {
								qliIdsSeen.push(jsonData.results[responseIndex].id);
							}
							// look through all the selected qlis, and find ones that weren't modified
							for (var selectedIndex = 0; selectedIndex < selectedRecords.length; selectedIndex++) {
								if (qliIdsSeen.indexOf(selectedRecords[selectedIndex].get('id')) == -1) {
									qlisToSelect.push(selectedRecords[selectedIndex]);
								}
							}
							//alert('About to select records!');
							// select the qlis that were not modified
							qliGridCheckBoxGroup.selectRecords(qlisToSelect);
						}
					}, failure: function (response) {
						btn.enable();
						alert(response);
					},
					params: {
						'quoteId': quoteId,
						'qliIds': qliIds.toString(),
						'itemSeq': itemSeq.toString()
					}
				});

			},

			/**
			* onDelete, handles single/multiple records
			*/
			onDelete: function (btn, ev) {

				var selectedRecords, selectedCount;

				//Make this delete a batch operation
				this.store.batch = true;

				selectedRecords = qliGridCheckBoxGroup.getSelections();
				selectedCount = selectedRecords.length;

				//No need to proceed when there are no QLI's
				if (selectedCount === 0) { alert(NO_QLIS_SELECTED); return; };

				for (var recordIndex = 0; recordIndex < selectedCount; recordIndex++) {
					if (selectedRecords[recordIndex].get('qliLocked')) {
						alert(CANNOT_DELETE_LOCKED_ITEM);
						return;
					}
				}

				while (selectedCount >= 0) {
					this.store.remove(selectedRecords[selectedCount]);
					this.store.commitChanges();
					--selectedCount;
				}

				getLineItemsNumber();
			},

			/**
			* onClick of Add Freight
			*/
			onAddfreight: function (btn, ev) {

				var FREIGHT_UOM = 'EA';
				var freightLineItemData = {
					quoteId: quoteId,
					itemSeq: '',
					qliSpecialItem: false,
					qliSpecialProduct: true,
					qliQty: '1',
					qliProdId: 'null',
					qliProdCode: 'null',
					qliProdDesc: 'null',
					qliUOM: 'null',
					qliPrice: '0',
					qliTargetPrice: '0',
					qliFloorPrice: '0',
					qliPriceUOM: 'null',
					qliPriceCode: 'null',
					qliExtendedPrice: '0',
					qliExtendedCost: '0',
					qliGTMPercent: '0',
					qliVendor: 'null',
					qliComments: 'null',
					qliCommentsDontPrint: 'null',
					qliBid: 'null',
					qliMinMfgQty: 'null',
					qliCost: '0',
					qliProjDel: 'null',
					qliVendorItem: 'null',
					qliMfgTol: 'null',
					qliLDC: 'null',
					qliGTMDollar: '0',
					qliVendorContact: 'null',
					qliUnisourceItem: 'null',
					qliPriceUnitFactor: 'null',
					qliQuantityUnitFactor: 'null',
					qliCostUnitFactor: 'null',
					qliCloned: false,
					qliStockedMfg: 'null',
					qliTypeOfQuote: 'null',
					qliItemOrigin: 'null',
					qliRollSize: 'null',
					qliBrightness: 'null',
					qliColor: 'null',
					qliFinish: 'null',
					qliBrand: 'null',
					qliGradeNameCls: 'null',
					qliBasisWeight: 'null',
					qliOuterDia: 'null',
					qliCore: 'null',
					qliRecContent: '0',
					qliPcwContent: '0',
					qliCocReq: 'null',
					qliCostComm: 'null',
					qliLastDateOrd: 'null',
					qliLocked: false,
					qliFutDevCost: 'null',
					qliItemEligibility: false
				};

				switch (btn.text) {

					case 'Customer Freight': {
						freightLineItemData.qliProdCode = 'CFREIGHT';
						freightLineItemData.qliProdDesc = 'SHIPPING & HANDLING *';
						break;
					} case 'Customer Freight 3rd Party': {
						freightLineItemData.qliProdCode = 'CFREIGHT3P';
						freightLineItemData.qliProdDesc = '3RD PARTY SHIPPING & HANDLING';
						break;
					} case 'No Freight': {
						freightLineItemData.qliProdCode = 'NFREIGHT';
						freightLineItemData.qliProdDesc = 'FREIGHT*';
						break;
					} case 'Split Freight': {
						freightLineItemData.qliProdCode = 'SFREIGHT';
						freightLineItemData.qliProdDesc = 'FREIGHT*';
						break;
					} case 'Unisource Freight': {
						freightLineItemData.qliProdCode = 'UFREIGHT';
						freightLineItemData.qliProdDesc = 'FREIGHT*';
						break;
					} case 'Unisource Freight 3rd Party': {
						freightLineItemData.qliProdCode = 'UFREIGHT3P';
						freightLineItemData.qliProdDesc = '3RD PARTY FREIGHT*';
						break;
					}

				}

				var currentCount = retrieveMaxSequenceValue();

				//Freight Codes need UOM
				freightLineItemData.qliUOM = freightLineItemData.qliPriceUOM = FREIGHT_UOM;
				freightLineItemData.itemSeq = currentCount + 1;

				var freightQLI = new this.store.recordType(freightLineItemData);
				this.stopEditing(); //stop any current editing

				//add the special line item as first row
				this.store.insert(this.store.getCount(), freightQLI);
			},

			/**
			* onAdditionalDetails
			*/
			onAdditionalDetails: function (btn, ev) {

				var selectedRecords, selectedRecordsCount, url, qliIds = [];
				selectedRecords = qliGridCheckBoxGroup.getSelections();
				selectedRecordsCount = selectedRecords.length;

				//No need to proceed when there are no QLI's
				if (selectedRecordsCount === 0) { alert(NO_QLIS_SELECTED); return; };

				//Support only 3 QLI selection
				if (selectedRecordsCount > 3) {
					alert('Only 3 Quote Line Items can be selected.');
					return;
				}

				for (var i = selectedRecordsCount - 1; i >= 0; --i) {
					qliIds.push(selectedRecords[i].get('id'));
				}

				hideLineItemsForReload();

				showAdditionalDetails(quoteId, qliIds.toString());
			},

			/**
			* onUpdatePricing
			*/
			onUpdatePricing: function (btn, ev) {

				var isSpecialItem, isLocked, isFreight, selectedRecords, selectedRecordsCount, url, qliIds = [];
				selectedRecords = qliGridCheckBoxGroup.getSelections();
				selectedRecordsCount = selectedRecords.length;

				//No need to proceed when there are no QLI's
				if (selectedRecordsCount === 0) { alert(NO_QLIS_SELECTED); return; };

				//Support only 3 QLI selection
				if (selectedRecordsCount > 3) {
					alert('Only 3 Quote Line Items can be selected.');
					return;
				}

				for (var i = selectedRecordsCount - 1; i >= 0; --i) {
					qliIds.push(selectedRecords[i].get('id'));

					isSpecialItem = selectedRecords[i].get('qliSpecialItem');
					isLocked = selectedRecords[i].get('qliLocked');
					isFreight = selectedRecords[i].get('qliProdCode').search(/FREIGHT/gi) > -1;
					if (isSpecialItem || isFreight || isLocked) break;
				}

				// Special Line Items do not support P and A
				if (isSpecialItem) { alert(NO_UPDATE_PRICING_ON_SPECIAL_ITEM); return; }
				// Freight Codes do not support P and A
				if (isFreight) { alert(NO_UPDATE_PRICING_CALLOUT_ON_FREIGHT); return; }
				// Locked items do not support P and A
				if (isLocked) { alert(CANNOT_UPDATE_LOCKED_ITEM_UPDATE_PRICING_DETAILS); return; }

				hideLineItemsForReload();

				showUpdatePricingDetails(quoteId, qliIds.toString());
			},

			/**
			* onCreateOrder, creates an order based on the selected QLI's
			*/
			onCreateOrder: function (btn, ev) {

				var selectedRecords, currentRecord, selectedRecordsCount, qliIds = [], itemSeqHash = {}, itemSeqSorter = [];

				selectedRecords = qliGridCheckBoxGroup.getSelections();
				selectedRecordsCount = selectedRecords.length;

				//No need to proceed when there are no QLI's
				if (selectedRecordsCount === 0) { alert(NO_QLIS_SELECTED); return; };

				//Wake up the user
				if (!confirm(SAVE_REMINDER)) return;

				for (var i = selectedRecordsCount - 1; i >= 0; --i) {
					currentRecord = selectedRecords[i];

					if (currentRecord.get('qliLocked')) {
						alert(CANNOT_ORDER_LOCKED_ITEM);
						return;
					}

					if (currentRecord.get('itemSeq') !== '') {
						itemSeqSorter.push(currentRecord.get('itemSeq'));
						itemSeqHash[currentRecord.get('itemSeq')] = currentRecord.get('id');
					}
				}

				if (itemSeqSorter.length > 0) {
					itemSeqSorter.sort();
					for (var i = 0; itemSeqSorter[i]; ++i) {
						qliIds.push(itemSeqHash[itemSeqSorter[i]]);
					}
				} else {
					for (var i = 0; selectedRecords[i]; ++i) {
						qliIds.push(selectedRecords[i].get('id'));
					}
				}

				if (selectedRecordsCount > 0) {
					window.location = '/apex/ViewCreateOrder?id=' + quoteId + '&qliIds=' + qliIds.toString();
				}
			},

			/**
			* onSendToCustomer, send to customer based on the selected QLI's
			*/
			onSendToCustomer: function (btn, ev) {

				var selectedRecords, selectedRecordsCount, qliIds = [];

				selectedRecords = qliGridCheckBoxGroup.getSelections();
				selectedRecordsCount = selectedRecords.length;

				//No need to proceed when there are no QLI's
				if (selectedRecordsCount === 0) { alert(NO_QLIS_SELECTED); return; };

				//Wake up the user
				if (!confirm(SAVE_REMINDER)) return;

				for (var i = selectedRecordsCount - 1; i >= 0; --i) {
					qliIds.push(selectedRecords[i].get('id'));
				}

				if (selectedRecordsCount > 0) {
					window.location = '/apex/ViewSendToCustomer?id=' + quoteId + '&qliIds=' + qliIds.toString();
				}
			},

			/**
			* onSendToVendor, send to vendor based on the selected QLI's
			*/
			onSendToVendor: function (btn, ev) {

				var selectedRecords, selectedRecordsCount, qliIds = [];

				selectedRecords = qliGridCheckBoxGroup.getSelections();
				selectedRecordsCount = selectedRecords.length;

				//No need to proceed when there are no QLI's
				if (selectedRecordsCount === 0) { alert(NO_QLIS_SELECTED); return; };

				//Wake up the user
				if (!confirm(SAVE_REMINDER)) return;

				for (var i = selectedRecordsCount - 1; i >= 0; --i) {
					qliIds.push(selectedRecords[i].get('id'));
				}

				if (selectedRecordsCount > 0) {
					window.location = '/apex/ViewSendToVendor?id=' + quoteId + '&qliIds=' + qliIds.toString();
				}
			},

			/**
			* onSendToSalesRep, send to sales rep based on the selected QLI's
			*/
			onSendToSalesRep: function (btn, ev) {

				var selectedRecords, selectedRecordsCount, qliIds = [];

				selectedRecords = qliGridCheckBoxGroup.getSelections();
				selectedRecordsCount = selectedRecords.length;

				//No need to proceed when there are no QLI's
				if (selectedRecordsCount === 0) { alert(NO_QLIS_SELECTED); return; };

				//Wake up the user
				if (!confirm(SAVE_REMINDER)) return;

				for (var i = selectedRecordsCount - 1; i >= 0; --i) {
					qliIds.push(selectedRecords[i].get('id'));
				}

				if (selectedRecordsCount > 0) {
					window.location = '/apex/ViewSendToSalesRep?id=' + quoteId + '&qliIds=' + qliIds.toString();
				}
			}
		});
		// End extendedEditorGridPanel

		searchResultStore = new Ext.data.JsonStore({
			proxy: new Ext.data.HttpProxy({
				method: 'GET',
				url: '/apex/ProductSearch',
				timeout: 1200000 // 20 min
			}),
			root: 'results',
			totalProperty: 'total',
			idProperty: 'id',
			autoDestroy: true,
			fields: [
				{ name: 'id' },
				{ name: 'itemSeq' },
				{ name: 'divCode' },
				{ name: 'prodCode' },
				{ name: 'desc' },
				{ name: 'pricingCostUOM' },
				{ name: 'venName' },
				{ name: 'UWWItem' },
				{ name: 'venProdCode' },
				{ name: 'qtyUOM' },
				{ name: 'priceUnit' },
				{ name: 'isStocked' }
			], listeners: {
				load: {
					fn: function (success) {
						//alert(success);
						searchResultGrid.setTitle('Search Results - Matches Found: ' + this.getTotalCount());
					}
				},
				exception: {
					fn: function (proxy, type, action, options, response, args) {
						//400, 500 or the response meta-data does not match that defined in the DataReader
						if (type === 'response')
							alert('There was an error while searching for item(s).');
					}
				}
			}
		});

		searchResultGrid = new Ext.grid.GridPanel({
			store: searchResultStore,
			height: 300,
			loadMask: true,
			layout: 'fit',
			renderTo: 'searchResults',
			autoWidth: true,
			autoScroll: true,
			stripeRows: true,
			collapsible: true,
			collapsed: true,
			title: 'Search Results - Matches Found:',
			titleCollapse: true,
			forceLayout: true,
			viewConfig: {
				forceFit: true
			},
			sm: searchResultGridCheckBoxGroup,
			//autoExpandColumn: 'desc',
			tbar: [{
				text: 'Add to Quote',
				handler: function (btn, ev) {
					var selectedRecords, selectedRecordsCount, index, quoteId, rec, searchResultToQLI, currentQLICount, itemSeqArr = [], itemSeqHash = {};

					quoteId = document.getElementById('quoteId').innerHTML;
					selectedRecords = searchResultGridCheckBoxGroup.getSelections();
					selectedRecordsCount = selectedRecords.length;

					//No need to proceed when there are no QLI's
					if (selectedRecordsCount === 0) { alert(NO_QLIS_SELECTED); return; };

					var qli = {
						quoteId: quoteId,
						itemSeq: '',
						qliSpecialItem: false,
						qliSpecialProduct: false,
						qliQty: '1',
						qliProdId: 'null',
						qliProdCode: 'null',
						qliProdDesc: 'null',
						qliUOM: 'null',
						qliPrice: '0',
						qliFloorPrice: '0',
						qliTargetPrice: '0',
						qliPriceUOM: 'null',
						qliPriceCode: 'null',
						qliExtendedPrice: '0',
						qliExtendedCost: '0',
						qliGTMPercent: '0',
						qliVendor: 'null',
						qliComments: 'null',
						qliCommentsDontPrint: 'null',
						qliBid: 'null',
						qliMinMfgQty: 'null',
						qliCost: '0',
						qliProjDel: 'null',
						qliVendorItem: 'null',
						qliMfgTol: 'null',
						qliLDC: 'null',
						qliGTMDollar: '0',
						qliVendorContact: 'null',
						qliUnisourceItem: 'null',
						qliPriceUnitFactor: 'null',
						qliQuantityUnitFactor: 'null',
						qliCostUnitFactor: 'null',
						qliCloned: false,
						qliStockedMfg: 'null',
						qliTypeOfQuote: 'null',
						qliItemOrigin: 'null',
						qliRollSize: 'null',
						qliBrightness: 'null',
						qliColor: 'null',
						qliFinish: 'null',
						qliBrand: 'null',
						qliGradeNameCls: 'null',
						qliBasisWeight: 'null',
						qliOuterDia: 'null',
						qliCore: 'null',
						qliRecContent: '0',
						qliPcwContent: '0',
						qliCocReq: 'null',
						qliCostComm: 'null',
						qliLastDateOrd: 'null',
						qliLocked: false,
						qliFutDevCost: 'null'
					};

					var currentItemSeq;
					for (var i = selectedRecordsCount - 1; i >= 0; --i) {
						currentItemSeq = parseInt(selectedRecords[i].get('itemSeq'));
						itemSeqArr.push(currentItemSeq);
						itemSeqHash[currentItemSeq] = selectedRecords[i];
					}
					itemSeqArr.sort(function (a, b) { return a - b });

					for (var i = 0, itemSeqCount = itemSeqArr.length; i < itemSeqCount; ++i) {

						currentQLICount = retrieveMaxSequenceValue();

						rec = itemSeqHash[itemSeqArr[i]];
						qli.itemSeq = currentQLICount + 1;
						qli.qliProdId = rec.get('id');
						qli.qliProdCode = rec.get('prodCode');
						qli.qliProdDesc = rec.get('desc');
						qli.qliUOM = rec.get('qtyUOM');
						qli.qliPriceUOM = rec.get('pricingCostUOM');
						qli.qliVendor = rec.get('venName');
						qli.qliVendorItem = rec.get('venProdCode');
						qli.qliUnisourceItem = rec.get('UWWItem');
						qli.qliPriceUnitFactor = rec.get('priceUnit');
						qli.qliQuantityUnitFactor = rec.get('priceUnit');
						qli.qliCostUnitFactor = rec.get('priceUnit');

						searchResultToQLI = new qliStore.recordType(qli);
						qliStore.insert(qliStore.getCount(), searchResultToQLI);
						qliStore.commitChanges();

					}
				}
			}, {
				text: 'Fetch P &amp A',
				handler: function (btn, ev) {

					var selectedRecords, selectedRecordsCount, queryParams, quoteId, url;
					queryParams = url = '';

					quoteId = document.getElementById('quoteId').innerHTML;
					selectedRecords = searchResultGridCheckBoxGroup.getSelections();
					selectedRecordsCount = selectedRecords.length;

					//No need to proceed when there are no QLI's
					if (selectedRecordsCount === 0) { alert(NO_QLIS_SELECTED); return; };

					for (var i = 0; i < selectedRecordsCount; ++i) {
						queryParams += '&pid' + i + '=' + selectedRecords[i].get('id');
					}

					url = '/apex/PricingAndAvailabilityQLI' + '?id=' + quoteId + queryParams;

					return window.open(url, '', 'width=1200px, height=900px, resizable, scrollbars');
				}
			}],
			columns: [
				//new Ext.grid.RowNumberer({header: '#', width: 22}),
				{
					header: '#',
					id: 'itemSeq',
					dataIndex: 'itemSeq',
					sortable: false,
					menuDisabled: true,
					width: 22
				},
				searchResultGridCheckBoxGroup,
				{
					header: "Division Code",
					id: 'divCode',
					dataIndex: 'divCode',
					sortable: true,
					menuDisabled: true,
					width: 35
				}, {
					header: "Product Code",
					id: 'prodCode',
					dataIndex: 'prodCode',
					sortable: true,
					menuDisabled: true,
					width: 75
				}, {
					header: "Description",
					id: 'desc',
					dataIndex: 'desc',
					sortable: true,
					menuDisabled: true,
					width: 250
				}, {
					header: "UOM",
					id: 'pricingCostUOM',
					dataIndex: 'pricingCostUOM',
					sortable: true,
					menuDisabled: true,
					width: 30,
					renderer: renderNull
				}, {
					header: "Vendor Name",
					id: 'venName',
					dataIndex: 'venName',
					sortable: true,
					menuDisabled: true,
					width: 45,
					renderer: renderNull
				}, {
					header: "UWW Item",
					id: 'UWWItem',
					dataIndex: 'UWWItem',
					sortable: true,
					menuDisabled: true,
					width: 45,
					renderer: renderNull
				}, {
					header: "Vendor Product Code",
					id: 'venProdCode',
					dataIndex: 'venProdCode',
					sortable: true,
					menuDisabled: true,
					width: 45,
					renderer: renderNull
				}, {
					header: "Stocked",
					id: 'isStocked',
					dataIndex: 'isStocked',
					sortable: true,
					menuDisabled: true,
					width: 35
				}
			]
		});
		// End Search GridPanel

		// The new DataWriter component.
		qliWriter = new Ext.data.JsonWriter({
			encode: true,
			writeAllFields: true
		});

		// A new generic text field
		var textField = new Ext.form.TextField({ selectOnFocus: true });

		qliStore = new Ext.data.JsonStore({
			proxy: new Ext.data.HttpProxy({
				//method: 'GET',
				api: {
					read: '/apex/QuoteLineItems',
					create: '/apex/QuoteLineItemsCreate',
					update: '/apex/QuoteLineItemsUpdate',
					destroy: '/apex/QuoteLineItemsDelete'
				},
				//url: '/apex/QuoteLineItems',
				timeout: 1200000 // 20 min
			}),
			root: 'results',
			totalProperty: 'total',
			successProperty: 'success',
			messageProperty: 'message',
			idProperty: 'id',
			writer: qliWriter,
			autoSave: true,
			batch: false,
			fields: [
				{ name: 'id' },
				{ name: 'itemSeq' },
				{ name: 'quoteId' },
				{ name: 'qliQty' },
				{ name: 'qliProdCode' },
				{ name: 'qliProdDesc' },
				{ name: 'qliUOM' },
				{ name: 'qliPrice' },
				{ name: 'qliTargetPrice' },
				{ name: 'qliPriceUOM' },
				{ name: 'qliFloorPrice' },
				{ name: 'qliProdId' },
				{ name: 'qliPriceCode' },
				{ name: 'qliSpecialItem' },
				{ name: 'qliSpecialProduct' },
				{ name: 'qliExtendedPrice' },
				{ name: 'qliExtendedCost' },
				{ name: 'qliGTMPercent' },
				{ name: 'qliVendor' },
				{ name: 'qliComments' },
				{ name: 'qliCommentsDontPrint' },
				{ name: 'qliBid' },
				{ name: 'qliMinMfgQty' },
				{ name: 'qliCost' },
				{ name: 'qliProjDel' },
				{ name: 'qliVendorItem' },
				{ name: 'qliMfgTol' },
				{ name: 'qliLDC' },
				{ name: 'qliGTMDollar' },
				{ name: 'qliVendorContact' },
				{ name: 'qliUnisourceItem' },
				{ name: 'qliPriceUnitFactor' },
				{ name: 'qliQuantityUnitFactor' },
				{ name: 'qliCloned' },
				{ name: 'qliStockedMfg' },
				{ name: 'qliTypeOfQuote' },
				{ name: 'qliItemOrigin' },
				{ name: 'qliRollSize' },
				{ name: 'qliBrightness' },
				{ name: 'qliColor' },
				{ name: 'qliFinish' },
				{ name: 'qliBrand' },
				{ name: 'qliGradeNameCls' },
				{ name: 'qliBasisWeight' },
				{ name: 'qliOuterDia' },
				{ name: 'qliCore' },
				{ name: 'qliRecContent' },
				{ name: 'qliPcwContent' },
				{ name: 'qliCocReq' },
				{ name: 'qliCostComm' },
				{ name: 'qliLastDateOrd' },
				{ name: 'qliLocked' },
				{ name: 'qliFutDevCost' },
				{ name: 'qliSentToZilliant' },
				{ name: 'qliItemEligibility' }
			], listeners: {
				write: {
					fn: function (store, action, result, res, rs) {
						var currentRecord, url;
						getLineItemsNumber();
						//Only after Special Line Item is added
						if (action === 'create' && result.length === 1) {

							if (rs.get('qliSpecialItem') && !rs.get('qliCloned')) {
								hideLineItemsForReload();

								isAdditionalPopUpEnabled = true;

								showAdditionalDetails(rs.get('quoteId'), rs.get('id'));
							}
						}
					}
				}, load: {
					fn: function (success) {
						//alert(success);
						calculateRunningTotals();
					}
				}, update: {
					fn: function (store, record, operation) {
						calculateRunningTotals();
					}
				}, exception: {
					fn: function (proxy, type, action, options, response, args) {
						if (type === 'remote') {
							// Success was set to false
							alert(response.message);
						}
					}
				}
			}
		});
		// End QliStore

		var qtyUOM = new Ext.form.ComboBox({
			id: 'qtyUOM',
			typeAhead: true,
			triggerAction: 'all',
			lazyRender: true,
			allowBlank: false,
			store: new Ext.data.ArrayStore({
				id: 'qtyUOMStore',
				url: '/apex/QuoteLineItemsQtyUOM',
				fields: ['id']
			}),
			mode: 'remote',
			displayField: 'id',
			valueField: 'id',
			listeners: {
				beforequery: function (qe) {
					//Always a single record will be selected
					var selectedRecords = qliGridCheckBoxGroup.getSelections();

					this.allowBlank = false;
					//Special line item will have custom value entered by user
					if (selectedRecords[0].get('qliSpecialItem')) {
						this.allowBlank = true;
						return false;
					}

					//Query will of the format quoteId&qliId
					qe.query = selectedRecords[0].get('quoteId') + '&' + selectedRecords[0].get('id');

					//delete the previous query in the beforequery event or set
					//combo.lastQuery = null (this will reload the store the next time it expands)
					delete qe.combo.lastQuery;
				}, focus: function (ref) {
					//Always a single record will be selected
					var selectedRecords = qliGridCheckBoxGroup.getSelections();

					if (selectedRecords[0].get('qliSpecialItem')) {
						if (ref.getValue() === 'null') {
							ref.setValue('');
						}
					}
				}
			}
			//listClass: 'x-combo-list-small'
		});
		// End QtyUOM combobox

		var priceUOM = new Ext.form.ComboBox({
			id: 'priceUOM',
			typeAhead: true,
			triggerAction: 'all',
			lazyRender: true,
			allowBlank: false,
			store: new Ext.data.ArrayStore({
				id: 'priceUOMStore',
				url: '/apex/QuoteLineItemsPriceUOM',
				fields: ['id']
			}),
			mode: 'remote',
			displayField: 'id',
			valueField: 'id',
			listeners: {
				beforequery: function (qe) {
					//Always a single record will be selected
					var selectedRecords = qliGridCheckBoxGroup.getSelections();

					this.allowBlank = false;
					//Special line item will have custom value entered by user
					if (selectedRecords[0].get('qliSpecialItem')) {
						this.allowBlank = true;
						return false;
					}

					//Query will of the format quoteId&qliId
					qe.query = selectedRecords[0].get('quoteId') + '&' + selectedRecords[0].get('id');

					//delete the previous query in the beforequery event or set
					//combo.lastQuery = null (this will reload the store the next time it expands)
					delete qe.combo.lastQuery;
				}, focus: function (ref) {
					//Always a single record will be selected
					var selectedRecords = qliGridCheckBoxGroup.getSelections();

					if (selectedRecords[0].get('qliSpecialItem')) {
						if (ref.getValue() === 'null') {
							ref.setValue('');
						}
					}
				}
			}
			//listClass: 'x-combo-list-small'
		});
		// End PriceUOM ComboBox

		// shorthand alias
		var fm = Ext.form;

		qliGrid = new extendedEditorGridPanel({//new Ext.grid.EditorGridPanel({
			id: 'qliGrid',
			store: qliStore,
			autoHeight: true,
			loadMask: true,
			layout: 'fit',
			renderTo: 'quoteLineItems',
			autoWidth: true,
			autoScroll: true,
			stripeRows: true,
			trackMouseOver: true,
			title: 'Quote Line Items',
			collapsible: true,
			titleCollapse: true,
			forceLayout: true,
			viewConfig: {
				forceFit: true,
				scrollOffset: 0
			},
			sm: qliGridCheckBoxGroup,
			//autoExpandColumn: 'qliProdDesc',
			listeners: {
				beforeedit: function (e) {

					var isSpecialItem, isCommentProductCode, isLocked, columnName,
						REGULAR_READ_ONLY_COLS = ['qliProdDesc', 'qliExtendedPrice', 'qliProdCode'],
						SPECIAL_TRIGGER_DETAIL_COLS = ['qliQty', 'qliPrice', 'qliUOM', 'qliPriceUOM', 'qliGTMPercent', 'qliCost', 'qliExtendedPrice'];

					isSpecialItem = e.record.get('qliSpecialItem');
					isLocked = e.record.get('qliLocked');
					columnName = e.field;

					if (isLocked) return false;

					//These columns are readable for non special items
					if (!isSpecialItem && REGULAR_READ_ONLY_COLS.indexOf(columnName) > -1) {
						return false;
					}

					var uomsDiffer = e.record.get('qliUOM') !== e.record.get('qliPriceUOM');
					// these columns force additional details to open for special items if uoms do not match
					if (isSpecialItem && uomsDiffer && SPECIAL_TRIGGER_DETAIL_COLS.indexOf(columnName) > -1) {
						hideLineItemsForReload();
						window.setTimeout(function () { showAdditionalDetails(e.record.get('quoteId'), e.record.get('id')) }, 500);
						return false;
					}
				}
			},
			columns: [
				{
					header: '#',
					id: 'itemSeq',
					dataIndex: 'itemSeq',
					sortable: false,
					menuDisabled: true,
					editor: textField,
					width: 23,
					renderer: renderZSent
				}, qliGridCheckBoxGroup, {
					header: "Product Code",
					id: 'qliProdCode',
					dataIndex: 'qliProdCode',
					sortable: true,
					menuDisabled: false,
					editor: textField,
					width: 85,
					renderer: renderLocked
				}, {
					header: "Description",
					id: 'qliProdDesc',
					dataIndex: 'qliProdDesc',
					width: 350,
					sortable: true,
					menuDisabled: true,
					editor: textField,
					renderer: renderLocked
				}, {
					header: "Qty",
					id: 'qliQty',
					dataIndex: 'qliQty',
					sortable: true,
					menuDisabled: true,
					align: 'right',
					//xtype: 'numbercolumn',
					width: 55,
					editor: textField,
					renderer: renderZSent
				}, {
					header: "Qty UOM",
					id: 'qliUOM',
					dataIndex: 'qliUOM',
					sortable: true,
					menuDisabled: true,
					editor: qtyUOM,
					align: 'center',
					width: 45,
					renderer: renderZSent
				}, {
					header: "Price",
					id: 'qliPrice',
					dataIndex: 'qliPrice',
					sortable: true,
					menuDisabled: true,
					align: 'right',
					editor: textField,
					width: 65,
					renderer: renderUSMoney
				}, {
					header: "Target Price",
					id: 'qliTargetPrice',
					dataIndex: 'qliTargetPrice',
					sortable: true,
					menuDisabled: true,
					align: 'right',
					editor: textField,
					width: 65,
					renderer: renderUSMoney
				}, {
					header: "Floor Price",
					id: 'qliFloorPrice',
					dataIndex: 'qliFloorPrice',
					sortable: true,
					menuDisabled: true,
					align: 'right',
					editor: textField,
					width: 65,
					renderer: renderUSMoney
				}, {
					header: "P/C UOM",
					id: 'qliPriceUOM',
					dataIndex: 'qliPriceUOM',
					sortable: true,
					menuDisabled: true,
					editor: priceUOM,
					align: 'center',
					width: 35,
					renderer: renderZSent
				}, {
					header: 'Cost',
					id: 'qliCost',
					dataIndex: 'qliCost',
					sortable: true,
					menuDisabled: true,
					align: 'right',
					/*xtype: 'numbercolumn',*/
					format: '$0,000.000',
					editor: textField,
					width: 70,
					renderer: renderBlueUSMoneyIfThereIsAFutureDevCost
				}, {
					header: "Price Code",
					id: 'qliPriceCode',
					dataIndex: 'qliPriceCode',
					sortable: true,
					menuDisabled: true,
					editor: textField,
					align: 'center',
					renderer: renderNull,
					//hidden: true
				}, {
					header: "GTM %",
					id: 'qliGTMPercent',
					dataIndex: 'qliGTMPercent',
					sortable: true,
					menuDisabled: true,
					align: 'center',
					editor: new fm.TextField({
						selectOnFocus: true
					}),
					width: 40,
					renderer: renderNegative
				}, {
					header: "Ext Price",
					id: 'qliExtendedPrice',
					dataIndex: 'qliExtendedPrice',
					sortable: true,
					menuDisabled: true,
					align: 'right',
					editor: textField,
					width: 65,
					renderer: renderUSMoney
				}, {
					header: "Vendor",
					id: 'qliVendor',
					dataIndex: 'qliVendor',
					sortable: true,
					menuDisabled: true,
					editor: textField,
					width: 55,
					renderer: renderZSent
				}, {
					header: 'Bid #',
					id: 'qliBid',
					dataIndex: 'qliBid',
					sortable: true,
					menuDisabled: true,
					editor: textField,
					width: 50,
					renderer: renderNull,
					hidden: true
				}, {
					header: 'Min Mfg Qty',
					id: 'qliMinMfgQty',
					dataIndex: 'qliMinMfgQty',
					sortable: true,
					menuDisabled: true,
					editor: textField,
					renderer: renderNull,
					hidden: true
				}, {
					header: 'Proj Del Date',
					id: 'qliProjDel',
					dataIndex: 'qliProjDel',
					sortable: true,
					menuDisabled: true,
					editor: textField,
					renderer: Ext.util.Format.dateRenderer('m/d/Y'),
					hidden: true
				}, {
					header: 'Vendor Item #',
					id: 'qliVendorItem',
					dataIndex: 'qliVendorItem',
					sortable: true,
					menuDisabled: true,
					editor: textField,
					renderer: renderNull,
					hidden: true
				}, {
					header: 'Mfg Tol',
					id: 'qliMfgTol',
					dataIndex: 'qliMfgTol',
					sortable: true,
					menuDisabled: true,
					editor: textField,
					width: 60,
					renderer: renderNull,
					hidden: true
				}, {
					header: 'LDC',
					id: 'qliLDC',
					dataIndex: 'qliLDC',
					sortable: true,
					menuDisabled: true,
					editor: textField,
					renderer: Ext.util.Format.dateRenderer('m/d/Y'),
					hidden: true
				}, {
					header: 'Vendor Contact',
					id: 'qliVendorContact',
					dataIndex: 'qliVendorContact',
					sortable: true,
					menuDisabled: true,
					editor: textField,
					renderer: renderNull,
					hidden: true
				}
			]
		});
		// End QliGrid


		qliStore.load({
			params: {
				'quoteId': quoteId
			}
		});

	};
	// End init method

	function retrieveMaxSequenceValue() {
		var maxSeq = 0;

		qliStore.each(function () {
			if (parseInt(this.get('itemSeq')) > maxSeq) {
				maxSeq = parseInt(this.get('itemSeq'));
			}
		});

		return maxSeq;
	}

	function doGET() {
		// TODO:
		// memoizer for these Id's
		var prodCode = document.getElementById('prodCode').value;
		var desc = document.getElementById('desc').value;
		var venProdCode = document.getElementById('venProdCode').value;
		var venName = document.getElementById('venName').value;
		var isStocked = document.getElementById('isStocked').checked;
		isStocked = (isStocked) ? '1' : '0';
		var showDeleted = document.getElementById('showDeleted').checked;
		showDeleted = (showDeleted) ? '1' : '0';

		var selectedDivisions = [];
		var myList = document.getElementById("pgQuotes:frmMain:pbQuoteLineItems:pbsProductSearch:pbsiSearch:divisionName");
		for (var i = myList.options.length - 1; i > 0; --i) {
			if (myList.options[i].selected === true)
				selectedDivisions.push(myList.options[i].value);
		}

		searchResultStore.load({
			params: {
				'pcode': prodCode,
				'pdesc': desc,
				'vpcode': venProdCode,
				'vname': venName,
				'isStocked': isStocked,
				'divisions': selectedDivisions.toString(),
				'showDeleted': showDeleted
			}
		});
		searchResultGrid.expand();
	};

	function renderNull(value) {
		return (value == 'null') ? '' : value;
	};

	function renderLocked(value, metaData, record) {
		if (value == 'null') {
			value = '';
		}

		var addedStyles = '';

		if (record.get('qliSentToZilliant') && record.get('qliSentToZilliant') !== 'null') {
			addedStyles = addedStyles + 'font-weight:bold;';
		}

		if (record.get('qliLocked')) {
			addedStyles = addedStyles + 'color:red;';
		}

		return '<span style="' + addedStyles + '">' + value + '</span>';
		//return value;
	}

	function renderZSent(value, metaData, record) {
		value = (value == 'null') ? '' : value;
		var addedStyles = '';

		var selectedRecords = qliGridCheckBoxGroup.getSelections();

		if (record.data.qliSentToZilliant && record.data.qliSentToZilliant !== 'null') {
			addedStyles = addedStyles + 'font-weight:bold;';
			//value = '<b>' + value + '</b>';
		}

		return '<span style="' + addedStyles + '">' + value + '</span>';
		//return value;
	}

	function renderUSMoney_GTM(value, metaData, record) {
		var amount = '';
		var currVal = Number(value);
		//value = value.toFixed(2);
		currVal = Math.round(currVal * 100) / 100;
		amount = currVal;

		if (record.get('qliSentToZilliant') && record.get('qliSentToZilliant') !== 'null') {
			return '<b>' + amount + '</b>';
		}

		return amount;
		//return Ext.util.Format.usMoney(value);
	}

	function renderBlueUSMoneyIfThereIsAFutureDevCost(value, metaData, record) {
		var retString = Ext.util.Format.usMoney(value);
		var addedStyles = '';

		if (record.get('qliFutDevCost') != 'null' && parseFloat(record.get('qliFutDevCost')) > 0) {
			addedStyles = 'color:blue;';
		}
		if (record.get('qliSentToZilliant') && record.get('qliSentToZilliant') !== 'null') {
			addedStyles = 'font-weight:bold';
		}

		return retString = '<span style="' + addedStyles + '">' + retString + '</span>';
		//return retString;
	}

	function renderUSMoney(value, metaData, record) {
		var retString = Ext.util.Format.usMoney(value);
		var addedStyles = '';

		if (record.get('qliSentToZilliant') && record.get('qliSentToZilliant') !== 'null') {
			addedStyles = 'font-weight:bold';
		}

		return retString = '<span style="' + addedStyles + '">' + retString + '</span>';
		//return retString;
	}

	function renderNegative(value, metaData, record) {
		var addedStyles = '';

		if (value == 'null' || value == null || typeof value === 'undefined') {
			value = 0;
		}
		if (record.get('qliSentToZilliant') && record.get('qliSentToZilliant') !== 'null') {
			addedStyles = 'font-weight:bold;';
		}
		if (value <= 0) {
			addedStyles = addedStyles + 'color:red;';
		}

		return '<span style="' + addedStyles + '">' + value + '%</span>';
		//return value + '%';
	}

	function disableSearch(btnRef) {
		btnRef.value = 'Saving...';
		btnRef.title = 'Saving...';
		btnRef.disabled = true;
	};

	function enableSearch(btnRef, name) {
		btnRef.value = name;
		btnRef.title = name;
		btnRef.disabled = false;
	};

	/**
	 * hideLineItemsForReload, masks line items and forces user to reload items
	*/
	function hideLineItemsForReload(errorMessage) {
		var displayMessage = 'Please click <font color="red">Reload</font> now.';
		if (errorMessage) {
			displayMessage = 'Error: ' + errorMessage + '\n' + displayMessage;
		}

		Ext.getCmp('qliGrid').getGridEl().mask(displayMessage, 'x-mask');
		Ext.getCmp('reloadQLI').setText('<font color="red">Reload</font>');
	}

	function hideItemsForIneligibility(item) {
		var displayMessage = 'Ineligible Item(s):\n';
		for (pc in item) {
			if (item[pc].hasOwnProperty(pc)) {
				displayMessage += 'Product Number: ' + item[pc] + '\n';
			}
		}
		alert(displayMessage);
		displayMessage = 'Please click <font color="red">Reload</font> now.';
		Ext.getCmp('qliGrid').getGridEl().mask(displayMessage, 'x-mask');
		Ext.getCmp('reloadQLI').setText('<font color="red">Reload</font>');
	}

	function showAdditionalDetails(quoteId, qliIds) {
		var targetURL = '/apex/ViewAdditionalDetails?id=' + quoteId + '&qliIds=' + qliIds;
		return window.open(targetURL, '', 'width=1200px, height=900px, resizable, scrollbars');
	}

	function showUpdatePricingDetails(quoteId, qliIds) {
		var targetURL = '/apex/UpdatePricingDetails?id=' + quoteId + '&qliIds=' + qliIds;
		return window.open(targetURL, '', 'width=1300px, height=900px, resizable, scrollbars');
	}

	function doSearch(e) {

		var key;
		if (window.event) {
			key = window.event.keyCode; //IE
			e = window.event;
			e.target = window.event.srcElement;
		} else if (e) {
			key = e.which;              //Firefox
		} else {
			return true;
		}
		var eTarget = Ext.fly(e.target.id);

		if (key === 13 && eTarget != null && !eTarget.hasClass('escapeReturn')) {

			var btnId = '';

			if (eTarget.hasClass('quickAddReturn')) {
				btnId = "pgQuotes:frmMain:pbQuoteLineItems:pbsProductSearch:quickAddButton";
			}
			else if (eTarget.hasClass('doSearch')) {
				btnId = "cbSearch";
			}

			if (btnId != '')
				document.getElementById(btnId).click();

			return false;
		}
		else {
			return true;
		}
	};

	/**
	 * reloadLineItems, reload all line items instead of just selected items
	*/
	function reloadLineItems() {
		//qliGrid.getView().refresh();
		qliStore.reload();
	}

	return {
		init: init,
		doGET: doGET,
		disableSearch: disableSearch,
		enableSearch: enableSearch,
		onReturn: doSearch,
		reload: reloadLineItems
	};
})(this, this.document);

window.addEventListener('load', Unisource.init, false);
//Ext.onReady(Unisource.init, Unisource);
document.onkeypress = Unisource.onReturn;
