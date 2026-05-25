trigger SkillSessionParticipantTrigger on Skill_Session_Participant__c (
    before insert,
    before update,
    after insert,
    after update,
    after delete,
    after undelete
) {
    if (Trigger.isBefore) {
        SkillSessionParticipantTriggerHandler.validateUniqueParticipantPerSession(
            Trigger.new,
            Trigger.isUpdate ? Trigger.oldMap : null
        );

        SkillSessionParticipantTriggerHandler.setParticipantName(
            Trigger.new
        );
    }

    if (Trigger.isAfter) {
        SkillSessionParticipantTriggerHandler.recalculateSeatsTaken(
            Trigger.isDelete ? Trigger.old : Trigger.new,
            Trigger.isUpdate ? Trigger.oldMap : null
        );
    }
}