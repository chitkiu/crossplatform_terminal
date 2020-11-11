/**
* JetBrains Space Automation
* This Kotlin-script file lets you automate build activities
* For more info, refer to https://www.jetbrains.com/help/space/automation.html
*/

job("Build and deploy web") {
    container("cirrusci/flutter") {
        env["IP"] = Params("web_ip")
        env["DIR"] = Params("web_dir")
        env["KEY1"] = Secrets("web_key_1")
        env["KEY2"] = Secrets("web_key_2")
        shellScript {
            content = """
            	flutter config --enable-web
                flutter upgrade
                flutter pub get
                flutter build web
                touch key.pem
                echo ${"$"}KEY1 >> key.pem
                echo ${"$"}KEY2 >> key.pem
                cat key.pem
                chmod 600 key.pem
                scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i key.pem build/web root@${"$"}IP:${"$"}DIR
            """
        }
    }
}
