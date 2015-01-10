
coffee = ./node_modules/coffee-script/bin/coffee

build:
		$(coffee) -co lib src
watch:
		$(coffee) -cwo lib src
