/*
 * When bookings move into the past, the status (and active class types) on Contact should change.
 */
public class ContactStatusBatchable implements Database.Batchable<SObject>, Database.Stateful {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        // Need to return all Contacts as any may have gone from having bookings to not having bookings
        return Database.getQueryLocator([
		        select Id, Name, Status__c, ClassType__c, ActiveClassType__c, (
		                select Id, Class__r.Type__c
		                from Bookings__r
		                where LatestBookedDate__c != null
		                and LatestBookedDate__c >= TODAY
		                )
		        from Contact
		        order by Name
		        ]);
    }
    
    public void execute(Database.BatchableContext bc, List<SObject> scope) {

        List<Contact> updates = new List<Contact>();
        
        for (SObject sob : scope) {
            Contact c = (Contact) sob;
            
            // Simlar logic in BookingAfter trigger
            
            Set<String> currentActiveClassTypes = c.ActiveClassType__c != null ? new Set<String>(c.ActiveClassType__c.split(';')) : new Set<String>();
            Set<String> currentWaitingClassTypes = c.ClassType__c != null ? new Set<String>(c.ClassType__c.split(';')) : new Set<String>();
            String currentStatus = c.Status__c;
            
            Set<String> newActiveClassTypes = new Set<String>();
            for (Booking__c b : c.Bookings__r) {
                newActiveClassTypes.add(b.Class__r.Type__c);
            }
            
            String newStatus = newActiveClassTypes.size() > 0 ? 'Active' : (currentWaitingClassTypes.size() > 0 ? 'Waiting' : 'Inactive');
            
            if (newStatus != currentStatus || newActiveClassTypes != currentActiveClassTypes) {
                updates.add(new Contact(
                       Id = c.Id,
                       Status__c = newStatus,
                       ActiveClassType__c = Strings.join(newActiveClassTypes, ';')
                       ));
            }
        }
        
        if (updates.size() > 0) {
            update updates;
        }
    }
    
    public void finish(Database.BatchableContext bc) {
    }
}