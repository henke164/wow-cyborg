function CreateOption(npc, text, index)
  local option = {}
  option.npc = npc;
  option.text = text;
  option.index = index;
  return option;
end

optionsToSelect = {};
table.insert(optionsToSelect, CreateOption("Ebyssian", "A great journey", 1));
table.insert(optionsToSelect, CreateOption("Pathfinder Tacha", "interested in", 1));
table.insert(optionsToSelect, CreateOption("Cataloger Coralie", "new discovery", 1));
table.insert(optionsToSelect, CreateOption("Boss Magor", "buy something", 1));
table.insert(optionsToSelect, CreateOption("Kodethi", "Welcome", 1));
table.insert(optionsToSelect, CreateOption("Archmage Khadgar", "We have much to discuss", 1));
table.insert(optionsToSelect, CreateOption(nil, "Each page is filled with an elegant,", 1));
table.insert(optionsToSelect, CreateOption(nil, "<The first column asks for your name.>", 1));
table.insert(optionsToSelect, CreateOption(nil, "<The middle column asks for", 3));
table.insert(optionsToSelect, CreateOption(nil, "<The final column asks for", 4));
table.insert(optionsToSelect, CreateOption("Sendrax", "A single egg remains.", 1));
table.insert(optionsToSelect, CreateOption("Alexstrasza the Life-Binder", "The Ruby Lifeshrine", 1));
table.insert(optionsToSelect, CreateOption("Gurgthock", "rumble", 1));
table.insert(optionsToSelect, CreateOption(nil, "It is an honor to serve", 1));
table.insert(optionsToSelect, CreateOption("Talonstalker Kavia", "occupying", 1));
table.insert(optionsToSelect, CreateOption("Archivist Edress", "history of the", 1));
table.insert(optionsToSelect, CreateOption("Forgemaster Bazentus", "mortal", 1));
table.insert(optionsToSelect, CreateOption("Wrathion", "grasp", 1));
table.insert(optionsToSelect, CreateOption("Wrathion", "secure this courtyard", 1));
table.insert(optionsToSelect, CreateOption("Left", "good fight", 1));
table.insert(optionsToSelect, CreateOption("Talonstalker Kavia", "new ways", 1));
table.insert(optionsToSelect, CreateOption("Archivist Edress", "books, scrolls, hours", 1));
table.insert(optionsToSelect, CreateOption("Baskilan", "Well met", 1));
table.insert(optionsToSelect, CreateOption("Forgemaster Bazentus", "begin building", 1));
table.insert(optionsToSelect, CreateOption("Sabellian", "Are you ready to depart", 1));
table.insert(optionsToSelect, CreateOption("Aru", "Hunting is about", 1));
table.insert(optionsToSelect, CreateOption("Beastmaster Nuqut", "I tend to our beasts", 1));
table.insert(optionsToSelect, CreateOption("Ohn Seshteng", "your arrival", 1));
table.insert(optionsToSelect, CreateOption("Scout Tomul", "to keep up", 1));
table.insert(optionsToSelect, CreateOption("Ohn Seshteng", "aid in the ritual", 2));
table.insert(optionsToSelect, CreateOption("Elder Odgerel", "Clan Teerai", 1));
table.insert(optionsToSelect, CreateOption("Ohn Arasara", "Stay true", 1));
table.insert(optionsToSelect, CreateOption("Provisioner Zara", "seeks a hearth.", 1));
table.insert(optionsToSelect, CreateOption("Sansok Khan", "Do you feel prepared", 1));
table.insert(optionsToSelect, CreateOption("Sansok Khan", "traditions and guides", 4));
table.insert(optionsToSelect, CreateOption("Sansok Khan", "honed a special connection", 1));
table.insert(optionsToSelect, CreateOption("Sansok Khan", "military force", 2));
table.insert(optionsToSelect, CreateOption("Sansok Khan", "hunting game", 1));
table.insert(optionsToSelect, CreateOption("Matchmaker Osila", "Zandalari", 1));
table.insert(optionsToSelect, CreateOption("Hunter Narman", "small pond", 1));
table.insert(optionsToSelect, CreateOption("Khansguard Akato", "Khanam", 1));
table.insert(optionsToSelect, CreateOption("Scout Khenyug", "What do you want", 1));
table.insert(optionsToSelect, CreateOption("Herbalist Agura", "A handful", 1));
table.insert(optionsToSelect, CreateOption("Khansguard Hojin", "Are you lost", 1));
table.insert(optionsToSelect, CreateOption("Quartermaster Gensai", "How can I help you", 1));
table.insert(optionsToSelect, CreateOption("Boku's Belongings", "There are more", 1));
table.insert(optionsToSelect, CreateOption("Unidentified Centaur", "This is not Boku", 1));
table.insert(optionsToSelect, CreateOption("Khanam Matra Sarest", "Have you rallied my forces?", 1));
table.insert(optionsToSelect, CreateOption("Khanam Matra Sarest", "The Horn of Drusahl is one", 1));
table.insert(optionsToSelect, CreateOption("Khanam Matra Sarest", "But first", 1));
table.insert(optionsToSelect, CreateOption("Gerithus", "My mother is kind", 1));
table.insert(optionsToSelect, CreateOption("Sariosa", "Greetings! Oh my", 1));
table.insert(optionsToSelect, CreateOption("Sidra the Mender", "The Primalists", 1));
table.insert(optionsToSelect, CreateOption("Guard-Captain Alowen", "The Primalists", 1));
table.insert(optionsToSelect, CreateOption("Aronus", "Care for a lift?", 1));
table.insert(optionsToSelect, CreateOption("Viranikus", "The Primalists", 1));
table.insert(optionsToSelect, CreateOption("Mysterious Apparition", "My name is...", 1));
table.insert(optionsToSelect, CreateOption("Mysterious Apparition", "First, a form is needed", 1));
table.insert(optionsToSelect, CreateOption("Mysterious Apparition", "Now, think of", 2));
table.insert(optionsToSelect, CreateOption("Mysterious Apparition", "Next, each creation", 2));
table.insert(optionsToSelect, CreateOption(nil, "The root is leeching", 1));
table.insert(optionsToSelect, CreateOption(nil, "Out of the corner of your eye", 1));
table.insert(optionsToSelect, CreateOption(nil, "The sludge oozing from the root", 1));
table.insert(optionsToSelect, CreateOption("Kalecgos", "Pardon me if I'm a little", 1));
table.insert(optionsToSelect, CreateOption("Elder Poa", "Have you come to hear a tale", 1));
table.insert(optionsToSelect, CreateOption("Elder Poa", "You think you have", 1));
table.insert(optionsToSelect, CreateOption("Elder Poa", "Oh really?", 1));
table.insert(optionsToSelect, CreateOption("Elder Poa", "Did you, now?", 1));
table.insert(optionsToSelect, CreateOption("Elder Poa", "Your powers of description", 1));
table.insert(optionsToSelect, CreateOption("Elder Poa", "Hmmm", 1));
table.insert(optionsToSelect, CreateOption("Rowie", "I can do this", 1));
table.insert(optionsToSelect, CreateOption("Rowie", "Y-you were", 1));
table.insert(optionsToSelect, CreateOption("Toejam the Terrible", "Toejam", 1));
table.insert(optionsToSelect, CreateOption("Brena", "Make yourself", 1));
table.insert(optionsToSelect, CreateOption("Neelo", "Who are you?", 1));
table.insert(optionsToSelect, CreateOption("Kalecgos", "The blue dragons must", 1));
table.insert(optionsToSelect, CreateOption("Sindragosa", "Shall we begin?", 1));
table.insert(optionsToSelect, CreateOption("Valdrakken Citizen", "Who maintained", 1));
table.insert(optionsToSelect, CreateOption("Valdrakken Citizen", "What", 1));
table.insert(optionsToSelect, CreateOption("Valdrakken Citizen", "Hello", 1));
table.insert(optionsToSelect, CreateOption("Mangled Corpse", "body", 1));
table.insert(optionsToSelect, CreateOption("Mangled Corpse", "dead", 1));
table.insert(optionsToSelect, CreateOption("Chromie", "It's you again", 1));
table.insert(optionsToSelect, CreateOption("Siaszerathel", "Ready to watch", 1));
table.insert(optionsToSelect, CreateOption("Aeonormu", "Which timeline is this", 1));
table.insert(optionsToSelect, CreateOption("Aeonormu", "Timewalkers?", 1));
table.insert(optionsToSelect, CreateOption("Chromie", "Are you ready? This ball full", 6));
table.insert(optionsToSelect, CreateOption("Soridormi", "We must hold", 1));
table.insert(optionsToSelect, CreateOption("Siaszerathel", "Chromie... I", 1));
table.insert(optionsToSelect, CreateOption("Andantenormu", "To be lost in time", 1));
table.insert(optionsToSelect, CreateOption("Nozdormu", "I fear time may unravel", 1));
table.insert(optionsToSelect, CreateOption("Chromie", "This is going to be one doozie", 1));
table.insert(optionsToSelect, CreateOption("Theramus", "You're still around?", 1));
table.insert(optionsToSelect, CreateOption("Theramus", "Ysera and I build this", 1));
table.insert(optionsToSelect, CreateOption("Belika", "With the clans", 1));
table.insert(optionsToSelect, CreateOption("Boku", "Glad to see you again", 1));
table.insert(optionsToSelect, CreateOption("Ohn Seshteng", "enemy positions", 1));
table.insert(optionsToSelect, CreateOption("Merithra", "battle has begun", 1));
table.insert(optionsToSelect, CreateOption("Gerithus", "You've done it", 1));
table.insert(optionsToSelect, CreateOption("Sansok Khan", "Sansok frowns", 1));
table.insert(optionsToSelect, CreateOption("Merithra", "Do you have something", 1));
table.insert(optionsToSelect, CreateOption("Tigari Khan", "offer the dragons", 3));
table.insert(optionsToSelect, CreateOption("Khanam Matra Sarest", "trusted to uphold our vow", 3));
table.insert(optionsToSelect, CreateOption("Bree'jo", "Good day being", 1));
table.insert(optionsToSelect, CreateOption("Bree'jo", "Dat thing", 1));
table.insert(optionsToSelect, CreateOption("Duncan Ironeye", "Ye", 1));
table.insert(optionsToSelect, CreateOption("Julk", "", 1));
table.insert(optionsToSelect, CreateOption("Supply Portal", "Need anything", 1));
table.insert(optionsToSelect, CreateOption("Kalecgos", "great jelp so far", 1));
table.insert(optionsToSelect, CreateOption(nil, "You who stand whence", 1));
table.insert(optionsToSelect, CreateOption("Korrikunit the Whalebringer", "Been too long", 1));
table.insert(optionsToSelect, CreateOption("Jokomuupat", "spread south all", 1));
table.insert(optionsToSelect, CreateOption("Babunituk", "Soup isn't ready", 1));
table.insert(optionsToSelect, CreateOption("Noriko the All-Remembering", "push forward", 1));
table.insert(optionsToSelect, CreateOption("Brena", "Busy at the moment", 1));
table.insert(optionsToSelect, CreateOption("Akiun", "Akiun gazes", 1));
table.insert(optionsToSelect, CreateOption("Tuskarr Fisherman", "She was clearly killed", 1));
table.insert(optionsToSelect, CreateOption("Tuskarr Hunter", "Gnolls would", 1));
table.insert(optionsToSelect, CreateOption("Tuskarr Craftsman", "daggers embedded", 1));
table.insert(optionsToSelect, CreateOption("Festering Gnoll", "foul gnoll", 1));


function HandleSpeak()
  if GossipFrame:IsVisible() ~= true then
    return true;
  end

  local avaQuests = C_GossipInfo.GetAvailableQuests();
  for _, v in ipairs(avaQuests) do
    C_GossipInfo.SelectAvailableQuest(v.questID);
    return;
  end

  local quests = C_GossipInfo.GetActiveQuests();
  for _, v in ipairs(quests) do
    if (v.isComplete == true) then
      C_GossipInfo.SelectActiveQuest(v.questID);
      return;
    end
  end

  local options = C_GossipInfo.GetOptions();
  for _, v in ipairs(options) do
    local textFound = string.find(v.name, "(Quest)");
    if textFound ~= nil then
      print("Selecting Quest option");
      C_GossipInfo.SelectOption(v.gossipOptionID);
      return;
    end
  end

  local npcOptions = {};
  for _, v in ipairs(optionsToSelect) do
    if (v.npc == nil or v.npc == UnitName("target")) then
      table.insert(npcOptions, v);
    end
  end
  
  local gossipText = C_GossipInfo.GetText();
  for _, v in ipairs(npcOptions) do
    local textFound = string.find(C_GossipInfo.GetText(), v.text);
    if textFound ~= nil then
      if C_GossipInfo.GetOptions()[v.index] == nil then
        return;
      end

      local optionId = C_GossipInfo.GetOptions()[v.index].gossipOptionID;
      C_GossipInfo.SelectOption(optionId);
      return;
    end
  end
end

local update = CreateFrame("FRAME");
update:SetScript("OnUpdate", function()
  HandleSpeak();
end);
