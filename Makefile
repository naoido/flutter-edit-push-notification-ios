init:
	dart pub global activate flutterfire_cli
	cd ios && pod install && cd ..
	export PATH="$${PATH}:$${HOME}/.pub-cache/bin" && flutterfire configure
