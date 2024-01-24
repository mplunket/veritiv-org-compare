global class CPLEmailBatchSchedulable implements Schedulable {
	global void execute(SchedulableContext sc) {
		CPLEmailBatch batch = new CPLEmailBatch();
		Database.executeBatch(batch); 
	}
}