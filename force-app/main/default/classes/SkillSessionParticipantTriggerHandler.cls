public with sharing class SkillSessionParticipantTriggerHandler {
    public static void validateUniqueParticipantPerSession(
        List<Skill_Session_Participant__c> records,
        Map<Id, Skill_Session_Participant__c> oldMap
    ) {
        Set<Id> sessionIds = new Set<Id>();
        Set<Id> participantIds = new Set<Id>();

        for (Skill_Session_Participant__c record : records) {
            if (record.Skill_Session__c == null || record.Participant__c == null) {
                continue;
            }

            sessionIds.add(record.Skill_Session__c);
            participantIds.add(record.Participant__c);
        }

        if (sessionIds.isEmpty() || participantIds.isEmpty()) {
            return;
        }

        Set<Id> currentRecordIds = new Set<Id>();

        for (Skill_Session_Participant__c record : records) {
            if (record.Id != null) {
                currentRecordIds.add(record.Id);
            }
        }

        Map<String, Skill_Session_Participant__c> existingBySessionAndParticipant =
            new Map<String, Skill_Session_Participant__c>();

        for (Skill_Session_Participant__c existingRecord : [
            SELECT Id, Name, Skill_Session__c, Participant__c, Status__c
            FROM Skill_Session_Participant__c
            WHERE Skill_Session__c IN :sessionIds
            AND Participant__c IN :participantIds
            AND Id NOT IN :currentRecordIds
        ]) {
            existingBySessionAndParticipant.put(
                buildSessionParticipantKey(
                    existingRecord.Skill_Session__c,
                    existingRecord.Participant__c
                ),
                existingRecord
            );
        }

        Set<String> keysSeenInThisTransaction = new Set<String>();

        for (Skill_Session_Participant__c record : records) {
            if (record.Skill_Session__c == null || record.Participant__c == null) {
                continue;
            }

            String key = buildSessionParticipantKey(
                record.Skill_Session__c,
                record.Participant__c
            );

            if (keysSeenInThisTransaction.contains(key)) {
                record.addError(
                    'This participant is already signed up for this session in this transaction.'
                );
                continue;
            }

            keysSeenInThisTransaction.add(key);

            Skill_Session_Participant__c existingRecord =
                existingBySessionAndParticipant.get(key);

            if (existingRecord != null) {
                record.addError(
                    'This participant is already signed up for this session. ' +
                    'Open the existing participant record if you need to review or update the status.'
                );
            }
        }
    }

    public static void setParticipantName(List<Skill_Session_Participant__c> records) {
        Set<Id> participantIds = new Set<Id>();

        for (Skill_Session_Participant__c record : records) {
            if (record.Participant__c != null) {
                participantIds.add(record.Participant__c);
            }
        }

        if (participantIds.isEmpty()) {
            return;
        }

        Map<Id, User> usersById = new Map<Id, User>([
            SELECT Id, Name
            FROM User
            WHERE Id IN :participantIds
        ]);

        for (Skill_Session_Participant__c record : records) {
            if (record.Participant__c == null) {
                continue;
            }

            User participant = usersById.get(record.Participant__c);

            if (participant != null) {
                record.Name = participant.Name;
            }
        }
    }

    private static String buildSessionParticipantKey(Id sessionId, Id participantId) {
        return String.valueOf(sessionId) + '-' + String.valueOf(participantId);
    }

    public static void recalculateSeatsTaken(
        List<Skill_Session_Participant__c> records,
        Map<Id, Skill_Session_Participant__c> oldMap
    ) {
        Set<Id> sessionIds = new Set<Id>();

        for (Skill_Session_Participant__c record : records) {
            if (record.Skill_Session__c != null) {
                sessionIds.add(record.Skill_Session__c);
            }

            if (
                oldMap != null &&
                oldMap.containsKey(record.Id) &&
                oldMap.get(record.Id).Skill_Session__c != null
            ) {
                sessionIds.add(oldMap.get(record.Id).Skill_Session__c);
            }
        }

        if (sessionIds.isEmpty()) {
            return;
        }

        Map<Id, Integer> countsBySessionId = new Map<Id, Integer>();

        for (AggregateResult ar : [
            SELECT Skill_Session__c sessionId, COUNT(Id) total
            FROM Skill_Session_Participant__c
            WHERE Skill_Session__c IN :sessionIds
            AND Status__c IN ('Confirmed', 'Completed')
            GROUP BY Skill_Session__c
        ]) {
            countsBySessionId.put(
                (Id) ar.get('sessionId'),
                (Integer) ar.get('total')
            );
        }

        List<Skill_Session__c> sessionsToUpdate = new List<Skill_Session__c>();

        for (Id sessionId : sessionIds) {
            sessionsToUpdate.add(new Skill_Session__c(
                Id = sessionId,
                Seats_Taken__c = countsBySessionId.containsKey(sessionId)
                    ? countsBySessionId.get(sessionId)
                    : 0
            ));
        }

        update sessionsToUpdate;
    }
}