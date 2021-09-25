createImage:
	docker build -t yt-looper .

runImage:
	docker run -d -p 8083:8080 --name yt-looper yt-looper

.PHONY: createImage runImage