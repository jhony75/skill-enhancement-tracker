List<Skill_Session_Participant__c> participants = [SELECT Id FROM Skill_Session_Participant__c];
List<Skill_Session__c> sessions = [SELECT Id FROM Skill_Session__c WHERE Name LIKE 'Seed %'];
List<Skill_Course__c> courses = [SELECT Id FROM Skill_Course__c WHERE Name LIKE 'Seed %'];
List<Skill_Program__c> programs = [SELECT Id FROM Skill_Program__c WHERE Name LIKE 'Seed %'];
List<Account> accounts = [SELECT Id FROM Account WHERE RecordType.Name = 'Skill Provider Account'];

delete participants;
delete sessions;
delete courses;
delete programs;
delete accounts;