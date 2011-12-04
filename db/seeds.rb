# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

stores = Store.create( [ {name:"HDO", store_type:"MWS" }, {name:"HDO Webstore", store_type:"MWS" },{name:"FieldDay", store_type:"MWS" } ] )
