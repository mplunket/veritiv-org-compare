/**
  * Apex class for building Composite Graph in JSON format
  */
 public without sharing class GraphService2 {
 
 	public class GraphServiceException extends Exception {}
 
 	/**
 	 * Fields to exclude for any object
 	 */
 	private final Set<String> standardFieldsToExclude = new Set<String>{
 			'Id',
 			'OwnerId',
 			'IsDeleted',
 			'CreatedDate',
 			'CreatedById',
 			'LastModifiedDate',
 			'LastModifiedById',
 			'SystemModstamp',
 			'LastViewedDate',
 			'LastReferencedDate',
 			'AutorabitExtId__c'
 	};
 
 	/**
 	 * Children object names to avoid for any object
 	 */
 	private final Set<String> pluralNamesToExclude = new Set<String>{
 			'PersonOpportunities',
 			'PersonOpportunityContactRoles'
 	};
 
 	/**
 	 * Fields do not populate in particular object
 	 */
 	private final Map<String, List<String>> badFieldToInsertMap = new Map<String, List<String>>{
 			'Account' => new List<String>{
 					'PersonContactId',
 					'Source_System__pc',
 					'CEC_PreferredCommunicationChannel__pc',
 					'Remove_me_from_UPS_e_mail_communications__pc',
 					'CEC_ContactOrigin__pc',
 					'Promotions_and_Offers__pc',
 					'FirstName',
 					'IDS_Integration_Key__pc',
 					'Teams_Migration_Key__pc',
 					'CEC_PhoneExtension__pc',
 					'Job_Class__pc',
 					'CEC_Language__pc',
 					'Do_Not_Direct_Mail__pc',
 					'CEC_Con_User_Registration_Number__pc',
 					'CEC_MyChoiceHomePremIndicator__pc',
 					'Region__pc',
 					'Employee_Status__pc',
 					'CEC_No_Autoresponse__pc',
 					'Newsletters__pc',
 					'CEC_Country__pc',
 					'Division__pc',
 					'Job_Group_Code__pc',
 					'LinkedIn_Profile__pc',
 					'Service_Updates_Regulatory_Changes__pc',
 					'Salutation',
 					'Personal_Interest__pc',
 					'AccountIdDupTest__pc',
 					'Migration_Key__pc',
 					'CEC_ReceiveAutomaticNotification__pc',
 					'Contact_Type__pc',
 					'Contact_Role__pc',
 					'District__pc',
 					'Submitter_ID__pc',
 					'CEC_MyChoiceIndicator__pc',
 					'New_Product_Announcements_Enhancements__pc',
 					'Mailing_List__pc',
 					'CEC_UPScomUserID__pc',
 					'Centre__pc',
 					'Loan_Amount__pc',
 					'LastName',
 					'IsCustomerPortal',
 					'IsChanged__c',
 					'IsChanged__pc',
 					'Report_WE_Date__c'
 			},
 			'Contact' => new List<String>{
 					'MasterRecordId',
 					'IsChanged__c',
 					'Loan_Amount__c'
 			},
 			'aiq_TierBand__c' => new List<String>{
 					'aiq_Deal__c'
 			},
 			'Total_Customer_Spend__c' => new List<String>{
 					'removeTcsShare__c'
 			},
 			'Opportunity' => new List<String>{
 					'IsExcludedFromTerritory2Filter',
 					'Lead_Submitter_2_Email1__c',
 					'Lead_Submitter_2_Email2__c',
 					'Lead_Submitter_2_Email__c',
 					'Sale_Reason_Code__c',
 					'X2nd_Lead_Number__c',
 					'IsExcludedFromTerritory2Filter'
 			}
 
 	};
 	/**
 	 * Map to find Children Objects Plural Names by Child Object Name for parent master object
 	 * Contains only children records which exist for parent master object and are present at allRelatedChildrenRecords
 	 * defined by user
 	 */
 	private Map<String, List<String>> objectNameToChildrenPluralNameParentMap = new Map<String, List<String>>();
 
 	/**
 	 * Map to find Parent Lookup field name by Child Object Plural Name for parent master object
 	 * Contains only children records which exist for parent master object and are present at allRelatedChildrenRecords
 	 * defined by user
 	 */
 	private Map<String, String> childPluralNameToParentLookupLinkParentMap = new Map<String, String>();
 
 	/**
 	 * Map to find Children Objects Plural Names by Child Object Name for current second layer object
 	 * Contains only children records which exist for current second layer object and are present at
 	 * allRelatedChildrenRecords defined by user
 	 */
 	private Map<String, List<String>> objectNameToChildrenPluralNameChildrenMap = new Map<String, List<String>>();
 
 	/**
 	 * Map to find Parent Lookup field name by Child Object Plural Name for current second layer object
 	 * Contains only children records which exist for parent master object and are present at allRelatedChildrenRecords
 	 * defined by user
 	 */
 	private Map<String, String> childPluralNameToParentLookupLinkChildrenMap = new Map<String, String>();
 
 	/**
 	 * Current map to find Children Objects Plural Names by Child Object Name
 	 */
 	private Map<String, List<String>> objectNameToChildrenPluralNameMap;
 
 	/**
 	 * Current map to find Parent Lookup field name by Child Object Plural Name
 	 */
 	private Map<String, String> childrenPluralNameToParentLookupLinkMap;
 
 	/**
 	 * Contains description of all the fields of the object we work with at the moment
 	 */
 	private Map<String, SObjectField> currentObjectFieldsMap;
 
 	/**
 	 * Contains all the fields we should populate for the record we work with at the moment
 	 */
 	private Set<String> currentFieldsToPopulate;
 
 	/**
 	 * Parent master record Id
 	 * Defined by User
 	 */
 	private Id recordId;
 
 	/**
 	 * All the Children records (Master-Detail/Lookup) we would like to create
 	 * Defined by User
 	 */
 	private Set<String> allRelatedChildrenRecords = new Set<String>();
 
 	/**
 	 * All the Lookup records we would like to query and create relationship (External Id should exist and be populated),
 	 * otherwise will be ignored
 	 * Defined by User
 	 */
 	private Set<String> allRelatedLookupRecords = new Set<String>();
 
 	/**
 	 * Specific Children objects we would like to check out for the Children existence and create
 	 * (children objects must be present in relatedChildrenRecords)
 	 * Defined by User
 	 */
 	private Set<String> secondLayer = new Set<String>();
 
 	/**
 	 * All the Lookup records we would like not to query but create
 	 * Defined by User
 	 */
 	private Set<String> relatedLookupRecordsToCreate = new Set<String>();
 
 	/**
 	 * Map to find Salesforce Id by object name, existing Lookup Records we need to populate using Salesforce Id
 	 * Defined by User
 	 */
 	private Map<String, String> relatedLookupHardcodedRecordsMap = new Map<String, String> ();
 
 	/**
 	 * Map to find Reference Field Salesforce Id by Reference Field Name for already created records with graph nodes
 	 * for current record
 	 */
 	private Map<String, Id> referenceFieldsToCheckIfAlreadyCreatedByGraph = new Map<String, Id>();
 
 	/**
 	 * Map to find Graph Reference Id By Salesforce Id
 	 */
 	private Map<Id, String> idToGraphReferenceIdMap = new Map<Id, String>();
 
 	/**
 	 * Already created Graph Objects Names
 	 */
 	private Set<String> alreadyCreatedObjectsWithoutExternalIdField = new Set<String>();
 
 	/**
 	 * Used for creating reference Ids for the related Get records to query nodes
 	 */
 	private Integer globalCounter = 1;
 
 	/**
 	 * For creating reference Ids for already queried in graph records
 	 */
 	private Integer oldGlobalCounter;
 
 	/**
 	 * counter for created with nodes (not queried) reference records
 	 */
 	private Integer referenceToCreateCounter = 1;
 
 	/**
 	 * counter to reference to created (not queried) reference records when populating fields lookup fields to current
 	 * record
 	 */
 	private Integer oldReferenceToCreateCounter;
 
 	/**
 	 * Counter for second layer records
 	 */
 	private Integer secondLayerCounter;
 
 	/**
 	 * Reference Fields to use for the current object, contains all the fields defined by User related to the current
 	 * object
 	 */
 	private Set<String> allCurrentReferenceFields;
 
 	/**
 	 * Map to find all the Reference Field Names by Object Name
 	 */
 	private Map<String, Set<String>> allReferenceFieldsToGetByObjectNameMap = new Map<String, Set<String>>();
 
 	/**
 	 * Map to find Object Name by Reference Field Name
 	 */
 	private Map<String, String> referenceFieldNameToObjectNameMap = new Map<String, String>();
 
 	/**
 	 * all populated Reference Field Names for which were created GET nodes to query this reference records,
 	 * valid for the current record
 	 */
 	private Set<String> allPopulatedReferenceFieldsToGet;
 
 	/**
 	 * Not populated Reference Fields for the current record which were defined by user in allRelatedLookupRecords
 	 */
 	private Set<String> emptyReferenceFields;
 
 	/**
 	 * Object Reference Field Names of related records we should create nodes for the current object
 	 */
 	private Set<String> referenceFieldsToCreate;
 
 	/**
 	 * Reference Fields which should be hardcoded for the current object
 	 */
 	private Set<String> referenceFieldsToHardCode;
 
 	/**
 	 * Map to find node counter by Salesforce Id, used to get reference Id of already queried or created object
 	 */
 	private Map<Id, Integer> idToCounterMap = new Map<Id, Integer>();
 
 	/**
 	 * All the graph reference Ids of already created or retrieved records
 	 */
 	Set<String> graphReferenceIds = new Set<String>();
 
 	private String JSONGraph = '{"graphs":[{"graphId":"1","compositeRequest":[';
 	private final String JSON_END = ']}]}';
 
 	/**
 	 * graph master parent reference Id
 	 */
 	private String graphParentReferenceId;
 
 	/**
 	 * Master parent object with all the children and lookups explicitly specified in
 	 * allRelatedChildrenRecords and allRelatedLookupRecords
 	 */
 	private SObject parentObject;
 
 	/**
 	 * List of current Child Second Level Objects with all the children and lookups explicitly specified in
 	 * allRelatedChildrenRecords and allRelatedLookupRecords
 	 */
 	private List<SObject> childSecondLevelObjects;
 
 	/**
 	 * query as a String for the current object
 	 */
 	private String query;
 	private String parentObjectName;
 
 	/**
 	 * Default field name for the 1st level of sorting objects
 	 */
 	private final static String COMPARABLE_FIELD = 'Name';
 
 	/**
 	 * Map to find field to compare objects, which do not have "Name" field, used for 1st level sorting
 	 */
 	private static Map<String, String> objectToFirstFieldToCompareMap = new Map<String, String>{
 			'Contact' => 'LastName',
 			'AccountTeamMember' => 'TeamMemberRole'
 	};
 
 	private static List<String> objectsNotToSort = new List<String> {
 			'Total_Customer_Spend__c'
 	};
 
 	/**
 	 * Map to find additional field to compare objects, in case records have the same Name field,
 	 * used for 2nd level sorting
 	 */
 	private static Map<String, String> objectToSecondFieldToCompareMap = new Map<String, String>{
 			'zpl__IQAFormulaFieldMapping__c' => 'zpl__FieldName__c',
 			'zpl__LineListColumn__c' => 'External_Id__c',
 			'zpl__ProductSearchField__c' => 'External_Id__c'
 	};
 
 	/**
 	 * Map to find External Id field name for the particular object, if not present GENERAL_EXTERNAL_ID is used
 	 */
 	private Map<String, String> objectNameToExternalIdMap = new Map<String, String>{
 			'zpf__SearchBarConfiguration__c' => null,
 			'zpf__SearchField__c' => null,
 			'zpl__PreSelectSearchConfiguration__c' => 'zpl__ExternalId__c',
 			'zpl__LineLevel__c' => 'zpl__LineLevelId__c',
 			'Account' => 'UPS_Account_Number__c',
 			'Contact' => null,
 			'AccountTeamMember' => null,
 			'Individual' => null,
 			'zsx__CustomerInsight__c' => 'zsx__CustomerInsightKey__c',
 			'Contract' => 'zpl__ContractId__c',
 			'zpl__PriceLookup__c' => 'zpl__ExternalId__c',
 			'aiq_AppealStatus__c' => null,
 			'Product2' => 'Product_Code_Id__c',
 			'RecordType' => null,
 			'User' => 'SR_ID__c',
 			'aiq_Category__c' => 'aiq_EXTID__c',
 			'aiq_DealType__c' => 'aiq_EXTID__c',
 			'zpl__MatrixConfiguration__c' => 'zpl__ExternalId__c',
 			'zpl__Template__c' => 'zpl__ExternalId__c',
 			'zpl__Deal__c' => 'aiq_ExternalId__c',
 			'zpl__DealLine__c' => 'aiq_ExternalId__c',
 			'zpl__DealSubline__c' => 'aiq_ExternalId__c',
 			'aiq_TierIncentive__c' => 'aiq_ExternalId__c',
 			'aiq_TierBand__c' => 'aiq_ExternalId__c',
 			'zpl__PolicyType__c' => 'zpl__PolicyTypeId__c',
 			'zpl__UOM__c' => 'zpl__ExternalId__c',
 			'zpl__ProductUOM__c' => 'zpl__ExternalId__c',
 			'Campaign' => null,
 			'Pricebook2' => null,
 			'OpportunityHistory' => null,
 			'Opportunity' => null,
 			'OpportunityLineItem' => null, //'IDS_Integration_Key__c',
 			'zpl__NoIQACallMapping__c' => 'zpl__ExternalId__c',
 			'zpf__DataTableExtensionPointConfiguration__c' => null,
 			'zpf__DataTableConfiguration__c' => 'zpf__DataTableId__c',
 			'zpf__DataTableFieldConfiguration__c' => null,
 			'zpf__DataTableFilterConfiguration__c' => null,
 			'zpf__DataTableHeaderButtonConfig__c' => null,
 			'zpf__DataTableRowButtonConfig__c' => null,
 			'zpf__DataTableButtonEventHandler__c' => null,
 			'zpl__ProductHierarchyChangeType__c' => null,
 			'zpl__LineParameterGroup__c' => 'zpl__ExternalId__c',
 			'zpl__LineParameter__c' => 'zpl__ExternalId__c',
 			'OpportunityContactRole' => null,
 			'Total_Customer_Spend__c' => 'IDS_Integration_Key__c',
 			'Competitor_Spend__c' => null,
            'zpl__PostProcessableFilterField__c' => 'zpl__ExternalId__c'
 	};
 
 	/**
 	 * Default External Id field name
 	 */
 	private final String GENERAL_EXTERNAL_ID = 'External_Id__c';
 	private final String REFERENCE = 'REFERENCE';
 	private final String PATCH = 'PATCH';
 	private final String POST = 'POST';
 	private final String GET = 'GET';
 	private final String SERVICES_URL = '"url":"/services/data/v52.0/sobjects/';
 
 	/**
 	 * Constructor to receive all the data defined by User
 	 * @param recordId Parent master record Id, head of graph hierarchy
 	 * @param children All the Children records (Master-Detail/Lookup) we would like to create
 	 * @param lookupRecords All the Lookup records we would like to query and create relationship
 	 * (External Id should exist and be populated), otherwise will be ignored
 	 * @param secondLayer Specific Children objects we would like to check out for the Children existence and create
 	 * (children objects must be present in relatedChildrenRecords)
 	 * @param relatedLookupRecordsToCreate All the Lookup records we would like not to query but create
 	 * @param relatedLookupHardcodedRecordsMap Map to find Salesforce Id by object name, existing Lookup Records we
 	 * need to populate using Salesforce Id
 	 */
 	public GraphService2(
 			Id recordId,
 			List<String> children,
 			List<String> lookupRecords,
 			List<String> secondLayer,
 			List<String> relatedLookupRecordsToCreate,
 			Map<String, String> relatedLookupHardcodedRecordsMap
 	) {
 		this.recordId = recordId;
 		this.allRelatedChildrenRecords.addAll(children);
 		this.allRelatedLookupRecords.addAll(lookupRecords);
 		this.secondLayer.addAll(secondLayer);
 		this.relatedLookupRecordsToCreate.addAll(relatedLookupRecordsToCreate);
 		this.relatedLookupHardcodedRecordsMap.putAll(relatedLookupHardcodedRecordsMap);
 		this.parentObjectName = getObjectName();
 		this.graphParentReferenceId = 'reference_id_' + this.parentObjectName + '_1';
 		this.graphReferenceIds.add(this.parentObjectName);
 	}
 
 	/**
 	 * Method to get built graph JSON
 	 * Endpoint: {{_endpoint}}/services/apexrest/graph2/recordId + JSON body:
 	 * {
 	 *  "relatedLookupChildRecords": ["SObject1Name","SObject2Name"],
 	 *  "relatedLookupRecords": ["SObject1Name","SObject2Name"],
 	 *  "secondLayer": ["SObject1Name","SObject2Name"],
 	 *  "relatedLookupRecordsToCreate": ["SObject1Name","SObject2Name"],
 	 *  "relatedLookupHardcodedRecords": [{"Field1Name": "Field1Value"}, {"Field2Name": "Field2Value"}]
 	 * }
 	 * @return String JSON Graph ready to push to the {{_endpoint}}//services/data/v52.0/composite/graph endpoint to
 	 * create records in Salesforce org
 	 */
 	public String createGraph() {
 		/**
 		 * Create parent master object with all the children and lookups explicitly specified in
 		 * allRelatedChildrenRecords and allRelatedLookupRecords
 		 */
 		parentObject = Database.query(getQuery(this.parentObjectName, null, false));
 		/**
 		 * Building parent node with all the relevant fields and get nodes to query lookup records/ create lookup
 		 * record nodes beforehand if needed
 		 */
 		buildParentNode();
 		/**
 		 * In case we create graph for "zpl__MassEditPolicyType__c" object, at first zpl__UserEnteredParameter__c
 		 * children records should be created
 		 */
 		List<String> childrenNamesToBuilt = handleMassEditPolicyTypeChildrenCase();
 		/**
 		 * Iterate over children records of parent object to create children nodes
 		 */
 		for (String childName : childrenNamesToBuilt) {
 			/**
 			 * build nodes for particular child object with all the relevant fields and get nodes to query lookup
 			 * records/ create lookup record nodes beforehand if needed
 			 */
 			Set<Id> childrenSecondLayerIds = buildNodes(childName, parentObject, this.parentObjectName, false);
 			/**
 			 * should create second level hierarchy
 			 */
 			if (!childrenSecondLayerIds.isEmpty()) {
 				/**
 				 * query for the Second Layer object with all the children and lookups explicitly specified in
 				 * allRelatedChildrenRecords and allRelatedLookupRecords
 				 */
 				childSecondLevelObjects = Database.query(getQuery(childName, childrenSecondLayerIds, false));
 				List<SObject> sortedChildSecondLevelObjects = !objectsNotToSort.contains(childName)
 						? sortChildren(childSecondLevelObjects)
 						: new List<SObject>(childSecondLevelObjects);
 				secondLayerCounter = 1;
 				/**
 				 * Iterate over children records of second level object to create children nodes
 				 */
 				for (SObject childSecondLevelObject : sortedChildSecondLevelObjects) {
 					/**
 					 * Iterate over each child with the same Object Name
 					 */
 					for (String childSecondLayerName : objectNameToChildrenPluralNameMap.keySet()) {
 						/**
 						 * build nodes for particular child object with all the relevant fields and get nodes to query
 						 * lookup records/ create lookup record nodes beforehand if needed
 						 */
 						buildNodes(childSecondLayerName, childSecondLevelObject, childName, true);
 					}
 				}
 			}
 		}
 		return JSONGraph + JSON_END;
 	}
 
 	/**
 	 * Method to move zpl__UserEnteredParameter__c at the beginning of the list if exists
 	 * in case parent object is zpl__MassEditPolicyType__c, at first necessarily zpl__UserEnteredParameter__c children
 	  * records should be inserted, then the rest
 	 */
 	private List<String> handleMassEditPolicyTypeChildrenCase() {
 		if (this.parentObjectName != 'zpl__MassEditPolicyType__c') {
 			return new List<String> (objectNameToChildrenPluralNameParentMap.keySet());
 		}
 		if (!objectNameToChildrenPluralNameParentMap.containsKey('zpl__UserEnteredParameter__c')) {
 			return new List<String> (objectNameToChildrenPluralNameParentMap.keySet());
 		}
 		/**
 		 * Move zpl__UserEnteredParameter__c at the beginning of the list
 		 */
 		List<String> children = new List<String>(objectNameToChildrenPluralNameParentMap.keySet());
 		Integer index = children.indexOf('zpl__UserEnteredParameter__c');
 		children.remove(index);
 		children.add(0, 'zpl__UserEnteredParameter__c');
 		return children;
 	}
 
 	//------------------------- Build Query -------------------------
 
 	/**
 	 * Method to get query with all the children and lookups as a String
 	 * @param objectName object Name we create query for
 	 * @param ids Ids of the records we should query for, if null recordId defined by User will be used
 	 * @param oneLevelOnly should we query children as well or the parent record only
 	 *
 	 * @return query with all the children and lookups as a String
 	 */
 	private String getQuery(String objectName, Set<Id> ids, Boolean oneLevelOnly) {
 		if (!allRelatedChildrenRecords.isEmpty()) {
 			/**
 			 * populate Children Objects Data about current object
 			 */
 			populateChildrenObjectsInfo(objectName);
 		} else {
 			oneLevelOnly = true;
 		}
 		/**
 		 * Build query with all the necessary fields and lookup fields with External Ids
 		 */
 		query = 'SELECT ' + getAllObjectFieldsToString(objectName, true) +
 				addReferenceObjectFieldsWithExternalIds(objectName);
 		/**
 		 * build subQueries for children records
 		 */
 		if (!oneLevelOnly) {
 			/**
 			 * Iterate by children of the current object
 			 */
 			for (String childName : objectNameToChildrenPluralNameMap.keySet()) {
 				/**
 				 * Iterate over each child with the same Object Name
 				 */
 				for (String pluralName : objectNameToChildrenPluralNameMap.get(childName)) {
 					/**
 					 * Build subQuery with all the necessary fields and lookup fields with External Ids
 					 */
 					query += ', (SELECT ' +
 							getAllObjectFieldsToString(childName, true) +
 							addReferenceObjectFieldsWithExternalIds(childName) +
 							' FROM ' +
 							pluralName +
 							')';
 				}
 			}
 		}
 		/**
 		 * Add condition whether query the Parent Master Record or second layer Children
 		 */
 		query += ' FROM ' + objectName + ' WHERE ' + getIdCondition(ids);
 		return query;
 	}
 
 	/**
 	 * Method to specify condition for the 1st level (query the Parent Master Record) or 2nd level
 	 * (query second layer Children)
 	 * @param ids Ids of the records we should query for, if null recordId defined by User will be used
 	 *
 	 * @return query condition as a String
 	 */
 	private String getIdCondition(Set<Id> ids) {
 		String childrenIds = '(';
 		if (ids != null) {
 			for (Id id : ids) {
 				childrenIds += '\'' + id + '\', ';
 			}
 			childrenIds = childrenIds.substring(0, childrenIds.length() - 2);
 			childrenIds += ')';
 			return 'Id IN ' + childrenIds;
 		} else {
 			return 'Id = \'' + recordId + '\'';
 		}
 	}
 
 	//------------------------- Build PATCH Graph -------------------------
 
 	/**
 	 * Method builds parent master node with all the relevant fields and get nodes to query or create lookup records
 	 * if needed
 	 */
 	private void buildParentNode() {
 		/**
 		 * Build GET nodes to query relatedLookupRecords if needed
 		 */
 		buildGetQueryBeforeRecordGraph(parentObject);
 		/**
 		 * Populates all the parent master record fields to currentObjectFieldsMap
 		 */
 		updateCurrentObjectFieldsMap(this.parentObjectName);
 		/**
 		 * Get External Id field name of parent Master Record
 		 */
 		String externalIdFieldName = getExternalIdFieldName(this.parentObjectName);
 		/**
 		 * Creating URL (POST or PATCH) depending on whether externalId field exist on the parent master object
 		 */
 		JSONGraph += externalIdFieldName != null
 				? '{' + SERVICES_URL + this.parentObjectName + '/' + externalIdFieldName + '/' + getExternalIdFieldValue(parentObject) + '","body":{'
 				: '{' + SERVICES_URL + this.parentObjectName + '/","body":{';
 		/**
 		 * Populate parent object fields to the node (apart of lookups and object External Id field)
 		 */
 		populateObjectFields(parentObject, getAllSortedObjectFields(parentObject, false));
 		/**
 		 * Add lookup Fields to the node
 		 */
 		populateGetRecordsRelations();
 		jsonRemoveComaFromEnd();
 		/**
 		 * Specify method PATCH/POST for node creating
 		 */
 		String method = externalIdFieldName != null ? PATCH : POST;
 		JSONGraph += '},"method":"' + method + '","referenceId":"' + graphParentReferenceId + '"}';
 		/**
 		 * Populate already created records to idToGraphReferenceIdMap to be able to find Graph Reference Id by
 		 * record Salesforce Id
 		 */
 		idToGraphReferenceIdMap.put(recordId, graphParentReferenceId);
 	}
 
 	/**
 	 * Method builds children records nodes for the current object
 	 * @param childObjectName child object name to create node for
 	 * @param masterObject Parent Object, which also contains all the info about children
 	 * @param masterObjectName Parent Object Name
 	 * @param isSecondLevel Do we work with Second Layer records
 	 *
 	 * @return Ids of children records if the object is present in secondLayer List
 	 */
 	private Set<Id> buildNodes(String childObjectName, SObject masterObject, String masterObjectName, Boolean isSecondLevel) {
 		/**
 		 * get current counter depending on logic
 		 */
 		Integer counter = getCounter(childObjectName, isSecondLevel);
 		Boolean isMasterObject = masterObjectName == this.parentObjectName;
 		/**
 		 * assign Children Objects Data Maps depending on whether Master Parent Object or Second Layer Object
 		 */
 		assignRelevantRelationMaps(isMasterObject);
 		Set<Id> childrenSecondLayerIds = new Set<Id>();
 		/**
 		 * Iterate over children records names
 		 */
 		for (String pluralChildName : objectNameToChildrenPluralNameMap.get(childObjectName)) {
 			/**
 			 * retrieve children records
 			 */
 			List<SObject> childObjects = masterObject.getSObjects(pluralChildName);
 			if (childObjects == null || childObjects.isEmpty()) continue;
 			/**
 			 * sort children records
 			 */
 			List<SObject> sortedChildObjects = !objectsNotToSort.contains(childObjectName)
 					? sortChildren(childObjects)
 					: new List<SObject>(childObjects);
 			/**
 			 * Iterate over children sorted records
 			 */
 			for (SObject childObject : sortedChildObjects) {
 				idToCounterMap.put((Id) childObject.get('Id'), counter);
 				String lookupFieldName = childrenPluralNameToParentLookupLinkMap.get(pluralChildName);
 				/**
 				 * Define graph Parent reference Id depending on whether parent is Master Object or not
 				 */
 				String graphParentReferenceId = isMasterObject
 						? this.graphParentReferenceId
 						: 'reference_id_' + masterObjectName + '_' + idToCounterMap.get((Id) childObject.get(lookupFieldName));
 				/**
 				 * Gathering Ids of children records if the object is present in secondLayer List
 				 */
 				if (secondLayer.contains(childObjectName)) {
 					childrenSecondLayerIds.add((Id) childObject.get('Id'));
 				}
 				/**
 				 * build GET nodes to query relatedLookupRecords
 				 */
 				Boolean hasQuery = buildGetQueryBeforeRecordGraph(childObject);
 				if (hasQuery) {
 					jsonRemoveComaFromEnd();
 				}
 				/**
 				 * create nodes for Reference Objects from referenceFieldsToCreate beforehand
 				 */
 				Boolean createdReferenceObjects = buildReferenceObjectBeforeRecordGraph(childObject);
 				if (createdReferenceObjects) {
 					jsonRemoveComaFromEnd();
 				}
 				/**
 				 * assign Children Objects Data Maps depending on whether Master Parent Object or Second Layer Object
 				 */
 				assignRelevantRelationMaps(isMasterObject);
 				/**
 				 * Populate all the fields for the current record to currentObjectFieldsMap
 				 */
 				updateCurrentObjectFieldsMap(childObjectName);
 				String externalIdFieldName = getExternalIdFieldName(childObjectName);
 				/**
 				 * Creating URL (POST or PATCH) depending on whether externalId field exist on the child object
 				 */
 				JSONGraph += externalIdFieldName != null
 						? ',{' + SERVICES_URL + childObjectName + '/' + externalIdFieldName + '/' +
 								getExternalIdFieldValue(childObject) + '","body":{'
 						: ',{' + SERVICES_URL + childObjectName + '/","body":{';
 				populateObjectFields(childObject, getAllSortedObjectFields(childObject, false));
 				/**
 				 * Add lookup Fields to the node
 				 */
 				populateGetRecordsRelations();
 				/**
 				 * creating lookup for the parent object
 				 */
 				JSONGraph += '"' + childrenPluralNameToParentLookupLinkMap.get(pluralChildName) + '":"@{' +
 						graphParentReferenceId + '.id}"';
 				/**
 				 * Define create record node method: POST/PATCH
 				 */
 				String method = externalIdFieldName != null ? PATCH : POST;
 				String graphReferenceId = 'reference_id_' + childObjectName + '_' + counter++;
 				/**
 				 * If the same graph reference Id exists add underscore at the end
 				 */
 				graphReferenceId = graphReferenceIds.contains(graphReferenceId) ?
 						graphReferenceId + '_' :
 						graphReferenceId;
 				graphReferenceIds.add(graphReferenceId);
 				/**
 				 * Assign graph reference Id to the created record node
 				 */
 				JSONGraph += '},"method":"' + method + '","referenceId":"' + graphReferenceId + '"}';
 				if (isSecondLevel) secondLayerCounter++;
 				/**
 				 * Populate already created records to idToGraphReferenceIdMap to be able to find Graph Reference Id by
 				 * record Salesforce Id
 				 */
 				idToGraphReferenceIdMap.put((Id) getFieldValue(childObject, 'Id'), graphReferenceId);
 			}
 		}
 		return childrenSecondLayerIds;
 	}
 
 	/**
 	 * Method returns counter for further creating graph reference Ids
 	 * @param childName Name of child object
 	 * @param isSecondLevel do we work with creating second level objects
 	 *
 	 * @return Integer counter depending on the logic
 	 */
 	private Integer getCounter(String childName, Boolean isSecondLevel) {
 		if (isSecondLevel) {
 			return secondLayerCounter;
 		}
 		return childName == this.parentObjectName ? 2 : 1;
 	}
 
 	/**
 	 * Method populates all the fields for the record we work with at the moment
 	 * @param objectName Name of current object
 	 */
 	private void updateCurrentObjectFieldsMap(String objectName) {
 		currentObjectFieldsMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
 	}
 
 	/**
 	 * Method to build GET nodes to query relatedLookupRecords if needed
 	 * @param obj current object to check out should we create GET nodes to query relatedLookupRecords
 	 *
 	 * @return Boolean value, TRUE if at least one GET node was created
 	 */
 	private Boolean buildGetQueryBeforeRecordGraph(SObject obj) {
 		Boolean getNodeExist = false;
 		Boolean hasGetQuery = false;
 		String objectName = getObjectName(obj);
 		/**
 		 * Populate all the fields for current object to currentObjectFieldsMap
 		 */
 		updateCurrentObjectFieldsMap(objectName);
 		/**
 		 * Reset all the related data for the current object
 		 */
 		allPopulatedReferenceFieldsToGet = new Set<String>();
 		emptyReferenceFields = new Set<String>();
 		referenceFieldsToCreate = new Set<String>();
 		referenceFieldsToHardCode = new Set<String>();
 		referenceFieldsToCheckIfAlreadyCreatedByGraph = new Map<String, Id>();
 		oldGlobalCounter = globalCounter;
 		/**
 		 * Iterate over all the Reference Field Names for current object
 		 */
 		for (String referenceFieldName : allReferenceFieldsToGetByObjectNameMap.get(objectName)) {
 			String relatedObjectName = referenceFieldNameToObjectNameMap.get(referenceFieldName);
 			/**
 			 * populate objects reference Fields Names which should be hardcoded for the current object if present
 			 * in relatedLookupHardcodedRecordsMap defined by user
 			 */
 			if (relatedLookupHardcodedRecordsMap.containsKey(relatedObjectName)) {
 				referenceFieldsToHardCode.add(referenceFieldName);
 				continue;
 			}
 			/**
 			 * populate object reference Fields Names which should be created for the current object if present
 			 * in relatedLookupRecordsToCreate defined by user
 			 */
 			if (relatedLookupRecordsToCreate.contains(relatedObjectName)) {
 				referenceFieldsToCreate.add(referenceFieldName);
 				continue;
 			}
 			/**
 			 * populate objects Reference Fields Names and their Ids which already were created with graph nodes
 			 * beforehand
 			 */
 			if (alreadyCreatedObjectsWithoutExternalIdField.contains(relatedObjectName) && !fieldValueIsNull(obj, referenceFieldName)) {
 				referenceFieldsToCheckIfAlreadyCreatedByGraph.put(referenceFieldName, (Id) getFieldValue(obj, referenceFieldName));
 				continue;
 			}
 			/**
 			 * if reference field is not populated add field to emptyReferenceFields
 			 */
 			if (fieldValueIsNull(obj, referenceFieldName)) {
 				populateEmptyReferenceField(referenceFieldName);
 				continue;
 			}
 			String externalId = getExternalIdValueFromReferenceField(obj, referenceFieldName);
 			/**
 			 * if reference object does not have External Id field add field to emptyReferenceFields
 			 */
 			if (externalId == null) {
 				populateEmptyReferenceField(referenceFieldName);
 				continue;
 			}
 			/**
 			 * GET node will be created to query this reference record
 			 */
 			/**
 			 * populate current Reference Field Name to the allPopulatedReferenceFieldsToGet for further creating
 			 * lookup to this record
 			 */
 			allPopulatedReferenceFieldsToGet.add(referenceFieldName);
 			String relationObjectName = getReferenceObjectNameByFieldName(referenceFieldName);
 			String externalIdFieldName = getExternalIdFieldName(relationObjectName);
 			/**
 			 * add comma if first GET node was created
 			 */
 			if (objectName != this.parentObjectName && !getNodeExist) {
 				JSONGraph += ', ';
 				getNodeExist = true;
 			}
 			String referenceId = 'reference_id_' + relationObjectName + '_' + globalCounter++;
 			/**
 			 * If the same graph reference Id exists add underscore at the end
 			 */
 			referenceId = graphReferenceIds.contains(referenceId) ? referenceId + '_' : referenceId;
 			/**
 			 * add current graph Reference Id to graphReferenceIds
 			 */
 			graphReferenceIds.add(referenceId);
 			/**
 			 * create GET node
 			 */
 			JSONGraph += '{"method": "' + GET + '", ' + SERVICES_URL + relationObjectName + '/' + externalIdFieldName + '/' + externalId + '", "referenceId": "' + referenceId + '" }, ';
 			hasGetQuery = true;
 		}
 		return hasGetQuery;
 	}
 
 	/**
 	 * Method to create Reference Objects nodes beforehand, if defined by User in relatedLookupRecordsToCreate
 	 * @param obj Object to create reference records node before to use reference graph Ids as lookups
 	 *
 	 * @return TRUE if at least one node was created
 	 */
 	private Boolean buildReferenceObjectBeforeRecordGraph(SObject obj) {
 		Boolean createdReferenceObjects = false;
 		oldReferenceToCreateCounter = referenceToCreateCounter;
 		/**
 		 * Iterate by records to Create nodes
 		 */
 		for (String referenceFieldName : referenceFieldsToCreate) {
 			String referenceObjectName = referenceFieldNameToObjectNameMap.get(referenceFieldName);
 			Id referenceObjectId = (Id) getFieldValue(obj, referenceFieldName);
 			/**
 			 * Build query as String to retrieve all the record's fields
 			 */
 			String query = getQuery(referenceObjectName, new Set<Id>{referenceObjectId}, true);
 			/**
 			 * Query for the particular record to retrieve all the fields
 			 */
 			SObject referenceObjectToCreate = Database.query(query)[0];
 			/**
 			 * create POST url
 			 */
 			JSONGraph += ',{' + SERVICES_URL + referenceObjectName + '/","body":{';
 			/**
 			 * populate fields to the node
 			 */
 			populateObjectFields(referenceObjectToCreate, getAllSortedObjectFields(referenceObjectToCreate, false));
 			jsonRemoveComaFromEnd();
 			/**
 			 * create Graph Reference Id
 			 */
 			String referenceId = 'reference_id_' + referenceObjectName + '_' + referenceToCreateCounter++;
 			/**
 			 * add current graph Reference Id to graphReferenceIds
 			 */
 			graphReferenceIds.add(referenceId);
 			/**
 			 * create POST node
 			 */
 			JSONGraph += '},"method":"' + POST + '","referenceId":"' + referenceId + '"}, ';
 			createdReferenceObjects = true;
 		}
 		return createdReferenceObjects;
 	}
 
 	/**
 	 * Method to populate Empty Reference Field for the current object, and this reference object was defined by user in
 	 * allRelatedLookupRecords
 	 * @param referenceFieldName reference Field Name which is empty
 	 */
 	private void populateEmptyReferenceField(String referenceFieldName) {
 		String relationObjectName = referenceFieldNameToObjectNameMap.get(referenceFieldName);
 		if (allRelatedLookupRecords.contains(relationObjectName)) {
 			emptyReferenceFields.add(referenceFieldName);
 		}
 	}
 
 	/**
 	 * Method to add lookup Fields to the node
 	 */
 	private void populateGetRecordsRelations() {
 		/**
 		 * add reference fields which were queried with GET nodes beforehand in graph
 		 */
 		for (String referenceFieldName : allPopulatedReferenceFieldsToGet) {
 			String relationObjectName = getReferenceObjectNameByFieldName(referenceFieldName);
 			JSONGraph += '"' + referenceFieldName + '":"@{reference_id_' + relationObjectName + '_' + oldGlobalCounter++ + '.Id}", ';
 		}
 		/**
 		 * add reference fields which were created with POST/PATCH nodes beforehand in graph
 		 */
 		for (String referenceFieldName : referenceFieldsToCreate) {
 			String relationObjectName = referenceFieldNameToObjectNameMap.get(referenceFieldName);
 			JSONGraph += '"' + referenceFieldName + '":"@{reference_id_' + relationObjectName + '_' + oldReferenceToCreateCounter++ + '.id}", ';
 		}
 		/**
 		 * Add reference fields with hardcoded values defined by User
 		 */
 		for (String referenceFieldName : referenceFieldsToHardCode) {
 			String relationObjectName = referenceFieldNameToObjectNameMap.get(referenceFieldName);
 			String relationObjectId = relatedLookupHardcodedRecordsMap.get(relationObjectName);
 			JSONGraph += '"' + referenceFieldName + '":"' + relationObjectId + '", ';
 		}
 		/**
 		 * add reference fields for records created with graph as POST/PATCH nodes beforehand
 		 */
 		for (String referenceFieldName : referenceFieldsToCheckIfAlreadyCreatedByGraph.keySet()) {
 			String referenceFieldId = referenceFieldsToCheckIfAlreadyCreatedByGraph.get(referenceFieldName);
 			/**
 			 * retrieve graph reference id
 			 */
 			if (idToGraphReferenceIdMap.containsKey(referenceFieldId)) {
 				JSONGraph += '"' + referenceFieldName + '":"@{' + idToGraphReferenceIdMap.get(referenceFieldId) + '.id}", ';
 			}
 		}
 	}
 
 	/**
 	 * Method to populate object fields to the node (apart of lookups and object External Id field)
 	 * @param obj Object to get fields and values to populate
 	 * @param fieldsToPopulate fields we want to populate to graph for this object
 	 */
 	private void populateObjectFields(sObject obj, List<String> fieldsToPopulate) {
 		String externalIdFieldName = getExternalIdFieldName(getObjectName(obj));
 		for (String field : fieldsToPopulate) {
 			/**
 			 * populate all the fields apart of External Id field
 			 */
 			if (field != externalIdFieldName) {
 				String fieldValue = fieldValueIsNull (obj, field) ? 'null, ' : '"' + getFieldValue(obj, field).escapeUnicode() + '", ';
 				JSONGraph += '"' + field + '":' + fieldValue;
 			}
 		}
 	}
 
 	/**
 	 * Method to get all object fields sorted alphabetically
 	 * @param obj Object to get all fields from
 	 * @param considerReference should query reference fields
 	 *
 	 * @return
 	 */
 	private List<String> getAllSortedObjectFields(sObject obj, Boolean considerReference) {
 		/**
 		 * get all object fields
 		*/
 		Set<String> allFields = getAllObjectFields(getObjectName(obj), considerReference);
 		/**
 		 * sort fields alphabetically
 		 */
 		List<String> sortedFields = new List<String>(allFields);
 		sortedFields.sort();
 		return sortedFields;
 	}
 
 	//------------------------- Populate Child Objects Info -------------------------
 
 	/**
 	 * Method to populate Children Objects Data about object
 	 * @param objectName Name of object to populate Data
 	 */
 	private void populateChildrenObjectsInfo(String objectName) {
 		Boolean isMasterObject = objectName == this.parentObjectName;
 		/**
 		 * Assign children Objects Data Maps to Master/Second Layer Objects Data Maps
 		 */
 		assignRelevantRelationMaps(isMasterObject);
 		/**
 		 * get object ChildRelationships Data for current object
 		 */
 		List<ChildRelationship> childrenRelationshipList = getAllChildrenRelationshipList(objectName);
 		/**
 		 * Iterate over object ChildRelationships Data
 		 */
 		for (ChildRelationship child : childrenRelationshipList) {
 			String childObjectName = String.valueof(child.getChildSObject());
 			/**
 			 * Populate data only about children defined by user
 			 */
 			if (allRelatedChildrenRecords.contains(childObjectName)) {
 				String childPluralName = String.valueof(child.getRelationshipName());
 				if (pluralNamesToExclude.contains(childPluralName)) continue;
 				String parentLookupLink = String.valueof(child.getField());
 				/**
 				 * Populate child object plural name to object name
 				 */
 				populateRelatedObjectMap(childObjectName, childPluralName, objectNameToChildrenPluralNameMap);
 				/**
 				 * Populate parent lookup field name by child object plural name
 				 */
 				childrenPluralNameToParentLookupLinkMap.put(childPluralName, parentLookupLink);
 			}
 		}
 	}
 
 	/**
 	 * Method to get object ChildRelationships Data
 	 * @param objectName Object Name to get ChildRelationships Data
 	 *
 	 * @return ChildRelationships Data for current object
 	 */
 	private List<ChildRelationship> getAllChildrenRelationshipList(String objectName) {
 		return Schema.getGlobalDescribe().get(objectName).getDescribe().getChildRelationships();
 	}
 
 	/**
 	 * Method to assign Children Objects Data Maps for Master Parent Object or Second Layer Object
 	 * @param isMasterObject defines whether Master Parent Object or Second Layer Object
 	 */
 	private void assignRelevantRelationMaps(Boolean isMasterObject) {
 		objectNameToChildrenPluralNameMap = getObjectNameToChildrenPluralNameMap(isMasterObject);
 		childrenPluralNameToParentLookupLinkMap = getChildrenPluralNameToParentLookupLinkMap(isMasterObject);
 	}
 
 	/**
 	 * Method to assign appropriate objectNameToChildrenPluralNameMap depending on Master/Second Layer object
 	 * @param isMasterObject defines whether Master Parent Object or Second Layer Object
 	 *
 	 * @return appropriate objectNameToChildrenPluralNameMap
 	 */
 	private Map<String, List<String>> getObjectNameToChildrenPluralNameMap(Boolean isMasterObject) {
 		return isMasterObject
 				? objectNameToChildrenPluralNameParentMap
 				: objectNameToChildrenPluralNameChildrenMap;
 	}
 
 	/**
 	 * Method to assign appropriate objectNameToChildrenPluralNameMap depending on Master/Second Layer object
 	 * @param isMasterObject defines whether Master Parent Object or Second Layer Object
 	 *
 	 * @return appropriate childrenPluralNameToParentLookupLinkMap
 	 */
 	private Map<String, String> getChildrenPluralNameToParentLookupLinkMap(Boolean isMasterObject) {
 		return isMasterObject
 				? childPluralNameToParentLookupLinkParentMap
 				: childPluralNameToParentLookupLinkChildrenMap;
 	}
 
 	//------------------------- Get All Object Fields Logic -------------------------
 
 	/**
 	 * Method to get all object fields to query as a String, comma-separated
 	 * @param objectName Object Name
 	 * @param considerReference should query reference fields
 	 *
 	 * @return all object fields to query as a String, comma-separated
 	 */
 	private String getAllObjectFieldsToString(String objectName, Boolean considerReference) {
 		return String.join(new List<String>(getAllObjectFields(objectName, considerReference)), ', ');
 	}
 
 	/**
 	 * Method to get all object fields
 	 * @param objectName Object Name
 	 * @param considerReference should query reference fields
 	 *
 	 * @return all object fields to query
 	 */
 	private Set<String> getAllObjectFields(String objectName, Boolean considerReference) {
 		Set<String> allFieldsToExclude = getAllFieldsToExclude(objectName, considerReference);
 		currentFieldsToPopulate = new Set<String>();
 		/**
 		 * Iterate over all the object fields
 		 */
 		for (SObjectField field : currentObjectFieldsMap.values()) {
 			String fieldApiName = field.getDescribe().getName();
 			if (!allFieldsToExclude.contains(fieldApiName)) {
 				currentFieldsToPopulate.add(fieldApiName);
 			}
 		}
 		return currentFieldsToPopulate;
 	}
 
 	/**
 	 * Method to get all the fields we should exclude from query
 	 * @param objectName Object Name
 	 * @param considerReference Should query reference fields
 	 *
 	 * @return All the fields we should exclude from query
 	 */
 	private Set<String> getAllFieldsToExclude(String objectName, Boolean considerReference) {
 		Set<String> allFieldsToExclude = new Set<String>();
 		allFieldsToExclude.addAll(standardFieldsToExclude);
 		if (badFieldToInsertMap.containsKey(objectName)) {
 			allFieldsToExclude.addAll(badFieldToInsertMap.get(objectName));
 		}
 		allFieldsToExclude.addAll(getFieldsToExclude(objectName, considerReference));
 		return allFieldsToExclude;
 	}
 
 	/**
 	 * Method to get fields we should exclude from query and populate all the reference lookup fields we would like
 	 * to query id considerReference = true
 	 * @param objectName Object Name
 	 * @param considerReference Should query reference fields
 	 *
 	 * @return All the fields we should exclude from query
 	 */
 	private Set<String> getFieldsToExclude(String objectName, Boolean considerReference) {
 		Set<String> fieldsToExclude = new Set<String>();
 		allCurrentReferenceFields = new Set<String>();
 		/**
 		 * Populate all the fields for the current record to currentObjectFieldsMap
 		 */
 		updateCurrentObjectFieldsMap(objectName);
 		/**
 		 * Iterate over all the object fields
 		 */
 		for (SObjectField field : currentObjectFieldsMap.values()) {
 			String fieldApiName = field.getDescribe().getName();
 			if (isReferenceField(field)) {
 				if (considerReference) {
 					/**
 					 * populate all the reference lookup fields we would like to query for the current object
 					 */
 					populateAllCurrentReferenceFields(fieldApiName, objectName);
 				} else if (!emptyReferenceFields.contains(fieldApiName)) {
 					fieldsToExclude.add(fieldApiName);
 				}
 				/**
 				 * Exclude Formula, Compoundable and not Updatable fields
 				 */
 			} else if (isCalculated(field) || isCompoundable(field) || !isUpdatable(field)) {
 				fieldsToExclude.add(fieldApiName);
 			}
 		}
 		return fieldsToExclude;
 	}
 
 	/**
 	 * Method to populate all the reference lookup fields we would like to query for the current object
 	 * based on User request
 	 * @param fieldApiName Field API Name
 	 * @param objectName Object Name
 	 */
 	private void populateAllCurrentReferenceFields(String fieldApiName, String objectName) {
 		/**
 		 * get Reference Object Name by Field Name for the current object
 		 */
 		String referenceObjectName = getReferenceObjectNameByFieldName(fieldApiName);
 		List<String> badFieldToInsert = badFieldToInsertMap.containsKey(objectName)
 				? new List<String>(badFieldToInsertMap.get(objectName))
 				: new List<String>();
 		/**
 		 * validate whether we should query this particular reference field
 		 */
 		if (!standardFieldsToExclude.contains(fieldApiName) &&
 				!badFieldToInsert.contains(fieldApiName) &&
 				(
 						allRelatedLookupRecords.contains(referenceObjectName) ||
 								relatedLookupRecordsToCreate.contains(referenceObjectName)) ||
 				relatedLookupHardcodedRecordsMap.containsKey(referenceObjectName)
 		) {
 			allCurrentReferenceFields.add(fieldApiName);
 		}
 	}
 
 	//------------------------- External Id Logic -------------------------
 
 	/**
 	 * Method to add comma before a String in case object has any reference Ids
 	 * @param objectName Name of current object
 	 *
 	 * @return String of all Reference Object Field Names with External Ids for current object with comma beforehand
 	 */
 	private String addReferenceObjectFieldsWithExternalIds(String objectName) {
 		String referenceObjectsWithExternalIdsFields = getReferenceObjectsWithExternalIdsToString(objectName);
 		if (referenceObjectsWithExternalIdsFields != '') {
 			return ', ' + referenceObjectsWithExternalIdsFields;
 		}
 		return '';
 	}
 
 	/**
 	 * Method to get Reference Field Names with External Ids as a String for current object
 	 * @param objectName current Object Name to get reference fields with Ids
 	 *
 	 * @return String of all Reference Field Object Names with External Ids for current object
 	 */
 	private String getReferenceObjectsWithExternalIdsToString(String objectName) {
 		return String.join(new List<String>(getReferenceObjectsWithExternalIds(objectName)), ', ');
 	}
 
 	/**
 	 * Method to get Reference Object Field Names for current object which have External Ids
 	 * @param objectName Name of current object
 	 *
 	 * @return Set of Reference Object Field Names which have External Ids
 	 */
 	private Set<String> getReferenceObjectsWithExternalIds(String objectName) {
 		Set<String> fieldsWithExternalIdToReturn = new Set<String>();
 		/**
 		 * populate all the Reference Field Names by Object Name Map with Object Name key
 		 */
 		allReferenceFieldsToGetByObjectNameMap.put(objectName, new Set<String>());
 		/**
 		 * Iterate over Reference Fields for current object
 		 */
 		for (String fieldApiName : allCurrentReferenceFields) {
 			String relationObjectName = getReferenceObjectNameByFieldName(fieldApiName);
 			/**
 			 * Populate Reference Field which has External Id
 			 */
 			if (shouldQueryReferenceObjectExternalId(relationObjectName, fieldApiName, objectName)) {
 				fieldsWithExternalIdToReturn.add(getRelationshipName(fieldApiName) + '.' + getExternalIdFieldName(relationObjectName));
 			}
 		}
 		return fieldsWithExternalIdToReturn;
 	}
 
 	/**
 	 * Method to gather data for Lookup Records
 	 * @param relationObjectName relation Object Name
 	 * @param fieldApiName field Api Name
 	 * @param objectName current Object Name
 	 *
 	 * @return TRUE if we should query lookup record with External Id
 	 */
 	private Boolean shouldQueryReferenceObjectExternalId(String relationObjectName, String fieldApiName, String objectName) {
 		/**
 		 * Should we query related record from allRelatedLookupRecords defined by User
 		 */
 		if (allRelatedLookupRecords.contains(relationObjectName) && relationObjectName != null) {
 			/**
 			 * In case record does not have External Id field
 			 */
 			if (getExternalIdFieldName(relationObjectName) == null) {
 				/**
 				 * Populate as already created object with POST method, so graph reference Id can be taken from graph
 				 * created node
 				 */
 				alreadyCreatedObjectsWithoutExternalIdField.add(relationObjectName);
 				/**
 				 * Map Reference Field Name to Object Name
 				 */
 				allReferenceFieldsToGetByObjectNameMap.get(objectName).add(fieldApiName);
 				/**
 				 * Map Relation Object Name to Reference Field Name
 				 */
 				referenceFieldNameToObjectNameMap.put(fieldApiName, relationObjectName);
 			} else {
 				/**
 				 * Map Reference Field Name to Object Name
 				 */
 				allReferenceFieldsToGetByObjectNameMap.get(objectName).add(fieldApiName);
 				/**
 				 * Map Relation Object Name to Reference Field Name
 				 */
 				referenceFieldNameToObjectNameMap.put(fieldApiName, relationObjectName);
 				return true;
 			}
 		}
 		/**
 		 * Should we hardcode related record value
 		 */
 		if (relatedLookupHardcodedRecordsMap.containsKey(relationObjectName)) {
 			/**
 			 * Map Reference Field Name to Object Name
 			 */
 			allReferenceFieldsToGetByObjectNameMap.get(objectName).add(fieldApiName);
 			/**
 			 * Map Relation Object Name to Reference Field Name
 			 */
 			referenceFieldNameToObjectNameMap.put(fieldApiName, relationObjectName);
 		}
 		/**
 		 * Should we create related record beforehand
 		 */
 		if (relatedLookupRecordsToCreate.contains(relationObjectName) && relationObjectName != null) {
 			/**
 			 * Map Reference Field Name to Object Name
 			 */
 			allReferenceFieldsToGetByObjectNameMap.get(objectName).add(fieldApiName);
 			/**
 			 * Map Relation Object Name to Reference Field Name
 			 */
 			referenceFieldNameToObjectNameMap.put(fieldApiName, relationObjectName);
 		}
 
 		return false;
 	}
 
 	/**
 	 * Method to get External Id Value from Reference Field from the current object
 	 * @param obj Object to get External Id Value From Reference Field
 	 * @param referenceFieldName Reference Field Name to get External Id
 	 *
 	 * @return External Id Value from the Reference Field from the current object
 	 */
 	private String getExternalIdValueFromReferenceField(sObject obj, String referenceFieldName) {
 		String parentObjectName = getReferenceObjectNameByFieldName(referenceFieldName);
 		String parentExternalIdFieldName = getExternalIdFieldName(parentObjectName);
 		String parentRelationshipName = getRelationshipName(referenceFieldName);
 		return String.valueOf(obj.getSObject(parentRelationshipName).get(parentExternalIdFieldName));
 	}
 
 	/**
 	 * Method for getting External Id Field Name by Object Name based on objectNameToExternalIdMap
 	 * @param objectName Object name which External Id Field Name we want to get
 	 *
 	 * @return External Id Field Name
 	 */
 	private String getExternalIdFieldName(String objectName) {
 		if (objectNameToExternalIdMap.containsKey(objectName)) {
 			return objectNameToExternalIdMap.get(objectName);
 		}
 		return GENERAL_EXTERNAL_ID;
 	}
 
 	/**
 	 * Method to get External Id Value for the current object
 	 * @param obj Object External Id Value we want to get
 	 *
 	 * @return Value of the External Id Field or Salesforce Id in case External Id Field is not populated
 	 */
 	private String getExternalIdFieldValue(SObject obj) {
 		String externalIdFieldName = getExternalIdFieldName(getObjectName(obj));
 		String externalIdFieldValue = getFieldValue(obj, externalIdFieldName);
 		return externalIdFieldValue != null ? externalIdFieldValue : getFieldValue(obj, 'Id');
 	}
 
 	//------------------------- Help Logic -------------------------
 
 	/**
 	 * Method to check out whether the Field Value is NULL
 	 * @param obj object to get field value
 	 * @param fieldName Field Name whose value we want to check
 	 *
 	 * @return TRUE if Field Value is not a NULL
 	 */
 	private Boolean fieldValueIsNull(sObject obj, String fieldName) {
 		if (obj.get(fieldName) == null) return true;
 		return getFieldValue(obj, fieldName) != null ? false : true;
 	}
 
 	/**
 	 * Method to check is field is compoundable (e.g. Full Name on User)
 	 * @param field Field to check
 	 *
 	 * @return TRUE if field is Compoundable
 	 */
 	private Boolean isCompoundable(SObjectField field) {
 		return field.getDescribe().getLabel().contains('Full') &&
 				field.getDescribe().getCompoundFieldName() == null &&
 				field.getDescribe().getLabel().deleteWhitespace() != field.getDescribe().getName();
 	}
 
 	/**
 	 * Method to check if field is a Reference Field
 	 * @param field Field to check
 	 *
 	 * @return TRUE if field is Reference Field
 	 */
 	private Boolean isReferenceField(SObjectField field) {
 		return String.valueOf(field.getDescribe().getType()) == REFERENCE;
 	}
 
 	/**
 	 * Method to check whether field can be updated
 	 * @param field Field to check
 	 *
 	 * @return TRUE if field can be updated
 	 */
 	private Boolean isUpdatable(SObjectField field) {
 		return field.getDescribe().isUpdateable();
 	}
 
 	/**
 	 * Method to check whether field is a formula field
 	 * @param field Field to check
 	 *
 	 * @return TRUE if field is formula field
 	 */
 	private Boolean isCalculated(SObjectField field) {
 		return field.getDescribe().isCalculated();
 	}
 
 	/**
 	 * Method to get Lookup Relationship Name by Field Api Name from the current record
 	 * @param fieldApiName Api Name of the field
 	 *
 	 * @return Lookup Relationship Name of the field
 	 */
 	private String getRelationshipName(String fieldApiName) {
 		return currentObjectFieldsMap.get(fieldApiName).getDescribe().getRelationshipName();
 	}
 
 	/**
 	 * Method to get Reference Object Name by Reference Field Name on the current object
 	 * @param fieldApiName Api Name of the field
 	 *
 	 * @return Reference Object Name
 	 */
 	private String getReferenceObjectNameByFieldName(String fieldApiName) {
 		List<Schema.SObjectType> referenceObjects = currentObjectFieldsMap.get(fieldApiName).getDescribe().getReferenceTo();
 		if (referenceObjects.isEmpty() || referenceObjects == null) return null;
 		return referenceObjects[0]?.getDescribe().getName();
 	}
 
 	/**
 	 * Method to get parent master object name by parent master record Id
 	 * @return parent master object name
 	 */
 	private String getObjectName() {
 		return recordId.getSobjectType().getDescribe().getName();
 	}
 
 	/**
 	 * Method to get object name from object
 	 * @param obj Object to get its name
 	 *
 	 * @return object name
 	 */
 	private String getObjectName(SObject obj) {
 		return obj.getSobjectType().getDescribe().getName();
 	}
 
 	/**
 	 * Method to get field value
 	 * @param obj Object to get field value
 	 * @param field Field Name
 	 *
 	 * @return Field value of given object
 	 */
 	private String getFieldValue(sObject obj, String field) {
 		if (obj.get(field) == null) return null;
 		/**
 		 * Check out if field type is DateTime and contains whitespace, if so additional logic needed
 		 */
 		Boolean isDateTimeField = field.contains('Date') || field.contains('Timestamp');
 		Boolean containsSpaceBetweenDateAndTime = String.valueOf(obj.get(field)).contains(' ');
 		return isDateTimeField && containsSpaceBetweenDateAndTime
 				? convertDateTimeToString(obj, field)
 				: String.valueOf(obj.get(field));
 	}
 
 	/**
 	 * Method to convert DateTime to Date before getting field Value
 	 * @param obj Object to get field value
 	 * @param field DateTime field name
 	 *
 	 * @return DateTime field value of given object converted to Date value
 	 */
 	private String convertDateTimeToString(sObject obj, String field) {
 		return String.valueOf(Date.valueOf(obj.get(field)));
 	}
 
 	/**
 	 * Method to populate given map with key-List<value>
 	 * @param key Key to populate
 	 * @param value Value to populate
 	 * @param mapToPopulate Map to work with
 	 */
 	private void populateRelatedObjectMap(String key, String value, Map<String, List<String>> mapToPopulate) {
 		if (!mapToPopulate.containsKey(key)) {
 			mapToPopulate.put(key, new List<String>());
 		}
 		mapToPopulate.get(key).add(value);
 	}
 
 	/**
 	 * Method to remove coma and whitespace at the end of String JSONGraph if exist
 	 */
 	private void jsonRemoveComaFromEnd() {
 		JSONGraph = JSONGraph.removeEnd(', ');
 	}
 
 	//------------------------- Comparable -------------------------
 
 	/**
 	 * Method to sort objects
 	 * @param childrenObjects List of objects to sort
 	 *
 	 * @return List of sorted objects
 	 */
 	private List<SObject> sortChildren(List<SObject> childrenObjects) {
 		if (childrenObjects.size() <= 1) {
 			return childrenObjects;
 		}
 		List<ObjectWrapper> wrappers = new List<ObjectWrapper>();
 		for (SObject child : childrenObjects) {
 			wrappers.add(new ObjectWrapper(child));
 		}
 		wrappers.sort();
 		List<SObject> sortedChildrenObjects = new List<SObject>();
 		for (ObjectWrapper wrapper : wrappers) {
 			sortedChildrenObjects.add(wrapper.obj);
 		}
 		return sortedChildrenObjects;
 	}
 
 	/**
 	 * Sorting inner cLass to sort objects by providing 1st compared Field and 2nd Compared Field if needed
 	 */
 	class ObjectWrapper implements Comparable {
 		SObject obj;
 		String objectName;
 		String comparableField;
 
 		ObjectWrapper(SObject obj) {
 			this.obj = obj;
 			this.objectName = obj.getSobjectType().getDescribe().getName();
 			mapComparableField();
 		}
 
 		/**
 		 * Get field by which we compare
 		 */
 		private void mapComparableField() {
 			comparableField = GraphService2.objectToFirstFieldToCompareMap.containsKey(this.objectName)
 					? obj.get(GraphService2.objectToFirstFieldToCompareMap.get(this.objectName)).toString()
 					: obj.get(GraphService2.COMPARABLE_FIELD).toString();
 		}
 
 		/**
 		 * Method to compare objects by Compared Field Value and if equal compare by 2nd Field Value
 		 * @param objToCompare object to compare with
 		 *
 		 * @return
 		 */
 		public Integer compareTo(Object objToCompare) {
 			objectWrapper comparedObject = (objectWrapper) objToCompare;
 			if (comparableField == comparedObject.comparableField) {
 				if (!GraphService2.objectToSecondFieldToCompareMap.containsKey(this.objectName)) {
 					return 0;
 				} else {
 					/**
 					 * Retrieve second field to compare objects if exist
 					 */
 					String comparableField2Name = GraphService2.objectToSecondFieldToCompareMap.get(this.objectName);
 					/**
 					 * Compare by second field if exist, otherwise use SalesForce Id for comparing
 					 */
 					String comparableField2Value = obj.get(comparableField2Name) != null
 							? obj.get(comparableField2Name).toString()
 							: obj.get('Id').toString();
 
 					String comparableField2ToCompareValue = comparedObject.obj.get(comparableField2Name).toString();
 					if (comparableField2Value == comparableField2ToCompareValue) {
 						return 0;
 					}
 					if (comparableField2Value > comparableField2ToCompareValue) {
 						return 1;
 					}
 					return -1;
 				}
 			}
 			if (comparableField > comparedObject.comparableField) {
 				return 1;
 			}
 			return -1;
 		}
 	}
}