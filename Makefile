IMAGE=$$USER/chrome_apps_nocache
PROJECT=sample
LPORT=8001

basedeb:
	time sudo /usr/share/docker.io/contrib/mkimage.sh -t cca_sdk/basedeb debootstrap --variant=minbase testing

image: chrome_apps.df
	docker build -t $(IMAGE) - < chrome_apps.df | tee licenses.out

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

testwww:
	@echo Open http://127.0.0.1:$(LPORT)/ in your browser.
	docker run -i -v $$(pwd)/code:/code -w /code/$(PROJECT)/www -p 127.0.0.1:$(LPORT):8000 $(IMAGE) python3 -m http.server

savekey:
	docker run -i -v $$(pwd)/code:/code $(IMAGE) cp /root/.android/debug.keystore /code

restorekey:
	docker run -i -v $$(pwd)/code:/code $(IMAGE) cp /code/debug.keystore /root/.android/
