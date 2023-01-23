package options.substates;

class LanguageSettingsSubState extends BaseOptionsMenu {
	public function new() {
		title = Language.getString({s: 'Language Settings', spanish: 'Ajustes de Idioma'});
		rpcTitle = 'Language Settings Menu'; //for Discord Rich Presence

		var option:Option = new Option({s: 'Language:', spanish: 'Idioma:'},
			{s: 'Language of the game', spanish: 'Idioma del juego'},
			'language',
			'string',
			'English',
			Language.getLanguages());
		option.id = 'lang';
		addOption(option);

		super();
	}
}