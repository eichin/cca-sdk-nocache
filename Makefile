IMAGE=$$USER/chrome_apps_nocache
PROJECT=sample

basedeb:
	time sudo /usr/share/docker.io/contrib/mkimage.sh -t cca_sdk/basedeb debootstrap --variant=minbase testing

image: chrome_apps.df
	docker build -t $(IMAGE) - < chrome_apps.df

check:
	docker run -i $(IMAGE) cca checkenv

$(PROJECT):
	mkdir -p code
	docker run -i -v $$(pwd)/code:/code -w /code $(IMAGE) cca create $(PROJECT)
	docker run -i -v $$(pwd)/code:/code -w /code/$(PROJECT) $(IMAGE) cca build
	ls -l code/$(PROJECT)/platforms/android/build/outputs/apk/

rebuild:
	docker run -i -v $$(pwd)/code:/code -w /code/$(PROJECT) $(IMAGE) cca build
	ls -l code/$(PROJECT)/platforms/android/build/outputs/apk/

shell:
	docker run -i -v $$(pwd)/code:/code -w /code/$(PROJECT) $(IMAGE) bash -i
