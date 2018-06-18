xcodebuild clean build CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -project IcyInstaller3.xcodeproj
<<<<<<< HEAD
ldid -S ./build/Release-iphoneos/IcyInstaller3.app/IcyInstaller3
=======
>>>>>>> 38eb216926d0ec48e117007657d788c8a51c9063
scp -r build/Release-iphoneos/IcyInstaller3.app root@192.168.1.115:/Applications
ssh mobile@192.168.1.115 'uicache && killall IcyInstaller3; sleep 1 &&  open com.artikus.IcyInstaller3'
