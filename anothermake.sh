xcodebuild clean build CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -project IcyInstaller3.xcodeproj
ldid -S ./build/Release-iphoneos/IcyInstaller3.app/IcyInstaller3
sshpass -palpine scp -r build/Release-iphoneos/IcyInstaller3.app root@192.168.0.18:/Applications
sshpass -palpine ssh -o StrictHostKeyChecking=no mobile@192.168.0.18 'uicache && killall IcyInstaller3; sleep 1 &&  open com.artikus.IcyInstaller3'
