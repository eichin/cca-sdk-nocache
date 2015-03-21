IMAGE=$$USER/chrome_apps_nocache

image: chrome_apps.df
	docker build -t $(IMAGE) - < chrome_apps.df

check:
	docker run -i $(IMAGE) cca checkenv

sample:
	mkdir -p code
	docker run -i -v $$(pwd)/code:/code -w /code $(IMAGE) cca create sample
	docker run -i -v $$(pwd)/code:/code -w /code/sample $(IMAGE) cca build
	ls -l code/sample/platforms/android/build/outputs/apk/

rebuild-sample:
	docker run -i -v $$(pwd)/code:/code -w /code/sample $(IMAGE) cca build
	ls -l code/sample/platforms/android/build/outputs/apk/

shell:
	docker run -i -v $$(pwd)/code:/code -w /code/sample $(IMAGE) bash -i
