createImage:
	docker build -t yt-looper .

runImage:
	docker run --name yt-looper -p 8081:8080

.PHONY: createImage runImage