local module = {}

local info = {
	['LowBlood'] = {
		"The darkness creeps in at the edges of my vision, each pulse a reminder of my dwindling time.",
		"The end looms over me, a shadow growing darker, and I must summon every last ounce of will to face it.",
		"Pain courses through me, a stark reminder that time is running out.",
		"Every breath feels heavier, the shadow of death draws closer.",
		"My strength fades, but I must summon every ounce of will to face what's ahead.",
		"The weight of my wounds pulls me down, but I must fight to stay on my feet.",
		"Is this truly the end for me, or can I find the strength to survive?",
		"Is this how it all ends?",
		"I can barely stand—am I about to meet my fate?",
		"Am I truly fated to die here, with no one to remember my name?",
		"I am running out of time...",
		"This is not good.",
		"I've got to do something quick.",
		"I can feel myself getting weaker.",
	},
	['LowBloodRecovered'] = {
		"Did I truly defy the odds and escape death's grip?",
		"Am I still alive, or is this some cruel trick of fate?",
		"Could I have really made it through, when all seemed lost?",
		"The shadow of death loomed close, but I have slipped through its grasp.",
		"Adrenaline floods my senses, fueling my every move as I push forward.",
		"The rhythm of my heartbeat is a symphony of survival, a primal drum urging me to fight on.",
	},
	['Fell'] = {
		"The fall rattled my bones, leaving a lingering weakness in my legs.",
		"The ground feels unsteady beneath me, but I cannot afford to falter now.",
		"What was I thinking? That was beyond reckless.",
		"That was a foolish move, and now I'm paying the price.",
		"I should have known better than to take such a risk.",
		"Leaping without thinking—how could I be so careless?",
		"That was a reckless leap, and now I face the consequences.",
		"That was incredibly stupid; I can't believe I did that.",
		"How stupid can I be sometimes?",
	},
}

function module:getDialogue(dialogueName :string)
	return info[dialogueName]
end

return module
