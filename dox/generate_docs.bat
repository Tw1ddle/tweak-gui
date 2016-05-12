haxe build.hxml
haxelib run dox -i types.xml --title "tweak-gui API" -D version 1.0.0 --include "(tweak)" --exclude "(backend)" -o generated_docs