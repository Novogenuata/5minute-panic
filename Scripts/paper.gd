extends Control
signal wrong_key
signal essay_finished
@onready var essay_text = $RichTextLabel
@onready var prompt_label = $CurrentPrompt

var current_sentence := []
var current_word_index := 0
var current_word := ""
var current_letter_index := 0

var words_written := 0
var page := 1
var finished := false

const WORDS_PER_PAGE := 5
const MAX_PAGES := 10

var sentence_pools_en = {
	1: [
		["cats", "need", "good", "daily", "care"],
		["sleep", "helps", "me", "think", "better"],
		["school", "can", "feel", "very", "hard"]
	],
	2: [
		["students", "need", "time", "to", "work"],
		["coffee", "keeps", "the", "brain", "awake"],
		["deadlines", "make", "people", "write", "fast"]
	],
	3: [
		["pressure", "can", "change", "student", "focus"],
		["research", "helps", "support", "strong", "claims"],
		["panic", "makes", "simple", "tasks", "harder"]
	],
	4: [
		["stress", "affects", "memory", "and", "focus"],
		["planning", "reduces", "panic", "during", "assignments"],
		["evidence", "shows", "habits", "shape", "success"]
	],
	5: [
		["students", "often", "delay", "important", "assignments"],
		["academic", "pressure", "increases", "late", "mistakes"],
		["healthy", "routines", "improve", "study", "performance"]
	],
	6: [
		["evidence", "supports", "healthier", "study", "habits"],
		["procrastination", "increases", "academic", "stress", "levels"],
		["deadlines", "intensify", "pressure", "and", "fatigue"]
	],
	7: [
		["consistent", "routines", "improve", "student", "performance"],
		["cognitive", "pressure", "reduces", "writing", "accuracy"],
		["motivation", "declines", "under", "constant", "stress"]
	],
	8: [
		["psychological", "pressure", "disrupts", "cognitive", "function"],
		["academic", "expectations", "compound", "student", "anxiety"],
		["prolonged", "stress", "undermines", "focused", "reasoning"]
	],
	9: [
		["institutional", "pressure", "complicates", "academic", "wellbeing"],
		["procrastination", "exacerbates", "cognitive", "overload", "rapidly"],
		["sustained", "anxiety", "deteriorates", "executive", "functioning"]
	],
	10: [
		["institutional", "expectations", "intensify", "procrastination", "consequences"],
		["psychophysiological", "stressors", "destabilize", "academic", "performance"],
		["metacognitive", "dysfunction", "exacerbates", "deadline", "paralysis"]
	]
}

var sentence_pools_fr = {
	1: [
		["les", "chats", "ont", "besoin", "soin"],
		["dormir", "aide", "a", "mieux", "penser"],
		["ecole", "peut", "etre", "tres", "dure"]
	],
	2: [
		["etudiants", "ont", "besoin", "de", "temps"],
		["cafe", "garde", "le", "cerveau", "eveille"],
		["delais", "font", "ecrire", "les", "gens"]
	],
	3: [
		["pression", "change", "la", "concentration", "etudiante"],
		["recherche", "aide", "a", "soutenir", "arguments"],
		["panique", "rend", "les", "taches", "difficiles"]
	],
	4: [
		["stress", "affecte", "memoire", "et", "concentration"],
		["planifier", "reduit", "panique", "lors", "devoirs"],
		["preuves", "montrent", "habitudes", "faconnent", "succes"]
	],
	5: [
		["etudiants", "remettent", "souvent", "devoirs", "importants"],
		["pression", "academique", "augmente", "les", "erreurs"],
		["routines", "saines", "ameliorent", "les", "performances"]
	],
	6: [
		["preuves", "soutiennent", "meilleures", "habitudes", "etudes"],
		["procrastination", "augmente", "stress", "academique", "niveaux"],
		["delais", "intensifient", "pression", "et", "fatigue"]
	],
	7: [
		["routines", "constantes", "ameliorent", "performances", "etudiantes"],
		["pression", "cognitive", "reduit", "precision", "ecriture"],
		["motivation", "decline", "sous", "stress", "constant"]
	],
	8: [
		["pression", "psychologique", "perturbe", "fonction", "cognitive"],
		["attentes", "academiques", "aggravent", "anxiete", "etudiante"],
		["stress", "prolonge", "mine", "raisonnement", "concentre"]
	],
	9: [
		["pression", "institutionnelle", "complique", "bienetre", "academique"],
		["procrastination", "aggrave", "surcharge", "cognitive", "rapidement"],
		["anxiete", "soutenue", "deteriore", "fonctionnement", "executif"]
	],
	10: [
		["attentes", "institutionnelles", "intensifient", "consequences", "procrastination"],
		["facteurs", "psychophysiologiques", "destabilisent", "performance", "academique"],
		["dysfonction", "metacognitive", "aggrave", "paralysie", "delais"]
	]
}

@onready var lang_manager = get_node("/root/LanguageManager")

func get_pools() -> Dictionary:
	if lang_manager.current_language == "fr":
		return sentence_pools_fr
	return sentence_pools_en

func _ready():
	randomize()
	essay_text.text = ""
	start_page()

func _input(event):
	if finished:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		if current_word == "" or current_letter_index >= current_word.length():
			return

		var pressed = event.as_text().to_lower()
		var expected = current_word[current_letter_index].to_lower()

		if pressed == expected:
			write_letter()
		else:
			prompt_label.text = tr("WRONG_KEY") + expected.to_upper()
			wrong_key.emit()

func start_page():
	current_sentence = get_pools()[page].pick_random()
	current_word_index = 0
	words_written = 0
	current_word = ""
	current_letter_index = 0
	essay_text.text = ""
	start_word()

func start_word():
	if current_word_index >= current_sentence.size():
		next_page()
		return

	current_word = current_sentence[current_word_index]
	current_letter_index = 0
	update_prompt()

func update_prompt():
	if current_word == "" or current_letter_index >= current_word.length():
		return

	var expected = current_word[current_letter_index]
	prompt_label.text = tr("PRESS_KEY") + expected.to_upper()

func write_letter():
	if current_word == "" or current_letter_index >= current_word.length():
		return

	essay_text.text += current_word[current_letter_index]
	current_letter_index += 1

	if current_letter_index >= current_word.length():
		essay_text.text += " "
		words_written += 1
		current_word_index += 1

		if words_written >= WORDS_PER_PAGE:
			next_page()
		else:
			start_word()
	else:
		update_prompt()

func next_page():
	page += 1

	if page > MAX_PAGES:
		finished = true
		prompt_label.text = tr("ESSAY_DONE")
		essay_finished.emit()
		return

	prompt_label.text = tr("PAGE") + str(page)
	await get_tree().create_timer(0.5).timeout
	start_page()
