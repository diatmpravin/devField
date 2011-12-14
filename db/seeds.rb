# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

stores = Store.create( [ 
  {name:"HDO", store_type:"MWS", queue_flag:"False", verify_flag:"True", max_order_pages:2, order_results_per_page:2 },
  {name:"HDO Webstore", store_type:"MWS", queue_flag:"False", verify_flag:"True", max_order_pages:2, order_results_per_page:2 },
  {name:"FieldDay", store_type:"MWS", queue_flag:"False", verify_flag:"True", max_order_pages:2, order_results_per_page:2 }
] )

vendors = Vendor.create( [ {name:"Safilo"}, {name:"Tifosi"}, {name:"Oakley"}, {name:"Arnette"}, {name:"Luxottica"} ])

brands = Brand.create( [ 	{name:'Carrera', vendor: vendors.first},
													#{name:'Dior', vendor: vendors.first},
													#{name:'Emporio Armani', vendor: vendors.first},
													#{name:'Giorgio Armani', vendor: vendors.first},
													#{name:'Marc Jacobs', vendor: vendors.first},
													#{name:'Marc by Marc Jacobs', vendor: vendors.first},
													#{name:'Gucci', vendor: vendors.first},
													#{name:'Jimmy Choo', vendor: vendors.first},
													#{name:'Juicy Couture', vendor: vendors.first},
													#{name:'Boss Hugo Boss', vendor: vendors.first},
													#{name:'Yves Saint Laurent', vendor: vendors.first},
													{name:'Tommy Hilfiger', vendor: vendors.first} ])
