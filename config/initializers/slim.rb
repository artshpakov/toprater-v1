# supressing default '('=> ')', '[' => ']', '{' => '}', eases pain with Angular {{ }} content
Slim::Engine.set_default_options attr_delims: {'[' => ']'}
