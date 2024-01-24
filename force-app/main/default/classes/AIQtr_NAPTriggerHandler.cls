public with sharing class AIQtr_NAPTriggerHandler extends AIQtr_TriggerHandler {

    public AIQtr_NAPTriggerHandler() {
        super();
    }

    protected override void afterUpdate() {
        AIQ_NAPTriggerHandler.handleDelete();
    }
}