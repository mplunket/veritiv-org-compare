@RestResource(UrlMapping='/graph2/*')
global class GraphRestResource2 {
 
 	@HttpPost
 	global static void getRecord() {
 		RestRequest request = RestContext.request;
 		String id = request.requestURI.substring(request.requestURI.lastIndexOf('/') + 1);
 
 		List<String> children = getRelatedRecords(
 				request.requestBody.toString(),
 				'relatedChildrenRecords'
 		);
 		List<String> lookupRecords = getRelatedRecords(
 				request.requestBody.toString(),
 				'relatedLookupRecords'
 		);
 		List<String> secondLayer = getRelatedRecords(
 				request.requestBody.toString(), 'secondLayer'
 		);
 		List<String> relatedLookupRecordsToCreate = getRelatedRecords(
 				request.requestBody.toString(), 'relatedLookupRecordsToCreate'
 		);
 		Map<String, String> relatedLookupHardcodedRecordsMap = getRelatedLookupHardcodedRecordsMap(
 				request.requestBody.toString()
 		);
 
 		RestContext.response.addHeader('Content-Type', 'application/json');
 		RestContext.response.responseBody = Blob.valueOf(
 				new GraphService2(
 						id,
 						children,
 						lookupRecords,
 						secondLayer,
 						relatedLookupRecordsToCreate,
 						relatedLookupHardcodedRecordsMap
 				).createGraph());
 	}
 
 	private static List<String> getRelatedRecords(String body, String childrenName) {
 		List<String> children = new List<String>();
 		if (String.isBlank(body)) return children;
 		Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(body);
 		if (!params.containsKey(childrenName)) return children;
 		for (Object obj : (List<Object>)params.get(childrenName)){
 			children.add(obj.toString());
 		}
 		return children;
 	}
 
 	private static Map<String, String> getRelatedLookupHardcodedRecordsMap(String body) {
 		List<Object> relatedLookupHardcodedObjects = getRelatedRecords(
 				body,
 				'relatedLookupHardcodedRecords'
 		);
 		Map<String, String> relatedLookupHardcodedRecordsMap = new Map<String, String>();
 		for (Object o : relatedLookupHardcodedObjects) {
 			List<String> params = o.toString().removeStart('{').removeEnd('}').split('=');
 			relatedLookupHardcodedRecordsMap.put(params[0], params[1]);
 		}
 		return relatedLookupHardcodedRecordsMap;
 	}
 
}