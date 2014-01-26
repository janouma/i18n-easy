@validDocument = (userId, doc)->
	check(
		doc
		language: String
		key: String
		message: Match.OneOf(String, [String])
	)
	yes