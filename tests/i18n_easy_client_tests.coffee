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
			['fr', 'en']
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