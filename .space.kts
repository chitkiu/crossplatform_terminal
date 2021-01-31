/**
* JetBrains Space Automation
* This Kotlin-script file lets you automate build activities
* For more info, refer to https://www.jetbrains.com/help/space/automation.html
*/

job("Build and deploy compiled app") {
    container("cirrusci/flutter") {
        shellScript {
            content = """
                flutter channel beta
            	flutter config --enable-web
                flutter upgrade
                flutter pub get
                flutter build web --release --dart-define=FLUTTER_WEB_USE_EXPERIMENTAL_CANVAS_TEXT=true
                #flutter build apk --release
                #cp build/app/outputs/flutter-apk/app-release.apk $mountDir/share/app-release.apk 
                cp -R build/web $mountDir/share/web    
            """
        }
    }

    /*container("dockito/ftp-client") {
        env["BUILD_IP"] = Params("web_build_ip")
        env["BUILD_USERNAME"] = Params("web_build_username")
        env["BUILD_PASSWORD"] = Secrets("web_build_password")
        shellScript {
            content = """
                ftp -n -i ${"$"}BUILD_IP <<EOF
                user ${"$"}BUILD_USERNAME ${"$"}BUILD_PASSWORD
                cd /files
                put $mountDir/share/app-release.apk app-release.apk
                quit
                EOF
                """
        }
    }*/

    container("occitech/ssh-client") {
        env["IP"] = Params("web_ip")
        env["DIR"] = Params("web_dir")
        env["STARTKEY"] = Secrets("web_key_1")
        env["ENDKEY"] = Secrets("web_key_2")

        shellScript {
            content = """
                touch key.pem
                echo ${"$"}STARTKEY ${"$"}ENDKEY | sed 's/ /\n/g;w key.pem'
                 #> /dev/null 2>&1
                sed -i '1s/^/-----BEGIN OPENSSH PRIVATE KEY-----\n/' key.pem
                echo "\n-----END OPENSSH PRIVATE KEY-----" >> key.pem
                chmod 600 key.pem
                scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i key.pem -r $mountDir/share/web/* root@${"$"}IP:${"$"}DIR
            """
        }
    }
}
