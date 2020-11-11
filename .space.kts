/**
* JetBrains Space Automation
* This Kotlin-script file lets you automate build activities
* For more info, refer to https://www.jetbrains.com/help/space/automation.html
*/

job("Build and deploy web") {
    container("cirrusci/flutter") {
        env["IP"] = Params("web_ip")
        env["DIR"] = Params("web_dir")
        env["STARTKEY"] = Secrets("web_key_1")
        env["ENDKEY"] = Secrets("web_key_2")
        env["newString"] = ""
        shellScript {
            content = """
            	flutter config --enable-web
                flutter upgrade
                flutter pub get
                flutter build web
                touch key.pem
                sed '${"$"}STARTKEY ${"$"}ENDKEY /\n/g;w key.pem'
                sed -i '1s/^/-----BEGIN OPENSSH PRIVATE KEY-----\n/' key.pem
                echo "\n-----END OPENSSH PRIVATE KEY-----" >> key.pem
                chmod 600 key.pem
                scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i key.pem -r build/web/* root@${"$"}IP:${"$"}DIR
            """
        }
    }
}
