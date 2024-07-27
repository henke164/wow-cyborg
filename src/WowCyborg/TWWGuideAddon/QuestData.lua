steps = {};

function CreateStep(x, y, zone, target, description, completeEvent, questId, npcMessage)
  local step = {};
  step.x = x;
  step.y = y;
  step.zone = zone;
  step.description = description;
  step.target = target;
  step.completeEvent = completeEvent;
  step.questId = questId;
  step.npcMessage = npcMessage;
  return step;
end

table.insert(steps, CreateStep(49.63, 59.44, "Chamber of Heart", nil, "Accept quest", "QUEST_ACCEPTED", 78716));
table.insert(steps, CreateStep(43.83, 59.35, "Dalaran", "Archmage Khadgar", "Complete quest", "COMPLETED", 78716));
table.insert(steps, CreateStep(41.24, 55.05, "Dalaran", "Moira Thaurissan", "Accept quest", "QUEST_ACCEPTED", 80500));
table.insert(steps, CreateStep(51.02, 55.77, "Dalaran", nil, "Turn in quest", "QUEST_TURNED_IN", 80500));
table.insert(steps, CreateStep(41.72, 53.81, "Dalaran", "Moira Thaurissan", "Turn in quest", "QUEST_TURNED_IN", 80500));
table.insert(steps, CreateStep(43.31, 59.48, "Dalaran", "Archmage Khadgar", "Accept quest", "QUEST_ACCEPTED", 82540));
table.insert(steps, CreateStep(43.31, 59.48, "Dalaran", "Archmage Khadgar", "Accept quest", "QUEST_ACCEPTED", 84373));
table.insert(steps, CreateStep(42.58, 60.79, "Dalaran", "Questzertauren", "Talk", "QUEST_WATCH_UPDATE", 84373));
table.insert(steps, CreateStep(29.44, 55.05, "Isle of Dorn", "Thrall", "Accept quest", "QUEST_ACCEPTED", 78531));
table.insert(steps, CreateStep(29.5, 55.02, "Isle of Dorn", "Lady Jaina Proudmoore", "Accept quest", "QUEST_ACCEPTED", 78530));
table.insert(steps, CreateStep(30.93, 55.16, "Isle of Dorn", "Archmage Aethas Sunreaver", "Accept quest", "QUEST_ACCEPTED", 78532));
table.insert(steps, CreateStep(29.47, 55.06, "Isle of Dorn", "Thrall", "Complete quest", "COMPLETED", 78531));
table.insert(steps, CreateStep(29.53, 54.97, "Isle of Dorn", "Anduin Wrynn", "Accept quest", "QUEST_ACCEPTED", 78533));