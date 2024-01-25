public class HomePageLinksPicklist extends VisualEditor.DynamicPickList {
    public override VisualEditor.DataRow getDefaultValue(){
        List<HomePageLink__c> hpls = [SELECT Name FROM HomePageLink__c LIMIT 1];

        if (hpls.size() > 0) {
            VisualEditor.DataRow defaultValue = new VisualEditor.DataRow(hpls[0].Name, hpls[0].Name);
            return defaultValue;
        }
        
        return null;
    }
    public override VisualEditor.DynamicPickListRows getValues() {
        List<HomePageLink__c> homePageLinks = [SELECT Name FROM HomePageLink__c];
        List<VisualEditor.DataRow> picklistDataRows = new List<VisualEditor.DataRow>();
        for (HomePageLink__c hpl : homePageLinks) {
            picklistDataRows.add(new VisualEditor.DataRow(hpl.Name, hpl.Name));
        }
        
        VisualEditor.DynamicPickListRows  picklistValues = new VisualEditor.DynamicPickListRows();
        picklistValues.addAllRows(picklistDataRows);
        return picklistValues;
    }
}