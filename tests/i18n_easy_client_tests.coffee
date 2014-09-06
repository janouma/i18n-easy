Tinytest.add(
	'setDefault/getDefault works'
	(test)->
		do resetData

		defaultLanguage = 'it'
		I18nEasy.setDefault defaultLanguage
		test.equal I18nEasy.getDefault(), defaultLanguage
)

Tinytest.add(
	'setLanguage/getLanguage works'
	(test)->
		do resetData

		language = 'es'
		I18nEasy.setLanguage language
		test.equal I18nEasy.getLanguage(), language
)

Tinytest.add(
	'i18n works'
	(test)->
		do resetData

		test.equal(
			I18nEasy.i18n 'unkown_key'
			"unkown_key..."
		)

		I18nEasy.setLanguage 'fr'
		do Deps.flush

		testKey = 'test_key'

		test.equal(
			I18nEasy.i18n testKey
			fr[testKey]
		)

		I18nEasy.setLanguage 'en'
		do Deps.flush

		test.equal(
			I18nEasy.i18n testKey
			en[testKey]
		)
)

Tinytest.add(
	'section keys take precedence over global ones'
		(test)->
			do resetData

			defaultLanguage = 'fr'
			language = 'en'

			I18nEasy.setDefault defaultLanguage
			I18nEasy.setLanguage language
			do Deps.flush

			testKey = 'section_test_key'
			globalDefaultValue = 'global test default value'
			globalValue = 'global test value'
			localDefaultValue = 'local test default value'
			localValue = 'local test value'
			section = 'test'

			I18nEasyMessages.insert {
				key: testKey
				language: defaultLanguage
				message: localDefaultValue
				section: section
			}

			I18nEasyMessages.insert {
				key: testKey
				language: defaultLanguage
				message: globalDefaultValue
			}

			I18nEasyMessages.insert {
				key: testKey
				language: language
				message: localValue
				section: section
			}

			I18nEasyMessages.insert {
				key: testKey
				language: language
				message: globalValue
			}


			# actual

			test.equal(
				I18nEasy.i18n testKey
				globalValue
			)

			test.equal(
				I18nEasy.i18n testKey, section: 'unknown'
				globalValue
			)

			test.equal(
				I18nEasy.i18n testKey, section: section
				localValue
			)

			test.equal(
				I18nEasy.i18n testKey, section
				localValue
			)


			# default

			test.equal(
				I18nEasy.i18nDefault testKey
				globalDefaultValue
			)

			test.equal(
				I18nEasy.i18nDefault testKey, section: 'unknown'
				globalDefaultValue
			)

			test.equal(
				I18nEasy.i18nDefault testKey, section: section
				localDefaultValue
			)

			test.equal(
				I18nEasy.i18nDefault testKey, section
				localDefaultValue
			)
)

Tinytest.add(
	'i18n uses current route name as "section" parameter'
	(test)->
		do resetData

		defaultLanguage = 'fr'
		language = 'en'

		I18nEasy.setDefault defaultLanguage
		I18nEasy.setLanguage language
		do Deps.flush

		testKey = 'route_test_key'
		localDefaultValue = 'route test default value'
		localValue = 'route test value'
		route = 'route'

		I18nEasyMessages.insert {
			key: testKey
			language: language
			message: localValue
			section: route
		}

		I18nEasyMessages.insert {
			key: testKey
			language: defaultLanguage
			message: localDefaultValue
			section: route
		}

		ironRouterPackage = 'iron:router'

		if Package[ironRouterPackage]
			OldRouter = Package[ironRouterPackage].Router
		else
			Package[ironRouterPackage] = {}

		Package[ironRouterPackage].Router = current: ->
			Meteor._debug "Calling mocked 'iron-router'"
			route: name: route


		# actual

		test.equal(
			I18nEasy.i18n testKey
			localValue
		)


		# default

		test.equal(
			I18nEasy.i18nDefault testKey
			localDefaultValue
		)

		if OldRouter
			Package[ironRouterPackage].Router = OldRouter
		else
			delete Package[ironRouterPackage]
)

Tinytest.add(
	'pluralize works'
	(test)->
		do resetData

		testKeyOne = 'test_key_one'
		testKeyTwo = 'test_key_two'
		I18nEasy.setLanguage 'en'
		do Deps.flush

		test.equal(
			I18nEasy.i18n "#{testKeyOne}s"
			"#{en[testKeyOne]}s"
		)
		test.equal(
			I18nEasy.i18n testKeyTwo
			en[testKeyTwo][0]
		)
		test.equal(
			I18nEasy.i18n "#{testKeyTwo}s"
			en[testKeyTwo][1]
		)
)

Tinytest.add(
	'getLanguages works'
	(test)->
		do resetData

		test.equal(
			I18nEasy.getLanguages()
			['en','fr']
		)
)

Tinytest.add(
	'translations works'
	(test)->
		do resetData

		I18nEasy.setDefault 'fr'
		I18nEasy.setLanguage 'en'
		do Deps.flush

		test.isTrue EJSON.equals(
			do I18nEasy.translations
			[
				{
					key: 'test_key'
					label: 'test de clé'
					singular:
						default: 'test de clé'
						actual: 'key test'
					plural:
						actual: undefined
						default: 'key tests'
				}
				{
					key: 'test_key_one'
					label: '{{test_key_one}}'
					singular:
						actual: 'test'
					plural:
						actual: undefined
						default: 'tests'
				}
				{
					key: 'test_key_two'
					label: '{{test_key_two}}'
					singular:
						actual: 'test2'
					plural:
						actual: 'all tests'
				}
			]
		)
)

Tinytest.add(
	'i18n replace placeholders'
	(test)->
		do resetData

		defaultLanguage = 'fr'
		language = 'en'

		I18nEasy.setDefault defaultLanguage
		I18nEasy.setLanguage language
		do Deps.flush

		testKey = 'key_with_placeholder'
		srcMessage = [
			'Hello there {{name}}, from {{company}}'
			'Hi there everyone of {{company}}, {{name}} too'
		]

		name = 'Sebastian'
		company = 'The Company'

		expectedMessage = [
			srcMessage[0].replace(/\{\{name\}\}/, name).replace(/\{\{company\}\}/, company)
			srcMessage[1].replace(/\{\{name\}\}/, name).replace(/\{\{company\}\}/, company)
		]

		I18nEasyMessages.insert {
			key: testKey
			language: language
			message: srcMessage
		}

		test.equal(
			I18nEasy.i18n testKey, name: name, company: company
			expectedMessage[0]
		)

		test.equal(
			I18nEasy.i18ns testKey, name: name, company: company
			expectedMessage[1]
		)
)