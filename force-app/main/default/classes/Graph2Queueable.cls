public class Graph2Queueable implements Queueable {

    public void execute(QueueableContext context) {
        GraphService2 graph2 = new GraphService2('a5Wf2000001hyJREAY', 
                                                 new List<String>{
                                                     'zpl__ProductSearchField__c',
                                                     'zpl__ProductsSearchFilter__c',
                                                     'zpl__LineLevel__c',
                                                     'zpl__EditPricesDialogField__c',
                                                     'zpl__LineListColumn__c',
                                                     'zpl__DataRequestAssignment__c',
                                                     'zpl__ProductHierarchyChangeType__c',
                                                     'zpl__ActionConfiguration__c',
                                                     'zpl__LineLevelProductMap__c',
                                                     'zpl__SublineColumn__c'
                                                         },
                                                 new List<String>{
                                                     'zpl__FilterFieldSet__c',
                                                     'zpl__WorkspaceConfiguration__c',
                                                     'zpl__IQAnywhereConfiguration__c',
                                                     'zpf__SearchBarConfiguration__c',
                                                     'zpf__DataRequestConfiguration__c'
                                                         },
                                                 new List<String>{'zpl__LineLevel__c'},
                                                 new List<String>(),
                                                 new Map<String, String>());
        System.debug('!!! ===== ' + graph2.createGraph());
    }
}