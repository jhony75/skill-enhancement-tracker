public with sharing class SkillSessionParticipantTriggerHandler {
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