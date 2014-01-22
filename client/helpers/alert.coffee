collection = new Meteor.Collection null

send = (status, key)->
	collection.remove {}
	collection.insert {
		status: status
		message: I18nEasy.i18nDefault key
		path: Router.current().path
	}
	module.changed = yes

module =
	message: -> collection.findOne()?.message
	status: -> collection.findOne()?.status
	path: -> collection.findOne()?.path
	changed: no
	clear: -> @changed = no


statuses = [
	'success'
	'info'
	'warning'
	'error'
]

for status in statuses
	do (status)->
		module[status] = (key)-> send(status, key)
		module["is#{status[0].toUpperCase()}#{status[1..]}"] = -> collection.findOne()?.status is status


@Alert = module