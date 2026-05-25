@IsTest
private class SkillSessionParticipantHandlerTest {
    @TestSetup
    static void setupData() {
        Account provider = new Account(
            Name = 'Test Skill Provider',
            Skill_Provider_Status__c = 'Approved'
        );
        insert provider;

        Skill_Program__c program = new Skill_Program__c(
            Name = 'Test Program',
            Skill_Provider__c = provider.Id
        );
        insert program;

        Skill_Course__c course = new Skill_Course__c(
            Name = 'Test Course',
            Skill_Program__c = program.Id,
            Areas_of_Interest__c = 'Programming'
        );
        insert course;

        List<Skill_Session__c> sessions = new List<Skill_Session__c>{
            new Skill_Session__c(
                Name = 'Test Session A',
                Skill_Course__c = course.Id,
                Session_Start_Time__c = System.now().addDays(1),
                Session_End_Time__c = System.now().addDays(1).addHours(2),
                Total_Seats__c = 10
            ),
            new Skill_Session__c(
                Name = 'Test Session B',
                Skill_Course__c = course.Id,
                Session_Start_Time__c = System.now().addDays(2),
                Session_End_Time__c = System.now().addDays(2).addHours(3),
                Total_Seats__c = 10
            )
        };
        insert sessions;
    }

    @IsTest
    static void shouldRecalculateWhenStatusChanges() {
        Skill_Session__c sessionA = [
            SELECT Id
            FROM Skill_Session__c
            WHERE Name = 'Test Session A'
            LIMIT 1
        ];

        Skill_Session_Participant__c participant = new Skill_Session_Participant__c(
            Skill_Session__c = sessionA.Id,
            Participant__c = UserInfo.getUserId(),
            Status__c = 'Confirmed'
        );
        insert participant;

        Skill_Session__c afterInsert = [
            SELECT Seats_Taken__c
            FROM Skill_Session__c
            WHERE Id = :sessionA.Id
        ];

        Test.startTest();

        participant.Status__c = 'Canceled';
        update participant;

        Test.stopTest();

        Skill_Session__c afterUpdate = [
            SELECT Seats_Taken__c
            FROM Skill_Session__c
            WHERE Id = :sessionA.Id
        ];

        System.assertEquals(
            0,
            afterUpdate.Seats_Taken__c,
            'Changing a participant away from Confirmed/Completed should decrement Seats Taken.'
        );
    }

    @IsTest
    static void shouldRecalculateBothSessionsWhenParticipantMoves() {
        Map<String, Skill_Session__c> sessionsByName = new Map<String, Skill_Session__c>();

        for (Skill_Session__c sessionRecord : [
            SELECT Id, Name
            FROM Skill_Session__c
            WHERE Name IN ('Test Session A', 'Test Session B')
        ]) {
            sessionsByName.put(sessionRecord.Name, sessionRecord);
        }

        Skill_Session_Participant__c participant = new Skill_Session_Participant__c(
            Skill_Session__c = sessionsByName.get('Test Session A').Id,
            Participant__c = UserInfo.getUserId(),
            Status__c = 'Confirmed'
        );
        insert participant;

        Test.startTest();

        participant.Skill_Session__c = sessionsByName.get('Test Session B').Id;
        update participant;

        Test.stopTest();

        Map<Id, Skill_Session__c> refreshedSessions = new Map<Id, Skill_Session__c>([
            SELECT Id, Seats_Taken__c
            FROM Skill_Session__c
            WHERE Id IN :new Set<Id>{
                sessionsByName.get('Test Session A').Id,
                sessionsByName.get('Test Session B').Id
            }
        ]);

        System.assertEquals(
            0,
            refreshedSessions.get(sessionsByName.get('Test Session A').Id).Seats_Taken__c,
            'Original session should be recalculated when participant moves away.'
        );

        System.assertEquals(
            1,
            refreshedSessions.get(sessionsByName.get('Test Session B').Id).Seats_Taken__c,
            'New session should be recalculated when participant moves in.'
        );
    }

    @IsTest
    static void shouldRecalculateAfterDeleteAndUndelete() {
        Skill_Session__c sessionA = [
            SELECT Id
            FROM Skill_Session__c
            WHERE Name = 'Test Session A'
            LIMIT 1
        ];

        Skill_Session_Participant__c participant = new Skill_Session_Participant__c(
            Skill_Session__c = sessionA.Id,
            Participant__c = UserInfo.getUserId(),
            Status__c = 'Confirmed'
        );
        insert participant;

        Test.startTest();

        delete participant;

        Skill_Session__c afterDelete = [
            SELECT Seats_Taken__c
            FROM Skill_Session__c
            WHERE Id = :sessionA.Id
        ];

        System.assertEquals(
            0,
            afterDelete.Seats_Taken__c,
            'Deleting a confirmed participant should decrement Seats Taken.'
        );

        undelete participant;

        Test.stopTest();

        Skill_Session__c afterUndelete = [
            SELECT Seats_Taken__c
            FROM Skill_Session__c
            WHERE Id = :sessionA.Id
        ];

        System.assertEquals(
            1,
            afterUndelete.Seats_Taken__c,
            'Undeleting a confirmed participant should increment Seats Taken again.'
        );
    }
}