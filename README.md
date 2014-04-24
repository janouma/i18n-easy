# I18n easy

[admin]: https://github.com/janouma/i18n-easy-admin

*version: 0.1.5*

**I18n easy** provide a simple way to add i18n feature to your meteor app.

When adding translation, one can set the plural version as well. For translation without plural, an *"s"* is added to the singular version when plural is requested.

It is possible to group translations by *sections*: indeed each route can have his own translation, thus reducing the amount of records sent to client via publications. *Section* translations overwrite global ones *– thoses not attached to any section*.

## Setup

### Setting default language

First you need to set the default language both server side and client side, for instance in a file placed under the ***/lib*** directory of your meteor app

	I18nEasy.setDefault('en');
	
### <a name="addingTranslations"></a> Adding translations

Then add translations server side:

	I18nEasy.mapAll({
		en: {
			home: "home",
			setting: "setting",
			greetings: "grettings {{name}}!",
			
			// singular and plural
			summary: ["summary","summaries"],
			
			// Client section
			clients: {
				name: "name",
				company: "company"
			}						
		},
		
		fr: {
			home: "acceuil",
			setting: "préférences",
			summary: "sommaire",
			greetings: "salutations {{name}}!",
			
			// Client section
			clients: {
				name: "nom",
				company: "société"
			}
		}
	});

***note:*** *`{{placeholders}}` cannot have the following names: `fallBack`, `autoPlural`, `useDefault` or `section`*

### <a name="publications"></a> Setting publications and subscriptions

Finally setup publications and subscriptions

Server side

	I18nEasy.publish();
	
Client side
	
	I18nEasy.subscribe();

To limit publications to a list of *sections*  

	I18nEasy.subscribe({sections: ["section1", "section2"]});
	
This will tell **I18n easy** to load only translations pertaining solely to the given sections and those not attached to any section *– global ones*. If no *section* is provided, only global ones will be loaded.

<a name="publications_notes"></a> ***note:*** *When the `subscribe` API is used, only the following translations are published:*

- *those in the selected language and not attached to any section;*
- *those pertaining to the `sections` parameter;*
- *those in the default language which are missing from the selected language*

### Setting current language

Every time language switch is necessary *– client side most of the time –* use the following api:

	// Switching to french
	I18nEasy.setLanguage('fr');

### <a name="allowWrite"></a> Security

To prevent unauthorized updates of translations, you should setup permissions *— server side and client side —* like this

	I18nEasy.allowWrite(function(){
		return false;
	});	

***note:*** *This is used by [I18n easy admin][admin] to restrict access to the admin UI. For example `true` could be returned only if user is authenticated.*

## Usage

Use the *i18n* helper to access translations within templates

	{{i18n 'summary'}} // -> display "summary" according to previously added translations
	{{i18n 'greetings' name='Sebastian'}} // -> display "grettings Sebastian!" according to previously added translations

To request plural translation, just add an *"s"* to the key or the helper

	{{i18n 'summarys'}} // -> display "summaries" according to previously added translations
	{{i18ns 'summary'}} // -> display "summaries" according to previously added translations

## iron-router integration

### Ease your setup

If you use *[iron-router](https://github.com/EventedMind/iron-router)*, here is the better way to subscribe to translations

	…
	
	waitOn: function(){
		return I18nEasy.subscribe();
	},
	
	…
	
The easiest way to switch language is to add an optional `language` parameter to every routes and add a `before` hook that use the `I18nEasy.setLanguage(<language parameter>)` api to actually switch language

	…
	
	function navigatorLanguage(){
    	var results = /(\w{2}).*/gi.exec(window.navigator.language);
    	return results.length > 1 && results[1];
    }
	
	Router.before(function(){
		var language = this.params.language || navigatorLanguage();

		if(language && I18nEasy.getLanguage() !== language){
			I18nEasy.setLanguage(language);
		}
	});

	…
	
	Router.map(function(){
	
		this.route('invoices', {
			path: '/:language?/invoices'
		});
	
    	…
    
    });
   
When no *section* is provided to `I18nEasy.subscribe()`, the current route name is used as *section* paramater. Therefore it is a good practice to put translations needed solely on a specific route under a *section* matching this route name: it will reduce the amount of records sent to the client, thus improve your app performances.

### pathToLanguage helper

Finally, **I18n easy** comes with the handy helper `pathToLanguage <language>` which gives you the path to the current route translated to the given language. It is usefull to display navigations for languages switching.


***footer.html***

	{{#each languages}}
	<li class="{{activeLanguageClass this}}">
		<a href="{{pathToLanguage this}}">{{i18n this}}</a>
	</li>
	{{/each}}
	
***footer.js***

	Template.footer.helpers({
		activeLanguageClass: function(language){
			if(language === I18nEasy.getLanguage()){
				return 'active';
			}else{
				return undefined;
			}	
		},
		
		languages: function(){return I18nEasy.getLanguages();}
	});
	

## API and helpers

### Helpers

#### <a name="i18n"></a> *i18n*

Request a translation in the current language.

**parameter**: key **[String]**


	{{i18n 'key'}} // display singular translation for 'key'
	{{i18n 'keys'}} // display plural translation for 'key'

###### **Default behavior**

If no translation is present in the current language, the translation in the default one is displayed. If the key has no translation *– neither in the current language nor in the default one*, the result is `key...` . When requesting plural, if no plural translation is present, an *"s"* is simply added to the singular translation.

	
#### <a name="i18ns"></a> *i18ns*

Request plural

**parameter**: key **[String]**

#### <a name="i18nDefault"></a> *i18nDefault*

Request translation in the default language.

**parameter**: key **[String]**

#### <a name="translate"></a> *translate*

Request a translation in the current language. The difference with *i18n*, is that *translate* doesn't have any default behavior: indeed when no translation is found, undefined is returned.

**parameter**: key **[String]**

#### <a name="translatePlural"></a> *translatePlural*

Same as *translate* for the plural version.

**parameter**: key **[String]**

#### *pathToLanguage – only when "iron-router" package is installed*

Gives you the path to the current route translated to the given language.

**parameter**: language **[String]**

### API

#### Client and Server

- **setDefault ( language [String] )** *– Set the default language*
- **getDefault ( )** *– Return the default language*
- **setLanguage ( language [String] )** *– Set the actual language*
- **getLanguage ( )** *– Return the actual language*
- **getLanguages ( )** *– Return an array of all available languages*
- **getSections ( )** *– Return an array of all available sections*

- **i18n ( key [String], options [Object] )** *– See [helpers](#i18n)*
	- **options**
		- **fallBack [Boolean]** *– If true return `key...` when no translation is available*
		- **autoPlural [Boolean]** *– If true return `singular+s` when no plural translation is available*
		- **useDefault [Boolean]** *– If true return default language translation when none is available in the current one*

- **i18nDefault ( key [String], options [Object] )** *– See [helpers](#i18nDefault)*
- **i18ns ( key [String], options [Object] )** *– See [helpers](#i18ns)*
- **translate ( key [String] )** *– See [helpers](#translate)*
- **translatePlural ( key [String] )** *– See [helpers](#translatePlural)*
- **translations ( section [String] )** *– Return all available translations in both default and actual language (usefull for [I18n easy admin][admin]). When section parameter is provided, returned translations are restricted to the given section*
- **allowWrite ( writePermission [Function] )** *– Set write permission for translations (see [Setup / Secutity](#allowWrite))*
- **writeIsAllowed ( )** *– Check if translation update is authorized according to the `writePermission` set via the [`allowWrite`](#allowWrite) API*

#### Client

- <a name="subscribe"></a>**subscribe ( options [Object] )** *– Subscribe to translations*
	- **options**
		- **default [String]** *– Subscribe to the given language after setting it as the default one*
		- **actual [String]** *– Subscribe to the given language as the actually selected one*
		- **sections [String array]** *– Subscribe only to translations pertaining the the given sections and the global ones (meaning those not attached to any section)*

- **defaultSubscribe ( options [Object] )** *– Subscribe to both languages set as default and actual language. See subscribe for options, remember though that "default" and "actual" options will be ignored*

- **subscribeForTranslation ( options [Object] )** *– Same as `subscribe ( options [Object] )` + subscribe to ALL translations both in default and actual languages (see [Setting publications and subscriptions / notes](#publications_notes). Usefull for [I18n easy admin][admin])*

#### Server

- **map ( language [String], messages [Object] )** *– Add the translations from "messages" to "language"*

- **mapAll ( translations [Object], options [Object] )** *– See [Adding translations](#addingTranslations)*
	- **options**
		- **overwrite [Boolean]** *– if true overwrite existing translations with the provided ones*
- **publish ( options [Object] )**
	- **options**
		- **default [String]** *– Publish translations from the given language, assuming that it is the default one*
		- **actual [String]** *– Publish translations from the given language, assuming that it is the selected one*
		- **sections [String array]** *– Publish translations pertaining the given sections and the global ones (meaning those not attached to any section)*

### Collection

`I18nEasyMessages`

### Meteor methods *( usefull for [I18n easy admin][admin] )*

- **i18nEasyAddKey ( key [String], section [String] *(optional)* )** *– Add the key with a blank translation (an empty string) to the current language. If section parameter is present, the key is added solely in this section.*

- **i18nEasySave ( translations [Object array] )** *– Add / update the given translations*
	- **translation item**
	
		`{language: [String], key: [String], message: [String]|[String array], section: [String] (optional)}`

- **i18nEasyRemoveKey ( key [String], section [String] *(optional)* )** *– Remove the key from all languages. If section parameter is present, the key is only removed from this section.*
- **i18nEasyAddLanguage ( language )** *– Add a new language*
- **i18nEasyRemoveLanguage ( language )** *– Remove a language and all attached translations*
- **I18nEasyImport ( translations [Object] )** *– See [Adding translations](#addingTranslations) for translations structure*
- **i18nEasyRemoveSection ( section )** *– Remove a section and all attached keys and translations from all languages*
