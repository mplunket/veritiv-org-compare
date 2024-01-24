global with sharing class AIQ_ContractLineItemPostFilter implements zpl.FilterFieldPostProcessor {

    global zal.Condition getFilterCondition(zpl__PostProcessableFilterField__c obj0, Object obj1) {
        zal.AndCondition whereAndCondition = new zal.AndCondition();
        Id objId = (Id) obj1;
        List<zpl__DMReferenceObject1__c> listDmObj = [
            SELECT Id, Name 
            FROM zpl__DMReferenceObject1__c 
            WHERE Id = :objId
        ];
        whereAndCondition.add(new zal.FieldCondition('zpl__Status__c', zal.Operator.EQUALS, listDmObj.get(0).Name));
        return whereAndCondition;
    }
}