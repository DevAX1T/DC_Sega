return {
	Name = "echo2";
	Aliases = {"=2"};
	Description = "Echoes your text back to you.";
	Group = "Operator";
	Args = {
		{
			Type = "string";
			Name = "Text";
			Description = "The text."
		},
	};

	Run = function(_, text)
		return text
	end
}