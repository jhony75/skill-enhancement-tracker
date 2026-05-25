trigger SkillSessionParticipantTrigger on Skill_Session_Participant__c (
    after insert,
    after update,
    after delete,
    after undelete
) {
    SkillSessionParticipantTriggerHandler.recalculateSeatsTaken(
        Trigger.isDelete ? Trigger.old : Trigger.new,
        Trigger.isUpdate ? Trigger.oldMap : null
    );
}