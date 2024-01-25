//package api.zCloud
public inherited sharing class AIQ_WorkflowServiceInvoker extends AIQ_AbstractZCloudInvoker {
    private class AIQ_WorkflowServiceInvokerException extends Exception {
    }
    private static final String workflowDescriptor = 'MARGIN_MAX_CUSTOM_WORKFLOW';
    private final String workflowIdKey = 'WORKFLOW_AUTOMATION_ID';
    private final String contractIdKey = 'Customer';
    private final String productIdKey = 'Product';
    private final String BASE_URL = '/v1/JobWorkflow';
    private final String jobStatusURI = '/Status';
    private String jobId;
    private final String job_already_running = 'running';

    /**
     * @description submitJob method to submit workflow job
     * @param  contractId         external id of a contract record
     * @param  productId internal id of a contract record
     * @return                return job id as a test
     */
    public String submitJob( String contractId, String productId) {
        RequestBodyDTO requestBody = new RequestBodyDTO(workflowDescriptor);
        requestBody.setParameter(workflowIdKey, 'jwfAddProductsToCostCacheForCustomer');
        requestBody.setParameter(contractIdKey, contractId);
        requestBody.setParameter(productIdKey, productId);
        System.debug('!!! requestBody ' + requestBody);
        AIQio_CalloutResponseDTO response = this.post(requestBody.toJson());
        System.debug('!!! response ' + response.responseBody);
        return response.responseBody;
    }

    /**
     * @description checkJobStatus method to query job status endpoint to retrieve the job status information
     * @param  jobId id of the job being verified
     * @return       return object representing job status information
     */
    public ResponseBodyDTO checkJobStatus(String jobId) {
        if (String.isBlank(jobId)) {
            throw new AIQ_WorkflowServiceInvokerException('Job id is not provided');
        }
        String relativePath = '/' + jobId + jobStatusURI;
        AIQio_CalloutResponseDTO response = this.get(relativePath);
        return (ResponseBodyDTO) response.deserializeResponseBody(ResponseBodyDTO.class);
    }

    public override String getBaseURL() {
        return BASE_URL;
    }

    @TestVisible
    protected override void handleError(HttpResponse res, String method) {
        if (res.getStatusCode() == AIQio_HTTPUtils.UNAUTHORIZED_STATUS_CODE) {
            throw new AIQ_WorkflowServiceInvokerException(AIQio_HTTPUtils.INVALID_SIGNATURE_MESSAGE);
        } else if (
            res.getStatusCode() == AIQio_HTTPUtils.VALIDATION_ERROR_STATUS_CODE &&
                res.getBody().contains(job_already_running)
            ) {
            throw new AIQ_WorkflowServiceInvokerException('There is another job already running for this contract');
        } else if (!String.valueOf(res.getStatusCode()).startsWith('2')) {
            throw new AIQ_WorkflowServiceInvokerException('Request failure. Response status: ' + res.getStatus());
        }
    }

    public class RequestBodyDTO {
        public String descriptor { get; set; }
        public Map<String, Object> parameters { get; set; }

        public RequestBodyDTO(String workflowDescriptor) {
            this.descriptor = workflowDescriptor;
            this.parameters = new Map<String, Object>();
        }

        public RequestBodyDTO(String workflowDescriptor, Map<String, Object> parameters) {
            this.descriptor = workflowDescriptor;
            this.parameters = parameters;
        }

        public void setParameter(String key, Object value) {
            parameters.put(key, value);
        }

        public virtual String toJson() {
            if (Test.isRunningTest()) {
                return JSON.serializePretty(this);
            } else {
                return JSON.serialize(this);
            }
        }
    }

    public class ResponseBodyDTO {
        public String executionStatus { get; set; }
        public String closeStatus { get; set; }
        public String startTimestamp { get; set; }
        public String closeTimestamp { get; set; }
    }
}