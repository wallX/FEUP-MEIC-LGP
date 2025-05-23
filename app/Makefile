ipa:
	flutter build ios --release && \
	cd build/ios/iphoneos && \
	mkdir -p Payload && \
	cp -r Runner.app Payload/ && \
	zip -r Runner.ipa Payload && \
	rm -rf Payload && \
	cp Runner.ipa ../../../app.ipa