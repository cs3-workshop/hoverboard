all: build serve

build:
	docker build -t hoverboard .

serve:
	docker run --name hb -v "$PWD":/app -p 3000:3000 -p 3001:3001 hoverboard

# common firebase deployment variables
api								= "AIzaSyBFP4gcAFuKc-Fjb11r2-8tXl_u4xLlOqM"
userSessionsPath	= "\/userSessions"
ratingsPath				= "\/ratings"
indexedDbSession	= "hoverboard"

configure-dev: name				= "cs3-krakow-2018-dev"
configure-dev: domain			= "cs3-krakow-2018-dev.firebaseapp.com"
configure-dev: database		= "https:\/\/cs3-krakow-2018-dev.firebaseio.com"

configure-dev: configure-deployment-dev
deploy-dev: configure-dev deploy

configure-prod: name				= "cs3-krakow-2018"
configure-prod: domain			= "cs3-krakow-2018.firebaseapp.com"
configure-prod: database		= "https:\/\/cs3-krakow-2018.firebaseio.com"

configure-prod: configure-deployment-prod
deploy-dev: configure-prod deploy


# plumbing for variable checking
check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
        $(error Undefined $1$(if $2, ($2))$(if $(value @), \
                required by target `$@')))

# config file customization
configure-deployment-%:
	@:$(call check_defined, name, firebase config)
	@:$(call check_defined, domain, firebase config)
	@:$(call check_defined, database, firebase config)
	sed -r \
	-e '/"firebase"/,/}/{' \
	-e 's/("name":).*/\1 $(name)/' \
	-e 's/("domain":).*/\1 $(domain)/' \
	-e 's/("database":).*/\1 $(database)/' \
	-e 's/("api":).*/\1 $(api)/' \
	-e 's/("userSessionsPath":).*/\1 $(userSessionsPath)/' \
	-e 's/("ratingsPath":).*/\1 $(ratingsPath)/' \
	-e 's/("indexedDbSession":).*/\1 $(indexedDbSession)/' \
	-e '}' data/hoverboard.config.json

deploy: configure-deployment`
	@:$(call check_defined, name, firebase config)
	ifndef name
	$(error name is not set)
	endif
	firebase deploy --project $(name)

