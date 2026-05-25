// ============================================================
// Skill Enhancement Tracker - Demo Seed Script
// Creates clean demo data for functional and technical videos.
// Prefix used: "Seed - "
// ============================================================

String PREFIX = 'Seed - ';

// ------------------------------------------------------------
// 1. Cleanup old seed records
// ------------------------------------------------------------

List<Skill_Session_Participant__c> oldParticipants = [
    SELECT Id
    FROM Skill_Session_Participant__c
    WHERE Name LIKE :PREFIX + '%'
];
if (!oldParticipants.isEmpty()) {
    delete oldParticipants;
}

List<Skill_Session__c> oldSessions = [
    SELECT Id
    FROM Skill_Session__c
    WHERE Name LIKE :PREFIX + '%'
];
if (!oldSessions.isEmpty()) {
    delete oldSessions;
}

List<Skill_Course__c> oldCourses = [
    SELECT Id
    FROM Skill_Course__c
    WHERE Name LIKE :PREFIX + '%'
];
if (!oldCourses.isEmpty()) {
    delete oldCourses;
}

List<Skill_Program__c> oldPrograms = [
    SELECT Id
    FROM Skill_Program__c
    WHERE Name LIKE :PREFIX + '%'
];
if (!oldPrograms.isEmpty()) {
    delete oldPrograms;
}

List<Account> oldProviders = [
    SELECT Id
    FROM Account
    WHERE Name LIKE :PREFIX + '%'
];
if (!oldProviders.isEmpty()) {
    delete oldProviders;
}

// ------------------------------------------------------------
// 2. Resolve users
// ------------------------------------------------------------

// ------------------------------------------------------------
// 2. Resolve users
// ------------------------------------------------------------

User currentUser = [
    SELECT Id, Name, IsActive, UserType, Profile.Name
    FROM User
    WHERE Id = :UserInfo.getUserId()
    LIMIT 1
];

List<User> kateUsers = [
    SELECT Id, Name, IsActive, UserType, Profile.Name
    FROM User
    WHERE IsActive = true
    AND UserType = 'Standard'
    AND Name = 'Kate Middleton'
    LIMIT 1
];

if (kateUsers.isEmpty()) {
    throw new IllegalArgumentException(
        'Seed script requires an active Standard user named Kate Middleton.'
    );
}

User secondaryUser = kateUsers[0];

System.debug('Current user selected for seed: ' + currentUser.Name + ' / ' + currentUser.UserType + ' / ' + currentUser.Profile.Name);
System.debug('Secondary user selected for seed: ' + secondaryUser.Name + ' / ' + secondaryUser.UserType + ' / ' + secondaryUser.Profile.Name);

// ------------------------------------------------------------
// 3. Resolve Skill Provider Account Record Type
// ------------------------------------------------------------

Id skillProviderRtId;

List<RecordType> providerRecordTypes = [
    SELECT Id, DeveloperName
    FROM RecordType
    WHERE SObjectType = 'Account'
    AND DeveloperName = 'Skill_Provider_Account'
    LIMIT 1
];

if (!providerRecordTypes.isEmpty()) {
    skillProviderRtId = providerRecordTypes[0].Id;
}

// ------------------------------------------------------------
// 4. Create Skill Providers
// ------------------------------------------------------------

List<Account> providers = new List<Account>{
    new Account(
        Name = PREFIX + 'Trailhead Academy',
        RecordTypeId = skillProviderRtId,
        Skill_Provider_Status__c = 'Approved',
        Phone = '+1 415 555 0101',
        Website = 'https://trailhead.salesforce.com',
        Description = 'Salesforce and platform enablement provider.'
    ),
    new Account(
        Name = PREFIX + 'Assistive Tech Institute',
        RecordTypeId = skillProviderRtId,
        Skill_Provider_Status__c = 'Approved',
        Phone = '+1 415 555 0102',
        Website = 'https://example.com/assistive-tech',
        Description = 'Provider focused on accessibility and assistive technology training.'
    ),
    new Account(
        Name = PREFIX + 'Leadership Lab',
        RecordTypeId = skillProviderRtId,
        Skill_Provider_Status__c = 'Approved',
        Phone = '+1 415 555 0103',
        Website = 'https://example.com/leadership',
        Description = 'Leadership and professional development provider.'
    ),
    new Account(
        Name = PREFIX + 'Data Skills Guild',
        RecordTypeId = skillProviderRtId,
        Skill_Provider_Status__c = 'Approved',
        Phone = '+1 415 555 0104',
        Website = 'https://example.com/data-skills',
        Description = 'Data analytics and reporting training provider.'
    )
};

insert providers;

Map<String, Account> providerByName = new Map<String, Account>();
for (Account provider : providers) {
    providerByName.put(provider.Name, provider);
}

// ------------------------------------------------------------
// 5. Create Skill Programs
// ------------------------------------------------------------

List<Skill_Program__c> programs = new List<Skill_Program__c>{
    new Skill_Program__c(
        Name = PREFIX + 'Salesforce Platform Enablement',
        Skill_Provider__c = providerByName.get(PREFIX + 'Trailhead Academy').Id
    ),
    new Skill_Program__c(
        Name = PREFIX + 'Inclusive Technology Program',
        Skill_Provider__c = providerByName.get(PREFIX + 'Assistive Tech Institute').Id
    ),
    new Skill_Program__c(
        Name = PREFIX + 'Emerging Leaders Program',
        Skill_Provider__c = providerByName.get(PREFIX + 'Leadership Lab').Id
    ),
    new Skill_Program__c(
        Name = PREFIX + 'Data-Driven Operations',
        Skill_Provider__c = providerByName.get(PREFIX + 'Data Skills Guild').Id
    )
};

insert programs;

Map<String, Skill_Program__c> programByName = new Map<String, Skill_Program__c>();
for (Skill_Program__c program : programs) {
    programByName.put(program.Name, program);
}

// ------------------------------------------------------------
// 6. Create Skill Courses
// ------------------------------------------------------------

List<Skill_Course__c> courses = new List<Skill_Course__c>{
    new Skill_Course__c(
        Name = PREFIX + 'Salesforce Admin Foundations',
        Skill_Program__c = programByName.get(PREFIX + 'Salesforce Platform Enablement').Id,
        Areas_of_Interest__c = 'Salesforce',
        Course_Description__c = '<p>Core Salesforce administration concepts, app configuration, security, and automation basics.</p>'
    ),
    new Skill_Course__c(
        Name = PREFIX + 'Flow Automation Workshop',
        Skill_Program__c = programByName.get(PREFIX + 'Salesforce Platform Enablement').Id,
        Areas_of_Interest__c = 'Salesforce;Programming',
        Course_Description__c = '<p>Hands-on workshop for Screen Flows, Record-Triggered Flows, and approval automation.</p>'
    ),
    new Skill_Course__c(
        Name = PREFIX + 'Assistive Technology Fundamentals',
        Skill_Program__c = programByName.get(PREFIX + 'Inclusive Technology Program').Id,
        Areas_of_Interest__c = 'Accessibility;Healthcare Technology',
        Course_Description__c = '<p>Introduction to assistive technology principles, accessibility workflows, and inclusive design.</p>'
    ),
    new Skill_Course__c(
        Name = PREFIX + 'Inclusive Product Design',
        Skill_Program__c = programByName.get(PREFIX + 'Inclusive Technology Program').Id,
        Areas_of_Interest__c = 'Accessibility;Communication',
        Course_Description__c = '<p>Designing training, products, and internal processes with accessibility in mind.</p>'
    ),
    new Skill_Course__c(
        Name = PREFIX + 'Leadership Essentials',
        Skill_Program__c = programByName.get(PREFIX + 'Emerging Leaders Program').Id,
        Areas_of_Interest__c = 'Leadership;Communication',
        Course_Description__c = '<p>Practical leadership, communication, feedback, and team enablement.</p>'
    ),
    new Skill_Course__c(
        Name = PREFIX + 'Operational Analytics',
        Skill_Program__c = programByName.get(PREFIX + 'Data-Driven Operations').Id,
        Areas_of_Interest__c = 'Data Analytics;Project Management',
        Course_Description__c = '<p>Using dashboards, reports, and operational metrics to improve decision-making.</p>'
    )
};

insert courses;

Map<String, Skill_Course__c> courseByName = new Map<String, Skill_Course__c>();
for (Skill_Course__c course : courses) {
    courseByName.put(course.Name, course);
}

// ------------------------------------------------------------
// 7. Create Skill Sessions
// ------------------------------------------------------------

Datetime base = System.now();

List<Skill_Session__c> sessions = new List<Skill_Session__c>{
    new Skill_Session__c(
        Name = PREFIX + 'Admin Foundations - Morning Batch',
        Skill_Course__c = courseByName.get(PREFIX + 'Salesforce Admin Foundations').Id,
        Session_Start_Time__c = base.addDays(3).addHours(9),
        Session_End_Time__c = base.addDays(3).addHours(11),
        Total_Seats__c = 5
    ),
    new Skill_Session__c(
        Name = PREFIX + 'Admin Foundations - Afternoon Batch',
        Skill_Course__c = courseByName.get(PREFIX + 'Salesforce Admin Foundations').Id,
        Session_Start_Time__c = base.addDays(7).addHours(14),
        Session_End_Time__c = base.addDays(7).addHours(16),
        Total_Seats__c = 3
    ),
    new Skill_Session__c(
        Name = PREFIX + 'Flow Automation - Deep Dive',
        Skill_Course__c = courseByName.get(PREFIX + 'Flow Automation Workshop').Id,
        Session_Start_Time__c = base.addDays(10).addHours(10),
        Session_End_Time__c = base.addDays(10).addHours(13),
        Total_Seats__c = 3
    ),
    new Skill_Session__c(
        Name = PREFIX + 'Assistive Tech - Accessibility Basics',
        Skill_Course__c = courseByName.get(PREFIX + 'Assistive Technology Fundamentals').Id,
        Session_Start_Time__c = base.addDays(5).addHours(9),
        Session_End_Time__c = base.addDays(5).addHours(12),
        Total_Seats__c = 4
    ),
    new Skill_Session__c(
        Name = PREFIX + 'Inclusive Product Design - Workshop',
        Skill_Course__c = courseByName.get(PREFIX + 'Inclusive Product Design').Id,
        Session_Start_Time__c = base.addDays(12).addHours(13),
        Session_End_Time__c = base.addDays(12).addHours(16),
        Total_Seats__c = 4
    ),
    new Skill_Session__c(
        Name = PREFIX + 'Leadership Essentials - Cohort A',
        Skill_Course__c = courseByName.get(PREFIX + 'Leadership Essentials').Id,
        Session_Start_Time__c = base.addDays(15).addHours(9),
        Session_End_Time__c = base.addDays(15).addHours(11),
        Total_Seats__c = 3
    ),
    new Skill_Session__c(
        Name = PREFIX + 'Operational Analytics - Reports Lab',
        Skill_Course__c = courseByName.get(PREFIX + 'Operational Analytics').Id,
        Session_Start_Time__c = base.addDays(20).addHours(10),
        Session_End_Time__c = base.addDays(20).addHours(12),
        Total_Seats__c = 3
    ),
    new Skill_Session__c(
        Name = PREFIX + 'Operational Analytics - Completed Session',
        Skill_Course__c = courseByName.get(PREFIX + 'Operational Analytics').Id,
        Session_Start_Time__c = base.addDays(-10).addHours(10),
        Session_End_Time__c = base.addDays(-10).addHours(12),
        Total_Seats__c = 3
    )
};

insert sessions;

Map<String, Skill_Session__c> sessionByName = new Map<String, Skill_Session__c>();
for (Skill_Session__c sessionRecord : sessions) {
    sessionByName.put(sessionRecord.Name, sessionRecord);
}

// ------------------------------------------------------------
// 8. Create Skill Session Participants
// ------------------------------------------------------------
// Name is set manually to the User Name because the helper Flow may not
// populate Name when records are created through Apex in this org.

List<Skill_Session_Participant__c> participants = new List<Skill_Session_Participant__c>{
    // Current user - confirmed/upcoming
    new Skill_Session_Participant__c(
        Name = PREFIX + currentUser.Name,
        Skill_Session__c = sessionByName.get(PREFIX + 'Admin Foundations - Morning Batch').Id,
        Participant__c = currentUser.Id,
        Status__c = 'Confirmed'
    ),
    new Skill_Session_Participant__c(
        Name = PREFIX + currentUser.Name,
        Skill_Session__c = sessionByName.get(PREFIX + 'Flow Automation - Deep Dive').Id,
        Participant__c = currentUser.Id,
        Status__c = 'Confirmed'
    ),
    new Skill_Session_Participant__c(
        Name = PREFIX + currentUser.Name,
        Skill_Session__c = sessionByName.get(PREFIX + 'Operational Analytics - Completed Session').Id,
        Participant__c = currentUser.Id,
        Status__c = 'Completed'
    ),

    // Secondary user - intended as pending approval demo
    new Skill_Session_Participant__c(
        Name = PREFIX + secondaryUser.Name,
        Skill_Session__c = sessionByName.get(PREFIX + 'Assistive Tech - Accessibility Basics').Id,
        Participant__c = secondaryUser.Id,
        Status__c = 'Pending Approval'
    ),
    new Skill_Session_Participant__c(
        Name = PREFIX + secondaryUser.Name,
        Skill_Session__c = sessionByName.get(PREFIX + 'Leadership Essentials - Cohort A').Id,
        Participant__c = secondaryUser.Id,
        Status__c = 'Pending Approval'
    ),

    // Current user - full session demo
    new Skill_Session_Participant__c(
        Name = PREFIX + currentUser.Name,
        Skill_Session__c = sessionByName.get(PREFIX + 'Admin Foundations - Afternoon Batch').Id,
        Participant__c = currentUser.Id,
        Status__c = 'Confirmed'
    ),
    new Skill_Session_Participant__c(
        Name = PREFIX + secondaryUser.Name,
        Skill_Session__c = sessionByName.get(PREFIX + 'Admin Foundations - Afternoon Batch').Id,
        Participant__c = secondaryUser.Id,
        Status__c = 'Confirmed'
    ),

    // Other status examples
    new Skill_Session_Participant__c(
        Name = PREFIX + currentUser.Name,
        Skill_Session__c = sessionByName.get(PREFIX + 'Inclusive Product Design - Workshop').Id,
        Participant__c = currentUser.Id,
        Status__c = 'Canceled'
    ),
    new Skill_Session_Participant__c(
        Name = PREFIX + currentUser.Name,
        Skill_Session__c = sessionByName.get(PREFIX + 'Operational Analytics - Reports Lab').Id,
        Participant__c = currentUser.Id,
        Status__c = 'No-Show'
    )
};

insert participants;

// ------------------------------------------------------------
// 9. Correct participant Name and desired statuses after automation
// ------------------------------------------------------------
// This is intentionally best-effort. If approval locks a third-party
// record, the script logs the issue but keeps the rest of the seed data.

Map<Id, User> usersById = new Map<Id, User>([
    SELECT Id, Name
    FROM User
    WHERE Id IN :new Set<Id>{
        currentUser.Id,
        secondaryUser.Id
    }
]);

List<Skill_Session_Participant__c> insertedParticipants = [
    SELECT Id, Name, Participant__c, Status__c, Skill_Session__r.Name
    FROM Skill_Session_Participant__c
    WHERE Name LIKE :PREFIX + '%'
];

List<Skill_Session_Participant__c> participantUpdates = new List<Skill_Session_Participant__c>();

for (Skill_Session_Participant__c participant : insertedParticipants) {
    User participantUser = usersById.get(participant.Participant__c);
    String desiredName = PREFIX + (participantUser == null ? 'Unknown Participant' : participantUser.Name);

    String desiredStatus = participant.Status__c;

    if (participant.Skill_Session__r.Name == PREFIX + 'Assistive Tech - Accessibility Basics') {
        desiredStatus = 'Pending Approval';
    } else if (participant.Skill_Session__r.Name == PREFIX + 'Leadership Essentials - Cohort A') {
        desiredStatus = 'Pending Approval';
    } else if (participant.Skill_Session__r.Name == PREFIX + 'Operational Analytics - Completed Session') {
        desiredStatus = 'Completed';
    } else if (participant.Skill_Session__r.Name == PREFIX + 'Inclusive Product Design - Workshop') {
        desiredStatus = 'Canceled';
    } else if (participant.Skill_Session__r.Name == PREFIX + 'Operational Analytics - Reports Lab') {
        desiredStatus = 'No-Show';
    } else {
        desiredStatus = 'Confirmed';
    }

    if (participant.Name != desiredName || participant.Status__c != desiredStatus) {
        participantUpdates.add(new Skill_Session_Participant__c(
            Id = participant.Id,
            Name = desiredName,
            Status__c = desiredStatus
        ));
    }
}

if (!participantUpdates.isEmpty()) {
    Database.SaveResult[] updateResults = Database.update(participantUpdates, false);

    for (Integer i = 0; i < updateResults.size(); i++) {
        if (!updateResults[i].isSuccess()) {
            System.debug(
                LoggingLevel.WARN,
                'Could not update participant ' + participantUpdates[i].Id + ': ' +
                updateResults[i].getErrors()[0].getMessage()
            );
        }
    }
}

// ------------------------------------------------------------
// 9.1. Close the demo "full session" after participant automation
// ------------------------------------------------------------
// The session is created with 3 seats to let participant after-save
// automation complete. After the two confirmed participants exist,
// reduce it to 2 seats to produce a clean full-session demo:
// Total Seats = 2, Seats Taken = 2, Seats Open = 0.

Skill_Session__c fullSession = [
    SELECT Id, Total_Seats__c, Seats_Taken__c, Seats_Open__c
    FROM Skill_Session__c
    WHERE Name = :PREFIX + 'Admin Foundations - Afternoon Batch'
    LIMIT 1
];

fullSession.Total_Seats__c = 2;
update fullSession;

// ------------------------------------------------------------
// 10. Re-query and log summary
// ------------------------------------------------------------

List<Skill_Session__c> seededSessions = [
    SELECT Id, Name, Total_Seats__c, Seats_Taken__c, Seats_Open__c, Training_Hours__c
    FROM Skill_Session__c
    WHERE Name LIKE :PREFIX + '%'
    ORDER BY Name
];

System.debug('============================================================');
System.debug('Skill Enhancement Tracker seed completed.');
System.debug('Providers: ' + providers.size());
System.debug('Programs: ' + programs.size());
System.debug('Courses: ' + courses.size());
System.debug('Sessions: ' + sessions.size());
System.debug('Participants: ' + participants.size());
System.debug('Current user: ' + currentUser.Name);
System.debug('Secondary user: ' + secondaryUser.Name);
System.debug('============================================================');

for (Skill_Session__c sessionRecord : seededSessions) {
    System.debug(
        sessionRecord.Name +
        ' | Total=' + sessionRecord.Total_Seats__c +
        ' | Taken=' + sessionRecord.Seats_Taken__c +
        ' | Open=' + sessionRecord.Seats_Open__c +
        ' | Hours=' + sessionRecord.Training_Hours__c
    );
}