/**
 * Created by junaidm on 7/29/21.
 */

trigger VRTB2B_BatchApexErrorEvent on BatchApexErrorEvent (after insert) {
	/*
    Set<Id> asyncApexJobIds = new Set<Id>();
    for(BatchApexErrorEvent evt:Trigger.new){
        asyncApexJobIds.add(evt.AsyncApexJobId);
    }
    VRTB2B_Utility.populateBatchException(asyncApexJobIds , Trigger.new);
	*/
}