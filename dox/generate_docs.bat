rem This batch file generates the documentation for tweak-gui.

rem Clean the generated documentation folder, to remove any old documentation.
rd /s /q "generated_docs"

rem Build the XML-format type information.
haxe build.hxml

rem Generate the documentation.
haxelib run dox -i types.xml --title "tweak-gui API" -D version 1.0.0 --include "(tweak)" --exclude "(backend)" -o generated_docs