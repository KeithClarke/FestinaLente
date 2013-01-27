trigger ContactBefore on Contact (before insert, before update) {
    
    Date today = Date.today();
    for (Contact c : Trigger.new) {
    
        // This affects status used below
        String waitingForClassType = c.WaitingForClassType__c;
        if (waitingForClassType != (Trigger.isInsert ? null : Trigger.oldMap.get(c.Id).WaitingForClassType__c)) {
            if (waitingForClassType != null) {
                c.Status__c = 'Waiting';
            } else {
                if (c.Status__c == 'Waiting') {
                    c.Status__c = 'Active';
                }
            }
        }
        
        String status = c.Status__c;
        if (status != (Trigger.isInsert ? null : Trigger.oldMap.get(c.Id).Status__c)) {
            if (status == 'Active') {
                c.ActiveSince__c = today;
                c.WaitingSince__c = null;
                c.InactiveSince__c = null;
                
                c.WaitingForClassType__c = null;
            } else if (status == 'Waiting') {
                if (c.ActiveSince__c == null) {
                    c.ActiveSince__c = today;
                }
                c.WaitingSince__c = today;
                c.InactiveSince__c = null;
                if (c.WaitingForClassType__c == null) {
                    c.WaitingForClassType__c.addError('When Status is set to "Waiting", one or more Class Types must be selected');
                }
            } else if (status == 'Inactive') {
                c.ActiveSince__c = null;
                c.WaitingSince__c = null;
                c.InactiveSince__c = today;
                
                c.WaitingForClassType__c = null;
            }
        }
    }
}