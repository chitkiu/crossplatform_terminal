/**
* JetBrains Space Automation
* This Kotlin-script file lets you automate build activities
* For more info, refer to https://www.jetbrains.com/help/space/automation.html
*/

job("Build and deploy web") {
    container("cirrusci/flutter") {
        env["BUILD_IP"] = Params("web_build_ip")
        env["BUILD_USERNAME"] = Params("web_build_username")
        env["BUILD_PASSWORD"] = Secrets("web_build_password")
        env["IP"] = Params("web_ip")
        env["DIR"] = Params("web_dir")
        env["STARTKEY"] = Secrets("web_key_1")
        env["ENDKEY"] = Secrets("web_key_2")
        env["newString"] = ""
        shellScript {
            content = """
                flutter channel beta
            	flutter config --enable-web
                flutter upgrade
                flutter pub get
                flutter build web --release --dart-define=FLUTTER_WEB_USE_EXPERIMENTAL_CANVAS_TEXT=true
                flutter build apk --release
                touch key.pem
                echo ${"$"}STARTKEY ${"$"}ENDKEY | sed 's/ /\n/g;w key.pem'  > /dev/null 2>&1
                sed -i '1s/^/-----BEGIN OPENSSH PRIVATE KEY-----\n/' key.pem
                echo "\n-----END OPENSSH PRIVATE KEY-----" >> key.pem
                chmod 600 key.pem
                lftp -n -i ${"$"}BUILD_IP <<EOF
                user ${"$"}BUILD_USERNAME ${"$"}BUILD_PASSWORD
                cd /files
                put build/app/outputs/flutter-apk/app-release.apk app-release.apk
                quit
                EOF
                scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i key.pem -r build/web/* root@${"$"}IP:${"$"}DIR
            """
        }
    }
}
