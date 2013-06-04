public with sharing class NightlySchedulable implements Schedulable {

    public void execute(SchedulableContext context) {
    	
    	// Initial test used 20 script statements per row.
    	// So processing 1000 rows per batch should leave x10 headroom.
        Database.executeBatch(new ContactStatusBatchable(), 1000);
    }
}