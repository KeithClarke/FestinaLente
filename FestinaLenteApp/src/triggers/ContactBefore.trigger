trigger ContactBefore on Contact (before insert, before update) {
	
	// If a Contact is added but not assigned to an Account then it is treated as "private" and e.g. will not be accessible in reports
	Boolean defaultAccountNeeded = false;
    if (Trigger.isInsert) {
        for (Contact contact : Trigger.new) {
            if (contact.AccountId == null) {
                defaultAccountNeeded = true;
            }
        }
    }
    if (defaultAccountNeeded) {
        
        String defaultName = 'Default Account';
        Account defaultAccount;
        
        Account[] accounts = [select Id from Account where Name = :defaultName limit 1];
        if (accounts.size() > 0) {
            defaultAccount = accounts[0];
        } else {
            // Deleting the account is very destructive so create it using a SA user to protect it
            User[] users = [
                    select Id
                    from User
                    where ProfileId in (select Id from Profile where Name = 'System Administrator')
                    and IsActive = true
                    ];
            Id ownerId = users.size() > 0 ? users[0].Id : UserInfo.getUserId();
            defaultAccount = new Account(
                    Name = defaultName,
                    Description = 'Contact objects are automatically assigned to this Account if no Account is specified',
                    OwnerId = ownerId
                    );
            insert defaultAccount;
        }
        
        for (Contact contact : Trigger.new) {
            if (contact.AccountId == null) {
                contact.AccountId = defaultAccount.Id;
            }
        }
    }
    
    Date today = Date.today();
    for (Contact c : Trigger.new) {
    
        // Trigger de not fire when a MigratedFromAccess Contact is inserted (i.e. migration being done)
        if (Trigger.isUpdate || !c.MigratedFromAccess__c) {
    
            //
            // Status logic
            //
            
            // This affects status used below
            String waitingForClassType = c.ClassType__c;
            if (waitingForClassType != (Trigger.isInsert ? null : Trigger.oldMap.get(c.Id).ClassType__c)) {
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
                    
                    c.ClassType__c = null;
                } else if (status == 'Waiting') {
                    if (c.ActiveSince__c == null) {
                        c.ActiveSince__c = today;
                    }
                    c.WaitingSince__c = today;
                    c.InactiveSince__c = null;
                    if (c.ClassType__c == null) {
                        c.ClassType__c.addError('When Status is set to "Waiting", one or more Class Types must be selected');
                    }
                } else if (status == 'Inactive') {
                    c.ActiveSince__c = null;
                    c.WaitingSince__c = null;
                    c.InactiveSince__c = today;
                    
                    c.ClassType__c = null;
                }
            }
            
            //
            // Waiver date
            //
            
            if (c.WaiverFormCompleted__c) {
                Boolean oldValue = Trigger.isInsert ? null : Trigger.oldMap.get(c.Id).WaiverFormCompleted__c;
                if (oldValue != true) {
                    c.WaiverFormCompletedDate__c = today;
                }
            } else {
                c.WaiverFormCompletedDate__c = null;
            }
        }
    }
}