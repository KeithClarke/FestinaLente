public with sharing class CalendarController {

    public static String BOOKINGS_COLOUR {
        get {
            return'#cc3366';
        }
    }
    public static String FREE_SPACES_COLOUR {
        get {
            return '#3366cc';
        }
    }
    public static String FULLY_BOOKED_COLOUR {
        get {
            return '#6699ff';
        }
    }
    
    private static final Set<String> ACTIVE_STATUSES = new Set<String>{'Waiting', 'Active'};
    private static final String A = ' and ';

    public class Back {
        public Id id {get; private set;}
        public String name {get; private set;}
        public Back(Id id, String name) {
            this.id = id;
            this.name = name;
        }
    }
    
    // Used to render initial page
    public List<Back> backs {get; private set;}
    private Date initialDate {get; private set;}
    public String initialDateDmy {
        get {
            return initialDate.day() + '/' + initialDate.month() + '/' + initialDate.year();
        }
    }

    // Used to render initial page
    public PageReference init() {

        Map<String, String> p = ApexPages.currentPage().getParameters();
        
        String clientId = p.get('clientId');
        String coachId = p.get('coachId');
        String horseId = p.get('horseId');
        String bookingId = p.get('bookingId');
        String classId = p.get('classId');
        
        // Transfer to fields for display/editing
        if (clientId != null) {
            filter.Client__c = clientId;
        }
        if (coachId != null) {
            filter.Coach__c = coachId;
        }
        if (horseId != null) {
            filter.Horse__c = horseId;
        }
        if (bookingId != null) {
            filter.Booking__c = bookingId;
        }
        if (classId != null) {
            filter.Class__c = classId;
        }
        
        backs = new List<Back>();
        
        Date earliest = null;
        Date latest = null;

        // Order here should match order of filter fields in page so "back" links are in matching order
        if (clientId != null) {
            Contact c = [select Name from Contact where Id = :clientId];
            
            backs.add(new Back(clientId, c.Name));
        }
        if (coachId != null) {
            Contact c = [select Name from Contact where Id = :coachId];
            
            backs.add(new Back(coachId, c.Name));
        }
        if (horseId != null) {
            Horse__c h = [select Name from Horse__c where Id = :horseId];
            
            backs.add(new Back(horseId, h.Name));
        }
        if (bookingId != null) {
            Booking__c b = [select Name, EarliestBookedDate__c, LatestBookedDate__c from Booking__c where Id = :bookingId];
            
            backs.add(new Back(bookingId, b.Name));
            
            // Create narrowest range
            earliest = Maths.max(earliest, b.EarliestBookedDate__c);
            latest = Maths.min(latest, b.LatestBookedDate__c);
        }
        if (classId != null) {
            Class__c c = [select Name, EarliestAvailableDate__c, LatestAvailableDate__c from Class__c where Id = :classId];
            
            backs.add(new Back(classId, c.Name));
            
            // Create narrowest range
            earliest = Maths.max(earliest, c.EarliestAvailableDate__c);
            latest = Maths.min(latest, c.LatestAvailableDate__c);
        }
        
        // Get calendar into a relevant range
        if (latest != null && latest < Date.today()) {
            initialDate = latest;
        } else if (earliest != null && earliest > Date.today()) {
            initialDate = earliest;
        } else {
            initialDate = Date.today();
        }
        
        return null;
    }
    
    public Filter__c filter {
        get {
            if (filter == null) {
                filter = new Filter__c(ShowBookings__c = true, ShowClassesFreeSpaces__c = true, ShowClassesFullyBooked__c = true);
            }
            return filter;
        }
        set;
    }
    
    public Date starts {
        get {
            if (starts == null) {
                starts = Date.newInstance(2000, 1, 1);
            }
            return starts;
        }
        set;
    }
    
    public Date ends {
        get {
            if (ends == null) {
                ends = Date.newInstance(2100, 1, 1);
            }
            return ends;
        }
        set;
    }
    
    private BookedDate__c[] queryBookedDates() {
    
        // Only simple variables can be bound into queries
        Id clientId = filter.Client__c;
        Id coachId = filter.Coach__c;
        Id horseId = filter.Horse__c;
        Id bookingId = filter.Booking__c;
        Id classId = filter.Class__c;
        String classType = filter.ClassType__c;
        
        // Build query
        String soql = ''
                + ' select'
                + '         Id, Name, Date__c,'
                + '         AvailableDate__r.Id, AvailableDate__r.Name, AvailableDate__r.CalendarSortKey__c, AvailableDate__r.SpacesRemaining__c, AvailableDate__r.SpacesBooked__c,'
                + '         Booking__r.Id, Booking__r.Name, Booking__r.EarliestBookedDate__c, Booking__r.LatestBookedDate__c,'
                + '         Booking__r.Client__r.Name, Booking__r.Client__r.Level__c,'
                + '         Booking__r.Client__r.PreferredHorse__r.Name,'
                + '         Booking__r.Class__r.Coach__r.Name,'
                + '         Booking__r.Class__r.Id, Booking__r.Class__r.Name, Booking__r.Class__r.TimeInMinutes__c, Booking__r.Class__r.LengthInMinutes__c,'
                + '         Booking__r.Class__r.Type__c, Booking__r.Class__r.Detail__c, Booking__r.Class__r.AgeGroup__c, Booking__r.Class__r.Level__c, Booking__r.Class__r.Price__c'
                + ' from BookedDate__c'
                + ' where Date__c >= :starts'
                + ' and Date__c <= :ends'
                ;
        if (is(clientId)) {
            soql += A + 'Booking__r.Client__r.Id = :clientId';
        }
        if (is(coachId)) {
            soql += A + 'Booking__r.Class__r.Coach__r.Id = :coachId';
        }
        if (is(horseId)) {
            soql += A + 'Booking__r.Client__r.PreferredHorse__r.Id = :horseId';
        }
        if (is(bookingId)) {
            soql += A + 'Booking__r.Id = :bookingId';
        }
        if (is(classId)) {
            soql += A + 'Booking__r.Class__r.Id = :classId';
        }
        if (is(classType)) {
            soql += A + 'Booking__r.Class__r.Type__c = :classType';
        }
        // Determinate order for BookedDates
        soql += ' order by Id';
        
        System.debug('>>> booked dates soql=' + soql);
        return Database.query(soql);
    }
    
    private AvailableDate__c[] queryAvailableDates(Boolean freeSpaces, Boolean fullyBooked, Set<Id> skipIds) {
    
        // Only simple variables can be bound into queries
        Id coachId = filter.Coach__c;
        Id classId = filter.Class__c;
        String classType = filter.ClassType__c;
        
        // Build query
        String soql = ''
                + ' select'
                + '         Id, Name, CalendarSortKey__c, Date__c, SpacesBooked__c, SpacesRemaining__c,'
                + '         Class__r.Coach__r.Name,'
                + '         Class__r.Id, Class__r.Name, Class__r.TimeInMinutes__c, Class__r.LengthInMinutes__c,'
                + '         Class__r.Type__c, Class__r.Detail__c, Class__r.AgeGroup__c, Class__r.Level__c, Class__r.Price__c'
                + ' from AvailableDate__c'
                + ' where Date__c >= :starts'
                + ' and Date__c <= :ends'
                ;
        if (is(coachId)) {
            soql += A + 'Class__r.Coach__r.Id = :coachId';
        }
        if (is(classId)) {
            soql += A + 'Class__r.Id = :classId';
        }
        if (is(classType)) {
            soql += A + 'Class__r.Type__c = :classType';
        }
        if (freeSpaces && !fullyBooked) {
            soql += A + '(SpacesRemaining__c = null or SpacesRemaining__c > 0)';
        }
        if (fullyBooked && !freeSpaces) {
            soql += A + 'SpacesRemaining__c <= 0';
        }
        // If already being presented as a booked date don't show again as an available date
        if (skipIds.size() > 0) {
            soql += A + 'Id not in :skipIds';
        }
        
        System.debug('>>> available dates soql=' + soql);
        return Database.query(soql);
    }
    
    private static Boolean is(String id) {
        return id != null && id != '' && id != '000000000000000';
    }
    
    private Event[] createEvents() {

        // Group the Events
        Map<String, List<Event>> m = new Map<String, List<Event>>();

        Set<Id> adIdSet = new Set<Id>();
        Set<String> keySet = new Set<String>();
        if (filter.ShowBookings__c) {
            for (BookedDate__c bd : queryBookedDates()) {
                Id adId = bd.AvailableDate__r.Id;
                String key = bd.AvailableDate__r.CalendarSortKey__c;
                List<Event> l = m.get(key);
                if (l == null) {
                    l = new List<Event>();
                    // Often multiple (already sorted) BookedDates for an AvailableDate; 
                    m.put(key, l);
                }
                l.add(new Event(
                        getTitle(bd),
                        getTooltip(bd),
                        getStartDateTime(bd.Date__c, bd.Booking__r.Class__r),
                        getEndDateTime(bd.Date__c, bd.Booking__r.Class__r),
                        '/' + bd.Booking__r.Id,
                        BOOKINGS_COLOUR
                        ));
                adIdSet.add(adId);
                keySet.add(key);
            }
        }
        if (filter.ShowClassesFreeSpaces__c || filter.ShowClassesFullyBooked__c) {
            for (AvailableDate__c ad : queryAvailableDates(filter.ShowClassesFreeSpaces__c, filter.ShowClassesFullyBooked__c, adIdSet)) {
                String key = ad.CalendarSortKey__c;
                List<Event> l = m.get(key);
                if (l == null) {
                    l = new List<Event>();
                    m.put(key, l);
                }
                l.add(new Event(
                        getTitle(ad),
                        getTooltip(ad),
                        getStartDateTime(ad.Date__c, ad.Class__r),
                        getEndDateTime(ad.Date__c, ad.Class__r),
                        '/' + ad.Class__r.Id,
                        (ad.SpacesRemaining__c != null && ad.SpacesRemaining__c <= 0 ? FULLY_BOOKED_COLOUR : FREE_SPACES_COLOUR)
                        ));
                keySet.add(key);
            }
        }
        
        // Want to keep in defined order so elements don't jump about on the Calendar when checkboxes are changed.
        // But note http://code.google.com/p/fullcalendar/issues/detail?id=379: problem with same time events in Chrome.
        List<String> keyList = new List<String>(keySet);
        keyList.sort();
        List<Event> events = new List<Event>();
        for (String key : keyList) {
            events.addAll(m.get(key));
        }
        
        return events;
    }
    
    private String getTitle(BookedDate__c bd) {

        return bd.Booking__r.Name;
    }
    
    private String getTitle(AvailableDate__c ad) {

        return ad.Class__r.Name;
    }
    
    private String getTooltip(BookedDate__c bd) {
    
        Booking__c b = bd.Booking__r;
        Class__c c = b.Class__r;
        AvailableDate__c ad = bd.AvailableDate__r;
        
        String s = 'Booking: <b>' + b.Name + '</b>';
        if (b.Client__r != null) {
            s += '<br/>Client: ' + b.Client__r.Name;
        }
        if (b.Client__r != null && b.Client__r.Level__c != null) {
            s += '<br/>Level: ' + b.Client__r.Level__c;
        }
        if (b.Client__r != null && b.Client__r.PreferredHorse__r != null) {
            s += '<br/>Preferred Horse: ' + b.Client__r.PreferredHorse__r.Name;
        }
        
        s += '<br/>';
        
        s += '<br/>Class: <b>' + c.Name + '</b>';
        s += '<br/>Type: ' + c.Type__c;
        if (c.Detail__c != null) {
            s += '<br/>Detail: ' + c.Detail__c;
        }
        if (c.AgeGroup__c != null) {
            s += '<br/>Age Group: ' + c.AgeGroup__c;
        }
        if (c.Level__c != null) {
            s += '<br/>Level: ' + c.Level__c;
        }
        if (c.Coach__r != null) {
            s += '<br/>Coach: ' + c.Coach__r.Name;
        }
        if (c.Price__c != null) {
            s += '<br/>Price: ' + c.Price__c;
        }
        if (ad.SpacesBooked__c != null && ad.SpacesRemaining__c != null) {
            s += '<br/>Free Spaces: ' + ad.SpacesRemaining__c + ' (' + (ad.SpacesBooked__c + ad.SpacesRemaining__c) + ' Total Spaces)';
        }

        return s;
    }
    
    private String getTooltip(AvailableDate__c ad) {
    
        Class__c c = ad.Class__r;

        String s = 'Class: <b>' + c.Name + '</b>';
        s += '<br/>Type: ' + c.Type__c;
        if (c.Detail__c != null) {
            s += '<br/>Detail: ' + c.Detail__c;
        }
        if (c.AgeGroup__c != null) {
            s += '<br/>Age Group: ' + c.AgeGroup__c;
        }
        if (c.Level__c != null) {
            s += '<br/>Level: ' + c.Level__c;
        }
        if (c.Coach__r != null) {
            s += '<br/>Coach: ' + c.Coach__r.Name;
        }
        if (c.Price__c != null) {
            s += '<br/>Price: ' + c.Price__c;
        }
        if (ad.SpacesBooked__c != null && ad.SpacesRemaining__c != null) {
            s += '<br/>Free Spaces: ' + ad.SpacesRemaining__c + ' (' + (ad.SpacesBooked__c + ad.SpacesRemaining__c) + ' Total Spaces)';
        }
        
        return s;
    }

    private DateTime getStartDateTime(Date d, Class__c c) {
        return toDateTime(d, defaultTime(c.TimeInMinutes__c));
    }
    
    private DateTime getEndDateTime(Date d, Class__c c) {
        return toDateTime(d, defaultTime(c.TimeInMinutes__c) + defaultLength(c.LengthInMinutes__c));
    }
    
    private DateTime toDateTime(Date d, Integer minutesIntoDay) {
        return DateTime.newInstance(d.year(), d.month(), d.day(), minutesIntoDay / 60, Math.mod(minutesIntoDay, 60), 0);
    }
    
    private Integer defaultTime(Decimal t) {
        return t != null ? t.intValue() : 8;
    }
    
    private Integer defaultLength(Decimal l) {
        return l != null ? l.intValue() : 45;
    }
    
    public class Event {
    
        public String title;
        public String tooltip;
        public DateTime starts;
        public DateTime ends;
        public String url;
        public String color;
        
        public Event(String title, String tooltip, DateTime starts, DateTime ends, String url, String color) {
            this.title = title;
            this.tooltip = tooltip;
            this.starts = starts;
            this.ends = ends;
            this.url = url;
            this.color = color;
        }
    }

    // Page calls back into this
    @RemoteAction
    public static Event[] events(Date starts, Date ends, Filter__c filter) {
    
        System.debug('>>> starts=' + starts + ' ends=' + ends + ' filter=' + filter);
        
        CalendarController c = new CalendarController();
        c.starts = starts;
        c.ends = ends;
        c.filter = filter;
        return c.createEvents();
    }
    
    @RemoteAction
    public static Contact nextContact(String recordTypeName, Id contactId) {
    
        Id rtId = contactRtId(recordTypeName);
        Contact[] contacts;
        if (is(contactId)) {
            String currentName = [select Name from Contact where Id = :contactId].Name;
            contacts = [
                    select Id, Name
                    from Contact
                    where RecordTypeId = :rtId
                    and Name > :currentName
                    and Status__c in :ACTIVE_STATUSES
                    order by Name
                    limit 1
                    ];
        } else {
            contacts = [
                    select Id, Name
                    from Contact
                    where RecordTypeId = :rtId
                    and Status__c in :ACTIVE_STATUSES
                    order by Name
                    limit 1
                    ];
        }
        return contacts.size() > 0 ? contacts[0] : null;
    }
    
    @RemoteAction
    public static Contact previousContact(String recordTypeName, Id contactId) {

        Id rtId = contactRtId(recordTypeName);
        Contact[] contacts;
        if (is(contactId)) {
            String currentName = [select Name from Contact where Id = :contactId].Name;
            contacts = [
                    select Id, Name
                    from Contact
                    where RecordTypeId = :rtId
                    and Name < :currentName
                    and Status__c in :ACTIVE_STATUSES
                    order by Name desc
                    limit 1
                    ];
        } else {
            contacts = [
                    select Id, Name
                    from Contact
                    where RecordTypeId = :rtId
                    and Status__c in :ACTIVE_STATUSES
                    order by Name desc
                    limit 1
                    ];
        }
        return contacts.size() > 0 ? contacts[0] : null;
    }
    
    private static Id contactRtId(String developerName) {
    
        return [
                select Id
                from RecordType
                where DeveloperName = :developerName
                and SObjectType = :String.valueOf(Contact.SObjectType)
                ].Id;
    }
}