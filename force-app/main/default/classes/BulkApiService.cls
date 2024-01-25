/**
 * @description       :
 * @author            : Abhishek
 * @group             : RafterOne
 * @last modified on  : 02-02-2023
 * @last modified by  : Abhishek
 * Modifications Log
 * Ver   Date         Author     Modification
 * 1.0   01-16-2023   Abhishek   Initial Version
**/
public with sharing class BulkApiService {


    public static string createBulkJobId(String namedCredential,String objectName,String operation,String extId){
        String bulkJobId = '';
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
		if(String.isNotBlank(namedCredential)){
			request.setEndpoint('callout:'+namedCredential+MigrationConstant.HTTP_BASE_URL+'/jobs/ingest');
		}else{
			request.setEndpoint(URl.getOrgDomainUrl().toExternalForm()+MigrationConstant.HTTP_BASE_URL+'/jobs/ingest');
			request.setHeader('Authorization' ,'Bearer '+userInfo.getSessionId());
		}
        request.setHeader(MigrationConstant.HTTP_HEADER_CONTENT_TYPE, MigrationConstant.HTTP_HEADER_CONTENT_TYPE_JSON );
		Map<String,String> bodyMap = new Map<String,String>();
		bodyMap.put('operation',operation);
		bodyMap.put('object',objectName);
		bodyMap.put('columnDelimiter',MigrationConstant.COLUMN_DELIMITER);
		if(operation == 'upsert' && String.isNotBlank(extId)){
			bodyMap.put('externalIdFieldName',extId);
		}
        request.setBody(JSON.serialize(bodyMap));
        request.setTimeout(MigrationConstant.HTTP_DEFAULT_TIMEOUT);
        Http h = new Http();
		HttpResponse resp = h.send(request);
		System.debug('resp : '+resp);
		System.debug('resp body : '+resp.getBody());
		if(resp.getStatusCode() <= 299) {
			Map<String, Object> respMap = (Map<String, Object>) Json.deserializeUntyped(resp.getBody());
			bulkJobId = (String)respMap.get('id');
		}
        return bulkJobId;
    }

	public static  Map<String, Object> getBulkJobInfo(String namedCredential,String bulkJobId){
        Map<String, Object> respMap = new Map<String, Object>();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
		if(String.isNotBlank(namedCredential)){
			request.setEndpoint('callout:'+namedCredential+MigrationConstant.HTTP_BASE_URL+'/jobs/ingest/'+bulkJobId);
		}else{
			request.setEndpoint(URl.getOrgDomainUrl().toExternalForm()+MigrationConstant.HTTP_BASE_URL+'/jobs/ingest/'+bulkJobId);
			request.setHeader('Authorization' ,'Bearer '+userInfo.getSessionId());
		}
        request.setHeader(MigrationConstant.HTTP_HEADER_CONTENT_TYPE, MigrationConstant.HTTP_HEADER_CONTENT_TYPE_JSON );
        request.setTimeout(MigrationConstant.HTTP_DEFAULT_TIMEOUT);
        Http h = new Http();
        HttpResponse resp = h.send(request);
        if(resp.getStatusCode() <= 299) {
            respMap = (Map<String, Object>) Json.deserializeUntyped(resp.getBody());
        }
        return respMap;
    }

	public static Boolean uploadDataToBulkJob(String namedCredential,String bulkJobId,String csvStr)
	{
		Boolean ret = false;
		HttpRequest request = new HttpRequest();
		request.setMethod('PUT');
		if(String.isNotBlank(namedCredential)){
			request.setEndpoint('callout:'+namedCredential+MigrationConstant.HTTP_BASE_URL+'/jobs/ingest/'+bulkJobId+'/batches');
		}else{
			request.setEndpoint(URl.getOrgDomainUrl().toExternalForm()+MigrationConstant.HTTP_BASE_URL+'/jobs/ingest/'+bulkJobId+'/batches');
			request.setHeader('Authorization' ,'Bearer '+userInfo.getSessionId());
		}
		request.setHeader(MigrationConstant.HTTP_HEADER_CONTENT_TYPE, MigrationConstant.HTTP_HEADER_CONTENT_TYPE_CSV );
		request.setTimeout(MigrationConstant.HTTP_DEFAULT_TIMEOUT);
		request.setBody(csvStr);
		Http h1 = new Http();
		HttpResponse resp1 = h1.send(request);
		if(resp1.getStatusCode() <= 299) {
				ret = true;
		}
		return ret;
	}

	public static Boolean submitBulkJob(String namedCredential,String bulkJobId){
		Boolean ret = false;
		HttpRequest request = new HttpRequest();
		request.setMethod('PATCH');
		if(String.isNotBlank(namedCredential)){
			request.setEndpoint('callout:'+namedCredential+MigrationConstant.HTTP_BASE_URL+'/jobs/ingest/'+bulkJobId);
		}else{
			request.setEndpoint(URl.getOrgDomainUrl().toExternalForm()+MigrationConstant.HTTP_BASE_URL+'/jobs/ingest/'+bulkJobId);
			request.setHeader('Authorization' ,'Bearer '+userInfo.getSessionId());
		}
		request.setHeader(MigrationConstant.HTTP_HEADER_CONTENT_TYPE, MigrationConstant.HTTP_HEADER_CONTENT_TYPE_JSON );
		request.setBody('{ "state" : "UploadComplete" }');
		request.setTimeout(MigrationConstant.HTTP_DEFAULT_TIMEOUT);
		Http h2 = new Http();
		HttpResponse resp2 = h2.send(request);
		if(resp2.getStatusCode() <= 299)
		{
			ret = true;
		}
		return ret;
	}

	public static List<Object> doQuery(String namedCredential,String query){
        List<Object> returnList = new List<Object>();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint('callout:'+namedCredential+MigrationConstant.HTTP_BASE_URL+'/query/?q='+query);
        request.setTimeout(MigrationConstant.HTTP_DEFAULT_TIMEOUT);
		request.setHeader(MigrationConstant.HTTP_HEADER_CONTENT_TYPE, MigrationConstant.HTTP_HEADER_CONTENT_TYPE_JSON );
        Http h = new Http();
		HttpResponse resp = h.send(request);
		String respBodyStr = resp.getBody();
		System.debug('respBodyStr :'+respBodyStr);
		if(String.isNotBlank(respBodyStr)){
			Map<String, Object> respMap = (Map<String, Object>) Json.deserializeUntyped(respBodyStr);
			if(respMap.containsKey('records')){
				returnList = (List<Object>)respMap.get('records');
			}
		}
        return returnList;
    }

	public static Attachment fetchFailedRecords(String namedCredential,String bulkJobId, String parentId){
		HttpRequest request = new HttpRequest();
		request.setMethod('GET');
		if(String.isNotBlank(namedCredential)){
			request.setEndpoint('callout:'+namedCredential+MigrationConstant.HTTP_BASE_URL+'/jobs/ingest/'+bulkJobId+'/failedResults');
		}else{
			request.setEndpoint(URl.getOrgDomainUrl().toExternalForm()+MigrationConstant.HTTP_BASE_URL+'/jobs/ingest/'+bulkJobId+'/failedResults');
			request.setHeader('Authorization' ,'Bearer '+userInfo.getSessionId());
		}
		request.setHeader(MigrationConstant.HTTP_HEADER_CONTENT_TYPE, MigrationConstant.HTTP_HEADER_CONTENT_TYPE_JSON );
		request.setTimeout(MigrationConstant.HTTP_DEFAULT_TIMEOUT);
		Http h2 = new Http();
		HttpResponse resp2 = h2.send(request);
		if(resp2.getStatusCode() <= 299)
		{
			String bodyStr = resp2.getBody();
			System.debug(bodyStr);

			Attachment att=new Attachment();
            att.Body=Blob.valueOf(bodyStr);
            att.Name= 'Failure_'+ System.now().format('yyyy_MM_dd_hh_mm_ss') + '.csv';
            att.parentId = parentId;
            return att;
		}
		return null;
	}


	public static Boolean pushAttachment(String namedCredential,String parentId ,Attachment att){
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
		request.setEndpoint('callout:'+namedCredential+MigrationConstant.HTTP_BASE_URL+'/sobjects/Attachment');
        request.setHeader(MigrationConstant.HTTP_HEADER_CONTENT_TYPE, MigrationConstant.HTTP_HEADER_CONTENT_TYPE_JSON );
		Map<String,String> bodyMap = new Map<String,String>();
		bodyMap.put('ParentId',parentId);
		bodyMap.put('Name',att.name);
		bodyMap.put('body',EncodingUtil.base64Encode(att.body));
		bodyMap.put('ContentType',att.ContentType);
		bodyMap.put('Description',att.Description);
        request.setBody(JSON.serialize(bodyMap));
        request.setTimeout(MigrationConstant.HTTP_DEFAULT_TIMEOUT);
        Http h = new Http();
		HttpResponse resp = h.send(request);
		System.debug('resp.getStatusCode() : '+resp.getStatusCode());
		System.debug('resp : '+resp);
		System.debug('resp body : '+resp.getBody());
		if(resp.getStatusCode() <= 299) {
			return true;
		}
        return false;
    }

	public static String pushContentVersion(String namedCredential ,ContentVersion cv){
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
		request.setEndpoint('callout:'+namedCredential+MigrationConstant.HTTP_BASE_URL+'/sobjects/ContentVersion');
        request.setHeader(MigrationConstant.HTTP_HEADER_CONTENT_TYPE, MigrationConstant.HTTP_HEADER_CONTENT_TYPE_JSON );
		Map<String,String> bodyMap = new Map<String,String>();
		bodyMap.put('Title',cv.Title);
		bodyMap.put('PathOnClient',cv.PathOnClient);
		bodyMap.put('VersionData',EncodingUtil.base64Encode(cv.VersionData));
		bodyMap.put('ContentLocation','S');
        request.setBody(JSON.serialize(bodyMap));
        request.setTimeout(MigrationConstant.HTTP_DEFAULT_TIMEOUT);
        Http h = new Http();
		HttpResponse resp = h.send(request);
		System.debug('resp.getStatusCode() : '+resp.getStatusCode());
		System.debug('resp : '+resp);
		System.debug('resp body : '+resp.getBody());
		if(resp.getStatusCode() == 201) {
			Map<String, Object> respMap = (Map<String, Object>) Json.deserializeUntyped(resp.getBody());
			return (String)respMap.get('id');
		}
        return null;
    }

	public static String pushContentWorkspaceDoc(String namedCredential ,String ContentDocumentId,String ContentWorkspaceId){
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
		request.setEndpoint('callout:'+namedCredential+MigrationConstant.HTTP_BASE_URL+'/sobjects/ContentWorkspaceDoc');
        request.setHeader(MigrationConstant.HTTP_HEADER_CONTENT_TYPE, MigrationConstant.HTTP_HEADER_CONTENT_TYPE_JSON );
		Map<String,String> bodyMap = new Map<String,String>();
		bodyMap.put('ContentDocumentId',ContentDocumentId);
		bodyMap.put('ContentWorkspaceId',ContentWorkspaceId);
        request.setBody(JSON.serialize(bodyMap));
        request.setTimeout(MigrationConstant.HTTP_DEFAULT_TIMEOUT);
        Http h = new Http();
		HttpResponse resp = h.send(request);
		System.debug('resp.getStatusCode() : '+resp.getStatusCode());
		System.debug('resp : '+resp);
		System.debug('resp body : '+resp.getBody());
		if(resp.getStatusCode() == 201) {
			Map<String, Object> respMap = (Map<String, Object>) Json.deserializeUntyped(resp.getBody());
			return (String)respMap.get('id');
		}
        return null;
    }


}