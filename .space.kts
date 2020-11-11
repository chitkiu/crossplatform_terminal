/**
* JetBrains Space Automation
* This Kotlin-script file lets you automate build activities
* For more info, refer to https://www.jetbrains.com/help/space/automation.html
*/

job("Build and deploy web") {
    container("cirrusci/flutter") {
        shellScript {
            content = """
            	flutter config --enable-web
                flutter upgrade
                flutter pub get
                flutter build web
                pwd
                ls -la 
            """
        }
    }
    
    container("ubuntu") {
        shellScript {
            content = """
                ls -la build/web
                rsync
            """
        }
    }
}
