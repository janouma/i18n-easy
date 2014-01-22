collection = new Meteor.Collection null

send = (status, message)->
	collection.remove {}
	collection.insert {
		status: status
		message: message
		path: Router.current().path
	}
	module.changed = yes

statuses = [
	'success'
	'info'
	'warning'
	'error'
]

module =
	message: -> collection.findOne()?.message
	status: -> collection.findOne()?.status
	path: -> collection.findOne()?.path
	changed: no
	clear: -> @changed = no


for status in statuses
	do (status)->
		module[status] = (message)-> send(status, message)
		module["is#{status[0].toUpperCase()}#{status[1..]}"] = -> collection.findOne()?.status is status


@Alert = module